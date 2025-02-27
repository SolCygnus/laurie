#!/usr/bin/env python3
# Author: SillyPenguin

import os
import cv2
import argparse
import numpy as np
from pyzbar.pyzbar import decode

def decode_qr(image_path):
    """Decodes a QR code from an image and saves the result to a text file inside the user's Documents folder."""
    try:
        # Expand tilde (~) to full path
        image_path = os.path.expanduser(image_path)

        # Load the image
        image = cv2.imread(image_path)

        # Check if the image was loaded successfully
        if image is None:
            print(f"Error: Could not read the image file '{image_path}'. Check the file path and permissions.")
            return
        
        # Convert the image to grayscale for better processing
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Decode the QR codes in the image
        qr_codes = decode(gray)
        
        if not qr_codes:
            print("No QR code found in the image.")
            return
        
        # Extract decoded data
        qr_data = [qr.data.decode('utf-8') for qr in qr_codes]
        
        # Define the output directory inside the user's Documents folder
        documents_dir = os.path.expanduser("~/Documents")
        if not os.path.exists(documents_dir):
            os.makedirs(documents_dir)
        
        # Generate output filename
        base_filename = os.path.splitext(os.path.basename(image_path))[0]
        output_file = os.path.join(documents_dir, f"{base_filename}_decode.txt")
        
        # Save to a text file
        with open(output_file, "w") as file:
            for data in qr_data:
                file.write(data + "\n")
        
        print(f"Decoded QR data saved to {output_file}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Decode a QR code from an image and save the result to a text file inside the user's Documents folder.",
        epilog="Example usage: qr_decode.py /path/to/qrcode.png"
    )
    parser.add_argument("image_path", help="Path to the QR code image file")
    args = parser.parse_args()
    decode_qr(args.image_path)


