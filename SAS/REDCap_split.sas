/********************************************************************************
* 
* FILE:    REDCap_split.sas
*
* VERSION: 0.1.0
*
* PURPOSE: Take a REDCap dataset with multiple events and make into several
*          tables with primary and foreign keys
*
* AUTHOR:  Paul W. Egeler, M.S., GStat
*
* DATE:    22JUN2017
*
*******************************************************************************
*
* INSTRUCTIONS:
* 
* 1. Run the SAS code provided by REDCap to load the records into your SAS session.
*
* 2. Download the data dictionary for your project.
*
* 3. Run the macro definitions REDCAP_READ_DATA_DICT and REDCAP_SPLIT
*
* 4. Run the macro call for REDCAP_READ_DATA_DICT to load in the data dictionry.
*    This is necessary to split the tables correctly.
* 
* 5. Run the macro call for REDCAP_SPLIT. You will have an output dataset for
*    your main table as well as for each repeating instrument.
*
********************************************************************************/

%MACRO REDCAP_READ_DATA_DICT(
    DATA_DICTIONARY  /* The file path for the data dictionary */
);
        DATA REDCAP_DATA_DICTIONARY;
    
            LENGTH VAR_NAME $ 200 FORM_NAME $ 200 SECTION_HEADER $ 200 FIELD_TYPE $ 200 X1-X14 $ 2250;
            INFILE "&DATA_DICTIONARY" FIRSTOBS = 2 DSD DLM = "," LRECL=32767;
            
            INPUT VAR_NAME $ FORM_NAME $ SECTION_HEADER $ FIELD_TYPE $ X1-X14 $;

            IF FIELD_TYPE EQ "descriptive" THEN DELETE;

            DROP SECTION_HEADER X1-X14;
                
        RUN;

%MEND REDCAP_READ_DATA_DICT;


