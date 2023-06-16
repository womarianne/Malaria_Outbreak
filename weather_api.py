import streamlit as st
import pandas as pd
import json
import requests
from sklearn import datasets
from sklearn.svm import SVR
from sklearn.model_selection import train_test_split

# Fit the SVR model
LoR = pd.read_csv("Average_Northern.csv")
LoR = LoR.dropna()
LoR1 = LoR.iloc[:, 0:11]
data= LoR1.iloc[0:90, :]
X= data[['Prec_Average', 'Average_Temperature_Max', 'Average_RH_Max']]
y= data['Malaria_incidence']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.10, random_state=42)
svr_model = SVR(kernel='rbf',epsilon=0.1)
svr_model.fit(X_train, y_train)

#current Weather data
def get_current_weather(city, api_key):
    base_url = "https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}"
    params = {
        "q": city,
        "appid": api_key,
        "units": "metric"  # You can change the unit of measurement if desired
    }
    response = requests.get(base_url, params=params).json()
    data=json.loads(response)
    #data = json.loads(data)
    # Extract relevant weather information
    extracted_data = {
        'Prec_Average': data["rain"]["1h"],
        'Average_Temperature_Max': data["main"]["temp_max"],
        'Average_RH_Max': data["main"]["humidity"]
    }
    current_data=pd.DataFrame.from_dict(extracted_data)
    return current_data
api_key = "0de7454df1e38fb4c2847b0a32bbac8d"
cities = ['Cotonou', 'Abomey-Calavi', 'Porto-Novo', 'Parakou', 'Djougou', 'Bohicon', 'Natitingou',
          'Savè', 'Abomey', 'Nikki', 'Lokossa', 'Ouidah', 'Dogbo-Tota', 'Kandi',
          'Covè', 'Malanville', 'Pobè', 'Kérou', 'Savalou', 'Sakété', 'Comè',
          'Bembéréké', 'Bassila', 'Banikoara', 'Kétou', 'Dassa-Zoumè', 'Tchaourou', 'Allada',
          'Aplahoué', 'Tanguiéta', 'N\'Dali', 'Ségbana', 'Athiémé', 'Grand Popo', 'Kouandé',

          ]
city= "Cotonou"
df = get_current_weather(city,api_key)
if st.button('PREDICTION SUR DONNEES COURANTES'):
    predictions = svr_model.predict(df).astype(int)

    st.write(predictions)