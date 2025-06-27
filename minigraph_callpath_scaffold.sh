#!/bin/bash

gfa=/home/FCAM/msmith/svs/minigraph_out/all_primscaff1split.gfa
fa=$1
out=$2

minigraph -cxasm --call -t24 "$gfa" "$fa" > "$out"
