# Copyright (C) 2015 Jeffrey Meyers
#
# This program is released under the "MIT License".
# Please see the file COPYING in this distribution for license terms.

import csv, subprocess, os, itertools

API_OUTPUT = "output_api"
MOBILE_OUTPUT = "output_mobile"
DATA_DIR = "data"
SCHEMA = os.path.join(DATA_DIR, "schema.sql")
ROUTE_DIRECTIONS = os.path.join(DATA_DIR, "route_directions.csv")
ROUTES = os.path.join(DATA_DIR, "tm_routes.shp")
STOPS = os.path.join(DATA_DIR, "tm_route_stops.shp")

ROUTE_IDS = ["4", "9", "17", "193", "194", "195"]
DIRECTION_IDS = ["0", "1"]

# each "run" has route along with direction
# Powell Blvd - To Portland
#   Route: 9
#   Direction: 1

# units in map projection for how much to simplify line geojson

SIMPLIFY = 20

"""
file naming schema:

<route_id>_<direction>_stops.geojson
<route_id>_<direction>_routes.geojson

Base command: 
  ogr2ogr -f GeoJSON -t_srs EPSG:4326 <output geojson> <input shapefile>

Extra flags:
  -simplify <tolerance>
  -sql "SELECT <..> FROM <..> WHERE <..>
"""


def pretty_json(source):
    target = os.path.splitext(source)[0] + ".geojson"
    prettify = "cat {0} | python -m json.tool > {1}".format(source, target)
    remove = "rm -rf {0}".format(source)
    subprocess.call(prettify, shell=True)
    subprocess.call(remove, shell=True) 

def api_runner():
    build_sql = "shp2pgsql -s 2913 -I -a {0} public.stops > {1}"
    command = build_sql.format(STOPS, os.path.join(API_OUTPUT, "stops.sql"))
    subprocess.call(command,  shell=True) 
    
    copy_schema = "cp {0} {1}"
    command = copy_schema.format(SCHEMA, os.path.join(API_OUTPUT, "schema.sql"))
    subprocess.call(command,  shell=True) 


def mobile_runner(route_ids=ROUTES):
    # clear output directory
    subprocess.call("rm -f {0}/*".format(MOBILE_OUTPUT),  shell=True) 
    runs = itertools.product(route_ids, DIRECTION_IDS)
    for run in runs:
        stops, stops_output = build_stops_command(*run)
        routes, routes_output = build_routes_command(*run)
        subprocess.call(stops, shell=True)
        subprocess.call(routes, shell=True) 
        pretty_json(stops_output)
        pretty_json(routes_output)
    print "view files in directoy: " + MOBILE_OUTPUT

def build_stops_command(route, direction):
    stops = os.path.splitext(os.path.basename(STOPS))[0]
    stops_file = "{0}_{1}_stops.temp"
    stops_command = """ogr2ogr \
        -f GeoJSON \
        -t_srs EPSG:4326 \
        -sql \"{0}\" \
        {1} {2}"""

    sql = "SELECT * FROM {0} WHERE rte={1} AND dir={2}"
    output = os.path.join(MOBILE_OUTPUT, stops_file.format(route,direction))
    sql_command = sql.format(stops, route, direction)
    command = stops_command.format(sql_command, output, STOPS) 
    return command, output

def build_routes_command(route, direction):
    routes = os.path.splitext(os.path.basename(ROUTES))[0]
    routes_file = "{0}_{1}_routes.temp"
    routes_command = """ogr2ogr \
        -f GeoJSON \
        -t_srs EPSG:4326 \
        -sql \"{0}\" \
        -simplify {1} \
        {2} {3}"""
    sql = "SELECT * FROM {0} WHERE rte={1} AND dir={2}"
    output = os.path.join(MOBILE_OUTPUT, routes_file.format(route,direction))
    sql_command = sql.format(routes, route, direction)
    command = routes_command.format(sql_command, SIMPLIFY, output, ROUTES) 
    return command, output


def route_ids(filepath):
    with open(filepath, 'rb') as f:
        return list(set([row['rte'] for row in csv.DictReader(f)]))

if __name__ == "__main__":
    routes = route_ids(ROUTE_DIRECTIONS)
    mobile_runner(route_ids=routes)
    api_runner()
    


