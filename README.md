REDCap Repeating Instrument Table Splitter
===========================================

Paul W. Egeler, M.S., GStat  
Spectrum Health Office of Research Administration  
13 July 2017

## Description

So the new buzz in the REDCap world seems to be Repeating Instruments 
and Events. Certainly there is potential for a lot of utility in this 
feature and I was excited to try it out. I know I will be using this 
feature a lot in the future.

Unfortunately, I was not very happy with the way the data was exported 
either via CSV or API call. When you conceptualize the data model for 
a Repeating Instrument, you probably think of a multi-table model. You 
might expect that the non-repeating instruments may constitute one table 
that would be related to Repeating Instruments tables via a one-to-many 
relationship. In reality, the data is outputted as one table with all 
possible fields; this has the effect of nesting the output table in a 
way that is not useful in most analysis software.

The normalized data can be retrieved by downloading repeating instruments individually then doing a little
data munging or by writing a few custom parameters in a series of API calls (then doing more data munging),
but this is a lot of extra steps that can make reproducible research more difficult.
Therefore, I have made a programmatic solution to handle the problem in both SAS and R.

### Illustration

For example, consider this mocked-up data involving some information about a subset 
of cars in R's built-in `mtcars` dataset (1). Contained in the data is a repeating instrument,
*sales*, which contains sales transaction data for some of those cars.

| car_id|redcap_repeat_instrument |redcap_repeat_instance |make     |model       |mpg  |cyl |motor_trend_cars_complete |price    |color |customer |sale_complete |
|------:|:------------------------|:----------------------|:--------|:-----------|:----|:---|:-------------------------|:--------|:-----|:--------|:-------------|
|      1|                         |                       |AMC      |Javelin     |15.2 |8   |1                         |         |      |         |              |
|      1|sale                     |1                      |         |            |     |    |                          |12000.50 |1     |Bob      |0             |
|      1|sale                     |2                      |         |            |     |    |                          |13750.77 |3     |Sue      |2             |
|      1|sale                     |3                      |         |            |     |    |                          |15004.57 |2     |Kim      |0             |
|      2|                         |                       |Cadillac |Fleetwood   |10.4 |8   |0                         |         |      |         |              |
|      3|                         |                       |Camaro   |Z28         |13.3 |8   |0                         |         |      |         |              |
|      3|sale                     |1                      |         |            |     |    |                          |7800.00  |2     |Janice   |2             |
|      3|sale                     |2                      |         |            |     |    |                          |8000.00  |3     |Tim      |0             |
|      4|                         |                       |Chrysler |Imperial    |14.7 |8   |0                         |         |      |         |              |
|      4|sale                     |1                      |         |            |     |    |                          |7500.00  |1     |Jim      |2             |
|      5|                         |                       |Datsun   |710         |22.8 |4   |0                         |         |      |         |              |
|      6|                         |                       |Dodge    |Challenger  |15.5 |8   |0                         |         |      |         |              |
|      7|                         |                       |Duster   |360         |14.3 |8   |0                         |         |      |         |              |
|      7|sale                     |1                      |         |            |     |    |                          |8756.40  |4     |Sarah    |1             |
|      7|sale                     |2                      |         |            |     |    |                          |6800.88  |2     |Pablo    |0             |
|      7|sale                     |3                      |         |            |     |    |                          |8888.88  |1     |Erica    |0             |
|      7|sale                     |4                      |         |            |     |    |                          |970.00   |4     |Juan     |0             |
|      8|                         |                       |Ferrari  |Dino        |19.7 |6   |0                         |         |      |         |              |
|      9|                         |                       |Mazda    |RX4 Wag     |21   |6   |0                         |         |      |         |              |
|     10|                         |                       |Merc     |230         |22.8 |4   |0                         |         |      |         |              |
|     10|sale                     |1                      |         |            |     |    |                          |7800.98  |2     |Ted      |0             |
|     10|sale                     |2                      |         |            |     |    |                          |7954.00  |1     |Quentin  |0             |
|     10|sale                     |3                      |         |            |     |    |                          |6800.55  |3     |Sharon   |2             |


You can see that the data from the non-repeating forms (primary table) is interlaced with the data in the repeating forms,
creating a checkerboard pattern. In order to do analysis, the data must be normalized and then the tables rejoined. 
Normalization would result in two tables: 1) a *primary* table and 2) a *sale* table.
The normalized tables would look like this:

**Primary table**

