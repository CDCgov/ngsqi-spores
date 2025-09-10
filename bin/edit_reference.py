#!/usr/bin/env python3
import argparse
from Bio import SeqIO

def edit_sequence(ref_file, chrom, pos, var_seq, output_fa):
    records = []
    for record in SeqIO.parse(ref_file, "fasta"):
        if record.id == chrom:
            record.seq = record.seq[:pos] + var_seq + record.seq[pos+len(var_seq):]
        records.append(record)
    SeqIO.write(records, output_fa, "fasta")

def main():
    parser = argparse.ArgumentParser(description='Edit a sequence in a FASTA file at a specific position.')
    parser.add_argument('-i', '--ref_file', required=True, help='Input FASTA file')
    parser.add_argument('-c', '--chrom', required=True, help='chromosomeosome/sequence ID to edit')
    parser.add_argument('-p', '--pos', required=True, type=int, help='position to edit (0-based)')
    parser.add_argument('-s', '--var_seq', required=True, help='New sequence to insert')
    parser.add_argument('-o', '--output_fa', required=True, help='Output FASTA file')

    args = parser.parse_args()

    edit_sequence(args.ref_file, args.chrom, args.pos, args.var_seq, args.output_fa)
    print(f"Sequence edited successfully. Output written to {args.output_fa}")

if __name__ == '__main__':
    main()
