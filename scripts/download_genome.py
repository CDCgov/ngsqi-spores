from Bio import Entrez
import sys
import time
import os
import urllib.request

def download_genome(reference_id):
    Entrez.email = os.environ.get('NCBI_EMAIL', None)
    Entrez.api_key = os.environ.get('NCBI_API_KEY', None)
    
    max_attempts = 5
    for attempt in range(max_attempts):
        try:
            # First, we need to get the FTP path
            handle = Entrez.esearch(db="assembly", term=reference_id)
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

            ftp_path = summary['DocumentSummarySet']['DocumentSummary'][0]['FtpPath_GenBank']
            if not ftp_path:
                print(f"No FTP path found for reference_id: {reference_id}", file=sys.stderr)
                return None

            # Convert FTP URL to HTTPS
            if ftp_path.startswith('ftp://'):
                file_url = ftp_path.replace('ftp://', 'https://')
            else:
                file_url = ftp_path

            # Construct the full URL for the genomic FASTA file
            file_url = f"{file_url}/{os.path.basename(file_url)}_genomic.fna.gz"

            # Download the file with proper binary handling
            time.sleep(1)  # Delay to respect NCBI's rate limits
            local_filename = f"{reference_id}_genomic.fna.gz"
            
            with urllib.request.urlopen(file_url) as response:
                with open(local_filename, 'wb') as out_file:
                    while True:
                        chunk = response.read(8192)
                        if not chunk:
                            break
                        out_file.write(chunk)

            print(f"Successfully downloaded: {local_filename}", file=sys.stderr)
            return local_filename

        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {str(e)}", file=sys.stderr)
            if attempt < max_attempts - 1:
                sleep_time = min(60, 2 ** attempt + 1)  # Cap at 60 seconds
                print(f"Retrying in {sleep_time} seconds...", file=sys.stderr)
                time.sleep(sleep_time)
            else:
                raise

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python download_genome.py <reference_id>", file=sys.stderr)
        sys.exit(1)

    reference_id = sys.argv[1]
    result = download_genome(reference_id)
    
    if result:
        print(result)  # Print the filename to stdout for Nextflow to capture
    else:
        print(f"Failed to download genome for reference_id: {reference_id}", file=sys.stderr)
        sys.exit(1)
