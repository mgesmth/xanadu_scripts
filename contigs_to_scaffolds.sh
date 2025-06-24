#!/bin/bash

awk '
{
    contig = $1

    if (contig ~ /^scaffold[0-9]+_[0-9]+$/) {
        match(contig, /^scaffold([0-9]+)_/, m)
        new_scaffold = "scaffold_" m[1]
        gsub(contig, new_scaffold)
    }

    print
}
' $1 > $2
