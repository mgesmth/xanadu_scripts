#!/usr/bin/env python3

def fix_gtf_attributes(input_path, output_path):
  with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
    for line in infile:
      if line.startswith('#') or line.strip() == '':
        outfile.write(line)
        continue

      fields = line.strip().split('\t')
      if len(fields) != 9:
        raise ValueError(
          f"Line {line_number}: Invalid GTF line (expected 9 fields, got {len(fields)}):\n{line}"
          )

      raw_attr = fields[8].strip()
      if not raw_attr.startswith("gene_id"):
        fixed_attr = f'gene_id "{raw_attr}";'
        fields[8] = fixed_attr

      outfile.write('\t'.join(fields) + '\n')

fix_gtf_attributes("Psme.1_0.gtf","Psme.1_0_geneid.gtf")
