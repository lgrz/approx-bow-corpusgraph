#!/usr/bin/env bash

set -ex

ABSP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOTD=$(realpath "$ABSP/..")

# path to pisa tools
PISABIN=$ROOTD/deps/pisa/build/bin
# query processing number of threads
THREADS=$(nproc)

run_queries() {
    echo "1: $1"
    echo "2: $2"
    echo "3: $3"
    echo "4: $4"
    echo "5: $5"
    local LOG="$ROOTD/graph/$1.log"
    local RUNFILE="$ROOTD/graph/$1.run"
    local QUERYFILE=$2
    local INDEX="$3.block_simdbp"
    local WANDFILE="`dirname $3`/$4"
    local LEXICON="$3.termlex"
    local DOCLEX="$3.doclex"
    local STOPWORDS="$ROOTD/index/terrier-stop.txt"
    local K=$(($5 + 1))
    local D=$5
    local CMD="$PISABIN/evaluate_queries"
    if [[ $1 == *"limitpairs"* ]]; then
        CMD="$PISABIN/evaluate_queries_bubble"
    fi
    # local EXTRA_ARGS=""
    # if [[ $1 == *"dt5q-05qry"* ]]; then
    #     # combsum
    #     EXTRA_ARGS="--weighted"
    # fi
    echo "==> graph: $1"
    echo "==> pisacmd: $CMD"
    echo "==> top-k is k+1: $K"
    echo "==> top-d is k: $D"
    >$LOG
    START=$SECONDS 
    $PISABIN/evaluate_queries \
        --threads $THREADS \
        --encoding block_simdbp \
        --index $INDEX \
        --wand $WANDFILE \
        --terms $LEXICON \
        --documents $DOCLEX \
        --algorithm block_max_maxscore \
        -k $K \
        --scorer bm25 \
        --bm25-k1 0.82 \
        --bm25-b 0.68 \
        --tokenizer english \
        --token-filters lowercase porter2 \
        --stopwords $STOPWORDS \
        --queries $QUERYFILE \
        --log-level off \
        > $RUNFILE
    END=$SECONDS 
    ELAPSED=$((END-START))
    echo "time: $ELAPSED seconds" | tee $LOG

    echo "converting $RUNFILE to corpus graph format..."
   $ROOTD/graph/runfile2graph $RUNFILE $D \
        && rm $RUNFILE
    echo "done."
}

# original index
for topk in 16 128; do
    # exhaustive
    run_queries "original-d$topk" "data/exhaustive.txt" "index/msmarco-passage.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # random 25, 75
    $ROOTD/graph/randgraph "original-d$topk"

    # tfidf top5
    run_queries "original-idf5-d$topk" "data/tfidf_top05.txt" "index/msmarco-passage.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # tfidf top10
    run_queries "original-idf10-d$topk" "data/tfidf_top10.txt" "index/msmarco-passage.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # title+url
    run_queries "original-titleurl-d$topk" "data/fields_title+url.txt" "index/msmarco-passage.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # limit pairs
    run_queries "original-limitpairs-d$topk" "data/exhaustive.txt" "index/msmarco-passage.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
done

# dt5q index
for topk in 16 128; do
    # exhaustive
    run_queries "doct5query-d$topk" "data/exhaustive.dt5q.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # random 25, 75
    $ROOTD/graph/randgraph "doct5query-d$topk"

    # tfidf top5
    run_queries "doct5query-idf5-d$topk" "data/tfidf_top05.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # tfidf top10
    run_queries "doct5query-idf10-d$topk" "data/tfidf_top10.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # title+url
    run_queries "doct5query-titleurl-d$topk" "data/fields_title+url.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # dt5q 1query
    run_queries "doct5query-q1-d$topk" "data/dt5q.01qry.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
    # dt5q 5query
    run_queries "doct5query-q5-d$topk" "data/dt5q.05qry.txt" "index/msmarco-passage.dt5q.pisa/marcopassage" "bm25_k1-0.82_b-0.68_fixed-40" $topk
done
