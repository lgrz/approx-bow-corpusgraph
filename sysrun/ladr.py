import pandas as pd
import itertools
import numpy as np
import pyterrier as pt
import ir_datasets

logger = ir_datasets.log.easy()

class LadrProactive(pt.Transformer):
    """Non truncated version.
    """
    def __init__(self, flex_index, graph, dense_scorer, hops=1):
        self.flex_index = flex_index
        self.graph = graph
        self.dense_scorer = dense_scorer
        self.hops = hops

    def transform(self, inp):
        assert 'query_vec' in inp.columns and 'qid' in inp.columns
        assert 'docno' in inp.columns
        docnos, config = self.flex_index.payload(return_dvecs=False)

        res = {'qid': [], 'docid': [], 'score': []}
        it = iter(inp.groupby('qid'))
        if self.flex_index.verbose:
            it = logger.pbar(it)
        for qid, df in it:
            docids = docnos.inv[df['docno'].values]
            lx_docids = docids
            ext_docids = [docids]
            for _ in range(self.hops):
                docids = self.graph.edges_data[docids].reshape(-1)
                ext_docids.append(docids)
            ext_docids = np.unique(np.concatenate(ext_docids))
            query_vecs = df['query_vec'].iloc[0].reshape(1, -1)
            scores = self.dense_scorer.score(query_vecs, ext_docids)
            scores = scores.reshape(-1)
            idxs = np.arange(scores.shape[0])
            docids, scores = ext_docids[idxs], scores[idxs]
            res['qid'].extend(itertools.repeat(qid, len(docids)))
            res['docid'].append(docids)
            res['score'].append(scores)
        res['docid'] = np.concatenate(res['docid'])
        res['score'] = np.concatenate(res['score'])
        res['docno'] = docnos.fwd[res['docid']]
        res = pd.DataFrame(res)
        res = pt.model.add_ranks(res)
        return res
