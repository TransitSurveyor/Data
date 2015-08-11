# Data

**author:** Jeffrey Meyers (jeffrey.alan.meyers@gmail.com)

Copyright © 2015 Jeffrey Meyers. This program is released under the "MIT License". Please see the file COPYING in this distribution for license terms.

Both the [MobileSurveyor](https://github.com/TransitSurveyor/MobileSurveyor) and [API](https://github.com/TransitSurveyor/API) repos contain a folder called `data_inputs`. There is sample data already in both of them, but to use your own data inputs you will want to run the `build.py` script after generating your own source files.

In `Data/source` you will find stops shapefile, routes shapefile and database schema. You can create your own shapefiles following the existing schema

### Dependencies

+ `ogr2ogr`
+ `sh2pgsql`

These commands need to be available and on your path

### Deploying

After running `build.py` both `Data/output_mobile` and `Data/output_api` will be populated with fresh data. This data will need to be copied into the `MobileSurveyor/data_inputs` and `API/data_inputs` in the respective repositories.

### TODO

The system is currently built using [TriMet's GIS data](http://developer.trimet.org/gis/). I would like to try and build the project with data from a different transit agency. This would help show different transit agencies how they could easily use it (assuming they generate GTFS schedule data).

##### Building PostgreSQL database from GTFS

GTFS provides a specification transit agencies use to publish their data. You will need to build a database using [gtfsdb](https://github.com/OpenTransitTools/gtfsdb). Data inputs could then potentially be generated from this database.

Follow the directions to build gtfsdb. You will then want to load a db using the is_spatial flag.

```shell
# assuming you have created a spatially enabled database

# using psql
#   create database dbname;
#   \c dbname
#   create extension postgis;

db=postgresql://user:password@localhost:port/database
gtfs=http://developer.trimet.org/schedule/gtfs.zip

git clone https://github.com/OpenTransitTools/gtfsdb.git
cd gtfsdb
virtualenv env
env/bin/pip install psycopg2
env/bin/python setup.py install
env/bin/gtfsdb-load --database_url ${db} --is_geospatial ${gtfs}
```

