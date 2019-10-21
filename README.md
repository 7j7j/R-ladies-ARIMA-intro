# R-ladies-ARIMA-intro
Files supporting R Ladies London workshop 24.10.2019 by Julia Shen <br>
Please send questions & comments to julia.shen1 (at) lshtm (dot) ac (dot) uk

# Required packages
<b>forecast</b>: we will use the <b>forecast::arima</b> wrapper and related functions in this package, which enhance the <b>base::arima</b> function included in the default R stats package <br>
<b>tidyverse</b>: recommended, not strictly necessary for practical exercises, though my data tidying and visualisation use dplyr, ggplot2, etc

# Directory
1) Case DATA in <b>"ARIMA-intro.csv"</b> <br>
2) Case CODE in <b>"ARIMA-intro.R"</b> <br>
3) Contextual and theoretical SLIDES, including important fundamentals of underlying statistical theory, in <b>"ARIMA-slides.html"</b> including a list of references and further useful reading <br>
4) Original inspiration for this practical case comes from Mark Green et al's article "Could the rise in mortality rates since 2015 be explained by changes in the number of delayed discharges of NHS patients?" <br>
in the BMJ Journal of Epidemiology & Community Health at https://jech.bmj.com/content/71/11/1068 <br>
... with many thanks to Mark at the University of Sheffield (https://www.researchgate.net/profile/Mark_Green10), and co-authors Danny Dorling, Jonathan Minton, and Kate E Pickett for the applied case in English health equity that surfaces such important and interesting policy questions <br>

5) This README.md + MIT license for open-access, attributed usage of these materials - please minimise commercial gatekeeping


# Original data sources for England
1) ONS, Mid-year population estimates: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland <br>
2) ONS, Deaths registered monthly in England and Wales: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland <br>
3) NHS England and NHS Improvement, Delayed Transfers of Care (DTOCs) from August 2010 - present: https://www.england.nhs.uk/statistics/statistical-work-areas/delayed-transfers-of-care/<br>

# Acknowledgments
- Cheers for the R Ladies London team for collegially peer-reviewing and organising this workshop, especially Emma Vestesson. <br>
- Brava to Ruslana Dalinina for an excellent model ARIMA tutorial at https://blogs.oracle.com/datascience/introduction-to-forecasting-with-arima-in-r <br>
... and bravos to Rob J Hyndman & George Athanasopoulos for their open textbook <i>Forecasting: Principles and practice</i> at https://otexts.com/fpp2/ <br>
- Many thanks to the Health Foundation and UK Economic & Social Research Council, and LSHTM Public Health & Policy faculty for funding and hosting me.
