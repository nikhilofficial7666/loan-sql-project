-- ==============================
-- 1. CREATE TABLE
-- ==============================

CREATE TABLE loan_data (
    loan_id INT,
    no_of_dependents INT,
    education TEXT,
    self_employed TEXT,
    income_annum BIGINT,
    loan_amount BIGINT,
    loan_term INT,
    cibil_score INT,
    residential_assets_value BIGINT,
    commercial_assets_value BIGINT,
    luxury_assets_value BIGINT,
    bank_asset_value BIGINT,
    loan_status TEXT
);

-- ==============================
-- 2. DDL COMMAND (ADD COLUMN)
-- ==============================

ALTER TABLE loan_data
ADD COLUMN risk_flag TEXT;

-- ==============================
-- 3. DML COMMAND (UPDATE DATA)
-- ==============================

UPDATE loan_data
SET risk_flag = 
CASE 
    WHEN cibil_score < 600 THEN 'High Risk'
    ELSE 'Low Risk'
END;

-- ==============================
-- 4. BASIC ANALYSIS
-- ==============================

SELECT COUNT(*) FROM loan_data;

SELECT loan_status, COUNT(*)
FROM loan_data
GROUP BY loan_status;

-- ==============================
-- 5. WINDOW FUNCTION (RANK)
-- ==============================

SELECT loan_id, cibil_score,
RANK() OVER (ORDER BY cibil_score DESC) AS credit_rank
FROM loan_data;

-- ==============================
-- 6. COHORT CREATION
-- ==============================

SELECT loan_id,
cibil_score,
CASE 
    WHEN cibil_score >= 750 THEN 'Excellent'
    WHEN cibil_score BETWEEN 650 AND 749 THEN 'Good'
    WHEN cibil_score BETWEEN 550 AND 649 THEN 'Medium'
    ELSE 'High Risk'
END AS credit_cohort
FROM loan_data;

-- ==============================
-- 7. TOP CUSTOMERS
-- ==============================

SELECT *
FROM (
    SELECT 
    loan_id,
    income_annum,
    loan_status,
    RANK() OVER (ORDER BY income_annum DESC) AS income_rank
    FROM loan_data
) t
WHERE loan_status = 'Approved'
LIMIT 5;

-- ==============================
-- 8. FINAL ELIGIBILITY COLUMN
-- ==============================

ALTER TABLE loan_data
ADD COLUMN eligibility TEXT;

UPDATE loan_data
SET eligibility = 
CASE 
WHEN cibil_score >= 700 
AND income_annum >= 3000000 
AND (loan_amount::float / income_annum) <= 0.5
THEN 'ELIGIBLE'
ELSE 'NOT ELIGIBLE'
END;

-- ==============================
-- 9. FINAL OUTPUT CHECK
-- ==============================

SELECT loan_id, cibil_score, income_annum, loan_amount, eligibility
FROM loan_data;