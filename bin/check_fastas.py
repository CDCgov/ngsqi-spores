#!/usr/bin/env python
import argparse
import csv
import logging
import sys
from pathlib import Path

logger = logging.getLogger()

class RowChecker:
    VALID_FORMATS = (".fa", ".fasta", ".fna")

    def __init__(self, fasta_col="reference", clade_col="clade", var_col="var_id", chrom_col="chrom", pos_col="pos", seq_col="var_seq"):
        self._fasta_col = fasta_col
        #self._path_col = path_col
        self._clade_col = clade_col
        self._var_col = var_col
        self._chrom_col = chrom_col
        self._pos_col = pos_col
        self._seq_col = seq_col
        self._seen = set()
        self.modified = []

    def validate_and_transform(self, row):
        try:
            #self._validate_fasta(row)
            self._validate_chrom(row)
            self._validate_pos(row)
            self._validate_seq(row)
            #self._seen.add(row[self._path_col])
            self.modified.append(row) 
        except AssertionError as error:
            logger.error(f"Validation error: {error} in row {row}")

    def _validate_chrom(self, row):
        chrom = row.get(self._chrom_col, "").strip()
        if not chrom:
            raise AssertionError("Chromosome field is required.")

    def _validate_pos(self, row):
        pos = row.get(self._pos_col, "").strip()
        if not pos.isdigit() or int(pos) <= 0:
            raise AssertionError("Position must be a positive integer.")

    def _validate_seq(self, row):
        new_seq = row.get(self._seq_col, "").strip()
        if not new_seq:
            raise AssertionError("New sequence is required.")
        if not all(nuc in "ACGT" for nuc in new_seq.upper()):
            raise AssertionError("Sequence contains invalid characters. Allowed: A, C, G, T.")

def check_fasta_samplesheet(file_in, file_out):
    required_columns = {"reference", "clade", "var_id", "chrom", "pos", "var_seq"}
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle)
        if not required_columns.issubset(reader.fieldnames):
            raise ValueError(f"Missing required columns: {required_columns - set(reader.fieldnames)}")
        checker = RowChecker()
        for row in reader:
            checker.validate_and_transform(row)
        with file_out.open(mode="w", newline="") as out_handle:
            writer = csv.DictWriter(out_handle, fieldnames=reader.fieldnames)
            writer.writeheader()
            writer.writerows(checker.modified)

def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Validate and transform a FASTA samplesheet.")
    parser.add_argument("file_in", type=Path, help="Input FASTA samplesheet in CSV format.")
    parser.add_argument("file_out", type=Path, help="Output validated FASTA samplesheet in CSV format.")
    parser.add_argument("--log-level", default="WARNING", choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"), help="Set log level")
    return parser.parse_args(argv)

def main(argv=None):
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"Input file not found: {args.file_in}")
        sys.exit(1)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_fasta_samplesheet(args.file_in, args.file_out)

if __name__ == "__main__":
    main()

