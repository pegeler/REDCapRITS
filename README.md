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

## Instructions

### SAS

1. Run the macro definition in the source editor or using `%include`.
2. Run the SAS code provided by REDCap to import the data BUT COMMENT 
THIS LINE:
    ```format redcap_repeat_instrument redcap_repeat_instrument_.;```
3. Open the data dictionary in MS Excel. We will need to do some pre-
processing to the data dictionary file before reading it in because
some of the user entry points (such as **Field Label**) allows for newline
characters, which can break our data ingestion. MS Excel will read in
the newline characters correctly.
    - Copy the first four columns and paste into a new sheet.
    - Save the new sheet as a .csv file.
    - Close the file.
4. Call the macro, adjusting parameters as needed.

### R

The function definition file contains an example to assist you.

1. Run the function definition in the source editor or using `source()`.
2. Download the record dataset and metadata and import them. This can
be accomplished either by traditional methods or using the API. The
`read.csv()` function should be able to handle newline characters within
records, so no pre-processing of metadata csv is needed.
3. Call the function, pointing it to your record dataset and metadata
`data.frame`s.