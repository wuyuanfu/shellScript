#!/bin/bash
awk 'BEGIN {OFS=FS=","} NR==FNR {a[$1]=$24} NR>FNR{$24=a[$1];print}' $1 $2 >tmpMargin.csv
awk 'BEGIN {OFS=FS=","} NR==FNR {a[$1]=$25} NR>FNR{$25=a[$1];print}' $1 tmpMargin.csv >t_Instrument.csv

