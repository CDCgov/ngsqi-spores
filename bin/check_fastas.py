#!/usr/bin/env python
import argparse
import csv
import logging
import sys
from pathlib import Path

logger = logging.getLogger()

class RowChecker:
    VALID_FORMATS = (
        ".fa",
        ".fasta",
        ".fna",
    )

    def __init__(self, fasta_col="fasta", chrom_col="chrom", pos_col="pos", seq_col="new_seq"):
        self._fasta_col = fasta_col
        self._chrom_col = chrom_col
        self._pos_col = pos_col
        self._seq_col = seq_col
        self._seen = set()
        self.modified = []

    def validate_and_transform(self, row):
        self._validate_fasta(row)
        self._validate_chrom(row)
        self._validate_pos(row)
        self._validate_new_seq(row)
        self._seen.add(row[self._fasta_col])
        self.modified.append(row)

    def _validate_fasta(self, row):
        """Assert that the FASTA file exists and has the correct format."""
        fasta_file = row[self._fasta_col]
        if len(fasta_file) <= 0:
            raise AssertionError("FASTA file path is required.")
        if not file(fasta_file).exists():
            raise AssertionError(f"FASTA file does not exist: {fasta_file}")
        if not any(fasta_file.endswith(extension) for extension in self.VALID_FORMATS):
            raise AssertionError(
                f"The FASTA file has an unrecognized extension: {fasta_file}\n"
                f"It should be one of: {', '.join(self.VALID_FORMATS)}"
            )

    def _validate_chrom(self, row):
        """Assert that the chromosome field is non-empty."""
        if len(row[self._chrom_col]) <= 0:
            raise AssertionError("Chromosome field is required.")

    def _validate_pos(self, row):
        """Assert that the position is a positive integer."""
        pos = row[self._pos_col]
        if not pos.isdigit() or int(pos) <= 0:
            raise AssertionError("Position must be a positive integer.")

    def _validate_new_seq(self, row):
        """Assert that the new sequence is non-empty and consists of valid nucleotides."""
        new_seq = row[self._seq_col]
        if len(new_seq) <= 0:
            raise AssertionError("New sequence is required.")
        if not all(nuc in "ACGT" for nuc in new_seq.upper()):
            raise AssertionError("New sequence contains invalid characters. Allowed: A, C, G, T.")

    def validate_unique_fasta(self):
        """Assert that FASTA file paths are unique."""
        if len(self._seen) != len(self.modified):
            raise AssertionError("FASTA file paths must be unique.")

def read_head(handle, num_lines=10):
    lines = []
    for idx, line in enumerate(handle):
        if idx == num_lines:
            break
        lines.append(line)
    return "".join(lines)

def sniff_format(handle):
    peek = read_head(handle)
    handle.seek(0)
    sniffer = csv.Sniffer()
    dialect = sniffer.sniff(peek)
    return dialect

def check_fasta_samplesheet(file_in, file_out):
    required_columns = {"fasta", "chrom", "pos", "new_seq"}
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle, dialect=sniff_format(in_handle))
        if not required_columns.issubset(reader.fieldnames):
            req_cols = ", ".join(required_columns)
            logger.critical(f"The sample sheet **must** contain these column headers: {req_cols}.")
            sys.exit(1)
        checker = RowChecker()
        for i, row in enumerate(reader):
            try:
                checker.validate_and_transform(row)
            except AssertionError as error:
                logger.critical(f"{str(error)} On line {i + 2}.")
                sys.exit(1)
        checker.validate_unique_fasta()
    header = list(reader.fieldnames)
    with file_out.open(mode="w", newline="") as out_handle:
        writer = csv.DictWriter(out_handle, header, delimiter=",")
        writer.writeheader()
        for row in checker.modified:
            writer.writerow(row)

def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Validate and transform a FASTA samplesheet.",
        epilog="Example: python check_fasta_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument("file_in", metavar="FILE_IN", type=Path, help="Input FASTA samplesheet in CSV or TSV format.")
    parser.add_argument("file_out", metavar="FILE_OUT", type=Path, help="Transformed output samplesheet in CSV format.")
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)

def main(argv=None):
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"The given input file {args.file_in} was not found!")
        sys.exit(2)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_fasta_samplesheet(args.file_in, args.file_out)

if __name__ == "__main__":
    sys.exit(main())
