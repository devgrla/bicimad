import geopandas as gpd
import folium
import psycopg2
conn = psycopg2.connect("host='postgre-sqltest.cpdeokpzufj1.us-west-2.rds.amazonaws.com' port=5432 dbname='postgres' user=xseed password=LosTilos114")
crs = {'init': 'epsg:4326'}
style =  {'fillColor': '#1a1aff', 'color': '#1a1aff', 'opacity': .1}

def get_routes_between_stations(estacion_origen, estacion_destino, fecha_origen, fecha_destino, user_type_code):
    query = '''
    select geom geometry from bike_movement_route_line
    inner join bike_movement bm on bike_movement_route_line.oid_bike_movement = bm.oid
    where  bm.unplug_hourtime >= '{0}' and bm.unplug_hourtime  <= '{1}' 
    and bm.idunplug_station = {2} and bm.idplug_station = {3} and bm.user_type_code in {4}
    order by random()
    LIMIT 2000;
    ''';

    query_estaciones ='''
    SELECT geom geometry, name, id, num_bases, address from station where id in ( ''' + str(estacion_origen) + ',' + str(estacion_destino) + ''')'''

    query_estaciones = query_estaciones.format(str(estacion_origen))
    estaciones = gpd.GeoDataFrame.from_postgis(query_estaciones, conn, crs=crs, geom_col='geometry')

    query = query.format(fecha_origen, fecha_destino, estacion_origen, estacion_destino, user_type_code)
    style =  {'fillColor': '#1a1aff', 'color': '#1a1aff', 'opacity': .5}
    dat = gpd.GeoDataFrame.from_postgis(query, conn, crs=crs, geom_col='geometry')
    m = folium.Map(location=[40.4, -3.7], zoom_start=13)
    folium.GeoJson(dat, lambda x: style).add_to(m)
    folium.GeoJson(estaciones, tooltip=folium.features.GeoJsonTooltip(fields=['id', 'name', 'num_bases', 'address'])).add_to(m)
    return m

def get_movements_lines(fecha_origen, fecha_destino, user_type_code, limit):
    query = '''
    select geom geometry from bike_movement_route_line
    inner join bike_movement bm on bike_movement_route_line.oid_bike_movement = bm.oid
    where  bm.unplug_hourtime >= '{0}' and bm.unplug_hourtime <= '{1}' and bm.user_type_code in {2} 
    ORDER BY random()
    LIMIT {3};
    '''
    query = query.format(fecha_origen, fecha_destino, user_type_code, limit)

    dat = gpd.GeoDataFrame.from_postgis(query, conn, crs=crs, geom_col='geometry')
    m = folium.Map(location=[40.4, -3.7], zoom_start=13)
    folium.GeoJson(dat, lambda x: style).add_to(m)
    return m