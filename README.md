# 🏥 Digital Health Care Tele-Rehabilitation Analytics – dbt + Snowflake + Tableau Project

### End-to-End Analytics Engineering Workflow for Patient Engagement & Therapy Success Tracking

---

## 📘 Project Overview

This project showcases how I designed and implemented a **modern analytics engineering pipeline** — from **raw data ingestion** to **business-ready insights** — for a simulated *digital rehabilitation platform*.

The dataset captures how patients progress through therapy modules across multiple clinics.  
The goal: build a scalable data foundation and visualize **therapy success**, **engagement trends**, and **clinic performance**.

---

## ⚙️ Tech Stack

| Layer | Tool | Purpose |
|-------|------|----------|
| 🧱 Data Warehouse | **Snowflake** | Secure storage and compute |
| 🔁 Transformation | **dbt (Data Build Tool)** | Modular ELT modeling and data testing |
| 📊 Visualization | **Tableau** | Data storytelling and KPI reporting |
| 💬 Language | **SQL** | Transformations, metrics, and analysis |

---

## 🧭 Architecture: The Medallion Model

📊 **Bronze → Silver → Gold**

| Layer | Description | Example |
|--------|--------------|----------|
| **Bronze (Raw)** | Ingested CSVs (patients, clinics, modules) with minimal processing | `bronze_clinics_with_patients_raw` |
| **Silver (Cleaned)** | Cleaned and standardized data: date parsing, null handling, naming consistency | `silver_clinics_with_patients_cleaned` |
| **Gold (Analytics)** | Business-ready model combining all sources for reporting | `gold_patient_module_activity` |

### 🖼 Pipeline Overview  
<p align="center">
  <img src="Screenshot 2025-11-04 214529.png" alt="Daily Conversion and User Journey Dashboard" width="700"/>
</p>

**Figure 1:** *📸 Screenshot of dbt lineage view (Bronze → Silver → Gold).*

---

## 📈 Tableau Dashboard

### **1️⃣ Therapy & Engagement Overview**
- **KPI Scorecards:** Therapy success rate, engagement rate, and patient growth  
- **Time-Series Trend:** Patients created vs. modules completed (Month-Year parameter)  
- **Filters:** Clinic title, clinic group, and time granularity (Month / Quarter / Week)

### **2️⃣ Clinic Performance Matrix**
- **Scatter Plot:** Patient volume (X-axis) vs. Success completion rate (Y-axis)  
- **Quadrants:**  
  - 🥇 *Top Performer* – High Volume / High Success  
  - ⚠️ *Needs Support* – High Volume / Low Success  
  - 🌱 *Growth Potential* – Low Volume / High Success  
  - 🧭 *Under Review* – Low Volume / Low Success  
- **Context Lines:** Average volume and success rates (LOD-calculated)

<p align="center">
  <img src="Screenshot 2025-11-05 113739.png" alt="Daily Conversion and User Journey Dashboard" width="700"/>
</p>

**Figure 2:** *📸 Screenshot of dashboard.*
---

## 🧱 Data Preparation (Snowflake + dbt)

### ✳️ Transformations & Handling Decisions

1. **Column Name Standardization**  
   → All fields renamed to `snake_case` for consistent references across layers.

2. **Clinic Metadata Gaps**  
   → Missing `clinic_group` entries replaced with `'Unknown'`; enforced referential integrity with LEFT JOINs.

3. **Removed Incomplete Time Periods**  
   → Excluded partial months (2018, early 2019, and April 2021) from time-series visualizations to avoid skewed insights.

4. **Date Parsing and Standardization**  
   → Converted inconsistent timestamp strings using `TRY_TO_DATE()` for Snowflake compatibility.

5. **Continuous Date Field**  
   → Built continuous date field for smoother trends, allowing Tableau to connect monthly observations naturally.

6. **Month–Year Parameter Filter**  
   → Replaced discrete year filters with dynamic *Month–Year parameters* for flexible granularity.

<p align="center">
  <img src="Screenshot 2025-11-04 215702.png" alt="Daily Conversion and User Journey Dashboard" width="700"/>
</p>

**Figure 3:** *📸 Screenshot of DIGITAL_HEALTH_ANALYTICS.GOLD.PATIENT_MODULE_ACTIVITY*

---

