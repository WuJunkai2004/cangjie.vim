import sys
import tempfile
import subprocess
import os

"""
A wrapper script that reads from stdin, 
use cjfmt to format the code,
and prints the result to stdout.
"""

def main():
    source_code = sys.stdin.read()

    temp_file_path = ""
    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.cj', delete=False) as tf:
            temp_file_path = tf.name
            tf.write(source_code)

        subprocess.run(['cjfmt', "-f", temp_file_path],
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL,
                        check=True)

        with open(temp_file_path, 'r') as tf:
            formatted_code = tf.read()

        print(formatted_code, end='')
    except subprocess.CalledProcessError as e:
        print(f"Error during formatting: {e}", file=sys.stderr)
        print(source_code, end='')
        sys.exit(1)
    finally:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

if __name__ == "__main__":
    main()