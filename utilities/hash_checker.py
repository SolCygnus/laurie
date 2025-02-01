#!/usr/bin/env python3

import hashlib
import argparse
import sys

# Dictionary mapping hash lengths to their algorithms
HASH_ALGORITHMS = {
    32: "md5",
    40: "sha1",
    56: "sha224",
    64: "sha256",
    96: "sha384",
    128: "sha512",
}

def detect_hash_algorithm(known_hash):
    """
    Detects the hash algorithm based on the length of the known hash.
    """
    return HASH_ALGORITHMS.get(len(known_hash), None)

def calculate_hash(file_path, hash_algorithm):
    """
    Calculates the hash of a file using the specified hash algorithm.
    """
    try:
        hash_func = getattr(hashlib, hash_algorithm)()
        
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                hash_func.update(chunk)
        
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
    parser = argparse.ArgumentParser(
        description="Verify the hash of a file against a known hash.",
        usage="python verify_hash.py <file_path> --hash <known_hash>",
        epilog="Example:\n  python verify_hash.py sample.txt --hash 5d41402abc4b2a76b9719d911017c592"
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
        required=True,
        help="The known hash to verify against."
    )

    # Show help message if no arguments are given
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

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

if __name__ == '__main__':
    main()