| car_id|make     |model      |mpg  |cyl |motor_trend_cars_complete |
|------:|:--------|:----------|:----|:---|:-------------------------|
|      1|AMC      |Javelin    |15.2 |8   |1                         |
|      2|Cadillac |Fleetwood  |10.4 |8   |0                         |
|      3|Camaro   |Z28        |13.3 |8   |0                         |
|      4|Chrysler |Imperial   |14.7 |8   |0                         |
|      5|Datsun   |710        |22.8 |4   |0                         |
|      6|Dodge    |Challenger |15.5 |8   |0                         |
|      7|Duster   |360        |14.3 |8   |0                         |
|      8|Ferrari  |Dino       |19.7 |6   |0                         |
|      9|Mazda    |RX4 Wag    |21   |6   |0                         |
|     10|Merc     |230        |22.8 |4   |0                         |

**Sale table**

|car_id |redcap_repeat_instrument |redcap_repeat_instance |price    |color |customer |sale_complete |
|:------|:------------------------|:----------------------|:--------|:-----|:--------|:-------------|
|1      |sale                     |1                      |12000.50 |1     |Bob      |0             |
|1      |sale                     |2                      |13750.77 |3     |Sue      |2             |
|1      |sale                     |3                      |15004.57 |2     |Kim      |0             |
|3      |sale                     |1                      |7800.00  |2     |Janice   |2             |
|3      |sale                     |2                      |8000.00  |3     |Tim      |0             |
|4      |sale                     |1                      |7500.00  |1     |Jim      |2             |
|7      |sale                     |1                      |8756.40  |4     |Sarah    |1             |
|7      |sale                     |2                      |6800.88  |2     |Pablo    |0             |
|7      |sale                     |3                      |8888.88  |1     |Erica    |0             |
|7      |sale                     |4                      |970.00   |4     |Juan     |0             |
|10     |sale                     |1                      |7800.98  |2     |Ted      |0             |
|10     |sale                     |2                      |7954.00  |1     |Quentin  |0             |
|10     |sale                     |3                      |6800.55  |3     |Sharon   |2             |

Suppose you would like to do some analysis such as sale price by make of car or find
the most popular color for each model. To do so, you can join the tables together using
relational algebra. After inner joining the *primary* table to the *sale* table on `car_id` 
and selecting only the fields you are interested in, 
your resulting analytic dataset might look something like this:

| car_id|make     |model    |price    |color |customer |
|------:|:--------|:--------|:--------|:-----|:--------|
|      1|AMC      |Javelin  |12000.50 |1     |Bob      |
|      1|AMC      |Javelin  |13750.77 |3     |Sue      |
|      1|AMC      |Javelin  |15004.57 |2     |Kim      |
|      3|Camaro   |Z28      |7800.00  |2     |Janice   |
|      3|Camaro   |Z28      |8000.00  |3     |Tim      |
|      4|Chrysler |Imperial |7500.00  |1     |Jim      |
|      7|Duster   |360      |8756.40  |4     |Sarah    |
|      7|Duster   |360      |6800.88  |2     |Pablo    |
|      7|Duster   |360      |8888.88  |1     |Erica    |
|      7|Duster   |360      |970.00   |4     |Juan     |
|     10|Merc     |230      |7800.98  |2     |Ted      |
|     10|Merc     |230      |7954.00  |1     |Quentin  |
|     10|Merc     |230      |6800.55  |3     |Sharon   |

Such a join can be accomplished numerous ways. Just to name a few:

- SAS
    - [`PROC SQL`](http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a002473709.htm)
    - The [`MERGE`](http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000202970.htm) statement in a `DATA` step
