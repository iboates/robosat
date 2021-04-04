#!/bin/bash
set -e
cd ..

# Parse arguments

batch_size=$(cat vineyards/config/model-unet.toml | grep batch_size | cut -d'=' -f2 | xargs)
echo "Training on $batch_size GPU(s)..."
./rs train --dataset vineyards/config/model-unet.toml --model vineyards/config/model-unet.toml
