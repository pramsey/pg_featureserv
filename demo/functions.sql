CREATE OR REPLACE FUNCTION postgisftw.us_grid(
	num_x integer DEFAULT 10,
	num_y integer DEFAULT 10)
RETURNS TABLE(id text, geom geometry)
AS $$
DECLARE
    lon_min CONSTANT numeric := -128;
    lon_max CONSTANT numeric := -64;
    lat_min CONSTANT numeric := 24;
    lat_max CONSTANT numeric := 49;
    dlon numeric;
    dlat numeric;
BEGIN
    dlon := (lon_max - lon_min) / num_x;
    dlat := (lat_max - lat_min) / num_y;
	RETURN QUERY
		SELECT
			x.x::text || '_' || y.y::text AS id,
			ST_MakeEnvelope(
                lon_min + (x.x - 1) * dlon, lat_min + (y.y - 1) * dlat,
                lon_min + x.x * dlon,       lat_min + y.y * dlat, 4326
             ) AS geom
		FROM generate_series(1, num_x) AS x(x)
        CROSS JOIN generate_series(1, num_y) AS y(y);
END;
$$
LANGUAGE 'plpgsql'
STABLE
STRICT;

COMMENT ON FUNCTION postgisftw.us_grid IS 'Generates a grid of rectangles covering the USA';

SELECT * FROM postgisftw.us_grid();


CREATE OR REPLACE FUNCTION postgisftw.us_grid_noid(
	num_x integer DEFAULT 10,
	num_y integer DEFAULT 10)
RETURNS TABLE(geom geometry)
AS $$
DECLARE
    lon_min CONSTANT numeric := -128;
    lon_max CONSTANT numeric := -64;
    lat_min CONSTANT numeric := 24;
    lat_max CONSTANT numeric := 49;
    dlon numeric;
    dlat numeric;
BEGIN
    dlon := (lon_max - lon_min) / num_x;
    dlat := (lat_max - lat_min) / num_y;
	RETURN QUERY
		SELECT
			ST_MakeEnvelope(
                lon_min + (x.x - 1) * dlon, lat_min + (y.y - 1) * dlat,
                lon_min + x.x * dlon,       lat_min + y.y * dlat, 4326
             ) AS geom
		FROM generate_series(1, num_x) AS x(x)
        CROSS JOIN generate_series(1, num_y) AS y(y);
END;
$$
LANGUAGE 'plpgsql'
STABLE
STRICT;

============================================================================

CREATE OR REPLACE FUNCTION postgisftw.geo_grid(
  num_x integer DEFAULT 10,
  num_y integer DEFAULT 10,
  lon_min numeric DEFAULT -180.0,
  lat_min numeric DEFAULT -90.0,
  lon_max numeric DEFAULT 180.0,
  lat_max numeric DEFAULT 90.0)
RETURNS TABLE(id text, geom geometry)
AS $$
DECLARE
    dlon numeric;
    dlat numeric;
BEGIN
    dlon := (lon_max - lon_min) / num_x;
    dlat := (lat_max - lat_min) / num_y;
	RETURN QUERY
		SELECT
			x.x::text || '_' || y.y::text AS id,
			ST_MakeEnvelope(
                lon_min + (x.x - 1) * dlon, lat_min + (y.y - 1) * dlat,
                lon_min + x.x * dlon,       lat_min + y.y * dlat, 4326
             ) AS geom
		FROM generate_series(1, num_x) AS x(x)
        CROSS JOIN generate_series(1, num_y) AS y(y);
END;
$$
LANGUAGE 'plpgsql'
STABLE
STRICT;

COMMENT ON FUNCTION postgisftw.geo_grid IS 'Generates a grid of rectangles over a geographic extent';

SELECT * FROM postgisftw.us_grid(5,5,-128,24,-64,49);

============================================================================

CREATE OR REPLACE FUNCTION postgisftw.buffer(
	input geometry DEFAULT 'POINT(0 0)'::geometry,
	dist numeric DEFAULT 10)
RETURNS TABLE(geom geometry)
AS $$
BEGIN
	RETURN QUERY
		SELECT
			ST_Buffer( ST_SetSRID(input, 4326), dist ) AS geom;
END;
$$
LANGUAGE 'plpgsql'
STABLE
STRICT;

============================================================================

CREATE OR REPLACE FUNCTION postgisftw.country_by_name(
	name_prefix text DEFAULT 'A')
RETURNS TABLE(name text, geom geometry)
AS $$
BEGIN
	RETURN QUERY
		SELECT t.name::text, t.geom
    FROM ne.admin_0_countries t
    WHERE t.name ILIKE name_prefix || '%';
END;
$$
LANGUAGE 'plpgsql' STABLE STRICT;
