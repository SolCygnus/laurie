#!/bin/bash

# Whisper Installation Script
# Author: SillyPenguin
# Date: 25 January 2025

### 🔍 Function: Check if CUDA is installed ###
check_cuda() {
    if command -v nvidia-smi &> /dev/null; then
        echo "✅ CUDA detected. Checking compatibility..."
        if nvidia-smi | grep -qi cuda; then
            echo "✅ Compatible NVIDIA CUDA installation detected."
            return 0
        else
            echo "⚠️ CUDA detected, but compatibility issues found."
            return 1
        fi
    else
        echo "❌ CUDA is not installed."
        return 1
    fi
}

### 🔧 Function: Install System Dependencies ###
install_prerequisites() {
    echo "🔄 Updating package list and installing prerequisites..."
    apt update && apt install -y git python3 python3-pip ffmpeg build-essential
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install prerequisites. Exiting."
        exit 1
    fi
    echo "✅ Prerequisites installed successfully."
}

### 🔧 Function: Install Whisper ###
install_whisper() {
    echo "🔄 Installing Whisper..."
    if ! command -v pip &> /dev/null; then
        echo "❌ Python pip is not installed. Exiting."
        exit 1
    fi

    pip install --upgrade pip setuptools wheel
    pip install openai-whisper
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Whisper. Exiting."
        exit 1
    fi
    echo "✅ Whisper installed successfully."
}

### 🔧 Function: Install PyTorch (CUDA) ###
install_nvidia_pytorch() {
    echo "🔄 Installing PyTorch with CUDA support..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install PyTorch with CUDA support. Exiting."
        exit 1
    fi
    echo "✅ PyTorch with CUDA support installed successfully."
}

### 🔧 Function: Install PyTorch (CPU Only) ###
install_cpu_pytorch() {
    echo "🔄 Installing PyTorch for CPU-only systems..."
    pip install torch torchvision torchaudio
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install CPU-only PyTorch. Exiting."
        exit 1
    fi
    echo "✅ PyTorch for CPU-only systems installed successfully."
}

### Main Script Execution ###
install_prerequisites
if check_cuda; then
    install_nvidia_pytorch
else
    install_cpu_pytorch
fi
install_whisper

echo "🎉 Setup complete. Whisper is now installed."
exit 0