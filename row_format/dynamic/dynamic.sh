#!/bin/bash
# encoding: UTF-8

./insert.lua \
  --mysql-password=sbtest \
  prepare

./insert.lua \
  --mysql-password=sbtest \
  --threads=1 \
  --report-interval=1 \
  --max-time=300 \
  run > insert.log

./select.lua \
  --mysql-password=sbtest \
  --threads=1 \
  --report-interval=1 \
  --max-time=300 \
  --thread-init-timeout=120 \
  run > select.log

./insert.lua \
  --mysql-password=sbtest \
  cleanup

cat insert.log | egrep '\d+\;\d+' > insert.csv
cat select.log | egrep '\d+\;\d+' > select.csv

./dynamic.pg

open -a "Gapplin" dynamic.svg

rm insert{.log,.csv}
rm select{.log,.csv}
