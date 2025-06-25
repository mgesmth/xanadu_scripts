#!/bin/bash

gfa=${minidir}/all_primscaff1split.gfa
fa=$1
out=$2

minigraph -cxasm --call -t24 "$gfa" "$fa" > "$out"
