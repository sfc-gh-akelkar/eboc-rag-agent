-- 04_search_service.sql
-- Creates the Cortex Search Service with hybrid search over all EBOC chunks.
-- ATTRIBUTES enable per-specialty filtering and diversity scoring.

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE APP_WH;

CREATE OR REPLACE CORTEX SEARCH SERVICE EXPLORER_SANDBOX.EBOC_RAG.EBOC_SEARCH
  ON chunk
  ATTRIBUTES category, guideline_name
  WAREHOUSE = APP_WH
  TARGET_LAG = '1 day'
  EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
  SELECT
      chunk,
      category,
      guideline_name,
      section,
      subsection,
      source_url,
      file_url
  FROM EXPLORER_SANDBOX.EBOC_RAG.DOC_CHUNKS
);

-- Verify: test a search query
SELECT
    r.value['guideline_name']::STRING AS guideline,
    r.value['category']::STRING AS category,
    r.value['section']::STRING AS section
FROM TABLE(FLATTEN(
    PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'EXPLORER_SANDBOX.EBOC_RAG.EBOC_SEARCH',
            '{"query":"DKA fluid resuscitation protocol","columns":["guideline_name","category","section"],"limit":3}'
        )
    )['results']
)) r;
