# following works using 
#R version 4.5.2 (2025-10-31 ucrt)
library(tigris)
library(tidycensus)
library(tigris)
library(tidycensus)
library(getACS)
library(gt)
library(ggplot2)
library(dplyr)
library(SuperLearner)



#seemingly not needed
# library(sf)
#library(lubridate)

#likely code for API key (DOES NOT WORK) (Correct API key)
#census_api_key(8386e8e51773225606d057764b1c51da0618d67b)


#Creates a table for each census variable in CVS with the data column named the same
CCs <- read.csv("Data/CensusCodes.csv")
n <- nrow(CCs)


Temp <- get_acs_ts(
  geography = "county",
  variables = "B19065_001",
  year = c(2024),
  survey = "acs5",
  geometry = FALSE
  
)
Census_Data <- Temp %>% select(-c(variable,column_id,table_id,estimate,moe,perc_estimate,perc_moe,table_title,simple_table_title,subject_area,universe,denominator_column_id,topics,line_number,column_id,indent,parent_column_id,denominator_column_id,denominator_estimate,denominator_moe,denominator_column_title, column_title))
# Creates a table for each census variable in CSV, renames data columns appropriately, adds to Census_Data

for (i in seq_len(n)) {
  ID <- CCs$CensusID[i]
  nm <- as.character(CCs$Name[i])
  #gets data
  assign(nm,get_acs_ts(
    geography = "county",
    variables = ID,
    year = c(2024),
    survey = "acs5",
    geometry = FALSE))
  
  #gets the newly created table & creates NAME_moe with table name TT
  TT <- get(nm)
  moe <- paste0(nm,"_moe")
  #renames estimate and moe in new table to NAME and NAME_moe
  TT <- TT %>% rename(!!sym(nm):= 'estimate',!!sym(moe) := 'moe')
  #add new data columns to Census_Data
  Census_Data <- Census_Data %>% left_join(TT %>% select(NAME,all_of(nm),all_of(moe),year), by = c("NAME","year"))
  #renames TT to NAME
  assign(nm,TT)
}

# Overdoses from wonder 
ODs_W <- read.csv('Data/Multiple Cause of Death, 2018-2024, Single Race.csv')
ODs_W <- ODs_W %>% mutate(County =  gsub('..$', '',County))
ODs_W <- ODs_W %>% mutate(NAME = paste0(County, State))
ODs_W <- ODs_W %>% rename(year = Year)

Census_Data <- Census_Data %>% left_join(ODs_W %>% select(NAME,year,Deaths,Crude.Rate), by = c("NAME","year"))

#export
write.csv(Census_Data, 'Data/Census_Data.csv', row.names = FALSE)

