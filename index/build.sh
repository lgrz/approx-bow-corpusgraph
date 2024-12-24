#!/usr/bin/env bash

set -ex

ABSP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOTD=$(realpath "$ABSP/..")

# path to pisa tools
PISABIN=$ROOTD/deps/pisa/build/bin

# original index
IDXD=$ROOTD/index/msmarco-passage.pisa
pushd $IDXD
ciff2pisa --ciff-file $ROOTD/data/msmarco-passage.pisa.bp.ciff --output marcopassage
popd
$PISABIN/compress_inverted_index \
    --collection $IDXD/marcopassage \
    --encoding block_simdbp \
    --output $IDXD/marcopassage.block_simdbp
$PISABIN/create_wand_data \
    --collection $IDXD/marcopassage \
    --block-size 40 \
    --scorer bm25 \
    --bm25-k1 0.82 \
    --bm25-b 0.68 \
    --output $IDXD/bm25_k1-0.82_b-0.68_fixed-40
$PISABIN/lexicon build $IDXD/marcopassage.terms $IDXD/marcopassage.termlex
$PISABIN/lexicon build $IDXD/marcopassage.documents $IDXD/marcopassage.doclex
echo '{"type": "sparse_index", "format": "pisa", "package_hint": "pyterrier-pisa", "stemmer": "porter2"}' > $IDXD/pt_meta.json
pushd $IDXD
ln -fs bm25_k1-0.82_b-0.68_fixed-40 bm25.k1-0.82.b-0.68.q0.bmw.64
ln -fs marcopassage.block_simdbp bm25.k1-0.82.b-0.68.q0.bmw.64.block_simdbp
ln -fs marcopassage.doclex fwd.doclex
ln -fs marcopassage.documents fwd.documents
ln -fs marcopassage.termlex fwd.termlex
ln -fs marcopassage.terms fwd.terms
ln -fs marcopassage.docs inv.docs
ln -fs marcopassage.freqs inv.freqs
ln -fs marcopassage.sizes inv.sizes
popd

# dt5q index
IDXD=$ROOTD/index/msmarco-passage.dt5q.pisa
pushd $IDXD
ciff2pisa --ciff-file $ROOTD/data/msmarco-passage.dt5q.pisa.bp.ciff --output marcopassage
popd
$PISABIN/compress_inverted_index \
    --collection $IDXD/marcopassage \
    --encoding block_simdbp \
    --output $IDXD/marcopassage.block_simdbp
$PISABIN/create_wand_data \
    --collection $IDXD/marcopassage \
    --block-size 40 \
    --scorer bm25 \
    --bm25-k1 0.82 \
    --bm25-b 0.68 \
    --output $IDXD/bm25_k1-0.82_b-0.68_fixed-40
$PISABIN/lexicon build $IDXD/marcopassage.terms $IDXD/marcopassage.termlex
$PISABIN/lexicon build $IDXD/marcopassage.documents $IDXD/marcopassage.doclex
echo '{"type": "sparse_index", "format": "pisa", "package_hint": "pyterrier-pisa", "stemmer": "porter2"}' > $IDXD/pt_meta.json
pushd $IDXD
ln -fs bm25_k1-0.82_b-0.68_fixed-40 bm25.k1-0.82.b-0.68.q0.bmw.64
ln -fs marcopassage.block_simdbp bm25.k1-0.82.b-0.68.q0.bmw.64.block_simdbp
ln -fs marcopassage.doclex fwd.doclex
ln -fs marcopassage.documents fwd.documents
ln -fs marcopassage.termlex fwd.termlex
ln -fs marcopassage.terms fwd.terms
ln -fs marcopassage.docs inv.docs
ln -fs marcopassage.freqs inv.freqs
ln -fs marcopassage.sizes inv.sizes
popd
