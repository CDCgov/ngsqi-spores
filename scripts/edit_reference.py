import pandas as pd
from Bio import SeqIO
import argparse
import os

#chr pos should be entered as a 0 format position

def edit_sequence(input_fa, chrom, pos, new_seq, output_fa):
   records = []
   for record in SeqIO.parse(input_fa, "fasta"):
       if record.id == chrom:
           record.seq = record.seq[:pos] + new_seq + record.seq[pos+len(new_seq):]
       records.append(record)
   SeqIO.write(records, output_fa, "fasta")

def main():
   parser = argparse.ArgumentParser()
   parser.add_argument('csv_file', help='CSV with columns: input_fa,chrom,pos,new_seq,output_fa')
   args = parser.parse_args()
   
   edits = pd.read_csv(args.csv_file)
   for _, row in edits.iterrows():
       edit_sequence(row['input_fa'], row['chrom'], row['pos'], row['new_seq'], row['output_fa'])

if __name__ == '__main__':
   main()
