###########################################################
## An intro to time series forecasting with ARIMA        ##
## R Ladies London 24 October 2019 workshop              ##
## Sample code by julia.shen1@lshtm.ac.uk                ##
###########################################################


### 0.  Load required packages + data and set filepath  ###

# install.packages(c('tidyverse', 'forecast', 'here'))

library(tidyverse) 
library(forecast)
library(here)

# set_here() # sets filepath to folder currently containing this script

data_orig <- read.csv(here::here('ARIMA-intro.csv')) # load example data


### 1. Clean up date formats for an analysis file   ###

str(data_orig) # examine data structure
levels(data_orig$�..month) # note "�..month" imported as an icky factor var

# specify a new date variable with day-month-year to replace the disaggregated factor vars
# nb NHS sitrep data from last Thursday of each month, so pick arbitrary consistent date 24
# nb Green et al (2017) analysis is based on 2010/08 to 2015/03, as reflected in plots etc

data_use <- data_orig %>% 
  mutate(�..month=as.character(�..month)) %>%  # change factor var to a string
  mutate(date=paste0('24', �..month, year, sep = "", collapse = NULL)) %>% #combine strings
  mutate(date=as.Date(date, "%d%B%Y")) # convert string to date

# str(data_use) # check this worked and some cleanup below

data_use <- data_use %>% 
  select(-�..month, -year)

rm(data_orig)


### 2. Create some analysis variables and look at summary descriptives   ###

data_use <- data_use %>%   
  mutate(annual_mort = out_deaths_total * 1000 / ONS_pop_est,  
         dtoc_days_rate = exp_days_dtoc * 1000 / ONS_pop_est,
         dtoc_pts_rate = exp_patients_dtoc * 100000 / ONS_pop_est, 
         dtoc_days_percapita = exp_days_dtoc / exp_patients_dtoc, 
         prop_acute_days = exp_days_acute / exp_days_dtoc, 
         prop_acute_patients = exp_patients_acute / exp_patients_dtoc)

summary(data_use) # note data descriptives, and also the NAs. What data are missing?

# data_use <- data_use %>%
#   filter(!is.na(ONS_pop_est)) # if you want to drop 8 missing obs in 2019 


### 3. Explore descriptive plots  ###

# Examine trends in absolute COUNTS over time for the exposures and outcome of interest
# for DAYS of delayed transfers of care vs. deaths
ggplot(data=data_use, aes(x=date)) +
  ggtitle("Trends in English mortality and NHS DAYS delayed") +
    geom_line(aes(y=out_deaths_total), color="darkred") +
  geom_line(aes(y=exp_days_dtoc), color="black") +
  geom_line(aes(y=exp_days_acute), color="black", linetype="longdash") +
  geom_line(aes(y=exp_days_nonacute), color="black", linetype="dotted") +
  xlab("Time") + ylab("Total counts of deaths and dtoc days") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")

# for PATIENTS with dtocs vs. deaths
ggplot(data=data_use, aes(x=date)) +
  ggtitle("Trends in English mortality and NHS PATIENTS delayed") +
  geom_line(aes(y=out_deaths_total), color="darkred") + # nb could rescale deaths here for viz
  geom_line(aes(y=exp_patients_dtoc), color="blue") +
  geom_line(aes(y=exp_patients_acute), color="blue", linetype="longdash") +
  geom_line(aes(y=exp_patients_nonacute), color="blue", linetype="dotted") +
  xlab("Time") + ylab("Total counts of deaths and dtoc patients") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")

# Examine seasonal "trends" in per capita days hospitalised (days of delay per patient delayed)
ggplot(data=data_use, aes(x=date)) +
  geom_line(aes(y=dtoc_days_percapita), color="darkblue", linetype="dotdash") +
  xlab("Time") + ylab("Mean days of delay per hospitalised patient") + 
  scale_x_date(minor_breaks=seq(as.Date("2010/08/24"), as.Date("2019/08/24"), by="months"), 
               breaks=seq(as.Date("2010/08/24"), as.Date("2019/08/24"), by="quarter")) + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen") + 
  theme(axis.text.x = element_blank())
#... After inspecting this as well as the table, perhaps find that values are suspiciously round
#... Note nevertheless global dips during end-of-year (holidays)


