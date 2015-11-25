#!/bin/bash

SCRIPT=$(readlink -f $0)
DATA_DIR=`dirname $SCRIPT`

cd $DATA_DIR
rm -rf output_mobile output_api
mkdir output_mobile output_api

routes=tm_routes
stops=tm_route_stops

cd data
rm -f ${stops}.* ${routes}.*
wget http://developer.trimet.org/gis/data/tm_route_stops.zip 
wget http://developer.trimet.org/gis/data/tm_routes.zip
unzip ${stops}.zip
unzip ${routes}.zip
rm ${stops}.zip ${routes}.zip

cd $DATA_DIR
python build.py
