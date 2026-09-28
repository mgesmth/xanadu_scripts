import pandas as pd

fai_file="/core/projects/EBP/smith/final_genome/psme_glauca_primary.fasta.fai"
repeats_file="repeatMasker_merged_bestmatch_shifted.out"
fai={}
with open(fai_file) as f:
    for line in f:
        x=line.strip().split("\t")
        fai[x[0]]=int(x[1])

prop_repeat={}
i=0
for s,l in fai.items():
    with open(repeats_file) as f:
        for line in f:
            i+=1
            if i == 1:
                next
            else:
                rep_len=0
                fields=line.strip().split("\t")
                if fields[4] == s:
                    start=int(fields[5])
                    end=int(fields[6])
                    if end > start:
                        rep_len+=end-start
                    else:
                        rep_len+=start-end

        prop_repeat[s]=rep_len/l
                    

reform={
    'scaffold': prop_repeat.keys(),
    'repeat_prop': prop_repeat.values()
}
    
df=pd.DataFrame(reform)
df.to_csv("repeat_prop_per_scaffold.csv", index=False)