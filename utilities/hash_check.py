#!/usr/bin/env python3
# Author: SillyPenguin

import hashlib
import argparse
import sys

# Dictionary mapping hash algorithms to their hashlib function names
HASH_ALGORITHMS = {
    "md5": hashlib.md5,
    "sha1": hashlib.sha1,
    "sha224": hashlib.sha224,
    "sha256": hashlib.sha256,
    "sha384": hashlib.sha384,
    "sha512": hashlib.sha512,
}

def detect_hash_algorithm(known_hash):
    """
    Detects the hash algorithm based on the length of the known hash.
    """
    hash_length_map = {32: "md5", 40: "sha1", 56: "sha224", 64: "sha256", 96: "sha384", 128: "sha512"}
    return hash_length_map.get(len(known_hash), None)

def calculate_hash(file_path, hash_algorithm):
    """
    Calculates the hash of a file using the specified hash algorithm.
    """
    try:
        hash_func = HASH_ALGORITHMS[hash_algorithm]()
        
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                hash_func.update(chunk)
        
        return hash_func.hexdigest()
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)
    except KeyError:
        print(f"Error: Unsupported hash algorithm '{hash_algorithm}'.")
        sys.exit(1)

def calculate_all_hashes(file_path):
    """
    Calculates and returns all supported hash values for a file.
    """
    hashes = {}
    try:
        with open(file_path, 'rb') as f:
            file_data = f.read()  # Read file once to optimize multiple hash calculations
        
        for algorithm, hash_func in HASH_ALGORITHMS.items():
            hash_obj = hash_func()
            hash_obj.update(file_data)
            hashes[algorithm] = hash_obj.hexdigest()
    
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

    return hashes

def main():
    """
    Main function to verify a file's hash or display all hash values.
    """
    parser = argparse.ArgumentParser(
        description="Verify the hash of a file against a known hash, or list all hash values.",
        usage="python hash_check.py <file_path> [--hash <known_hash_value>]",
        epilog="Examples:\n  python hash_check.py sample.txt --hash 5d41402abc4b2a76b9719d911017c592\n  python verify_hash.py sample.txt"
    )
    
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
        help="The known hash to verify against (optional). If omitted, all hash values will be displayed."
    )

    # Show help message if no arguments are given
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    if args.hash:
        # Verify file hash against provided known hash
        detected_algorithm = detect_hash_algorithm(args.hash)
        if not detected_algorithm:
            print("❌ Error: Could not determine hash algorithm. Ensure the known hash is correct.")
            sys.exit(1)

        print(f"🔍 Detected hash algorithm: {detected_algorithm}")

        calculated_hash = calculate_hash(args.file_path, detected_algorithm)

        if calculated_hash == args.hash:
            print(f"✅ [PASS] The file '{args.file_path}' matches the known hash.")
        else:
            print(f"❌ [FAIL] The file '{args.file_path}' does NOT match the known hash.")
            print(f"   ➡ Calculated: {calculated_hash}")
            print(f"   ➡ Expected:   {args.hash}")
    else:
        # Display all hash values if no known hash is provided
        print(f"🔍 Calculating all hash values for '{args.file_path}'...\n")
        all_hashes = calculate_all_hashes(args.file_path)
        for algo, hash_value in all_hashes.items():
            print(f"   {algo.upper()}: {hash_value}")

if __name__ == '__main__':
    main()
