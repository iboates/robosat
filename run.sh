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
wget -O anaconda.sh https://repo.anaconda.com/archive/ -q -O- | grep 'Anaconda3'| sed -n 's|.*>Anaconda3-\([0-9]\{4\}\.[0-9]\{2\}\)-.*|\1|p' uniq | sort -r | head -1

chmod +x anaconda.sh
./anaconda.shh -b -p $HOME/anaconda
source .bashrc
conda create -n robosat python=3.8
conda activate robosat

# Clone the repo and install the deps, plus the ones that are missing for some reason
pip install -r requirements.in
pip install torch
pip install torchvision

# Make folder structure for dataset
mkdir dataset
mkdir dataset/training
mkdir dataset/validation
mkdir holdout
mkdir holdout/images
mkdir holdout/labels

# Download the OSM data
wget $pbf_download_link

# Run RoboSat
./rs extract --type building seychelles-latest.osm.pbf buildings.geojson
buildings_geojson=$(find . -name 'buildings-*.geojson')
./rs cover --zoom 17 $buildings_geojson cover.csv
./rs download --ext png https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}@2x.webp?access_token=$mapbox_access_token cover.csv holdout/images
./rs rasterize --zoom 17 --dataset config/model-unet-building.toml $buildings_geojson cover.csv holdout/labels
python create_dataset.py $zoom $frac_train $frac_validate $frac_holdout
./rs weights --dataset config/model-unet-building.toml
./rs train --dataset config/model-unet-building.toml --model config/model-unet-building.toml
