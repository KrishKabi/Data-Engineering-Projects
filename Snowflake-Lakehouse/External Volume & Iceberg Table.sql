-- Creating Catalog Integration

CREATE OR REPLACE CATALOG INTEGRATION deconnect_hol_demo_int 
  CATALOG_SOURCE=POLARIS
  TABLE_FORMAT=ICEBERG
  CATALOG_NAMESPACE='default' 
  REST_CONFIG = (
    CATALOG_URI ='https://PMKJSNQ-DECONNECT_HOL_DEMO.snowflakecomputing.com/polaris/api/catalog' 
    CATALOG_NAME = 'external_catalog_snowflake'
  )
  REST_AUTHENTICATION = (
    TYPE=OAUTH 
    OAUTH_CLIENT_ID='wmqdzxNE9YOmo0b87Hf3CJXwejY=' 
    OAUTH_CLIENT_SECRET='0ZnDx5fT2PW0A8FxZOENSrbrMTDMc5sKgl2osfsSb/8=' 
    OAUTH_ALLOWED_SCOPES=('PRINCIPAL_ROLE:ALL')
  ) 
  ENABLED=true;


SELECT SYSTEM$VERIFY_CATALOG_INTEGRATION('deconnect_hol_demo_int');

DESC CATALOG INTEGRATION deconnect_hol_demo_int;


-- Creating database and raw schema

CREATE DATABASE IF NOT EXISTS DECONNECT_HOL_ICEBERG;
USE DATABASE DECONNECT_HOL_ICEBERG;
CREATE SCHEMA IF NOT EXISTS DECONNECT_HOL_ICEBERG.HOL_DEMO;
USE SCHEMA DECONNECT_HOL_ICEBERG.HOL_DEMO;



-- Creating external volume

CREATE OR REPLACE EXTERNAL VOLUME iceberg_hol_demo_ext_vol
    STORAGE_LOCATIONS = 
    (
        (
            NAME = 'main_hol_s3'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://deconnect-hol-demo-krish/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::807304180493:role/deconnect-hol-demo-role'
            STORAGE_AWS_EXTERNAL_ID = 'deconnect_hol_demo'
        )
    )
    ALLOW_WRITES = TRUE;


DESC EXTERNAL VOLUME iceberg_hol_demo_ext_vol;



-- Sync between all iceberg tables and Snowflake Open Catalog

alter schema deconnect_hol_iceberg.hol_demo 
    set catalog = 'snowflake' 
        external_volume = iceberg_hol_demo_ext_vol 
        CATALOG_SYNC = deconnect_hol_demo_int;