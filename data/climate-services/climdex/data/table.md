|Short name| Long name |Definition|Plain language description|Units|Time scale|Sector(s)|
|---|---|---|---|---|---|---|
|FD|Frost Days|Number of days when TN < 0 °C|Days when minimum temperature is below 0°C|days|Mon/Ann|H, AFS|
|TNlt2|TN below 2°C|Number of days when TN < 2 °C|Days when minimum temperature is below 2°C|days|Mon/Ann|AFS|
|TNltm2|TN below -2°C|Number of days when TN < -2 °C|Days when minimum temperature is below -2°C|days|Mon/Ann|AFS|
|TNltm20|TN below -20°C|Number of days when TN < -20 °C|Days when minimum temperature is below -20°C|days|Mon/Ann|H, AFS|
|ID|Ice Days|Number of days when TX < 0 °C|Days when maximum temperature is below 0°C|days|Mon/Ann|H, AFS|
|SU|Summer days|Number of days when TX > 25 °C|Days when maximum temperature exceeds 25°C|days|Mon/Ann|H|
|TR|Tropical nights|Number of days when TN > 20 °C|Days when minimum temperature exceeds 20°C|days|Mon/Ann|H,AFS|
|GSL|Growing Season Length|Annual number of days between the first occurrence of 6 consecutive days with TM > 5 °C and the first occurrence of 6 consecutive days with TM < 5 °C|Length of time in which plants can grow|days|Ann|AFS|
|TXx|Max TX|Warmest daily TX|Hottest day|°C|Mon/Ann|AFS|
|TNn|Min TN|Coldest daily TN|Coldest night|°C|Mon/Ann|AFS|
|WSDI|Warm spell duration indicator|Annual number of days contributing to events where 6 or more consecutive days experience TX > 90th percentile|Number of days contributing to a warm period (where the period has to be at least 6 days long)|days|Ann|H, AFS, WRH|
|WSDId|User-defined WSDI|Annual number of days contributing to events where d or more consecutive days experience TX > 90th percentile|Number of days contributing to a warm period (where the minimum length is user-specified)|days|Ann|H, AFS, WRH|
|CSDI|Cold spell duration indicator|Annual number of days contributing to events where 6 or more consecutive days experience TN < 10th percentile|Number of days contributing to a cold period (where the period has to be at least 6 days long)|days|Ann|H, AFS|
|CSDId|User-defined CSDI|Annual number of days contributing to events where d or more consecutive days experience TN < 10th percentile|Number of days contributing to a cold period (where the minimum length is user-specified)|days|Ann|H, AFS, WRH|
|TXgt50p|Fraction of days with temperatures above the median|Percentage of days where TX > 50th percentile|Fraction of days with above-median temperature|%|Mon/Ann|H, AFS, WRH|
|TX95t|Very warm day threshold|Value of 95th percentile of TX|A threshold where days above this temperature would be classified as very warm|°C|Daily|H, AFS|
|TMge5|TM of at least 5°C|Number of days when TM >= 5 °C|Days when average temperature is at least 5°C|days|Mon/Ann|AFS|
|TMlt5|TM below 5°C|Number of days when TM < 5 °C|Days when average temperature is below 5°C|days|Mon/Ann|AFS|
|TMge10|TM of at least 10°C|Number of days when TM >= 10 °C|Days when average temperature is at least 10°C|days|Mon/Ann|AFS|
|TMlt10|TM below 10°C|Number of days when TM < 10 °C|Days when average temperature is below 10°C|days|Mon/Ann|AFS|
|TXge30|TX of at least 30°C|Number of days when TX >= 30 °C|Days when maximum temperature is at least 30°C|days|Mon/Ann|H, AFS|
|TXge35|TX of at least 35°C|Number of days when TX >= 35 °C|Days when maximum temperature is at least 35°C|days|Mon/Ann|H, AFS|
|TXdTNd|User-defined consecutive number of hot days and nights|Annual count of d consecutive days where both TX > 95th percentile and TN > 95th percentile, where 10 >= d >= 2|Total consecutive hot days and hot nights (where consecutive periods are user-specified)|events|Ann|H, AFS, WRH|
|HDDheatn|Heating Degree Days|Annual sum of n - TM (where n is a user-defined location-specific base temperature and TM < n)|A measure of the energy demand needed to heat a building|degree-days|Ann|H|
|CDDcoldn|Cooling Degree Days|Annual sum of TM - n (where n is a user-defined location-specific base temperature and TM > n)|A measure of the energy demand needed to cool a building|degree-days|Ann|H|
|GDDgrown|Growing Degree Days|Annual sum of TM - n (where n is a user-defined location-specific base temperature and TM > n)|A measure of heat accumulation to predict plant and animal developmental rates|degree-days|Ann|H, AFS|
|CDD|Consecutive Dry Days|Maximum number of consecutive dry days (when PR < 1.0 mm)|Longest dry spell|days|Ann|H, AFS, WRH|
|R20mm|Number of very heavy rain days|Number of days when PR >= 20 mm|Days when rainfall is at least 20mm|days|Mon/Ann|AFS, WRH|
|PRCPTOT|Annual total wet-day PR|Sum of daily PR >= 1.0 mm|Total wet-day rainfall|mm|Mon/Ann|AFS, WRH|
|R95pTOT|Contribution from very wet days|100*r95p / PRCPTOT|Fraction of total wet-day rainfall that comes from very wet days|%|Ann|AFS, WRH|
|R99pTOT|Contribution from extremely wet days|100*r99p / PRCPTOT|Fraction of total wet-day rainfall that comes from extremely wet days|%|Ann|AFS, WRH|
|RXdday|User-defined consecutive days PR amount|Maximum d-day PR total|Maximum amount of rain that falls in a user-specified period|mm|Mon/Ann|H, AFS, WRH|
|SPI|Standardised Precipitation Index|Measure of “drought” using the Standardised Precipitation Index on time scales of 3, 6 and 12 months. See [McKee et al. (1993)](#appendixa_refs) and the [WMO SPI User guide (World Meteorological Organization, 2012)](#appendixa_refs) for details.<br>Calculated using the [SPEI R package](https://cran.r-project.org/web/packages/SPEI/index.html).|A drought measure specified as a precipitation deficit|unitless|Custom|H, AFS, WRH|
|SPEI|Standardised Precipitation Evapotranspiration Index|Measure of “drought” using the Standardised Precipitation Evapotranspiration Index on time scales of 3, 6 and 12 months. See [Vicente-Serrano et al. (2010)](#appendixa_refs) for details.<br>Calculated using the [SPEI R package](https://cran.r-project.org/web/packages/SPEI/index.html).|A drought measure specified using precipitation and evaporation|unitless|Custom|H, AFS, WRH|
|TXbdTNbd|User-defined consecutive number of cold days and nights|Annual number of d consecutive days where both TX < 5th percentile and TN < 5th percentile, where 10 >= d >=2|Total consecutive cold days and cold nights (where consecutive periods are user-specified)|events|Ann|H, AFS, WRH|
|DTR|Daily Temperature Range|Mean difference between daily TX and daily TN|Average range of maximum and minimum temperature|°C|Mon/Ann||
|TNx|Max TN|Warmest daily TN|Hottest night|°C|Mon/Ann||
|TXn	|Min TX|Coldest daily TX|Coldest day|°C|Mon/Ann||
|TMm|Mean TM|Mean daily mean temperature|Average daily temperature|°C|Mon/Ann||
|TXm|Mean TX|Mean daily maximum temperature|Average daily maximum temperature|°C|Mon/Ann||
|TNm|Mean TN|Mean daily minimum temperature|Average daily minimum temperature|°C|Mon/Ann||
|TX10p|Amount of cool days|Percentage of days when TX < 10th percentile|Fraction of days with cool day time temperatures|%|Ann||
|TX90p|Amount of hot days|Percentage of days when TX > 90th percentile|Fraction of days with hot day time temperatures|%|Ann||
|TN10p|Amount of cold nights|Percentage of days when TN < 10th percentile|Fraction of days with cold night time temperatures|%|Ann||
|TN90p|Amount of warm nights|Percentage of days when TN > 90th percentile|Fraction of days with warm night time temperatures|%|Ann||
|CWD|Consecutive Wet Days|Maximum annual number of consecutive wet days (when PR >= 1.0 mm)|The longest wet spell|days|Ann||
|R10mm|Number of heavy rain days|Number of days when PR >= 10 mm|Days when rainfall is at least 10mm|days|Mon/Ann||
|Rnnmm|Number of customised rain days|Number of days when PR >= nn|Days when rainfall is at least a user-specified number of mm|days|Mon/Ann||
|SDII|Daily PR intensity|Annual total PR divided by the number of wet days (when total PR >= 1.0 mm)|Average daily wet-day rainfall intensity|mm/day|Ann||
|R95p|Total annual PR from heavy rain days|Annual sum of daily PR > 95th percentile|Amount of rainfall from very wet days|mm|Ann||
|R99p|Total annual PR from very heavy rain days|Annual sum of daily PR > 99th percentile|Amount of rainfall from extremely wet days|mm|Ann||
|Rx1day|Max 1-day PR|Maximum 1-day PR total|Maximum amount of rain that falls in one day|mm|Mon/Ann||
|Rx5day|Max 5-day PR|Maximum 5-day PR total|Maximum amount of rain that falls in five consecutive days|mm|Mon/Ann|
|HWN(EHF/Tx90/Tn90)|Heatwave number (HWN) as defined by either the Excess Heat Factor (EHF), 90th percentile of TX or the 90th percentile of TN|The number of individual heatwaves that occur each summer (Nov – Mar in southern hemisphere and May – Sep in northern hemisphere). A heatwave is defined as 3 or more days where either the EHF is positive, TX > 90th percentile of TX or where TN > 90th percentile of TN. Where percentiles are calculated from base period specified by user.|See Appendix D and [Perkins and Alexander (2013)](#appendixa_refs) for more details.|Number of individual heatwaves events|Ann|H, AFS, WRH|
|HWF(EHF/Tx90/Tn90)|Heatwave frequency (HWF) as defined by either the Excess Heat Factor (EHF), 90th percentile of TX or the 90th percentile of TN|The number of days that contribute to heatwaves as identified by HWN.|See Appendix D and [Perkins and Alexander (2013)](#appendixa_refs) for more details.|days|Ann|H, AFS, WRH|
|HWD(EHF/Tx90/Tn90)|Heatwave duration (HWD) as defined by either the Excess Heat Factor (EHF), 90th percentile of TX or the 90th percentile of TN|The length of the longest heatwave identified by HWN.|See Appendix D and [Perkins and Alexander (2013)](#appendixa_refs) for more details.|days|Ann|H, AFS, WRH|
|HWM(EHF/Tx90/Tn90)|Heatwave magnitude (HWM) as defined by either the Excess Heat Factor (EHF), 90th percentile of TX or the 90th percentile of TN|The mean temperature of all heatwaves identified by HWN.|See Appendix D and [Perkins and Alexander (2013)](#appendixa_refs) for more details.|°C (°C^2 for  EHF)|Ann|H, AFS, WRH|
|HWA(EHF/Tx90/Tn90)|Heatwave amplitude (HWA) as defined by either the Excess Heat Factor (EHF), 90th percentile of TX or the 90th percentile of TN|The peak daily value in the hottest heatwave (defined as the heatwave with highest HWM).|See Appendix D and [Perkins and Alexander (2013)](#appendixa_refs) for more details.|°C (°C^2 for  EHF)|Ann|H, AFS, WRH|
|CWN_ECF|Coldwave number (CWN) as defined by the Excess Cold Factor (ECF).|The number of individual ‘coldwaves’ that occur each year.|See Appendix D and [Nairn and Fawcett (2013)](#appendixa_refs) for more information.|events|Ann|H, AFS, WRH|
|CWF_ECF|Coldwave frequency (CWF) as defined by the Excess Cold Factor (ECF).|The number of days that contribute to ‘coldwaves’ as identified by ECF_HWN.|See Appendix D and [Nairn and Fawcett (2013)](#appendixa_refs) for more information.|days|Ann|H, AFS, WRH|
|CWD_ECF|Coldwave duration (CWD) as defined by the Excess Cold Factor (ECF).|The length of the longest ‘coldwave’ identified by ECF_HWN.|See Appendix D and [Nairn and Fawcett (2013)](#appendixa_refs) for more information.|days|Ann|H, AFS, WRH|
|CWM_ECF|Coldwave magnitude (CWM) as defined by the Excess Cold Factor (ECF).|The mean temperature of all ‘coldwaves’ identified by ECF_HWN.|See Appendix D and [Nairn and Fawcett (2013)](#appendixa_refs) for more information.|°C^2|Ann|H, AFS, WRH|
|CWA_ECF|Coldwave amplitude (CWA) as defined by the Excess Cold Factor (ECF).|The minimum daily value in the coldest ‘coldwave’ (defined as the coldwave with lowest ECF_HWM).|See Appendix D and [Nairn and Fawcett (2013)](#appendixa_refs) for more information.|°C^2|Ann|H, AFS, WRH|