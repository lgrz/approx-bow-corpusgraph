#!/usr/bin/env bash

set -e

# title+url
./tools/fields map
./tools/fields title_url > data/fields_title+url.txt
rm data/{fields_firstsent,fields_pid_did_map}.tsv

# tfidf
./tools/tfidf index
./tools/tfidf score
sort -k1n data/tfidf_dump.txt > data/tfidf_dump.sort.txt
./tools/tfidf topten > data/tfidf_top10.txt
awk '{print $1, $2, $3, $4, $5}' data/tfidf_top10.txt > data/tfidf_top05.txt
rm data/tfidf_dump_*.pkl data/tfidf_dump.txt

# dt5q
curl https://git.uwaterloo.ca/jimmylin/doc2query-data/raw/master/T5-passage/predicted_queries_topk_sampling.zip -o data/predicted_queries_topk_sampling.zip
unzip -d data/predicted_queries_topk_sampling predicted_queries_topk_sampling.zip
./tools/dt5q
rm -rf data/predicted_queries_topk_sampling*
