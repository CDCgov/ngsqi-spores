import argparse
from Bio import SeqIO

#chr pos should be entered as a 0 format position

def edit_sequence(input_fa, chrom, pos, new_seq, output_fa):
    records = []
    for record in SeqIO.parse(input_fa, "fasta"):
        if record.id == chrom:
            record.seq = record.seq[:pos] + new_seq + record.seq[pos+len(new_seq):]
        records.append(record)
    SeqIO.write(records, output_fa, "fasta")

def main():
    parser = argparse.ArgumentParser(description='Edit a sequence in a FASTA file at a specific position.')
    parser.add_argument('-i', '--input_fa', required=True, help='Input FASTA file')
    parser.add_argument('-c', '--chrom', required=True, help='Chromosome/sequence ID to edit')
    parser.add_argument('-p', '--pos', required=True, type=int, help='Position to edit (0-based)')
    parser.add_argument('-s', '--new_seq', required=True, help='New sequence to insert')
    parser.add_argument('-o', '--output_fa', required=True, help='Output FASTA file')
    
    args = parser.parse_args()
    
    edit_sequence(args.input_fa, args.chrom, args.pos, args.new_seq, args.output_fa)
    print(f"Sequence edited successfully. Output written to {args.output_fa}")

if __name__ == '__main__':
    main()