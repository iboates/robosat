#!/bin/bash
set -e

# Parse arguments
pbf_download_link=$1
zoom=$2
frac_train=$3
frac_validate=$4
frac_holdout=$5
mapbox_access_token=$6

# Update environment
sudo apt update

# Download & install Anaconda, then make an env
#wget -O anaconda.sh https://repo.anaconda.com/archive/ -q -O- | grep 'Anaconda3'| sed -n 's|.*>Anaconda3-\([0-9]\{4\}\.[0-9]\{2\}\)-.*|\1|p' uniq | sort -r | head -1
#
#chmod +x anaconda.sh
#./anaconda.sh -b -p $HOME/anaconda
#source .bashrc
#conda create -n robosat python=3.8
#conda activate robosat

# Clone the repo and install the deps, plus the ones that are missing for some reason
pip install -r requirements.in
pip install torch
pip install torchvision

# Make folder structure for dataset
mkdir -p dataset
mkdir -p dataset/training
mkdir -p dataset/validation
mkdir -p holdout
mkdir -p holdout/images
mkdir -p holdout/labels

# Download the OSM data
#wget -O osm_data.pbf $pbf_download_link

# Run RoboSat
#./rs extract --type building osm_data.pbf buildings.geojson



echo "Writing cover CSV..."
for buildings_geojson in ./buildings-postgis-*.geojson; do
    ./rs cover --zoom $zoom $buildings_geojson buildings_cover.csv
done

echo "Downloading tiles..."
./rs download --ext png https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.webp?access_token=$mapbox_access_token buildings_cover.csv holdout/images

echo "Rasterizing..."
for buildings_geojson in ./buildings-postgis-*.geojson; do
    ./rs rasterize --zoom $zoom --dataset config/model-unet-building.toml $buildings_geojson buildings_cover.csv holdout/labels
done

echo "Splitting data into train/validate/holdout..."
python create_dataset.py $zoom $frac_train $frac_validate $frac_holdout

echo "Creating weights..."
./rs weights --dataset config/model-unet-building.toml

batch_size=$(cat config/model-unet-building.toml | grep batch_size | cut -d'=' -f2 | xargs)
echo "Training on $batch_size GPU(s)..."
./rs train --dataset config/model-unet-building.toml --model config/model-unet-building.toml


./rs predict --tile_size 512 --model config/model-unet-building.toml --dataset config/model-unet-building.toml holdout/images probs
./rs masks masks probs
./rs compare compare holdout/images holdout/labels masks
