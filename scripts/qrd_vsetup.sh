#!/bin/bash

# Check if virtualenv is installed, install if necessary
if ! command -v virtualenv &> /dev/null; then
    echo "virtualenv not found. Installing..."
    pip install --user virtualenv
    echo "virtualenv installed."
fi

# Define the utilities directory in the user's Documents folder
UTILITIES_DIR="$HOME/Documents/utilities"

# Check if the utilities directory exists, create if necessary
if [ ! -d "$UTILITIES_DIR" ]; then
    echo "Creating utilities directory in Documents..."
    mkdir -p "$UTILITIES_DIR"
    echo "Utilities directory created at $UTILITIES_DIR."
fi

# Define virtual environment directory
VENV_DIR="$UTILITIES_DIR/qrd_venv"

# Check if the virtual environment already exists
if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment '$VENV_DIR' already exists. Skipping creation."
else
    echo "Creating virtual environment in utilities directory..."
    virtualenv -p python3 $VENV_DIR
    echo "Virtual environment created."
fi

# Activate virtual environment
echo "Activating virtual environment..."
source $VENV_DIR/bin/activate

# Install dependencies
echo "Installing required dependencies..."
pip install --upgrade pip
pip install opencv-python pyzbar numpy 

deactivate
echo "Setup complete! Virtual environment created in $VENV_DIR."
echo "Use 'source $VENV_DIR/bin/activate' to activate the environment."