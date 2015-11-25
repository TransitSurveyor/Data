-- Copyright © 2015 Jeffrey Meyers
-- This program is released under the "MIT License".
-- Please see the file COPYING in the source
-- distribution of this software for license terms.

--
-- Temporarily stores On Scans
-- Is sorted by date and joined by UUID to link to Off Scan
--
CREATE TABLE on_temp (
    id integer NOT NULL,
    uuid text,
    date timestamp without time zone,
    rte integer,
    dir integer,
    match boolean,
    geom geometry(Point,2913),
    user_id TEXT
);

CREATE SEQUENCE on_temp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE on_temp_id_seq OWNED BY on_temp.id;
ALTER TABLE ONLY on_temp ALTER COLUMN id SET DEFAULT nextval('on_temp_id_seq'::regclass);
ALTER TABLE ONLY on_temp
    ADD CONSTRAINT on_temp_pkey PRIMARY KEY (id);
CREATE INDEX idx_on_temp_geom ON on_temp USING gist (geom);

--
-- Temporarily stores Off Scans
-- Not required, used for debugging
--
CREATE TABLE off_temp (
    id integer NOT NULL,
    uuid text,
    date timestamp without time zone,
    rte integer,
    dir integer,
    match boolean,
    geom geometry(Point,2913),
    user_id TEXT
);

CREATE SEQUENCE off_temp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE off_temp_id_seq OWNED BY off_temp.id;
ALTER TABLE ONLY off_temp ALTER COLUMN id SET DEFAULT nextval('off_temp_id_seq'::regclass);
ALTER TABLE ONLY off_temp
    ADD CONSTRAINT off_temp_pkey PRIMARY KEY (id);
CREATE INDEX idx_off_temp_geom ON off_temp USING gist (geom);

--
-- Stores final On-Off scans that are linked up
-- Data is copied from temp tables
--
CREATE TABLE scans (
    id integer NOT NULL,
    date timestamp without time zone,
    rte integer,
    dir integer,
    geom geometry(Point,2913),
    user_id TEXT,
    stop integer
);

CREATE SEQUENCE scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE scans_id_seq OWNED BY scans.id;
ALTER TABLE ONLY scans ALTER COLUMN id SET DEFAULT nextval('scans_id_seq'::regclass);
ALTER TABLE ONLY scans
    ADD CONSTRAINT scans_pkey PRIMARY KEY (id);
CREATE INDEX idx_scans_geom ON scans USING gist (geom);

--
-- Stores primary key for on-off pairs
-- Used for Bus routes
--
CREATE TABLE on_off_pairs__scans (
    id integer NOT NULL,
    on_id integer NOT NULL,
    off_id integer NOT NULL
);

CREATE SEQUENCE on_off_pairs__scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE on_off_pairs__scans_id_seq OWNED BY on_off_pairs__scans.id;
ALTER TABLE ONLY on_off_pairs__scans ALTER COLUMN id SET DEFAULT nextval('on_off_pairs__scans_id_seq'::regclass);
ALTER TABLE ONLY on_off_pairs__scans
    ADD CONSTRAINT on_off_pairs__scans_pkey PRIMARY KEY (id);

--
-- Stores on-off stops that were selected from map
-- Used for MAX and Streetcar routes
--
CREATE TABLE on_off_pairs__stops (
    id integer NOT NULL,
    date timestamp without time zone,
    rte integer,
    dir integer,
    on_stop integer NOT NULL,
    off_stop integer NOT NULL,
    user_id TEXT
);

CREATE SEQUENCE on_off_pairs__stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE on_off_pairs__stops_id_seq OWNED BY on_off_pairs__stops.id;
ALTER TABLE ONLY on_off_pairs__stops ALTER COLUMN id SET DEFAULT nextval('on_off_pairs__stops_id_seq'::regclass);
ALTER TABLE ONLY on_off_pairs__stops
    ADD CONSTRAINT on_off_pairs__stops_pkey PRIMARY KEY (id);

--
-- Stores Survey User information
-- Can be expaned to include more information
--
CREATE TABLE users (
    username text,
    password_hash text
);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);

--
-- Contains stop information for all TriMet stops
-- populated via shapefile using shp2pgsql
--

CREATE TABLE stops (
    gid serial primary key,
    rte smallint,
    dir smallint,
    rte_desc character varying(50),
    dir_desc character varying(50),
    "type" varchar,
    stop_seq integer,
    stop_id integer,
    stop_name character varying(50),
    jurisdic varchar,
    zipcode varchar,
    frequent boolean,
    geom geometry(Point,2913)
);

--
-- Foreign Key Constrains
--

-- on_off_pairs__scans
ALTER TABLE ONLY on_off_pairs__scans
    ADD CONSTRAINT on_off_pairs__scans_off_id_fkey FOREIGN KEY (off_id) REFERENCES scans(id);
ALTER TABLE ONLY on_off_pairs__scans
    ADD CONSTRAINT on_off_pairs__scans_on_id_fkey FOREIGN KEY (on_id) REFERENCES scans(id);

-- on_off_pairs__stops
ALTER TABLE ONLY on_off_pairs__stops
    ADD CONSTRAINT on_off_pairs__stops_off_stop_fkey FOREIGN KEY (off_stop) REFERENCES stops(gid);
ALTER TABLE ONLY on_off_pairs__stops
    ADD CONSTRAINT on_off_pairs__stops_on_stop_fkey FOREIGN KEY (on_stop) REFERENCES stops(gid);
ALTER TABLE ONLY scans
    ADD CONSTRAINT scans_stop_fkey FOREIGN KEY (stop) REFERENCES stops(gid);

