# hospital-flow-insights
Data-driven analysis of hospital admission patterns, patient flow, doctor workload, and length of stay to uncover operational insights and support better healthcare decision-making.

*** Data Cleaning Summary ***

Removed duplicate records to keep admissions unique

Standardized categorical values (gender, admission_type, etc.)

Anonymized patient names with SHA-256 for HIPAA compliance

Created unique IDs for patients, doctors, and admissions

Calculated Length of Stay (LOS) from admission & discharge dates

Added time features (year, month, day of week) for trend analysis

Dropped unnecessary columns (e.g., patient_name)

✅ Dataset is now clean, compliant, and ready for modeling & SQL analysis.
