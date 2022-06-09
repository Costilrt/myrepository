# 1. import Flask
from flask import Flask, jsonify
from matplotlib import style
style.use('fivethirtyeight')
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import datetime as datetime
from dateutil.relativedelta import relativedelta
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func, desc, inspect

database_path = "Resources/hawaii.sqlite"
engine = create_engine(f"sqlite:///{database_path}")
# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)
# Save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station
session = Session(engine)
# 2. Create an app, being sure to pass __name__
app = Flask(__name__)

# 3. Define what to do when a user hits the index route
@app.route("/")
def home():

    return (f"Welcome to my 'Home' page!<br/>"
    f"/api/v1.0/precipitation<br/>"
    f"/api/v1.0/stations<br/>"
    f"/api/v1.0/tobs<br/>"
    f"/api/v1.0/start/end"
    )


# 4. Define what to do when a user hits the /about route
@app.route("/api/v1.0/precipitation")
def precipitation():

    year_ago_date=datetime.date(2017, 8, 23) - datetime.timedelta(days=366)
    year_prcp_stats=(session.query(Measurement.date, Measurement.prcp)\
                        .filter(Measurement.date > year_ago_date).all())
    prcp_dict={date: prcp for date, prcp in year_prcp_stats}

    # close session
    session.close()

    return jsonify(prcp_dict)

@app.route("/api/v1.0/stations")
def stations():
# create session 
    session = Session(engine)

    # query database for all stations
    stations = session.query(Station.station, Station.name, Station.id, Station.elevation, Station.longitude, Station.latitude).all()

    # create empty list
    stations_list = []

    # turn list of tuples into dictionary and add to list
    for entry in stations:
        station_dict = {}
        station_dict["station"] = entry[5]
        station_dict["name"] = entry[1]
        station_dict["id"] = entry[2]
        station_dict["elevation"] = entry[3]
        station_dict["longitude"] = entry[0]
        station_dict["latitude"] = entry[4]
        stations_list.append(station_dict)

    # close session
    session.close()

    return jsonify(stations_list)

@app.route("/api/v1.0/tobs")
def tobs():
     # create session 
    session = Session(engine)

    # Calculate the date 1 year ago from last date in database
    prev_year = dt.date(2017, 8, 23) - dt.timedelta(days=365)
   # Query the primary station for all tobs from the last year
    results = session.query(Measurement.tobs).\
       filter(Measurement.station == 'USC00519281').\
       filter(Measurement.date >= prev_year).all()
    session.close()
   # Unravel results into a 1D array and convert to a list
    temps = list(np.ravel(results))
   # Return the results
    return jsonify(temps=temps)

# create date search route
@app.route("/api/v1.0/<start>")
@app.route("/api/v1.0/<start>/<end>")
def date_search(start, end):

    # create session 
    session = Session(engine)

    # query database for temp calculated data
    date_range = session.query(func.min(Measurement.tobs),func.max(Measurement.tobs),func.avg(Measurement.tobs)).\
        filter(Measurement.date >= start).\
        filter(Measurement.date <= end).\
        all()

    # create empty dictionary
    stats_dict = {}

    # turn list of tuples into dictionary
    for stat in date_range:
        stats_dict["Min Temp"] = stat[0]
        stats_dict["Avg Temp"] = round(stat[2],2)
        stats_dict["Max Temp"] = stat[1]

    # close session
    session.close()

    return jsonify(stats_dict)

# run in debug mode
if __name__ == "__main__":
    app.run(debug=True)
