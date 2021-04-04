#!/bin/bash
set -e
cd ..

# Parse arguments
zoom=$1
frac_train=$2
frac_validate=$3
frac_holdout=$4
mapbox_access_token=$5

# Make folder structure for dataset
mkdir -p vineyards/dataset
mkdir -p vineyards/dataset/training
mkdir -p vineyards/dataset/training/images
mkdir -p vineyards/dataset/training/labels
mkdir -p vineyards/dataset/validation
mkdir -p vineyards/dataset/validation/images
mkdir -p vineyards/dataset/validation/labels
mkdir -p vineyards/dataset/holdout
mkdir -p vineyards/dataset/holdout/images
mkdir -p vineyards/dataset/holdout/labels

./rs cover --zoom $zoom vineyards/data/all_classes.geojson vineyards/data/vineyards-cover.csv
./rs cover --zoom $zoom vineyards/data/all_classes.geojson vineyards/data/all_classes-cover.csv

echo "Downloading tiles..."
./rs download --ext png https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.png?access_token=$mapbox_access_token vineyards/data/all_classes-cover.csv vineyards/dataset/holdout/images

echo "Rasterizing..."
./rs rasterize --zoom $zoom --dataset vineyards/config/model-unet.toml vineyards/data/vineyards.geojson vineyards/data/vineyards-cover.csv vineyards/dataset/holdout/labels

echo "Splitting data into train/validate/holdout..."
cd vineyards
python create_dataset.py $zoom $frac_train $frac_validate $frac_holdout
cd ..

echo "Creating weights..."
./rs weights --dataset vineyards/config/model-unet.toml