# Examine the created analysis vars to assess summary change in RISK over time
# The below is constant for population growth and thus (crudely) factors in demographics
ggplot(data=data_use, aes(x=date, y=c(annual_mort, dtoc_days_rate, dtoc_pts_rate))) +
  ggtitle("Trend in English risk RATES") +
  geom_line(aes(y=annual_mort), color="darkred", linetype="dotdash") +
  geom_line(aes(y=dtoc_days_rate), color="black", linetype="dotdash") +
    xlab("Time") + ylab("Mortality (red) and DTOC days (black) per 1000 pop.") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")

ggplot(data=data_use, aes(x=date, y=c(annual_mort, dtoc_days_rate, dtoc_pts_rate))) +
  ggtitle("Trend in English RISK RATES") +
  geom_line(aes(y=annual_mort*10), color="darkred", linetype="dotdash") + #nb scale factor for viz
  geom_line(aes(y=dtoc_pts_rate), color="blue", linetype="dotdash") +
  xlab("Time") + ylab("Mortality (red) per 10000 pop. and DTOC patients (blue) per 100000 pop.") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")


### 4. Create time series objects and examine potential seasonality in plots  ###

# Cut a version of the dataset from Green et al paper, to test replication
data_green <- data_use %>% 
  filter(date<"2016-04-24")

# Create some time series objects
#... Specify a monthly time series for DTOC days and deaths, starting from August 2010
ts_dtocdays_all <- ts(data_use$exp_days_dtoc, frequency=12, start=c(2010, 8))
ts_deaths_all <- ts(data_use$out_deaths_total, frequency=12, start=c(2010, 8))
#... Do the same for the retrospective Green 'training' data
ts_dtocdays_green <- ts(data_green$exp_days_dtoc, frequency=12, start=c(2010, 8))
ts_deaths_green <- ts(data_green$out_deaths_total, frequency=12, start=c(2010, 8))

# In principle, one can use tsclean() to identify & smooth outliers but this doesn't apply here
# tsclean(ts_dtocdays_all)

# Generate MOVING AVERAGES for any time series and see how this smooths trends
#... for deaths as outcome of interest
data_use$deaths_ma_q = ma(data_use$out_deaths_total, order=4)
data_use$deaths_ma_y = ma(data_use$out_deaths_total, order=12)

ggplot(data=data_use, aes(x=date)) +
  ggtitle("Deaths in England, monthly snapshot vs quarterly and annual moving average") +
  geom_line(aes(y=out_deaths_total), color="darkred") +
  geom_line(aes(y=deaths_ma_q), color="darkred", linetype="longdash") +
  geom_line(aes(y=deaths_ma_y), color="darkred", linetype="twodash") +
  xlab("Time") + ylab("Deaths") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")

#... for DTOC days as exposure
data_use$dtoc_days_ma_q = ma(data_use$exp_days_dtoc, order=4)
data_use$dtoc_days_ma_y = ma(data_use$exp_days_dtoc, order=12)

ggplot(data=data_use, aes(x=date)) +
  ggtitle("NHS DAYS delayed, monthly snapshot vs quarterly and annual moving average") +
  geom_line(aes(y=exp_days_dtoc), color="black") +
  geom_line(aes(y=dtoc_days_ma_q), color="black", linetype="longdash") +
  geom_line(aes(y=dtoc_days_ma_y), color="black", linetype="twodash") +
  xlab("Time") + ylab("DTOC days") + 
  geom_vline(aes(xintercept = as.numeric(as.Date("2015/03/24"))), color="darkgreen")


# Seasonal plots also help to assess trend
ggseasonplot(ts_deaths_all, year.labels=TRUE, year.labels.left=TRUE) +
  ylab("Count of deaths") + ggtitle("Seasonal plot: deaths in England")

ggseasonplot(ts_dtocdays_all, year.labels=TRUE, year.labels.left=TRUE) +
  ylab("Count of days delayed in transfers of care") + ggtitle("Seasonal plot: days of DTOCs in England")

# A nice alternative view of the above data
ggseasonplot(ts_deaths_all, polar=TRUE) +
  ylab("Count of deaths") + ggtitle("Polar seasonal plot: deaths in England")

ggseasonplot(ts_dtocdays_all, polar=TRUE) +
  ylab("Count of days delayed in transfers of care") + ggtitle("Polar seasonal plot: days of DTOCs in England")


# optionally, explore...
# ts_dtoc_days_acute <- ts(data_use$exp_days_acute, frequency=12, start=c(2010, 8))
# ts_dtoc_patients <- ts(data_use$exp_patients_dtoc, frequency=12, start=c(2010, 8))
# ts_dtoc_patients_acute <- ts(data_use$exp_patients_acute, frequency=12, start=c(2010, 8))


### 5. Decompose the exposure and outcome time series of interest  ###

