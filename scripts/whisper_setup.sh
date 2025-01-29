#!/bin/bash

# Whisper Installation Script
# Author: SillyPenguin
# Date: 25 January 2025

### 🔍 Function: Check if CUDA is installed ###
check_cuda() {
    if command -v nvidia-smi &>/dev/null; then
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
    if ! apt update && apt install -y git python3 python3-pip ffmpeg build-essential; then
        echo "❌ Failed to install prerequisites."
    else
        echo "✅ Prerequisites installed successfully."
    fi
}

### 🔧 Function: Install Whisper ###
install_whisper() {
    echo "🔄 Installing Whisper..."
    if ! command -v pip &>/dev/null; then
        echo "❌ Python pip is not installed. Skipping Whisper installation."
        return 1
    fi

    pip install --upgrade pip setuptools wheel
    if ! pip install openai-whisper; then
        echo "❌ Failed to install Whisper."
    else
        echo "✅ Whisper installed successfully."
    fi
}

### 🔧 Function: Install PyTorch (CUDA) ###
install_nvidia_pytorch() {
    echo "🔄 Installing PyTorch with CUDA support..."
    if ! pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118; then
        echo "❌ Failed to install PyTorch with CUDA support."
    else
        echo "✅ PyTorch with CUDA support installed successfully."
    fi
}

### 🔧 Function: Install PyTorch (CPU Only) ###
install_cpu_pytorch() {
    echo "🔄 Installing PyTorch for CPU-only systems..."
    if ! pip install torch torchvision torchaudio; then
        echo "❌ Failed to install CPU-only PyTorch."
    else
        echo "✅ PyTorch for CPU-only systems installed successfully."
    fi
}

### 🔧 Main Script Execution ###
echo "🚀 Starting Whisper installation process..."
install_prerequisites

if check_cuda; then
    install_nvidia_pytorch
else
    install_cpu_pytorch
fi

install_whisper

echo "🎉 Setup complete. Whisper is now installed."
exit 0