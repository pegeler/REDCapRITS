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
* 2. Open the data dictionary in MS Excel.
* 
*  2a. Copy the first four columns and paste into a new sheet.
* 
*  2b. Save the new sheet as a .csv file.
* 
*  2c. Close the file.
* 
* 3. Change the data dictionary name and file path in the macro call.
* 
* 4. Run the macro definition and the macro call
* 
*
********************************************************************************/

%MACRO REDCAP_SPLIT(
	DATA_DICTIONARY  /* The file path for the data dictionary */, 
	DATA_SET = REDCAP/* The name of the SAS dataset created by REDCap */,
	KEY = RECORD_ID  /* Variable that links base table with other tables */
);

	PROC SQL NOPRINT;

		SELECT DISTINCT
			REDCAP_REPEAT_INSTRUMENT,
			"'"!!trim(REDCAP_REPEAT_INSTRUMENT)!!"'" AS INSTRUMENT_QUOTED
		INTO 
			:INSTRUMENTS 		SEPARATED BY ' ',
			:INSTRUMENT_LIST 	SEPARATED BY ','
		FROM &DATA_SET AS A
		WHERE REDCAP_REPEAT_INSTRUMENT GT '';
		
		%LET N_SUBTABLES = &SQLOBS;

		%PUT INSTRUMENTS:     %LEFT(&INSTRUMENTS);
		%PUT INSTRUMENT LIST: %LEFT(&INSTRUMENT_LIST);
		%PUT N SUBTABLES:     %LEFT(&N_SUBTABLES);

	QUIT;
	

	%IF &N_SUBTABLES GT 0 %THEN %DO;
	
		DATA DATA_DICTIONARY;
	
			LENGTH VAR_NAME $ 255 FORM_NAME $ 255 SECTION_HEADER $ 255 FIELD_TYPE $ 255;
			INFILE "&DATA_DICTIONARY" FIRSTOBS = 2 DSD DLM = ",";
			
			INPUT VAR_NAME $ FORM_NAME $ SECTION_HEADER $ FIELD_TYPE $;

			IF FIELD_TYPE EQ "descriptive" THEN DELETE;
				
		RUN;
	
		PROC SQL NOPRINT;

			SELECT VAR_NAME
			INTO :VARS_BASE SEPARATED BY ' '
			FROM DATA_DICTIONARY AS A
			WHERE FORM_NAME NOT IN (&INSTRUMENT_LIST);

			%put Base vars: &VARS_BASE;
			
			%DO I = 1 %TO &N_SUBTABLES;

				%LET INSTRUMENT_I = %SCAN(&INSTRUMENTS,&I,%STR( ));
				
				SELECT VAR_NAME
				INTO :VARS_&INSTRUMENT_I. SEPARATED BY ' '
				FROM DATA_DICTIONARY AS A
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
