# Data

Copyright © 2015 Jeffrey Meyers. This program is released under the "MIT License". Please see the file COPYING in this distribution for license terms.

### dependencies

+ `ogr2ogr`
+ `sh2pgsql`

These commands need to be available and on your path

### Deploying

Run `build_data_inputs.sh` to download shapefiles from trimet developer resources
and use them as inputs to generate resources for the Android APP and API. After
running `Data/output_mobile` and `Data/output_api` will be populated with data.
