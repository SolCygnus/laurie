#!/bin/bash

# Function to check if CUDA is installed
check_cuda() {
    if command -v nvidia-smi &> /dev/null; then
        echo "CUDA is installed. Checking compatibility..."
        nvidia-smi | grep -i cuda &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Compatible NVIDIA CUDA installation detected."
            return 0
        else
            echo "CUDA installed, but compatibility issues found."
            return 1
        fi
    else
        echo "CUDA is not installed."
        return 1
    fi
}

# Function to install prerequisites
install_prerequisites() {
    echo "Updating package list and installing prerequisites..."
    sudo apt update && sudo apt install -y git python3 python3-pip ffmpeg build-essential
    if [ $? -ne 0 ]; then
        echo "Failed to install prerequisites. Exiting."
        exit 1
    fi
    echo "Prerequisites installed successfully."
}

# Function to install Whisper
install_whisper() {
    echo "Installing Whisper..."
    pip install --upgrade pip setuptools wheel
    pip install openai-whisper
    if [ $? -ne 0 ]; then
        echo "Failed to install Whisper. Exiting."
        exit 1
    fi
    echo "Whisper installed successfully."
}

# Function to install NVIDIA PyTorch if CUDA is detected
install_nvidia_pytorch() {
    echo "Installing PyTorch with CUDA support..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    if [ $? -ne 0 ]; then
        echo "Failed to install PyTorch with CUDA support. Exiting."
        exit 1
    fi
    echo "PyTorch with CUDA support installed successfully."
}

# Function to install CPU-only PyTorch if CUDA is not detected
install_cpu_pytorch() {
    echo "Installing PyTorch for CPU-only systems..."
    pip install torch torchvision torchaudio
    if [ $? -ne 0 ]; then
        echo "Failed to install CPU-only PyTorch. Exiting."
        exit 1
    fi
    echo "PyTorch for CPU-only systems installed successfully."
}

# Main script logic
install_prerequisites
check_cuda
if [ $? -eq 0 ]; then
    install_nvidia_pytorch
else
    install_cpu_pytorch
fi
install_whisper

echo "Setup complete. Whisper is now installed."
