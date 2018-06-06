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
way that is not useful in most analysis software. Therefore, I have made 
a solution to handle the problem in both SAS and R.

## Supported Platforms

- R
- SAS

### Coming Soon

- Python
- VBA

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

1. Download the record dataset and metadata. This can
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

This code was written for [REDCap electronic data capture tools](https://projectredcap.org/).^1^ Code for this project was tested on the REDCap instance hosted at Spectrum Health, Grand Rapids, MI. REDCap (Research Electronic Data Capture) is a secure, web-based application designed to support data capture for research studies, providing 1) an intuitive interface for validated data entry; 2) audit trails for tracking data manipulation and export procedures; 3) automated export procedures for seamless data downloads to common statistical packages; and 4) procedures for importing data from external sources.

## References

^1^Paul A. Harris, Robert Taylor, Robert Thielke, Jonathon Payne, Nathaniel Gonzalez, Jose G. Conde, Research electronic data capture (REDCap) – A metadata-driven methodology and workflow process for providing translational research informatics support, J Biomed Inform. 2009 Apr;42(2):377-81.
