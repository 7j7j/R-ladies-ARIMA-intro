# R-ladies-ARIMA-intro
Files supporting R Ladies London workshop 24.10.2019 by Julia Shen <br>
Please send questions & comments to julia.shen1 (at) lshtm (dot) ac (dot) uk

# Required packages
<b>forecast</b>: we will use the <b>forecast::arima</b> wrapper and related functions in this package, which enhance the <b>base::arima</b> function included in the default R <b>stats</b> library <br>
<b>tidyverse</b>: recommended if not strictly necessary for practical exercises, though my tidying + dataviz processes use <b>dplyr</b>, <b>ggplot2</b>, etc <br>
<b>here</b>: used for easier filepaths


# Directory
1) Case DATA in <b>"ARIMA-intro.csv"</b> <br>
2) ... with more contextual metadata and calculations in <b>"ARIMA-intro-meta.xls"</b> <br>
3) Case CODE in <b>"ARIMA-intro.R"</b> <br>
4) Contextual and theoretical SLIDES, including important fundamentals of underlying statistical theory, in <b>"ARIMA-slides.pdf"</b> including a list of references and further useful reading <br> 
5) Original inspiration for this practice case comes from Mark Green et al's article "Could the rise in mortality rates since 2015 be explained by changes in the number of delayed discharges of NHS patients?" <br>
in the <i>BMJ Journal of Epidemiology & Community Health</i> at https://jech.bmj.com/content/71/11/1068 <br>
... with many thanks to Mark at the University of Liverpool, and co-authors Danny Dorling, Jonathan Minton, and Kate E. Pickett for the applied example in English health geography that surfaces such important and interesting policy questions about service performance and equity. <br>

6) This README.md + MIT license for open-access, attributed usage of these materials - please minimise commercial gatekeeping


# Original data sources for England
1) ONS, Mid-year population estimates: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland <br>
2) ONS, Deaths registered monthly in England and Wales: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland <br>
3) NHS England and NHS Improvement, Delayed Transfers of Care (DTOCs) from August 2010 - present: https://www.england.nhs.uk/statistics/statistical-work-areas/delayed-transfers-of-care/<br>

# Acknowledgments
- Cheers for the R Ladies London team for collegial peer review and organisation, especially Emma Vestesson (@emmavestesson). <br>
- Brava to Ruslana Dalinina for an excellent model ARIMA tutorial at https://blogs.oracle.com/datascience/introduction-to-forecasting-with-arima-in-r <br>
... and bravos to Rob J Hyndman & George Athanasopoulos for their open textbook <i>Forecasting: Principles and Practice</i> at https://otexts.com/fpp2/ <br>
- Many thanks to the Health Foundation, UK Economic & Social Research Council, and LSHTM Public Health & Policy faculty, for funding and hosting me.
