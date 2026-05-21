-- 06_evaluation.sql
-- Creates the evaluation dataset, file format, stage, and provides instructions for running evaluations.
-- Prerequisites: 05_agents.sql has been run.

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE APP_WH;
USE DATABASE EXPLORER_SANDBOX;
USE SCHEMA EBOC_RAG;

-- Create evaluation dataset with 12 test questions and ground truth
CREATE OR REPLACE TABLE EXPLORER_SANDBOX.EBOC_RAG.AGENT_EVAL_DATA (
    input_query VARCHAR,
    ground_truth VARIANT
);

INSERT INTO EXPLORER_SANDBOX.EBOC_RAG.AGENT_EVAL_DATA
SELECT 'What is the recommended workup for a first unprovoked seizure in a pediatric patient?',
  PARSE_JSON('{"ground_truth_output": "The workup should include: ABC assessment, blood glucose check (Accu-Chek), Chem 10 (sodium, potassium, chloride, CO2, BUN, creatinine, glucose, calcium, magnesium, phosphorus), toxicology screen for afebrile patients. For febrile patients: add CBC, UA with culture, viral cultures, and consider LP. Brain CT or MRI not routinely recommended but consider neuroimaging once stabilized if no apparent etiology. EEG for patients not returning to baseline. Neurology consult for unprovoked seizure. Follow-up in New Onset Seizure Clinic within 4 weeks. Source: Status Epilepticus: Initial Management guideline."}')
UNION ALL
SELECT 'What are the diagnostic criteria for Kawasaki disease?',
  PARSE_JSON('{"ground_truth_output": "Kawasaki disease diagnosis requires fever of 5 or more days with at least 2 principal clinical features, OR fever of 4 days with all 5 clinical criteria. The 5 principal features are: (1) bilateral conjunctival injection, (2) oral mucous membrane changes (strawberry tongue, lip cracking), (3) peripheral extremity changes (edema, erythema, desquamation), (4) polymorphous rash, (5) cervical lymphadenopathy (at least 1.5cm). Incomplete Kawasaki should be considered with fewer criteria plus supportive lab findings. Source: Kawasaki Disease: Diagnosis and Management guideline."}')
UNION ALL
SELECT 'What is the initial fluid resuscitation protocol for DKA?',
  PARSE_JSON('{"ground_truth_output": "Initial fluid resuscitation for DKA includes: Normal saline (NS) bolus of 10-20 mL/kg over the first hour for volume resuscitation. Avoid excessive fluid boluses due to cerebral edema risk. After initial bolus, calculate deficit replacement over 24-48 hours. Monitor for signs of cerebral edema including altered mental status, headache, and bradycardia. Risk factors for cerebral edema include age less than 5 years and new onset diabetes. Source: Diabetes: Diabetic Ketoacidosis (DKA) guideline."}')
UNION ALL
SELECT 'When should HFNC be initiated for bronchiolitis?',
  PARSE_JSON('{"ground_truth_output": "HFNC should be initiated when Clinical Respiratory Score (CRS) is 7 or greater, OR for rapidly deteriorating patients who cannot maintain oxygen saturation of 90% while awake or 88% while sleeping on 2 LPM low-flow oxygen. Maximum flow in Acute Care is 2 L/kg/min for patients 2 years and under. Use maximum flow rate for appropriate cannula size. Place on Watcher List/RRT at 2 L/kg/min. Identify nonresponders as patients showing no response (HR, RR) within 1 hour of initiating therapy. Source: Bronchiolitis and HFNC Pathway guidelines."}')
UNION ALL
SELECT 'What antibiotics are recommended for community-acquired pneumonia?',
  PARSE_JSON('{"ground_truth_output": "The answer should specify antibiotic recommendations from the TCH Community-Acquired Pneumonia guideline, including first-line empiric therapy (typically amoxicillin for outpatient, ampicillin for inpatient), alternative agents for penicillin-allergic patients, and criteria for escalation. Dosing and duration should be referenced if available in the guideline. Source: Community-Acquired Pneumonia guideline."}')
UNION ALL
SELECT 'What is the Bromage scale and when is it used?',
  PARSE_JSON('{"ground_truth_output": "The Bromage scale is used to assess leg weakness after epidural analgesia. It grades motor block from 0 (no block, free movement of legs and feet) to 3 (complete block, unable to move legs or feet). It is used to monitor patients receiving epidural analgesia for signs of epidural complications. Source: Bromage Scale: Leg Weakness After Epidural Analgesia guideline."}')
