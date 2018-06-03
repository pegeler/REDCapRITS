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

First you must install the package. To do so, execute the following in your R console:

```r
if (!require(devtools)) install.packages("devtools")
devtools::install_github("SpectrumHealthResearch/REDCapRITS/R")
```

After the package is installed, follow these instructions:

1. Download the record dataset and metadata. This can
be accomplished either by traditional methods or using the API. The
`read.csv()` function should be able to handle newline characters within
records, so no pre-processing of metadata csv is needed.
1. Call the function, pointing it to your record dataset and metadata
`data.frame`s or JSON character vectors.

### SAS

1. Download the data, SAS code to load the data, and the data dictionary from REDCap
1. Run the SAS code provided by REDCap to import the data BUT COMMENT 
THIS LINE:
    ```format redcap_repeat_instrument redcap_repeat_instrument_.;```
1. Run the RECapRITS macro definitions in the source editor or using `%include`.
1. Run the macro call `%REDCAP_READ_DATA_DICT()` to load the data dictionary into your SAS session, pointing to the file location of your REDCap data dictionary.
1. Run the macro call `%REDCAP_SPLIT()`. You will have an output dataset for
your main table as well as for each repeating instrument.


## Issues

Suggestions and contributions are more than welcome! Please feel free to create an issue or pull request.

## About REDCap

This code was written for [REDCap electronic data capture tools](https://projectredcap.org/).^1^ Code for this project was tested on the REDCap instance hosted at Spectrum Health, Grand Rapids, MI. REDCap (Research Electronic Data Capture) is a secure, web-based application designed to support data capture for research studies, providing 1) an intuitive interface for validated data entry; 2) audit trails for tracking data manipulation and export procedures; 3) automated export procedures for seamless data downloads to common statistical packages; and 4) procedures for importing data from external sources.

## References

^1^Paul A. Harris, Robert Taylor, Robert Thielke, Jonathon Payne, Nathaniel Gonzalez, Jose G. Conde, Research electronic data capture (REDCap) – A metadata-driven methodology and workflow process for providing translational research informatics support, J Biomed Inform. 2009 Apr;42(2):377-81.
