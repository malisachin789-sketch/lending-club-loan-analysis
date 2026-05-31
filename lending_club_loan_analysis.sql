-- ================================================
-- PROJECT 1: Lending Club Loan Analysis
-- TOOL: MySQL
-- DATASET: Lending Club (Kaggle) — 1,00,000 rows
-- ANALYST: Sachin Malee
-- ================================================

USE bank_loan_db;

-- ================================================
-- BUSINESS PROBLEM 1: Overall Loan Summary
-- ================================================

SELECT
    COUNT(*)                                AS total_loans,
    ROUND(SUM(loan_amount), 2)               AS total_loan_amount,
    ROUND(AVG(loan_amount), 2)               AS avg_loan_amount,
    ROUND(AVG(int_rate), 2)                AS avg_interest_rate,
    ROUND(AVG(dti), 2)                     AS avg_dti,
    ROUND(AVG(annual_income), 2)              AS avg_annual_income,
    -- Default rate (Charged Off)
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                     AS default_rate_pct,
    -- Fully Paid rate
    ROUND(SUM(CASE
        WHEN loan_status = 'Fully Paid'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                     AS fully_paid_pct
FROM loan_data;


-- ================================================
-- BUSINESS PROBLEM 2: Loan Status Distribution
-- ================================================
SELECT
    loan_status,
    COUNT(*)                                AS total_loans,
    ROUND(COUNT(*) * 100.0 /
	SUM(COUNT(*)) OVER(), 2)           		AS percentage,
    ROUND(AVG(loan_amount), 2)              AS avg_loan_amount,
    ROUND(AVG(int_rate), 2)                	AS avg_interest_rate,
	ROUND(AVG(annual_income), 2) 			AS avg_income 
FROM loan_data
GROUP BY loan_status
ORDER BY total_loans DESC;

-- ================================================
-- BUSINESS PROBLEM 3: Loan Grade Analysis
-- ================================================
SELECT
    grade,
    COUNT(*)                                AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off, 
    ROUND(AVG(int_rate), 2)                AS avg_interest_rate,
    ROUND(AVG(loan_amount), 2)               AS avg_loan_amount,
    ROUND(AVG(dti), 2)                     AS avg_dti,
    -- Default rate per grade
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                     AS default_rate_pct,
    RANK() OVER (
        ORDER BY SUM(CASE
            WHEN loan_status = 'Charged Off'
            THEN 1 ELSE 0 END) * 100.0
            / COUNT(*) DESC)               AS risk_rank
FROM loan_data
GROUP BY grade
ORDER BY grade;

-- ================================================
-- BUSINESS PROBLEM 4: Loan Purpose Analysis
-- ================================================
SELECT
    purpose,
    COUNT(*)                                AS total_loans,
    ROUND(SUM(loan_amount), 2)               AS total_amount,
    ROUND(AVG(loan_amount), 2)               AS avg_loan_amount,
    ROUND(AVG(int_rate), 2)                AS avg_interest_rate,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                     AS default_rate_pct,
    RANK() OVER (
        ORDER BY COUNT(*) DESC)            AS popularity_rank
FROM loan_data
GROUP BY purpose
ORDER BY total_loans DESC;

-- ================================================
-- BUSINESS PROBLEM 5: Income vs Loan Analysis
-- ================================================
WITH income_bands AS (
    SELECT *,
        CASE
            WHEN annual_income < 40000
                THEN '1. Low (<40K)'
            WHEN annual_income BETWEEN 40000
                AND 80000
                THEN '2. Medium (40K-80K)'
            WHEN annual_income BETWEEN 80000
                AND 150000
                THEN '3. High (80K-150K)'
            ELSE '4. Very High (150K+)'
        END                                AS income_band,
        ROUND(loan_amount /
            NULLIF(annual_income, 0)
            * 100, 2)                      AS loan_to_income_pct
    FROM loan_data
    WHERE annual_income > 0
      AND annual_income < 500000
)
SELECT
    income_band,
    COUNT(*)                               AS total_loans,
    ROUND(AVG(loan_amount), 2)              AS avg_loan,
    ROUND(AVG(loan_to_income_pct), 2)     AS avg_loan_to_income_pct,
    ROUND(AVG(int_rate), 2)               AS avg_interest_rate,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                    AS default_rate_pct
FROM income_bands
GROUP BY income_band
ORDER BY income_band;

-- ================================================
-- BUSINESS PROBLEM 6: Employment Length Impact
-- ================================================
SELECT
    emp_length,
    COUNT(*)                               AS total_loans,
    ROUND(AVG(loan_amount), 2)             AS avg_loan,
    ROUND(AVG(annual_income), 2)            AS avg_income,
    ROUND(AVG(int_rate), 2)              AS avg_rate,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                   AS default_rate_pct
FROM loan_data
WHERE emp_length IS NOT NULL
GROUP BY emp_length
ORDER BY default_rate_pct DESC;

-- ================================================
-- BUSINESS PROBLEM 7: Home Ownership Analysis
-- ================================================
SELECT
    home_ownership,
    COUNT(*)                               AS total_loans,
    ROUND(AVG(loan_amount), 2)             AS avg_loan,
    ROUND(AVG(annual_income), 2)            AS avg_income,
    ROUND(AVG(dti), 2)                   AS avg_dti,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                   AS default_rate_pct
FROM loan_data
WHERE home_ownership IN (
    'RENT','MORTGAGE','OWN')
GROUP BY home_ownership
ORDER BY default_rate_pct DESC;

-- ================================================
-- BUSINESS PROBLEM 8: Loan Term Analysis
-- ================================================
SELECT
    term,
    COUNT(*)                               AS total_loans,
    ROUND(SUM(loan_amount), 2)             AS total_amount,
    ROUND(AVG(loan_amount), 2)             AS avg_loan,
    ROUND(AVG(int_rate), 2)              AS avg_interest_rate,
    ROUND(AVG(dti), 2)                   AS avg_dti,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                   AS default_rate_pct
FROM loan_data
GROUP BY term
ORDER BY term;

-- ================================================
-- BUSINESS PROBLEM 9: Top 10 States by Volume
-- ================================================
SELECT
    addr_state                             AS state,
    COUNT(*)                               AS total_loans,
    ROUND(SUM(loan_amount), 2)             AS total_amount,
    ROUND(AVG(loan_amount), 2)             AS avg_loan,
    ROUND(AVG(int_rate), 2)              AS avg_rate,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                   AS default_rate_pct,
    RANK() OVER (
        ORDER BY COUNT(*) DESC)          AS volume_rank
FROM loan_data
GROUP BY addr_state
ORDER BY total_loans DESC
LIMIT 10;

-- ================================================
-- BUSINESS PROBLEM 10: Monthly Trend Analysis
-- ================================================
WITH monthly AS (
    SELECT
        YEAR(issue_date)                      AS yr,
        MONTH(issue_date)                     AS mn,
        DATE_FORMAT(issue_date, '%Y-%m')      AS years_month,
        COUNT(*)                           AS total_loans,
        ROUND(SUM(loan_amount), 2)          AS total_amount,
        ROUND(AVG(int_rate), 2)           AS avg_rate
    FROM loan_data
    WHERE issue_date IS NOT NULL
    GROUP BY yr, mn, years_month
)
SELECT
    years_month,
    total_loans,
    total_amount,
    avg_rate,
    LAG(total_loans) OVER (
        ORDER BY yr, mn)                  AS prev_month_loans,
    ROUND((total_loans -
        LAG(total_loans) OVER (
            ORDER BY yr, mn)) * 100.0
        / NULLIF(LAG(total_loans) OVER (
            ORDER BY yr, mn), 0)
    , 2)                                  AS mom_growth_pct,
    SUM(total_amount) OVER (
        ORDER BY yr, mn
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW)                  AS cumulative_amount
FROM monthly
ORDER BY yr, mn;

-- ================================================
-- BUSINESS PROBLEM 11: DTI Risk Analysis
-- ================================================
WITH dti_bands AS (
    SELECT *,
        CASE
            WHEN dti < 10
                THEN '1. Low (<10)'
            WHEN dti BETWEEN 10 AND 20
                THEN '2. Medium (10-20)'
            WHEN dti BETWEEN 20 AND 30
                THEN '3. High (20-30)'
            ELSE '4. Very High (30+)'
        END                               AS dti_band
    FROM loan_data
    WHERE dti BETWEEN 0 AND 100
)
SELECT
    dti_band,
    COUNT(*)                              AS total_loans,
    ROUND(AVG(loan_amount), 2)            AS avg_loan,
    ROUND(AVG(int_rate), 2)             AS avg_rate,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                  AS default_rate_pct
FROM dti_bands
GROUP BY dti_band
ORDER BY dti_band;


-- ================================================
-- BUSINESS PROBLEM 12: High Risk Profile
-- ================================================
WITH risk_profile AS (
    SELECT *,
        CASE
            WHEN grade IN ('F','G')
             AND int_rate > 25
             AND dti > 30
            THEN 'Very High Risk'
            WHEN grade IN ('D','E')
             AND int_rate > 18
             AND dti > 25
            THEN 'High Risk'
            WHEN grade IN ('B','C')
             AND int_rate > 12
            THEN 'Medium Risk'
            ELSE 'Low Risk'
        END                               AS risk_category
    FROM loan_data
    WHERE dti BETWEEN 0 AND 100
)
SELECT
    risk_category,
    COUNT(*)                              AS total_loans,
    ROUND(AVG(loan_amount), 2)            AS avg_loan,
    ROUND(AVG(int_rate), 2)             AS avg_rate,
    ROUND(AVG(dti), 2)                  AS avg_dti,
    ROUND(SUM(CASE
        WHEN loan_status = 'Charged Off'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)                  AS actual_default_pct
FROM risk_profile
GROUP BY risk_category
ORDER BY actual_default_pct DESC;


