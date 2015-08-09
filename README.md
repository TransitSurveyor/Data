# Data


Both the [MobileSurveyor](https://github.com/TransitSurveyor/MobileSurveyor) and [API](https://github.com/TransitSurveyor/API) repos contain a folder called `data_inputs`. There is sample data already in both of them, but to use your own data inputs you will want to run the `build.py` script after generating your own source files.

In `Data/source` you will find stops shapefile, routes shapefile and database schema. You can create your own shapefiles follwing the existing schema

### dependencies

+ `ogr2ogr`
+ `sh2pgsql`

These commands need to be available and on your path

### Deploying

After running `build.py` both `Data/output_mobile` and `Data/output_api` will be populated with fresh data. This data will need to be copied into the `MobileSurveyor/data_inputs` and `API/data_inputs` in the respective repositories.
