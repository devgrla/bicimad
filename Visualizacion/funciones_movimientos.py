import folium
import json
import pandas as pd
from PIL import Image, ImageDraw
import geopandas as gpd
import psycopg2
conn = psycopg2.connect("host='postgre-sqltest.cpdeokpzufj1.us-west-2.rds.amazonaws.com' port=5432 dbname='postgres' user=xseed password=LosTilos114")

def get_data_for_trip_counts(date_from, date_to, user_type):
    query = '''
    select user_type_code, travel_time, idunplug_station,age_range_code,idplug_station,unplug_hourtime,
    s.code_station as code_station_departure, s.latitude as latitude_departure, 
    s.longitude as longitude_departure, s.name as name_departure,b.nombre AS barrio_departure,d.nombre AS distrito_departure,
    s2.code_station as code_station_arrival, s2.latitude as latitude_arrival, 
    s2.longitude as longitude_arrival, s2.name as name_arrival, b2.nombre AS barrio_arrival,d2.nombre AS distrito_arrival
    from bike_movement bm
    join station s on bm.idunplug_station = s.id
    join station s2 on bm.idplug_station = s2.id
    join barrio b on ST_Intersects(b.geom, s.geom)
    join barrio b2 on ST_Intersects(b2.geom, s2.geom)
    join distrito d on b.distrito_id = d.id
    join distrito d2 on b2.distrito_id = d2.id
    where bm.unplug_hourtime >= '{0}'
    and bm.unplug_hourtime  <= '{1}' and bm.user_type_code IN {2}
    '''

    query = query.format(date_from, date_to, user_type)
    data = pd.read_sql(query, conn)
    return data

def get_trip_counts_by_hour(selected_hour, data):

    locations = data.groupby("code_station_departure").first()
    # and select only the tree columns we are interested in
    locations = locations.loc[:, ["latitude_departure",
                              "longitude_departure",
                              "name_departure",
                              "distrito_departure"]]
    
    subset = data[data["hour"]==selected_hour]
    subset_arrival = data[data["hour_arrival"]==selected_hour]
    
    departure_counts =  subset.groupby("code_station_departure").count()
    # select one column
    departure_counts = departure_counts.iloc[:,[0]]
    # and rename that column
    departure_counts.columns= ["Departure Count"]

    arrival_counts =  subset_arrival.groupby("code_station_arrival").count()
    # select one column
    arrival_counts = arrival_counts.iloc[:,[0]]
    # and rename that column
    arrival_counts.columns= ["Arrival Count"]
    trip_counts = departure_counts.join(locations).join(arrival_counts)
    
    return trip_counts

def plot_station_counts(trip_counts, data, radius_divisor):

    folium_map = folium.Map(location=[40.4, -3.7], zoom_start=13,
                        tiles="CartoDB dark_matter")
    
    for index, row in trip_counts.iterrows():
        
        net_departures = (row["Departure Count"]-row["Arrival Count"])
        popup_text = "{}<br> Total Salidas: {}<br> Total Llegadas: {}<br> Balance: {}"
        popup_text = popup_text.format(row["name_departure"],
                              row["Departure Count"],
                              row["Arrival Count"],
                              net_departures)
        
        radius = abs(net_departures/radius_divisor)
        if radius == 0:
            radius = 1/radius_divisor

        if net_departures>0:
            color="#E37222" # tangerine
        else:
            color="#0A8A9F" # teal

        folium.CircleMarker(location=(row["latitude_departure"],
                                      row["longitude_departure"]),
                            radius=radius,
                            color=color,
                            popup=popup_text,
                            fill=True).add_to(folium_map)
        
    return folium_map

def get_trip_counts_total(data):

    locations = data.groupby("code_station_departure").first()
    # and select only the tree columns we are interested in
    locations = locations.loc[:, ["latitude_departure",
                              "longitude_departure",
                              "name_departure",
                              "distrito_departure"]]
    
    departure_counts =  data.groupby("code_station_departure").count()
    # select one column
    departure_counts = departure_counts.iloc[:,[0]]
    # and rename that column
    departure_counts.columns= ["Departure Count"]

    arrival_counts =  data.groupby("code_station_arrival").count()
    # select one column
    arrival_counts = arrival_counts.iloc[:,[0]]
    # and rename that column
    arrival_counts.columns= ["Arrival Count"]
    trip_counts = departure_counts.join(locations).join(arrival_counts)
    
    return trip_counts

def get_table_counts_by_hour(trip_counts, max_rows, orderAsc):
    tabla = trip_counts.reset_index()
    tabla['Estacion'] = tabla['name_departure']
    tabla['Distrito'] = tabla['distrito_departure']
    tabla['Llegadas'] = tabla['Arrival Count']
    tabla['Salidas'] = tabla['Departure Count']
    tabla['Balance'] = tabla["Salidas"]-tabla["Llegadas"]
    del tabla['code_station_departure']
    del tabla['latitude_departure']
    del tabla['longitude_departure']
    del tabla['Departure Count']
    del tabla['Arrival Count']
    del tabla['name_departure']
    del tabla['distrito_departure']
    if orderAsc == 1:
         return tabla.head(max_rows).sort_values(by = 'Balance')
    else:
         return tabla.head(max_rows).sort_values(by = 'Balance', ascending = False)
    
   