- R
    - [`dplyr::*_join`](https://www.rdocumentation.org/packages/dplyr/versions/0.7.5/topics/join)
    - [`sqldf`](https://www.rdocumentation.org/packages/sqldf/versions/0.4-11/topics/sqldf)
    - [`base::merge`](https://www.rdocumentation.org/packages/base/versions/3.5.0/topics/merge)

### Supported Platforms

Currently, the R and SAS code is well-tested with mocked-up data. 

- R
- SAS

I have made some effort to replicate the
messiness of real-world data and have tried to include as many special cases and data types as possible.
However, this code may not account for all contingencies or changes in the native REDCap export format.
If you find a bug, please feel free to open an issue or pull request.

#### Coming Soon

Currently, we have given some consideration to expand the capabilities into the following languages.

- Python
- VBA

If you have some talents in these or other languages, please feel free to open a pull request! We
welcome your contributions!


## Instructions
### R

#### Installation

First you must install the package. To do so, execute the following in your R console:

```r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("SpectrumHealthResearch/REDCapRITS/R")
```

#### Usage

After the package is installed, follow these instructions:

1. Download the record dataset and metadata (data dictionary). This can
be accomplished by several methods:
    - Using the API. Check with your REDCap administrator for details.
    - Exporting the data from the web interface by selecting *CSV / Microsoft Excel (raw data)*.
    - Exporting the data from the web interface by selecting *R Statistical Software*.
      If you use this method, you may run the R script supplied by REDCap prior to splitting the data.
	- **Do NOT** export from the web interface with the *CSV / Microsoft Excel (labels)* option.
      This will not work with REDCapRITS.
1. Call the function, pointing it to your record dataset and metadata
`data.frame`s or JSON character vectors. You may need to load the package via 
`library()` or `require()`.

#### Examples

Here is an example usage in conjuction with an API call to your REDCap instance:

```r
library(RCurl)

# Get the records
records <- postForm(
    uri = api_url,     # Supply your site-specific URI
    token = api_token, # Supply your own API token
    content = 'record',
    format = 'json',
    returnFormat = 'json'
)

# Get the metadata
metadata <- postForm(
    uri = api_url,     # Supply your site-specific URI
    token = api_token, # Supply your own API token
    content = 'metadata',
    format = 'json'
)

# Convert exported JSON strings into a list of data.frames
REDCapRITS::REDCap_split(records, metadata)
```

And here is an example of usage when downloading a REDCap export of the raw data (not labelled!) manually from your REDCap web interface:

```r
# Get the records
records <- read.csv("/path/to/data/ExampleProject_DATA_2018-06-03_1700.csv")

# Get the metadata
metadata <- read.csv("/path/to/data/ExampleProject_DataDictionary_2018-06-03.csv")

# Split the tables
REDCapRITS::REDCap_split(records, metadata)
```

REDCapRITS also works with the data export script (a.k.a., *syntax file*) supplied by REDCap. Here is an example of its usage:

```r
# You must set the working directory first since the REDCap data export script
# contains relative file references.
setwd("/path/to/data/")

# Run the data export script supplied by REDCap. 
# This will create a data.frame of your records called 'data'
source("ExampleProject_R_2018-06-03_1700.r")

# Get the metadata
metadata <- read.csv("ExampleProject_DataDictionary_2018-06-03.csv")

# Split the tables
REDCapRITS::REDCap_split(data, metadata)
```

### SAS

1. Download the data, SAS code to load the data, and the data dictionary from REDCap.
1. Run the SAS code provided by REDCap to import the data.
1. Run the RECapRITS macro definitions in the source editor or using `%include`.
1. Run the macro call `%REDCAP_READ_DATA_DICT()` to load the data dictionary into your SAS session, pointing to the file location of your REDCap data dictionary.
1. Run the macro call `%REDCAP_SPLIT()`. You will have an output dataset for
your main table as well as for each repeating instrument.

#### Examples

Please follow the instructions from REDCap on importing the data into SAS. REDCap provides the data in a *csv* format as well as *bat* and *sas* files. The instructions are available when exporting the data from the REDCap web interface. If you do not use the pathway mapper (*bat* file) provided, you will need to go into the *sas* file provided by REDCap and alter the file path in the `infile` statment (Line 2).

```sas
* Run the program to import the data file into a SAS dataset;
%INCLUDE "c:\path\to\data\ExampleProject_SAS_2018-06-04_0950.sas";

* Run the MACRO definitions from this repo;
%INCLUDE "c:\path\to\macro\REDCap_split.sas";

* Read in the data dictionary;
%REDCAP_READ_DATA_DICT(c:\path\to\data\ExampleProject_DataDictionary_2018-06-04.csv);

* Split the tables;
%REDCAP_SPLIT();

```

## Issues

Suggestions and contributions are more than welcome! Please feel free to create an issue or pull request.

## About REDCap

This code was written for [REDCap electronic data capture tools](https://projectredcap.org/)(2). Code for this project was tested on the REDCap instance hosted at Spectrum Health, Grand Rapids, MI. REDCap (Research Electronic Data Capture) is a secure, web-based application designed to support data capture for research studies, providing 1) an intuitive interface for validated data entry; 2) audit trails for tracking data manipulation and export procedures; 3) automated export procedures for seamless data downloads to common statistical packages; and 4) procedures for importing data from external sources.

## References

(1) Henderson and Velleman (1981), Building multiple regression models interactively. *Biometrics*, **37**, 391--411.
**Modified with fake data for the purpose of illustration**

(2) Paul A. Harris, Robert Taylor, Robert Thielke, Jonathon Payne, Nathaniel Gonzalez, Jose G. Conde, Research electronic data capture (REDCap) – A metadata-driven methodology and workflow process for providing translational research informatics support, J Biomed Inform. 2009 Apr;42(2):377-81.
