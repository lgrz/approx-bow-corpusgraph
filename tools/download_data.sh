#!/usr/bin/env bash

set -e

mkdir -p data
pushd data
curl --parallel \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/dt5q.01qry.txt.xz -o dt5q.01qry.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/dt5q.05qry.txt.xz -o dt5q.05qry.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/exhaustive.dt5q.txt.xz -o exhaustive.dt5q.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/exhaustive.txt.xz -o exhaustive.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/fields_title%2burl.txt.xz -o fields_title+url.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/msmarco-passage.dt5q.pisa.bp.ciff.xz -o msmarco-passage.dt5q.pisa.bp.ciff.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/msmarco-passage.pisa.bp.ciff.xz -o msmarco-passage.pisa.bp.ciff.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/tfidf_top05.txt.xz -o tfidf_top05.txt.xz \
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/tfidf_top10.txt.xz -o tfidf_top10.txt.xz
    https://d1ywzm2ov946sx.cloudfront.net/bow-corpus-graph/shasum.txt -o shasum.txt
sha256 -c shasum.txt
popd

pushd index/msmarco-passage.tasb.flex
curl --parallel --location \
    https://huggingface.co/datasets/macavaney/msmarco-passage.tasb.index/resolve/main/docnos.npids -o docnos.npids \
    https://huggingface.co/datasets/macavaney/msmarco-passage.tasb.index/resolve/main/pt_meta.json -o pt_meta.json \
    https://huggingface.co/datasets/macavaney/msmarco-passage.tasb.index/resolve/main/vecs.f4 -o vecs.f4
popd