%MACRO REDCAP_SPLIT(
    DATA_SET = REDCAP /* The name of the SAS dataset created by REDCap */,
    DATA_DICTIONARY = REDCAP_DATA_DICTIONARY  /* The name of the SAS dataset of the data dictionary */,
    NUMERIC_SUBTABLES = N /* Y/N: Should the subtables be numbered (Y) or should they be based on the name of the repeating instrument (N)? */
);

    /* Find the key that links the base table to child tables */
    /* Also check that REDCAP_REPEAT_INSTRUMENT is present in the data */
    %LET DSID  = %SYSFUNC(OPEN(&DATA_SET));
    %LET KEY   = %SYSFUNC(VARNAME(&DSID, 1));
    %LET CHECK = %SYSFUNC(VARNUM(&DSID, REDCAP_REPEAT_INSTRUMENT));
    %LET RC    = %SYSFUNC(CLOSE(&DSID));

    %IF &CHECK EQ 0 %THEN %DO;

        %PUT ERROR: The dataset &DATA_SET does not contain repeating instruments.;
        %PUT ERROR: Stopping MACRO.;
        %GOTO FINISH;

    %END;

    /* Remove formatting from repeat instrument field */
    %PUT NOTE: Removing formatting from REDCAP_REPEAT_INSTRUMENT in &DATA_SET..;
    DATA &DATA_SET.;
    SET &DATA_SET.;
      FORMAT REDCAP_REPEAT_INSTRUMENT;
    RUN;
    
    /* Find the subtable names and number of subtables */
    PROC SQL NOPRINT;

        SELECT DISTINCT
            REDCAP_REPEAT_INSTRUMENT,
            "'"!!trim(REDCAP_REPEAT_INSTRUMENT)!!"'" AS INSTRUMENT_QUOTED
        INTO 
            :INSTRUMENTS         SEPARATED BY ' ',
            :INSTRUMENT_LIST     SEPARATED BY ','
        FROM &DATA_SET AS A
        WHERE REDCAP_REPEAT_INSTRUMENT GT '';
        
        %LET N_SUBTABLES = &SQLOBS;

    QUIT;
    

    %IF &N_SUBTABLES EQ 0 %THEN %DO;

        %PUT WARNING: There were no records containing repeating instruments in the dataset %LEFT(&DATA_SET).;
        %PUT WARNING: No action was taken.;
        %GOTO FINISH;

    %END;

    %PUT N SUBTABLES:     %LEFT(&N_SUBTABLES);
    %PUT INSTRUMENTS:     %LEFT(&INSTRUMENTS);
    %PUT INSTRUMENT LIST: %LEFT(%BQUOTE(&INSTRUMENT_LIST));

    /* Get information on the variables in the dataset */
    PROC CONTENTS
      DATA = &DATA_SET.
      OUT = REDCAP_VARNAMES(KEEP=NAME VARNUM)
      NOPRINT;
    RUN;

    /* Make a list of fields and their associated forms based on data dictionary */
    DATA REDCAP_FIELDS(KEEP=VAR_NAME FORM_NAME);
    SET &DATA_DICTIONARY.;
      IF FIELD_TYPE EQ "checkbox" THEN DO;
        BASENAME = VAR_NAME;
        DO I = 1 TO N;
          SET REDCAP_VARNAMES POINT=I NOBS=N;
          IF PRXMATCH("/^"!!trim(BASENAME)!!"___.+$/", NAME) THEN DO;
            VAR_NAME = NAME;
            OUTPUT;
          END;
        END;
      END;
      ELSE OUTPUT;
    RUN;

    /* Add instrument status fields to list of fields */
    PROC SQL;

        CREATE TABLE REDCAP_INSTRUMENT_STATUS_FIELDS AS
            SELECT DISTINCT TRIM(FORM_NAME)!!"_complete" AS VAR_NAME LENGTH=200, FORM_NAME
            FROM &DATA_DICTIONARY.;

    QUIT;

    PROC APPEND
        BASE=REDCAP_FIELDS
        DATA=REDCAP_INSTRUMENT_STATUS_FIELDS;
    RUN;

    DATA REDCAP_FIELDS;
        SET REDCAP_FIELDS;

        IF LENGTH(VAR_NAME) GT 32 THEN DO;
            PUT "WARNING: The variable " VAR_NAME "is too long (MAX 32 CHARACTERS).";
            PUT "WARNING: " VAR_NAME "will not be included in the output dataset.";
            DELETE;
        END;

    RUN;

    /* Sort out the field names */
    PROC SQL NOPRINT;

        SELECT VAR_NAME
        INTO :VARS_BASE SEPARATED BY ' '
        FROM REDCAP_FIELDS AS A
        WHERE FORM_NAME NOT IN (&INSTRUMENT_LIST);

        %put Base vars: &VARS_BASE;

        %DO I = 1 %TO &N_SUBTABLES;

            %LET INSTRUMENT_I = %SCAN(&INSTRUMENTS,&I,%STR( ));

            SELECT VAR_NAME
            INTO :VARS_&I. SEPARATED BY ' '
            FROM REDCAP_FIELDS AS A
            WHERE FORM_NAME EQ "&INSTRUMENT_I.";

            %PUT &INSTRUMENT_I. vars: &&VARS_&I;

        %END;

    QUIT;

    /* Make new data sets based on field names above */
    DATA &DATA_SET._BASE (KEEP = &VARS_BASE);
        SET &DATA_SET;
        IF MISSING(REDCAP_REPEAT_INSTRUMENT);
    RUN;

    %DO I = 1 %TO &N_SUBTABLES;

        %LET INSTRUMENT_I = %SCAN(&INSTRUMENTS,&I,%STR( ));

		/* Create either numeric table name or name based on repeating instrument name (see issue #12) */
		%IF &NUMERIC_SUBTABLES EQ N %THEN %DO;

            %LET SUBTABLE_NAME = &DATA_SET._&INSTRUMENT_I.;

			%IF %LENGTH(&SUBTABLE_NAME) GT 32 %THEN %DO;

                %PUT ERROR: The table name &SUBTABLE_NAME is %LENGTH(&SUBTABLE_NAME) characters long (MAX 32 CHARACTERS).;
				%PUT ERROR: &SUBTABLE_NAME will be skipped. Consider setting NUMERIC_SUBTABLES = Y.;
				%GOTO SKIP;

			%END;

		%END;
		%ELSE %DO;

		    %LET SUBTABLE_NAME = &DATA_SET._&I.;

		%END;

		DATA &SUBTABLE_NAME (KEEP = &KEY redcap_repeat_instance &&VARS_&I);
            SET &DATA_SET;
            IF REDCAP_REPEAT_INSTRUMENT EQ "&INSTRUMENT_I.";
        RUN;

        %PUT NOTE: Records from instrument &INSTRUMENT_I have been placed in &SUBTABLE_NAME;

        %SKIP:

    %END;

    /* Clean up temporary datasets */
    PROC DATASETS MEMTYPE=DATA LIBRARY=WORK NOLIST;
    DELETE REDCAP_FIELDS REDCAP_VARNAMES REDCAP_INSTRUMENT_STATUS_FIELDS;
    RUN;

    %FINISH:

%MEND REDCAP_SPLIT;
