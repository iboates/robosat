#!/bin/bash
set -e

# Parse arguments
zoom=$1
frac_train=$2
frac_validate=$3
frac_holdout=$4
mapbox_access_token=$5

# Clone the repo and install the deps, plus the ones that are missing for some reason
#pip install -r requirements.in
#pip install torch
#pip install torchvision

# Make folder structure for dataset
mkdir -p dataset
mkdir -p dataset/training
mkdir -p dataset/training/images
mkdir -p dataset/training/labels
mkdir -p dataset/validation
mkdir -p dataset/validation/images
mkdir -p dataset/validation/labels
mkdir -p holdout
mkdir -p holdout/images
mkdir -p holdout/labels

#echo "Writing cover CSV..."
#for buildings_geojson in ./buildings-postgis-*.geojson; do
#    ./rs cover --zoom $zoom $buildings_geojson buildings_cover.csv
#done
#
#echo "Downloading tiles..."
#./rs download --ext png https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.png?access_token=$mapbox_access_token buildings_cover.csv holdout/images

#echo "Rasterizing..."
#for buildings_geojson in ./buildings-postgis-*.geojson; do
#    ./rs rasterize --zoom $zoom --dataset config/model-unet-building.toml $buildings_geojson buildings_cover.csv holdout/labels
#done

echo "Splitting data into train/validate/holdout..."
python create_dataset.py $zoom $frac_train $frac_validate $frac_holdout

echo "Creating weights..."
./rs weights --dataset config/model-unet-building.toml