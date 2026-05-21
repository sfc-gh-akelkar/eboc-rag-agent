-- 01_setup.sql
-- Creates the database objects and stage for the EBOC RAG Agent
-- Run this first, then upload PDFs to the stage via Snowsight
-- Assumes TCH_SANDBOX_ROLE with appropriate permissions already exists.

USE ROLE TCH_SANDBOX_ROLE;
USE WAREHOUSE EXPLORER_WH;

-- Create schema
CREATE SCHEMA IF NOT EXISTS EXPLORER_SANDBOX.EBOC_RAG;

-- Create stage for PDF uploads
CREATE OR REPLACE STAGE EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS
  DIRECTORY = (ENABLE = TRUE)
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

-- After running this script:
-- 1. Navigate to EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS in Snowsight
-- 2. Click "+ Files" and upload all EBOC guideline PDFs
-- 3. Run: ALTER STAGE EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS REFRESH;
-- 4. Verify: SELECT COUNT(*) FROM DIRECTORY(@EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS);
