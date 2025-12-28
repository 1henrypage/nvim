#!/bin/bash

# Detect OS
OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
    echo "Detected macOS"
    # Update Homebrew
    brew update
    brew upgrade

    # Install dependencies
    brew install ripgrep
    brew install unzip
    # xclip is usually not needed on macOS (use pbcopy/pbpaste)
elif [ "$OS" = "Linux" ]; then
    echo "Detected Linux"
    # Check for Ubuntu/Debian
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt upgrade -y
        sudo apt-get install -y ripgrep xclip unzip
    else
        echo "Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
else
    echo "Unsupported OS: $OS"
    exit 1
fi

echo "Dependencies installed successfully."

