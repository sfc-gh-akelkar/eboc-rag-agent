-- 03_parse_and_chunk.sql
-- Parses all PDFs with AI_PARSE_DOCUMENT and chunks with SPLIT_TEXT_MARKDOWN_HEADER.
-- Prerequisites: 01_setup.sql and 02_category_map.sql have been run, PDFs uploaded to stage.

USE ROLE TCH_SANDBOX_ROLE;
USE WAREHOUSE EXPLORER_XS_WH;

-- Step 1: Parse all PDFs (extracts text with markdown structure)
CREATE OR REPLACE TABLE EXPLORER_SANDBOX.EBOC_RAG.RAW_TEXT AS
SELECT
    RELATIVE_PATH,
    TO_VARCHAR(
        AI_PARSE_DOCUMENT(
            TO_FILE('@EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS', RELATIVE_PATH),
            {'mode': 'LAYOUT'}
        ):content
    ) AS EXTRACTED_LAYOUT
FROM DIRECTORY(@EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS)
WHERE RELATIVE_PATH LIKE '%.pdf';

-- Verify parse results
SELECT COUNT(*) AS parsed_pdfs,
       ROUND(AVG(LENGTH(EXTRACTED_LAYOUT))) AS avg_chars
FROM EXPLORER_SANDBOX.EBOC_RAG.RAW_TEXT;

-- Step 2: Chunk and enrich with metadata from CATEGORY_MAP
CREATE OR REPLACE TABLE EXPLORER_SANDBOX.EBOC_RAG.DOC_CHUNKS AS
SELECT
    r.relative_path,
    m.pdf_filename,
    m.guideline_name,
    m.category,
    m.source_url,
    BUILD_SCOPED_FILE_URL(@EXPLORER_SANDBOX.EBOC_RAG.EBOC_PDFS, r.relative_path) AS file_url,
    c.value['headers']['header_1']::STRING AS section,
    c.value['headers']['header_2']::STRING AS subsection,
    (
        'Guideline: ' || m.guideline_name || ' | Category: ' || m.category || '\n'
        || COALESCE('Section: ' || c.value['headers']['header_1']::STRING || '\n', '')
        || COALESCE('Subsection: ' || c.value['headers']['header_2']::STRING || '\n', '')
        || c.value['chunk']::STRING
    ) AS chunk
FROM EXPLORER_SANDBOX.EBOC_RAG.RAW_TEXT r
JOIN EXPLORER_SANDBOX.EBOC_RAG.CATEGORY_MAP m
    ON REPLACE(r.relative_path, '/', '') = m.pdf_filename
, LATERAL FLATTEN(
    SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
        r.EXTRACTED_LAYOUT,
        OBJECT_CONSTRUCT('#', 'header_1', '##', 'header_2'),
        2000,
        300
    )
) c;

-- Verify chunks
SELECT
    COUNT(*) AS total_chunks,
    COUNT(DISTINCT guideline_name) AS guidelines,
    COUNT(DISTINCT category) AS categories,
    ROUND(AVG(LENGTH(chunk))) AS avg_chunk_chars
FROM EXPLORER_SANDBOX.EBOC_RAG.DOC_CHUNKS;
