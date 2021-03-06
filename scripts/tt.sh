#!/usr/bin/env bash

if [ -z "$TFD_HOME" ]; then
  TFD_HOME=~/TFD_HOME
fi

if [ "$1" = "parameter" ]; then
	RUNS=parameter_runs
    EVALS=parameter_evals
else
	RUNS=runs
    EVALS=evals
fi

echo "starting Terabyte (TT) evaluator with RUNS = $RUNS and EVALS = $EVALS ..."

 qrels[4]=qrels.701-750.txt
 qrels[5]=qrels.751-800.txt
 qrels[6]=qrels.801-850.txt


for TT in 04 05 06; do
 printf "%s\n" ${qrels[${TT#0}]}
done


for set in GOV2; do

if [ ! -d "${TFD_HOME}/${set}/${RUNS}" ]; then
       continue
fi

for tag in ${TFD_HOME}/${set}/${RUNS}/*; do
if [[ ! -d ${tag} ]]; then
    continue
fi
tag=$(basename "${tag}")
mkdir -p "$TFD_HOME/$set/${EVALS}/$tag"
# TREC Terabyte Tracks from 2004 to 2006
for TT in 04 05 06; do

    if [ ! -d "${TFD_HOME}/${set}/${RUNS}/${tag}/TT${TT}" ]; then
        # Control will enter here if $DIRECTORY does not exist.
        echo "${TFD_HOME}/${set}/${RUNS}/${tag}/TT${TT} does not exist!"
        continue
    fi

     mkdir -p "$TFD_HOME/$set/${EVALS}/$tag/TT$TT"
     mkdir -p "$TFD_HOME/$set/${EVALS}/$tag/TT$TT/trec_eval"

    for f in ${TFD_HOME}/${set}/${RUNS}/${tag}/TT${TT}/*.txt; do
        ${TFD_HOME}/scripts/trec_eval -M1000 -q ${TFD_HOME}/topics-and-qrels/${qrels[${TT#0}]} ${f} > "${TFD_HOME}/${set}/${EVALS}/${tag}/TT${TT}/trec_eval/${f##/*/}" &
        for k in 20 100 1000; do
          mkdir -p "$TFD_HOME/$set/${EVALS}/$tag/TT$TT/$k"
          ${TFD_HOME}/scripts/gdeval.pl -k ${k} ${TFD_HOME}/topics-and-qrels/${qrels[${TT#0}]} ${f} > "${TFD_HOME}/${set}/${EVALS}/${tag}/TT${TT}/${k}/${f##/*/}" &
        done
    done
    wait

done
done
done