-- Creating internal stage for loading CSV file

CREATE STAGE rawdatastage;
ls @rawdatastage;



-- Creating normal file format and for infer schema

CREATE OR REPLACE FILE FORMAT my_csv
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    REPLACE_INVALID_CHARACTERS = TRUE;

CREATE OR REPLACE FILE FORMAT my_csv_format_infer_schema
    TYPE = CSV
    PARSE_HEADER = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    REPLACE_INVALID_CHARACTERS= TRUE
    SKIP_BLANK_LINES = TRUE;
    

SELECT $1,$2,$3,$4,$5,$6,$7,$8
FROM '@"DECONNECT_HOL_ICEBERG"."HOL_DEMO"."RAWDATASTAGE"/online_retail_II.csv'
(FILE_FORMAT => DECONNECT_HOL_ICEBERG.HOL_DEMO.MY_CSV);


-- Get column names and data types using infer schema

-- SELECT * FROM
--     TABLE (
--         INFER_SCHEMA(
--           LOCATION=>'@rawdatastage/',
--           FILE_FORMAT=>'MY_CSV',
--           IGNORE_CASE => FALSE,
--           MAX_FILE_COUNT => 1
--           ,MAX_RECORDS_PER_FILE => 1000
--         )
--       );
--     )


SELECT GENERATE_COLUMN_DESCRIPTION(
    ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') AS COLUMNS
      FROM TABLE (
        INFER_SCHEMA(
          LOCATION=>'@rawdatastage/',
          FILE_FORMAT=>'my_csv_format_infer_schema',
          IGNORE_CASE => FALSE,
          MAX_FILE_COUNT => 1
          ,MAX_RECORDS_PER_FILE => 1000
        )
      );


CREATE OR REPLACE ICEBERG TABLE POI (
    "Invoice" TEXT,
    "StockCode" TEXT,
    "Description" TEXT,
    "Quantity" NUMBER(3, 0),
    "InvoiceDate" TEXT,
    "Price" NUMBER(5, 2),
    "Customer ID" NUMBER(5, 0),
    "Country" TEXT
);


COPY INTO POI
FROM '@"DECONNECT_HOL_ICEBERG"."HOL_DEMO"."RAWDATASTAGE"/online_retail_II.csv'
FILE_FORMAT = my_csv_format_infer_schema
MATCH_BY_COLUMN_NAME = 'case_sensitive'
ON_ERROR = CONTINUE
LOAD_MODE = FULL_INGEST;


SELECT * FROM POI;


SELECT
    "Invoice",
    SUM("Quantity") AS Total_Quantity,
    SUM("Price") AS Total_Price
FROM
    POI
WHERE "Invoice" IS NOT NULL
GROUP BY 1
ORDER BY 3 DESC;