# EBOC Clinical Guidelines RAG Agent

AI-powered question-answering over Texas Children's Hospital Evidence-Based Outcomes Center (EBOC) clinical practice guidelines. Built on Snowflake Cortex AI.

## Architecture

```
56 EBOC PDFs (uploaded manually to Snowflake stage)
  --> AI_PARSE_DOCUMENT (LAYOUT mode — preserves headers, sections, tables)
    --> SPLIT_TEXT_MARKDOWN_HEADER (2,000 char chunks, 300 overlap)
      --> DOC_CHUNKS table (enriched with category, guideline name, section)
        --> Cortex Search Service (hybrid vector + keyword + reranker)
          --> Cortex Agents (1 universal + 4 specialty)
            --> Snowflake Intelligence / Streamlit / Teams
```

**Key numbers**: 56 PDFs, 14 clinical categories, 2,059 searchable chunks, 5 agents, <5 second response time.

---

## How Accuracy is Achieved

The #1 concern for clinical AI is accuracy. This solution ensures clinicians get the right answer from the right guideline through three architectural decisions:

### 1. Metadata Prepend (Embedding Disambiguation)

Every chunk is prepended with contextual metadata before embedding:

```
"Guideline: Diabetes: Diabetic Ketoacidosis (DKA) | Category: Endocrine
Section: Fluid Resuscitation
[actual guideline text...]"
```

**Why this matters**: Without the prepend, a chunk about "fluid resuscitation" in the DKA guideline would be semantically identical to "fluid resuscitation" in the Septic Shock guideline. The prepend gives the embedding model disambiguating context so the vector search retrieves the clinically correct chunk for the question asked.

### 2. ATTRIBUTES Filtering (Per-Specialty Scoping)

The Cortex Search Service is created with filterable ATTRIBUTES:

```sql
CREATE CORTEX SEARCH SERVICE ... ATTRIBUTES category, guideline_name
```

**What this enables**:
- **Specialty agents** apply `{"@eq": {"category": "Nervous"}}` to every search — a Neurology agent only searches neurology guidelines, eliminating cross-specialty noise
- **Diversity scoring** groups by `guideline_name` — prevents one verbose guideline from dominating results when a question spans multiple documents
- **Precise citations** — the agent knows exactly which guideline and section each chunk came from

**Impact on accuracy**: In testing, 12/12 retrieval queries returned the correct guideline in the top 3 results. Filtered specialty queries returned 100% same-specialty results.

### 3. Category Mapping Table (Clean Citations + Source Linking)

A lookup table (`CATEGORY_MAP`) maps each PDF filename to:
- A human-readable `guideline_name` (e.g., "Diabetes: Diabetic Ketoacidosis (DKA)")
- A clinical `category` (e.g., "Endocrine")
- The public `source_url` on the TCH website

**Why not derive this automatically?** PDF filenames like `DKAGuideline_FINAL.pdf` don't contain category information and aren't suitable for citations. The mapping table provides the clean metadata that makes citations trustworthy and verifiable.

**How citations work end-to-end**: Agent retrieves chunks → each chunk carries `guideline_name` and `section` → agent's system prompt enforces `[Guideline Name, Section]` citation format → clinician sees specific source and can click through to verify.

---

## Prerequisites

