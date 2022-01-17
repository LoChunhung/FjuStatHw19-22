# Step 1. Before Data Pre-processing
#pkgs <- c("magrittr", "dplyr","tidyr","readr")
#install.packages(pkgs)
library(magrittr)
library(dplyr)
library(tidyr)
library(readr)

# Step 2. Determine the sampling period
SDt <- as.Date("2019-12-31")
EDt <- as.Date("2021-12-31")
allDates <- seq.Date( SDt, EDt, "day")

# Step 3. Load specific stock data- 1303.TW 
tejdb_1303_2Y <- read_csv("Dataset/tejdb_1303_2Y.csv", col_types = cols(Stock_Date = col_date(format = "%Y/%m/%d")))
View(tejdb_1303_2Y)

##Check missing date and value. Calculate the daily change (Daily Return) 

new_1303 <- tejdb_1303_2Y %>%
  complete(Stock_Date = seq.Date(min(Stock_Date), max(Stock_Date), by="day")) %>%
  fill('Close_1303') %>%
  arrange(desc(Stock_Date)) %>%
  mutate(ReturnStk = (Close_1303 - lead(Close_1303)) / lead(Close_1303)*100)        

# Step 4. Load risk-free yield curve- 10 Year bond benchmark interest rate

##Check missing date and change bond yield rate base converted to daily (360) from yearly.

tejdb_10YGB_2Y <- read_csv("Dataset/tejdb_10ybond_2y.csv", col_types = cols(GB_Date = col_date(format = "%Y/%m/%d")))
new_tejdb_10YGB_2Y <- tejdb_10YGB_2Y %>%
  complete(GB_Date = seq.Date(min(GB_Date), max(GB_Date), by="day")) %>%
  mutate(Return_Rfree = (Return_Rfree /360)) %>%
  fill('Return_Rfree') %>%
  arrange(desc(GB_Date))

# Step 5. Load Brent Oil Future Price

tejdb_BrentF_2y <- read_csv("Dataset/tejdb_BrentFuture_2y.csv", col_types = cols(BrentF_Date = col_date(format = "%Y/%m/%d")))

##Check missing date, add new field ChangeOil represent daily change by Brent Oil Future
new_tejdb_BrentF_2y <- tejdb_BrentF_2y %>%
  complete(BrentF_Date = seq.Date(min(BrentF_Date), max(BrentF_Date), by="day")) %>%
  fill('Price') %>%
  arrange(desc(BrentF_Date)) %>%
  mutate(ChangeOil = (Price - lead(Price)) / lead(Price)*100)
  
# Step 6. Make merge three data-sets left join on stock date.

MyData <- new_1303 %>% 
  left_join(new_tejdb_10YGB_2Y,  by = c("Stock_Date" = "GB_Date")) %>% 
  left_join(new_tejdb_BrentF_2y, by = c("Stock_Date" = "BrentF_Date")) %>% 
  filter(row_number() <= n()-1) %>% 
  arrange(Stock_Date) %>% 
  mutate(Return_E = (ReturnStk -Return_Rfree))

# Step 7. One factor analysis
model=lm(Return_E ~ ChangeOil, data = MyData)
summary(model)
plot(MyData$ChangeOil,MyData$Return_E)
abline(lm(Return_E ~ ChangeOil, data = MyData))

