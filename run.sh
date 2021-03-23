#!/bin/bash
set -e

# Parse arguments

batch_size=$(cat config/model-unet-building.toml | grep batch_size | cut -d'=' -f2 | xargs)
echo "Training on $batch_size GPU(s)..."
./rs train --dataset config/model-unet-building.toml --model config/model-unet-building.toml