## 🧮 Key SQL Logic (Core Queries)

### **A. Busines Metrics**
```sql
-- Aggregate patient modules and compute success completion rates
WITH Patient_Lifetime_Modules AS (
    SELECT
        PATIENT_ID,
        CLINIC_TITLE,
        SUM(NUMBER_OF_MODULES) AS LIFETIME_MODULES
    FROM DIGITAL_HEALTH_ANALYTICS.GOLD.PATIENT_MODULE_ACTIVITY
    GROUP BY 1, 2
)
SELECT
    CLINIC_TITLE,
    COUNT(DISTINCT PATIENT_ID) AS TOTAL_PATIENTS,
    SUM(CASE WHEN LIFETIME_MODULES >= 24 THEN 1 ELSE 0 END) AS SUCCESSFUL_PATIENTS,
    ROUND(SUM(CASE WHEN LIFETIME_MODULES >= 24 THEN 1 ELSE 0 END) / COUNT(DISTINCT PATIENT_ID) * 100, 2) AS SUCCESS_COMPLETION_RATE
FROM Patient_Lifetime_Modules
GROUP BY 1;


-- Module completion distribution
SELECT
    CASE
        WHEN modules_completed < 6 THEN '0–5'
        WHEN modules_completed BETWEEN 6 AND 12 THEN '6–12'
        WHEN modules_completed BETWEEN 13 AND 23 THEN '13–23'
        WHEN modules_completed >= 24 THEN '24+ (Successful)'
    END AS completion_band,
    COUNT(DISTINCT patient_id) AS num_patients
FROM gold_patient_module_activity
GROUP BY 1
ORDER BY 1;

```
---
### 📊 Tableau Calculated Fields

The following custom fields were implemented in Tableau to define success, establish network averages, and segment performance.

| Field                                 | Formula                                                                     | Description                                                                                                   |
| ------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Completion Rate**                   | `SUM(IF [Lifetime Modules] >= 24 THEN 1 ELSE 0 END) / COUNTD([Patient ID])` | Measures therapy success rate (24+ modules) as a percentage of total unique patients.                         |
| **Avg Success Completion Rate (LOD)** | `{ FIXED : AVG([Completion Rate]) }`                                        | Global, fixed-level average success rate across the entire network for peer comparison.                       |
| **Avg Patient Volume (LOD)**          | `{ FIXED : AVG(COUNTD([Patient ID])) }`                                     | Global, fixed-level average patient volume for peer comparison.                                               |
| **Clinic Quadrant Label**             | *Conditional logic using above fields*                                      | Conditional logic used to assign quadrant label and color for the color-coded assessment matrix segmentation. |

---

### Key Findings & Strategic Conclusions

1. **Engagement Behavior**

- Early Drop-off: Module completion distribution reveals that a majority of patients drop off early—with over 40% completing fewer than 6 modules.

- Retention Strength: Approximately 30% achieve the 24+ modules threshold, indicating a strong but uneven retention pattern after initial engagement.

2. **Clinic Benchmarking**

- Variability: Clinics exhibit significant variability in success rates and patient volumes.

- Assessment Matrix Impact: The Tableau Assessment Matrix effectively distinguishes between high-performing clinics and those requiring intervention.

- Best Practices: Top-performing clinics combine both engagement consistency and high patient throughput, representing core operational best practices.

3. **Operational Observations**

- Data Integrity: Partial timeframes (2018 and early 2019) showed irregular participation and were excluded to ensure accurate trend analysis.

- Stabilization: Engagement momentum stabilizes after mid-2019, correlating with more structured data and likely the standardization of clinic operations.

4. **Strategic Recommendations**

The following actionable steps were recommended to operational leadership:

- Standardize Protocols: Replicate onboarding and engagement protocols from top-performing clinics across the entire network.

- Investigate Bottlenecks: Conduct deep-dive investigations into high-volume, low-success clinics to diagnose potential workflow or coaching bottlenecks.

- Leading KPI: Continue tracking “Engagement Momentum” (average modules per active patient) as a leading Key Performance Indicator for early success prediction.

---

### 🌐 Project Links

📊 **Dashboard Preview:** [ link]

💻 **Portfolio Page:** [portfolio website link]

---

### ✍️ Author

**Godwin Oti:** Data Analyst

