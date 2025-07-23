#!/bin/bash

# Script to install LaTeX dependencies for ACM paper compilation

echo "Installing LaTeX dependencies..."

# Update package list
sudo apt-get update

# Install texlive and required packages
sudo apt-get install -y \
    texlive-full \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-bibtex-extra \
    biber \
    latexmk \
    texlive-xetex \
    texlive-luatex

echo "LaTeX dependencies installed successfully!"