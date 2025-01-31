#!/usr/bin/python3

import hashlib
import argparse
import sys

def calculate_hash(file_path, hash_algorithm='sha256'):
    """
    Calculates the hash of a file using the specified hash algorithm.
    """
    try:
        # Select the hashing algorithm
        hash_func = getattr(hashlib, hash_algorithm)()
        
        # Read and update the hash function in chunks
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                hash_func.update(chunk)
        
        # Return the computed hash
        return hash_func.hexdigest()
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)
    except AttributeError:
        print(f"Error: Unsupported hash algorithm '{hash_algorithm}'.")
        sys.exit(1)

def main():
    """
    Main function to check the hash of a file.
    """
    # Create an argument parser
    parser = argparse.ArgumentParser(
        description="Verify the hash of a file against a known hash.",
        epilog="Example: python verify_hash.py sample.txt --hash 5d41402abc4b2a76b9719d911017c592 --algorithm sha256"
    )
    
    # Add arguments
    parser.add_argument(
        'file_path',
        metavar='file_path',
        type=str,
        help="Path to the file to verify."
    )
    parser.add_argument(
        '--hash',
        metavar='known_hash',
        type=str,
        required=True,
        help="The known hash to verify against."
    )
    parser.add_argument(
        '--algorithm',
        metavar='hash_algorithm',
        type=str,
        default='sha256',
        choices=hashlib.algorithms_available,
        help="The hash algorithm to use (default: sha256)."
    )
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Calculate the hash of the file
    calculated_hash = calculate_hash(args.file_path, args.algorithm)
    
    # Compare the calculated hash with the known hash
    if calculated_hash == args.hash:
        print(f"[PASS] The file '{args.file_path}' matches the known hash.")
    else:
        print(f"[FAIL] The file '{args.file_path}' does NOT match the known hash.")
        print(f"Calculated: {calculated_hash}")
        print(f"Expected:   {args.hash}")

if __name__ == '__main__':
    main()
