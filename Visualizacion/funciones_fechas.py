
import pandas as pd
from datetime import date, datetime, timedelta
import re
import numpy as np

#Devuelve estacion del año según fecha
def get_season(date):
    if date >= datetime(date.year, 3, 21) and date <= datetime(date.year, 6, 20):
        return 'Primavera'
    elif date >= datetime(date.year, 6, 21) and date <= datetime(date.year, 9 , 20):
        return 'Verano'
    elif date >= datetime(date.year, 9, 21) and date <= datetime(date.year, 12 , 20):
        return 'Otoño'
    else:
        return 'Invierno'

#Devuelve dia de la semana por fecha
def get_day_of_week(date):    
    day = date.weekday()
    if day == 0:
        return '1 - Lunes'
    elif day == 1:
        return '2 - Martes'
    elif day == 2:
        return '3 - Miércoles'
    elif day == 3:
        return '4 - Jueves'
    elif day == 4:
        return '5 - Viernes'
    elif day == 5:
        return '6 - Sabádo'
    elif day == 6:
        return '7 - Domingo'

def isWeekend(date):    
    day = date.weekday()
    if day == 5 or day == 6:
        return 1
    else:
        return 0

def cast_date(date):
    return datetime.strptime(date, '%Y-%m-%d')

def get_season_row(row):
    if row.date >= datetime(row.date.year, 3, 21) and row.date <= datetime(row.date.year, 6, 20):
        return 'Primavera'
    elif row.date >= datetime(row.date.year, 6, 21) and row.date <= datetime(row.date.year, 9 , 20):
        return 'Verano'
    elif row.date >= datetime(row.date.year, 9, 21) and row.date <= datetime(row.date.year, 12 , 20):
        return 'Otoño'
    else:
        return 'Invierno'