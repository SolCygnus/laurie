#!/usr/bin/env python3
# Author: SillyPenguin

import cv2
import numpy as np
from pyzbar.pyzbar import decode

def decode_qr(image_path, output_file="qr_output.txt"):
    """Decodes a QR code from an image and saves the result to a text file."""
    try:
        # Load the image
        image = cv2.imread(image_path)
        
        # Convert the image to grayscale for better processing
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Decode the QR codes in the image
        qr_codes = decode(gray)
        
        if not qr_codes:
            print("No QR code found in the image.")
            return
        
        # Extract decoded data
        qr_data = [qr.data.decode('utf-8') for qr in qr_codes]
        
        # Save to a text file
        with open(output_file, "w") as file:
            for data in qr_data:
                file.write(data + "\n")
        
        print(f"Decoded QR data saved to {output_file}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    image_path = input("Enter the path to the QR code image: ")
    decode_qr(image_path)
