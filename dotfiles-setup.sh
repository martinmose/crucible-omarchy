#!/bin/bash

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/martinmose/.dotfiles"
REPO_NAME=".dotfiles"

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
    git clone "$REPO_URL" ~/"$REPO_NAME"
fi

# Check if the clone was successful
if [ $? -eq 0 ]; then
    echo "Repository cloned successfully."
    echo "Changing to the repository directory and follow the README.md instructions."
else
    echo "Failed to clone the repository."
    exit 1
fi

