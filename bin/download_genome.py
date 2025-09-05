#!/usr/bin/env python3
from Bio import Entrez
import sys
import time
import os
import urllib.request
import gzip
import shutil
def download_genome(reference_id, clade, var_id):
   Entrez.email = os.environ.get('NCBI_EMAIL', None)
   Entrez.api_key = os.environ.get('NCBI_API_KEY', None)
   max_attempts = 5
   for attempt in range(max_attempts):
       try:
           # First, we need to get the FTP path
           if reference_id.startswith(('GCA_', 'GCF_')):
               search_term = f'"{reference_id}"[Assembly Accession]'
           else:
               search_term = reference_id
           handle = Entrez.esearch(db="assembly", term=search_term)
           record = Entrez.read(handle)
           handle.close()
           if not record['IdList']:
               print(f"No assembly found for reference_id: {reference_id}", file=sys.stderr)
               return None
           assembly_id = record['IdList'][0]
           time.sleep(1)  # Delay to respect NCBI's rate limits
           # Now get the assembly summary
           handle = Entrez.esummary(db="assembly", id=assembly_id)
           summary = Entrez.read(handle)
           handle.close()
           doc_summary = summary['DocumentSummarySet']['DocumentSummary'][0]
           # Choose appropriate FTP path based on accession type
           if reference_id.startswith('GCF_'):
               ftp_path = doc_summary.get('FtpPath_RefSeq') or doc_summary.get('FtpPath_GenBank')
           elif reference_id.startswith('GCA_'):
               ftp_path = doc_summary.get('FtpPath_GenBank') or doc_summary.get('FtpPath_RefSeq')
           else:
               ftp_path = doc_summary.get('FtpPath_GenBank') or doc_summary.get('FtpPath_RefSeq')
           if not ftp_path:
               print(f"No FTP path found for reference_id: {reference_id}", file=sys.stderr)
               return None
           # Convert FTP URL to HTTPS
           if ftp_path.startswith('ftp://'):
               file_url = ftp_path.replace('ftp://', 'https://')
           else:
               file_url = ftp_path
           # Get the base filename
           base_name = os.path.basename(ftp_path)
           # Construct the full URL for the genomic FASTA file
           file_url = f"{file_url}/{base_name}_genomic.fna.gz"
           # Create output filename
           gz_filename = f"{reference_id}_{clade}_{var_id}_genomic.fna.gz"
           out_filename = f"{reference_id}_{clade}_{var_id}.fna"
           # Download the file with proper binary handling
           time.sleep(1)  # Delay to respect NCBI's rate limits
           with urllib.request.urlopen(file_url) as response:
               with open(gz_filename, 'wb') as out_file:
                   while True:
                       chunk = response.read(8192)
                       if not chunk:
                           break
                       out_file.write(chunk)
           # Decompress the file
           with gzip.open(gz_filename, 'rb') as f_in:
               with open(out_filename, 'wb') as f_out:
                   shutil.copyfileobj(f_in, f_out)
           # Remove the compressed file
           os.remove(gz_filename)
           print(f"Successfully downloaded and decompressed: {out_filename}", file=sys.stderr)
           return out_filename
       except Exception as e:
           print(f"Attempt {attempt + 1} failed: {str(e)}", file=sys.stderr)
           if attempt < max_attempts - 1:
               sleep_time = min(60, 2 ** attempt + 1)  # Cap at 60 seconds
               print(f"Retrying in {sleep_time} seconds...", file=sys.stderr)
               time.sleep(sleep_time)
           else:
               raise
if __name__ == "__main__":
   if len(sys.argv) != 4:
       print("Usage: python download_genome.py <reference_id> <clade> <var_id>", file=sys.stderr)
       sys.exit(1)
   reference_id = sys.argv[1]
   clade = sys.argv[2]
   var_id = sys.argv[3]
   result = download_genome(reference_id, clade, var_id)
   if result:
       print(result)  # Print the filename to stdout for Nextflow to capture
   else:
       print(f"Failed to download genome for reference_id: {reference_id}", file=sys.stderr)
       sys.exit(1)