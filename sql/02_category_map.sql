-- 02_category_map.sql
-- Creates the lookup table that maps PDF filenames to guideline names, categories, and source URLs.
-- This enables per-specialty filtering and clean citations.

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE APP_WH;

CREATE OR REPLACE TABLE EXPLORER_SANDBOX.EBOC_RAG.CATEGORY_MAP (
    pdf_filename VARCHAR,
    guideline_name VARCHAR,
    category VARCHAR,
    source_url VARCHAR
);

INSERT INTO EXPLORER_SANDBOX.EBOC_RAG.CATEGORY_MAP VALUES
('ADHD Guideline Final.pdf', 'ADHD: Screening and Diagnosis', 'Behavioral', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/ADHD%20Guideline%20Final.pdf'),
('Autism Guideline FINAL.pdf', 'Autism Spectrum Disorder: Screening and Diagnosis', 'Behavioral', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Autism%20Guideline%20FINAL.pdf'),
('Kawasaki Guideline FINAL 3.12.2025.pdf', 'Kawasaki Disease: Diagnosis and Management', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Kawasaki%20Guideline%20FINAL%203.12.2025.pdf'),
('Arterial Thrombosis Guideline FINAL 2.26.20.pdf', 'Vascular Thrombosis: Arterial Thrombosis', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Arterial%20Thrombosis%20Guideline%20FINAL%202.26.20.pdf'),
('Venous Thrombosis Guideline FINAL 08.2023.pdf', 'Vascular Thrombosis: Venous Thrombosis', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Venous%20Thrombosis%20Guideline%20FINAL%2008.2023.pdf'),
('Acute Ischemic Stroke Guideline FINAL02.26.2026_A.pdf', 'Acute Ischemic Stroke', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Acute%20Ischemic%20Stroke%20Guideline%20FINAL02.26.2026_A.pdf'),
('Acute Ischemic Stroke Algorithm HOUSTON FINAL02.26.2026.pdf', 'Acute Ischemic Stroke: Houston Algorithm', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Acute%20Ischemic%20Stroke%20Algorithm%20HOUSTON%20FINAL02.26.2026.pdf'),
('Acute Ischemic Stroke Algorithm AUSTIN FINAL02.26.2026.pdf', 'Acute Ischemic Stroke: Austin Algorithm', 'Cardiovascular', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Acute%20Ischemic%20Stroke%20Algorithm%20AUSTIN%20FINAL02.26.2026.pdf'),
('AGE Clinical Guideline FINAL.pdf', 'Acute Gastroenteritis (AGE)', 'Digestive', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/AGE%20Clinical%20Guideline%20FINAL.pdf'),
('Continuous Glucose Monitoring in Pediatric Type 1 Diabetes Mellitus Patients FINAL.docx.pdf', 'Diabetes: Continuous Glucose Monitoring in Type 1 DM', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Continuous%20Glucose%20Monitoring%20in%20Pediatric%20Type%201%20Diabetes%20Mellitus%20Patients%20FINAL.docx.pdf'),
('DKAGuideline_FINAL.pdf', 'Diabetes: Diabetic Ketoacidosis (DKA)', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/DKAGuideline_FINAL.pdf'),
('HHS Guideline FINAL.pdf', 'Diabetes: Hyperglycemic Hyperosmolar State (HHS)', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/HHS%20Guideline%20FINAL.pdf'),
('DiabetesandPerioperativeManagement 01032020 Reaffirmed.pdf', 'Diabetes: Perioperative Management', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/DiabetesandPerioperativeManagement%2001032020%20Reaffirmed.pdf'),
('Childhood Obesity Guideline FINAL.pdf', 'Overweight and Obesity', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Childhood%20Obesity%20Guideline%20FINAL.pdf'),
('Perioperative Management of Well-Differentiated Thyroid Carcinoma FINAL.pdf', 'Thyroid Carcinoma: Perioperative Management', 'Endocrine', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Perioperative%20Management%20of%20Well-Differentiated%20Thyroid%20Carcinoma%20FINAL.pdf'),
('UTI Guideline FINAL.pdf', 'Urinary Tract Infection, First Febrile', 'Genitourinary', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/UTI%20Guideline%20FINAL.pdf'),
('Malnutrition Pathway 2023 FINAL.pdf', 'Malnutrition (Failure to Thrive)', 'Growth', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Malnutrition%20Pathway%202023%20FINAL.pdf'),
('Red Blood Cell Transfusion Guideline FINAL.pdf', 'Red Blood Cell Transfusions', 'Hematological', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Red%20Blood%20Cell%20Transfusion%20Guideline%20FINAL.pdf'),
('Sickle Cell Acute and Chronic Pain Guideline FINAL.pdf', 'Sickle Cell Disease: Acute and Chronic Pain', 'Hematological', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Sickle%20Cell%20Acute%20and%20Chronic%20Pain%20Guideline%20FINAL.pdf'),
('Sickle Cell ACS Pathway Document FINAL.pdf', 'Sickle Cell Disease: Acute Chest Syndrome', 'Hematological', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Sickle%20Cell%20ACS%20Pathway%20Document%20FINAL.pdf'),
('Sickle Cell Fever Pathway Document FINAL.pdf', 'Sickle Cell Disease With Fever', 'Hematological', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Sickle%20Cell%20Fever%20Pathway%20Document%20FINAL.pdf'),
('CLABSI Diagnosis and Managemenrt Guideline FINAL.pdf', 'CLABSI: Diagnosis and Management', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/CLABSI%20Diagnosis%20and%20Managemenrt%20Guideline%20FINAL.pdf'),
('CLABSI Prevention Guideline.Final.02.23.21.pdf', 'CLABSI: Prevention', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/CLABSI%20Prevention%20Guideline.Final.02.23.21.pdf'),
('COVID 19 Guideline FINAL.pdf', 'COVID-19: Care of Hospitalized Patient', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/COVID%2019%20Guideline%20FINAL.pdf'),
('FWLS 0-60 Days Guideline FINAL.pdf', 'Fever Without Localizing Signs, 0-60 Days', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/FWLS%200-60%20Days%20Guideline%20FINAL.pdf'),
('FWLS2-36Mos_Guideline_FINAL.pdf', 'Fever Without Localizing Signs, 2-36 Months', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/FWLS2-36Mos_Guideline_FINAL.pdf'),
('MSK Infections Guideline FINAL FEB 2024.pdf', 'Osteomyelitis / Septic Arthritis', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/MSK%20Infections%20Guideline%20FINAL%20FEB%202024.pdf'),
('Septic_Shock_Guideline_FINAL.pdf', 'Septic Shock: Recognition and Initial Management', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Septic_Shock_Guideline_FINAL.pdf'),
('SSTI Guideline FINAL.pdf', 'Skin and Soft Tissue Infection / Abscess', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/SSTI%20Guideline%20FINAL.pdf'),
('Management of Possible Infectious Complications for Patients with an Artificial Airway Pathway FINAL.pdf', 'Infectious Complications with Artificial Airway', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Management%20of%20Possible%20Infectious%20Complications%20for%20Patients%20with%20an%20Artificial%20Airway%20Pathway%20FINAL.pdf'),
('CAP Guideline FINAL.pdf', 'Community-Acquired Pneumonia', 'Infection', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/CAP%20Guideline%20FINAL.pdf'),
('Ketamine Summary FINAL.pdf', 'Ketamine Subanesthetic IV Infusions for Analgesia', 'Medications', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Ketamine%20Summary%20FINAL.pdf'),
('Synagis Evidence Summary 2.14.20 final.pdf', 'Palivizumab (Synagis) Prophylaxis', 'Medications', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Synagis%20Evidence%20Summary%202.14.20%20final.pdf'),
('Procedural Sedation Guideline FINAL.pdf', 'Procedural Sedation', 'Medications', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Procedural%20Sedation%20Guideline%20FINAL.pdf'),
('Wound Care Guideline.FINAL.pdf', 'Management of Acute and Chronic Wounds', 'Musculoskeletal', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Wound%20Care%20Guideline.FINAL.pdf'),
('Spinal Instrumentation EI Pathway Nov 2021.pdf', 'Spinal Instrumentation: Intraoperative Infection Prevention', 'Musculoskeletal', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Spinal%20Instrumentation%20EI%20Pathway%20Nov%202021.pdf'),
('Hyperbili Guideline FINAL (External Webpage Version) No Internal Link.pdf', 'Hyperbilirubinemia', 'Neonatal', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Hyperbili%20Guideline%20FINAL%20(External%20Webpage%20Version)%20No%20Internal%20Link.pdf'),
('Headaches Evidence Summary 2023 FINAL.pdf', 'Migraine Headaches: Treatment in the EC', 'Nervous', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Headaches%20Evidence%20Summary%202023%20FINAL.pdf'),
('Status Epilepticus Guideline Final.pdf', 'Status Epilepticus: Initial Management', 'Nervous', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Status%20Epilepticus%20Guideline%20Final.pdf'),
('Closed Head Injuries Evidence Summary FINAL.pdf', 'Closed Head Injury: Initial Assessment in EC', 'Nervous', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Closed%20Head%20Injuries%20Evidence%20Summary%20FINAL.pdf'),
('Concussion Concensus Clinical Pathway final3.30.2023.pdf', 'Evaluation and Management of Pediatric Concussion', 'Nervous', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Concussion%20Concensus%20Clinical%20Pathway%20final3.30.2023.pdf'),
('Severe TBI Guideline 2023 FINAL.pdf', 'Traumatic Brain Injury, Severe', 'Nervous', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Severe%20TBI%20Guideline%202023%20FINAL.pdf'),
('Appendicitis Guideline FINAL.pdf', 'Acute Appendicitis / Appendectomy', 'Perioperative', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Appendicitis%20Guideline%20FINAL.pdf'),
('Bromage Scale ES 01032020 Reaffirmed.pdf', 'Bromage Scale: Leg Weakness After Epidural Analgesia', 'Perioperative', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Bromage%20Scale%20ES%2001032020%20Reaffirmed.pdf'),
('Craniosynostosis Pathway FINAL.pdf', 'Craniosynostosis: Preoperative Management', 'Perioperative', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Craniosynostosis%20Pathway%20FINAL.pdf'),
('Spontaneous_Pneumothorax_Guideline_Update_FINAL5.21.2024.pdf', 'Pneumothorax, Primary Spontaneous', 'Perioperative', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Spontaneous_Pneumothorax_Guideline_Update_FINAL5.21.2024.pdf'),
('T&A Guideline update 8.17.2023.pdf', 'Tonsillectomy and Adenoidectomy: Perioperative Management', 'Perioperative', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/T%26A%20Guideline%20update%208.17.2023.pdf'),
('Acut Asthma Guideline Final.pdf', 'Asthma: Acute Exacerbations', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Acut%20Asthma%20Guideline%20Final.pdf'),
('TCH Chronic Asthma Guideline FINAL.pdf', 'Asthma: Chronic Management', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/TCH%20Chronic%20Asthma%20Guideline%20FINAL.pdf'),
('BRUE Guideline_Final.pdf', 'Brief Resolved Unexplained Event (BRUE)', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/BRUE%20Guideline_Final.pdf'),
('BRAND-33412-25-BRUE Flyer_English_Final.pdf', 'BRUE: Parent Information Sheet (English)', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/standards/BRAND-33412-25-BRUE%20Flyer_English_Final.pdf'),
('BRAND-33412-25-BRUE Flyer-Spanish_Final.pdf', 'BRUE: Parent Information Sheet (Spanish)', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/standards/BRAND-33412-25-BRUE%20Flyer-Spanish_Final.pdf'),
('BronchiolitisGuideline_FINAL.pdf', 'Bronchiolitis', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/BronchiolitisGuideline_FINAL.pdf'),
('Croup Guideline_update 8.9.2021.pdf', 'Croup', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/outcomes/2024%20standards/Croup%20Guideline_update%208.9.2021.pdf'),
('HFNCPathway_FINAL.pdf', 'High Flow Nasal Cannula Therapy', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/HFNCPathway_FINAL.pdf'),
('OxygenWeaningEIPathway_FINAL.pdf', 'Oxygen Weaning Protocol', 'Respiratory', 'https://www.texaschildrens.org/sites/tc/files/uploads/documents/OxygenWeaningEIPathway_FINAL.pdf');

-- Verify
SELECT category, COUNT(*) AS cnt FROM EXPLORER_SANDBOX.EBOC_RAG.CATEGORY_MAP GROUP BY category ORDER BY cnt DESC;
