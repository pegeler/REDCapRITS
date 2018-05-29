/********************************************************************************
* 
* FILE:    REDCap_split.sas
*
* VERSION: 0.0.0
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
* 1. Run the SAS code provided by REDCap to import the data 
*    BUT COMMENT THIS LINE:
*
*      format redcap_repeat_instrument redcap_repeat_instrument_.;
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

            DROP SECTION_HEADER FIELD_TYPE X1-X14;
                
        RUN;

%MEND REDCAP_READ_DATA_DICT;


%MACRO REDCAP_SPLIT(
    DATA_DICTIONARY = REDCAP_DATA_DICTIONARY  /* The name of the SAS dataset of the data dictionary */, 
    DATA_SET = REDCAP /* The name of the SAS dataset created by REDCap */,
    KEY = RECORD_ID  /* Variable that links base table with other tables */
);

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

        %PUT INSTRUMENTS:     %LEFT(&INSTRUMENTS);
        %PUT INSTRUMENT LIST: %LEFT(&INSTRUMENT_LIST);
        %PUT N SUBTABLES:     %LEFT(&N_SUBTABLES);

    QUIT;
    

    %IF &N_SUBTABLES GT 0 %THEN %DO;
    
        PROC SQL NOPRINT;

            SELECT VAR_NAME
            INTO :VARS_BASE SEPARATED BY ' '
            FROM &DATA_DICTIONARY. AS A
            WHERE FORM_NAME NOT IN (&INSTRUMENT_LIST);

            %put Base vars: &VARS_BASE;
            
            %DO I = 1 %TO &N_SUBTABLES;

                %LET INSTRUMENT_I = %SCAN(&INSTRUMENTS,&I,%STR( ));
                
                SELECT VAR_NAME
                INTO :VARS_&INSTRUMENT_I. SEPARATED BY ' '
                FROM &DATA_DICTIONARY. AS A
                WHERE FORM_NAME EQ "&INSTRUMENT_I.";

                %put &INSTRUMENT_I. vars: &&VARS_&INSTRUMENT_I;
            
            %END;


        QUIT;

        DATA &DATA_SET._BASE (KEEP = &VARS_BASE);
            SET &DATA_SET;
            
            IF MISSING(REDCAP_REPEAT_INSTRUMENT);
        RUN;
            
        %DO I = 1 %TO &N_SUBTABLES;

            %LET INSTRUMENT_I = %SCAN(&INSTRUMENTS,&I,%STR( ));
        
            DATA &DATA_SET._&INSTRUMENT_I. (KEEP = &KEY redcap_repeat_instance &&VARS_&INSTRUMENT_I);
                SET &DATA_SET;
        
                IF REDCAP_REPEAT_INSTRUMENT EQ "&INSTRUMENT_I.";
            
            RUN;            
        
        %END;

    %END;

    %ELSE %DO;

        %PUT THERE WERE NO REPEAT INSTRUMENTS IN THE DATASET %LEFT(&DATA_SET);
        %PUT NO ACTION WAS TAKEN;

    %END;


%MEND REDCAP_SPLIT;