UNION ALL
SELECT 'How should acute chest syndrome be managed in a sickle cell patient?',
  PARSE_JSON('{"ground_truth_output": "Acute chest syndrome management in sickle cell disease should include: aggressive pain management, incentive spirometry, supplemental oxygen to maintain saturation above 92%, empiric antibiotics covering atypical organisms and encapsulated bacteria, simple transfusion or exchange transfusion based on severity, IV fluids at maintenance rate (avoid overhydration), and consideration of bronchodilators. Escalation criteria for ICU transfer should be specified. Source: Sickle Cell Disease: Acute Chest Syndrome pathway."}')
UNION ALL
SELECT 'What are the BRUE risk stratification criteria?',
  PARSE_JSON('{"ground_truth_output": "BRUE (Brief Resolved Unexplained Event) risk stratification divides patients into lower-risk and higher-risk categories. Lower-risk criteria include: age greater than 60 days, gestational age 32 weeks or greater, no CPR by trained medical provider required, event duration less than 1 minute, and first event. Higher-risk patients have any factor not meeting lower-risk criteria. Lower-risk patients may be observed briefly; higher-risk patients require more extensive workup. Source: Brief Resolved Unexplained Event (BRUE) guideline."}')
UNION ALL
SELECT 'What is the septic shock recognition and initial management protocol?',
  PARSE_JSON('{"ground_truth_output": "Septic shock recognition includes identifying signs of systemic infection plus evidence of inadequate tissue perfusion (altered mental status, prolonged capillary refill greater than 2 seconds, diminished pulses, mottled cool extremities, or flash capillary refill with bounding pulses). Initial management within the first hour should include: aggressive fluid resuscitation (20 mL/kg NS boluses up to 60 mL/kg), broad-spectrum antibiotics within 1 hour, blood cultures before antibiotics if possible without delay, and vasoactive medications if fluid-refractory shock. Source: Septic Shock: Recognition and Initial Management guideline."}')
UNION ALL
SELECT 'A sickle cell patient presents with fever - what is the protocol?',
  PARSE_JSON('{"ground_truth_output": "For sickle cell patients with fever (temperature 38.5C or 101.3F or higher): obtain blood cultures, CBC with differential and reticulocyte count, administer empiric antibiotics (typically ceftriaxone) within 1 hour of triage, assess for other sources of infection, and determine disposition based on clinical appearance and risk factors. High-risk features requiring admission include ill appearance, temperature above 40C, WBC above 30K or below 5K, infiltrate on chest X-ray, or history of sepsis/previous bacteremia. Source: Sickle Cell Disease With Fever pathway."}')
UNION ALL
SELECT 'What is the treatment for croup in pediatric patients?',
  PARSE_JSON('{"ground_truth_output": "Croup treatment depends on severity. Mild croup: single dose of oral dexamethasone (0.6 mg/kg, max 10mg). Moderate croup: dexamethasone plus nebulized racemic epinephrine. Severe croup: dexamethasone, nebulized racemic epinephrine, and close monitoring with potential for repeat epinephrine doses. Observation for at least 2-4 hours after epinephrine administration for rebound symptoms. Source: Croup guideline."}')
UNION ALL
SELECT 'What are the guidelines for neonatal hyperbilirubinemia?',
  PARSE_JSON('{"ground_truth_output": "Neonatal hyperbilirubinemia management is based on total serum bilirubin (TSB) levels plotted against the hour-specific nomogram. Treatment thresholds vary by gestational age and risk factors. Phototherapy is initiated based on AAP phototherapy thresholds. Exchange transfusion is considered when TSB approaches exchange transfusion levels despite intensive phototherapy. Risk factors for severe hyperbilirubinemia include jaundice in first 24 hours, blood group incompatibility, prematurity, previous sibling requiring phototherapy, cephalohematoma, and exclusive breastfeeding with poor intake. Source: Hyperbilirubinemia guideline."}');

-- Create file format and stage for eval config YAML
CREATE OR REPLACE FILE FORMAT EXPLORER_SANDBOX.EBOC_RAG.YAML_FILE_FORMAT
  TYPE = 'CSV'
  FIELD_DELIMITER = NONE
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 0
  FIELD_OPTIONALLY_ENCLOSED_BY = NONE
  ESCAPE_UNENCLOSED_FIELD = NONE;

CREATE OR REPLACE STAGE EXPLORER_SANDBOX.EBOC_RAG.EVAL_CONFIG
  FILE_FORMAT = EXPLORER_SANDBOX.EBOC_RAG.YAML_FILE_FORMAT;

-- After running this script:
-- 1. Upload eval/eboc_eval_config.yaml to @EVAL_CONFIG stage
-- 2. Run the evaluation (see README for full instructions)