- Snowflake account with Cortex AI enabled
- A warehouse (XS is sufficient)
- Role with: `SNOWFLAKE.CORTEX_USER` database role, `CREATE CORTEX SEARCH SERVICE`, `CREATE AGENT`, `EXECUTE TASK ON ACCOUNT`
- EBOC guideline PDFs (download from [TCH Clinical Standards](https://www.texaschildrens.org/patients-families/safety-and-outcomes/clinical-standards))

---

## Quickstart

### Step 1: Upload PDFs to Stage

Upload all EBOC guideline PDFs via Snowsight:
1. Navigate to your database/schema
2. Create or open the stage `EBOC_PDFS`
3. Click "+ Files" and upload all PDFs

Or run `sql/01_setup.sql` first to create the stage, then use the Snowsight UI.

### Step 2: Run SQL Scripts in Order

Execute each script sequentially in a Snowflake worksheet:

```sql
-- Run these in order:
-- sql/01_setup.sql        (database, schema, stage, permissions)
-- sql/02_category_map.sql (56-row lookup table)
-- sql/03_parse_and_chunk.sql (PDF extraction + chunking)
-- sql/04_search_service.sql  (Cortex Search Service)
-- sql/05_agents.sql          (Universal + 4 specialty agents)
```

### Step 3: Chat with the Agent

Open **Snowflake Intelligence** (AI & ML > Agents) — your agents appear automatically. Ask a question:

> "What is the recommended workup for a first unprovoked seizure in a pediatric patient?"

### Step 4 (Optional): Deploy Streamlit App

Upload `streamlit/app.py` to Streamlit in Snowflake via Snowsight for a dedicated chat interface with specialty selector.

### Step 5 (Optional): Run Evaluation

See the [Running Evaluations](#running-evaluations) section below.

---

## SQL Scripts

| Script | Purpose |
|--------|---------|
| `sql/01_setup.sql` | Create database, schema, stage, and grant permissions |
| `sql/02_category_map.sql` | Insert 56-row category mapping (filename → guideline name + category + URL) |
| `sql/03_parse_and_chunk.sql` | Parse PDFs with AI_PARSE_DOCUMENT, chunk with SPLIT_TEXT_MARKDOWN_HEADER, enrich with metadata |
| `sql/04_search_service.sql` | Create Cortex Search Service with ATTRIBUTES on category and guideline_name |
| `sql/05_agents.sql` | Create 5 agents: Universal, Neurology, Cardiology, Respiratory, Infection |
| `sql/06_evaluation.sql` | Create evaluation dataset table (12 test questions with ground truth) |

---

## Agents

| Agent | Category Filter | Best For |
|-------|----------------|----------|
| `EBOC_UNIVERSAL_AGENT` | None (all 55 guidelines) | Cross-specialty questions, unknown specialty |
| `EBOC_NEUROLOGY_AGENT` | Nervous | Seizures, stroke, TBI, concussion, headaches |
| `EBOC_CARDIOLOGY_AGENT` | Cardiovascular | Kawasaki, thrombosis, ischemic stroke |
| `EBOC_RESPIRATORY_AGENT` | Respiratory | Asthma, bronchiolitis, croup, HFNC, BRUE |
| `EBOC_INFECTION_AGENT` | Infection | Sepsis, CAP, CLABSI, SSTI, fever workups |

All agents enforce strict grounding: answers come ONLY from EBOC guidelines, with mandatory citations.

---

## Running Evaluations

Cortex Agent Evaluations use an LLM-as-a-judge approach to score your agent's responses against ground truth.

### What Gets Evaluated

| Metric | Type | What It Measures |
|--------|------|-----------------|
| `answer_correctness` | System (built-in) | Does the agent's answer match the expected clinical content? |
| `logical_consistency` | System (reference-free) | Are the agent's tool calls and reasoning steps consistent? |
| `clinical_grounding` | Custom | Does the response ONLY use guideline content with no hallucination? |
| `citation_accuracy` | Custom | Are sources cited with specific guideline name and section? |

### Step-by-Step: Run an Evaluation

**1. Create the evaluation dataset** (already done if you ran `sql/06_evaluation.sql`):

```sql
-- Verify the eval table has 12 questions
SELECT COUNT(*) FROM EBOC_RAG.AGENT_EVAL_DATA;
```

**2. Upload the evaluation config to the stage**:

Upload `eval/eboc_eval_config.yaml` to the `EVAL_CONFIG` stage (created in `sql/06_evaluation.sql`) via Snowsight, or:

```sql
PUT file:///path/to/eboc_eval_config.yaml @EBOC_RAG.EVAL_CONFIG AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
```

**3. Start the evaluation**:

```sql
USE DATABASE EXPLORER_SANDBOX;
USE SCHEMA EBOC_RAG;

CALL EXECUTE_AI_EVALUATION(
  'START',
  OBJECT_CONSTRUCT('run_name', 'my-eval-run'),
  '@EBOC_RAG.EVAL_CONFIG/eboc_eval_config.yaml'
);
```

**4. Check status** (evaluations take 2-5 minutes):

```sql
CALL EXECUTE_AI_EVALUATION(
  'STATUS',
  OBJECT_CONSTRUCT('run_name', 'my-eval-run'),
  '@EBOC_RAG.EVAL_CONFIG/eboc_eval_config.yaml'
);
-- Wait for STATUS = 'COMPLETED'
```

**5. View results — summary scores**:

```sql
SELECT
    METRIC_NAME,
    ROUND(AVG(EVAL_AGG_SCORE), 2) AS avg_score,
    COUNT(*) AS num_questions
FROM TABLE(SNOWFLAKE.LOCAL.GET_AI_EVALUATION_DATA(
  'EXPLORER_SANDBOX', 'EBOC_RAG', 'EBOC_UNIVERSAL_AGENT', 'CORTEX AGENT', 'my-eval-run'))
GROUP BY METRIC_NAME
ORDER BY METRIC_NAME;
```

**6. View results — per-question detail with judge explanations**:

```sql
SELECT
    LEFT(INPUT, 70) AS question,
    METRIC_NAME,
    EVAL_AGG_SCORE AS score,
    METRIC_CALLS[0]['explanation']::STRING AS judge_explanation
FROM TABLE(SNOWFLAKE.LOCAL.GET_AI_EVALUATION_DATA(
  'EXPLORER_SANDBOX', 'EBOC_RAG', 'EBOC_UNIVERSAL_AGENT', 'CORTEX AGENT', 'my-eval-run'))
WHERE METRIC_NAME = 'answer_correctness'
ORDER BY EVAL_AGG_SCORE;
```

**7. View in Snowsight UI**:

Navigate to AI & ML > Agents > EBOC_UNIVERSAL_AGENT > Evaluations tab for a visual dashboard.

### Interpreting Results

| Score Range | Meaning | Action |
|-------------|---------|--------|
| **0.9-1.0** (correctness) | Excellent — answer matches ground truth | None needed |
| **0.6-0.9** (correctness) | Partial — some content missing or a detail differs | Review judge explanation; may indicate a chunking issue or a ground truth that's too strict |
| **7-10** (custom metrics) | High — well-grounded with good citations | None needed |
| **4-6** (custom metrics) | Medium — grounded but citations may be imprecise | Tune agent system prompt for citation format |
| **1-3** (custom metrics) | Low — potential hallucination or missing citations | Investigate: check if the chunk exists in DOC_CHUNKS for that topic |

### Adding New Test Questions

```sql
INSERT INTO EBOC_RAG.AGENT_EVAL_DATA
SELECT
  'Your new clinical question here?',
  PARSE_JSON('{"ground_truth_output": "The expected answer content with key facts the agent should include. Source: [Guideline Name]."}');
```

Then re-run the evaluation with a new `run_name`.

### Creating Custom Metrics

Add to the `metrics:` section of your YAML config:

```yaml
- name: "your_metric_name"
  score_ranges:
    min_score: [1, 3]
    median_score: [4, 6]
    max_score: [7, 10]
  prompt: |
    Your evaluation prompt here. Use {{output}} for the agent's response
    and {{ground_truth}} for the expected answer.
    Rate from 1-10 where:
    1 = [worst case]
    10 = [best case]
```

---

## Deployment Options

| Option | Auth | Effort | Best For |
|--------|------|--------|----------|
| **Snowflake Intelligence** | SSO (AD) | Zero | Internal validation, tech-savvy clinicians |
| **Streamlit in Snowflake** | Snowflake login | Upload `app.py` | Custom UI with specialty selector |
| **Microsoft Teams** | Teams login (already signed in) | 1-2 hrs admin config | Enterprise rollout |
| **Custom Web App** | None (backend PAT) | 3-4 hrs dev | "Just a URL" access, Epic iframe |

---

## Cost Estimate (POC)

| Component | Monthly Cost |
|-----------|-------------|
| Cortex Search serving (~5MB indexed) | ~$0.30 |
| Warehouse (daily refresh) | ~$1.50 |
| Agent inference (50 queries/day) | ~$15-30 |
| **Total** | **~$20-35/month** |

---

## Customization: Adding New Guidelines

1. Upload the new PDF to the `EBOC_PDFS` stage
2. Add a row to `CATEGORY_MAP`:
   ```sql
   INSERT INTO EBOC_RAG.CATEGORY_MAP VALUES
   ('New_Guideline.pdf', 'New Guideline: Descriptive Name', 'Category', 'https://...');
   ```
3. Re-run `sql/03_parse_and_chunk.sql` (or just the INSERT for the new PDF)
4. The Cortex Search Service auto-refreshes within `TARGET_LAG` (1 day)

No agent changes needed — the new guideline is automatically searchable.

---

## Project Structure

```
tch-eboc-rag-agent/
├── README.md
├── sql/
│   ├── 01_setup.sql
│   ├── 02_category_map.sql
│   ├── 03_parse_and_chunk.sql
│   ├── 04_search_service.sql
│   ├── 05_agents.sql
│   └── 06_evaluation.sql
├── streamlit/
│   └── app.py
├── eval/
│   └── eboc_eval_config.yaml
└── .gitignore
```