# Decompose the death outcome of interest
#... Method 1a using decompose with additive model
decomp_deaths_add <- 
  decompose(ts_deaths_all, type="additive") 
plot(decomp_deaths_add)

#... Method 1b using decompose with multiplicative model
decomp_deaths_mult <- 
  decompose(ts_deaths_all, type="multiplicative") 
plot(decomp_deaths_mult)

#... Alternative method 2 using stl()
stl_deaths <- 
  stl(ts_deaths_all, s.window="periodic") 
autoplot(stl_deaths)


# Decompose the days of DTOC exposure
decomp_dtocdays_all <- 
  decompose(ts_dtocdays_all, type="additive") 
plot(decomp_dtocdays_all)


### 6. Evaluate stationarity of the time series  ###

# Looking at the raw data (0 differences), the ACF/PACF plots and stats test show clear problems
Acf(ts_deaths_all, lag.max = NULL, type = c("correlation", "covariance",
                                "partial"), plot = TRUE, na.action = na.contiguous, demean = TRUE)
Pacf(ts_deaths_all, lag.max = NULL, plot = TRUE, na.action = na.contiguous, demean = TRUE)
ts_deaths_all %>% ggtsdisplay() # summary view across data, Acf, and Pacf
Box.test(diff(ts_deaths_all), lag=12, type="Ljung-Box")

# For NONSEASONAL data, ndiffs() can be used to evaluate usefulness of differencing 
# ndiffs(ts_deaths_all, alpha = 0.05, test = c("kpss", "adf", "pp"),
#        type = c("level", "trend"), max.d = 2)

# Here, let's take a seasonal (monthly) difference to try to get to more stationary data
ts_deaths_all %>% diff(lag=12) %>% ggtsdisplay() # set a lag of 12 to reflect monthly seasonality
ts_deaths_all %>% diff(lag=12) %>% diff() %>% ggtsdisplay() # differencing=2 doesn't seem to change much


### 7. Fit ARIMA models using auto.arima including some forward forecasts  ###

# Univariate time series models from machine-automated selection
fit_deaths_all <- ts_deaths_all %>%
  auto.arima()
fit_deaths_all

fit_deaths_all %>% forecast(h=12) %>%  autoplot()

fit_deaths_green <- ts_deaths_green %>%
  auto.arima()
fit_deaths_green

fit_deaths_green %>% forecast(h=12) %>%  autoplot()


### 8. Check fit and predictiveness, refining as needed  ###

# What about residuals of the univariate ARIMA models?
checkresiduals(fit_deaths_all)
checkresiduals(fit_deaths_green)

refit_deaths_all <- ts_deaths_all %>%
  auto.arima(approximation=FALSE)
refit_deaths_all # we see that approximation in the algo isn't the root issue

refit_deaths_green <- ts_deaths_green %>% 
  auto.arima(approximation=FALSE)
refit_deaths_green # ditto for Green et al's analysis
  
autoplot(refit_deaths_all)
autoplot(refit_deaths_green)
# Maybe we decide to live with the fit as-is, unless we have other data on cause of difference?
  

### 9. Extend to regression between different time-series  ###

# Specify the acute days time-series, as found by Green et al
ts_acutedays_all <- ts(data_use$exp_days_acute, frequency=12, start=c(2010, 8))
ts_acutedays_green <- ts(data_green$exp_days_acute, frequency=12, start=c(2010, 8))

# Regress the two time-series
regress_green_auto <- auto.arima(ts_deaths_green, xreg=ts_acutedays_green, allowdrift=TRUE)
regress_green_auto

# Alternatively one could manually specify as below based on the best-fit UNIVARIATE model
regress_green_manual <- Arima(ts_deaths_green, xreg=ts_acutedays_green, 
                       order=c(0,0,0), seasonal=c(1,1,0),
                       include.drift=TRUE)
regress_green_manual # these estimates still differ from the JECH article

# What happens when we include 41 more months of data?
regress_all_auto <- auto.arima(ts_deaths_all, xreg=ts_acutedays_all, allowdrift=TRUE)
regress_all_auto

# Check that the automatic ARIMA regression residuals look like white noise/random walk (2nd plot)
cbind("Regression Errors" = residuals(regress_all_auto, type="regression"),
      "ARIMA errors" = residuals(regress_all_auto, type="innovation")) %>%
  autoplot(facets=TRUE)

# What do forecasts look like if DTOCs are unchanged in future?
regress_all_auto %>% forecast(xreg = ts_acutedays_all, h=12) %>%  autoplot()
