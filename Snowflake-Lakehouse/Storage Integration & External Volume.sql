-- Creating Lakehouse database and raw schema

CREATE DATABASE LAKEHOUSE IF NOT EXISTS;
USE DATABASE LAKEHOUSE;
CREATE SCHEMA RAW IF NOT EXISTS;
USE SCHEMA RAW;


-- Creating Storage Integration

CREATE STORAGE INTEGRATION S3_TO_SNOWFLAKE_INTEGRATION IF NOT EXISTS
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-lakehouse-trial/')
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::807304180493:role/snowflake_access';


DESC INTEGRATION S3_TO_SNOWFLAKE_INTEGRATION;



-- Creating external volume

CREATE EXTERNAL VOLUME IF NOT EXISTS my_external_volume
    STORAGE_LOCATIONS = (
        (
            NAME = 'snowflake-lakehouse-trial'
            STORAGE_PROVIDER = 'S3'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::807304180493:role/snowflake_access'
            STORAGE_BASE_URL = 's3://snowflake-lakehouse-trial/'
        )
    )
    ALLOW_WRITES = TRUE;