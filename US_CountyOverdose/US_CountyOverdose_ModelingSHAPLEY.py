import sys
if sys.prefix == r"C:\Users\ellis\miniconda3\envs\GeoShply_OD":
    print('virtual environment is correct')
else: print('WRONG VIRTUAL ENVIRONMENT')

#packages
import random
import os
import geopandas as gpd
import pandas as pd
from sklearn.model_selection import train_test_split
import xgboost as xgb
import shap
from sklearn.neural_network import MLPRegressor

#set working directory
os.chdir(r'C:\Users\ellis\OneDrive\Desktop\School\Research\US_CountyOverdose')

#               Gets & readies testing data
Data = pd.read_csv(r"Data\Census_Data.csv")

#Not using geometry yet
#Data = gpd.GeoDataFrame(
 #   Data, crs="EPSG:32610", geometry=gpd.points_from_xy(x=Sea.UTM_X, y=Sea.UTM_Y))

#creates smaller sample
Data = Data.sample(n = 400, random_state = 1)
 
#Adds synthetic data for missing overdose values
random.seed(1)
for index, value in Data['Deaths'].items():
    if pd.isna(value):
        Data.loc[index, "Deaths"] = random.randint(0,9)
   

Data.to_csv('Data\Census_Data_Random.csv', index = False)

print("Data Ready")


#Sets up and fits model(s)
y = Data.Deaths
X = Data[['AggSSInc']]
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1)


#XG boost
xgb_model = xgb.XGBRegressor(objective='reg:squarederror',n_estimators=100, random_state=1)
xgb_model.fit(X_train, y_train)


print("Model(s) Fitted")
#Specify a small data set
background = X_train.sample(100)

#Shapley explaining xgboost 
explainer = shap.TreeExplainer(xgb_model, feature_perturbation="tree_path_dependent")
shap_values = explainer(X_test)
shap.plots.beeswarm(shap_values)

