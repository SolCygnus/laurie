#!/bin/bash

# Define variables
BACKGROUND_FOLDER="/path/to/your/images"  # Replace with the folder containing your images
PICTURE_OPTIONS="zoom"                   # Options: none, wallpaper, centered, scaled, stretched, zoom, spanned
SLIDESHOW_DELAY=300                      # Delay in seconds (e.g., 300 seconds = 5 minutes)

# Set the folder for slideshow images
gsettings set org.cinnamon.desktop.background picture-uri "file://$BACKGROUND_FOLDER"

# Enable slideshow mode
gsettings set org.cinnamon.desktop.background slideshow true

# Set slideshow delay
gsettings set org.cinnamon.desktop.background slideshow-delay "$SLIDESHOW_DELAY"

# Set picture aspect ratio options
gsettings set org.cinnamon.desktop.background picture-options "$PICTURE_OPTIONS"

# Confirm changes
echo "Desktop background slideshow has been configured with the following settings:"
echo "Folder: $BACKGROUND_FOLDER"
echo "Slideshow Delay: $SLIDESHOW_DELAY seconds"
echo "Picture Options: $PICTURE_OPTIONS"