#!/bin/bash

awk '/^S/{print ">"$2"\n"$3}' intDF010.asm.bp.p_ctg.gfa | fold > intDF010.asm.bp.p_ctg.fasta
#in GFA files, the "segment" (i.e. actual sequence, or contig) starts with S. So finding all lines starting with
#S, print >, col $2 (which is the contig name) and then on the next line, $3 (the sequence)
#fold line wraps the file
