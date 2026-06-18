-- =============================================
-- RAVENSTACK SAAS PROJECT -- SETUP
-- =============================================

-- 1. ACCOUNTS
CREATE TABLE IF NOT EXISTS accounts (
    account_id        TEXT,
    account_name      TEXT,
    industry          TEXT,
    country           TEXT,
    signup_date       TEXT,
    referral_source   TEXT,
    plan_tier         TEXT,
    seats             INTEGER,
    is_trial          TEXT,
    churn_flag        TEXT
);

-- 2. SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id   TEXT,
    account_id        TEXT,
    churn_date        TEXT,
    reason_code       TEXT,
    refund_amount_usd REAL,
    preceding_upgrade_flag   TEXT,
    preceding_downgrade_flag TEXT,
    is_reactivation   TEXT,
    feedback_text     TEXT
);

-- 3. CHURN EVENTS
CREATE TABLE IF NOT EXISTS churn_events (
    churn_event_id    TEXT,
    account_id        TEXT,
    churn_date        TEXT,
    reason_code       TEXT,
    refund_amount_usd REAL,
    preceding_upgrade_flag   TEXT,
    preceding_downgrade_flag TEXT,
    is_reactivation   TEXT,
    feedback_text     TEXT
);

-- 4. FEATURE USAGE
CREATE TABLE IF NOT EXISTS feature_usage (
    usage_id           TEXT,
    subscription_id    TEXT,
    usage_date         TEXT,
    feature_name       TEXT,
    usage_count        INTEGER,
    usage_duration_secs INTEGER,
    error_count        INTEGER,
    is_beta_feature    TEXT
);

-- 5. SUPPORT TICKETS
CREATE TABLE IF NOT EXISTS support_tickets (
    ticket_id                  TEXT,
    account_id                 TEXT,
    submitted_at               TEXT,
    closed_at                  TEXT,
    resolution_time_hours      REAL,
    priority                   TEXT,
    first_response_time_minutes REAL,
    satisfaction_score         REAL,
    escalation_flag            TEXT
);

SELECT * FROM accounts limit 10;

SELECT * FROM accounts limit 10;
SELECT * FROM churn_events limit 10;
SELECT * FROM feature_usage limit 10;
SELECT * FROM support_tickets limit 10;

-- Clean header rows imported as data
DELETE FROM accounts WHERE account_id = 'account_id';
DELETE FROM churn_events WHERE churn_event_id = 'churn_event_id';
DELETE FROM feature_usage WHERE usage_id = 'usage_id';
DELETE FROM support_tickets WHERE ticket_id = 'ticket_id';


-- =============================================
-- MODULE 1: Revenue baseline by plan tier
-- =============================================

select plan_tier,
       count(*) as num_aaccounts, 
       sum(seats) as total_seats,
       sum(seats * case plan_tier when 'Basic' then 10 
                                when 'Pro' then 20
                                  when 'Enterprise' then 50
                                  else 0 end) as total_revenue,
        round(100.0 * sum(case when churn_flag = 'True' then 1 else 0 end) / count(*),1) as churn_rate_pct  
from accounts
group by plan_tier
order by total_revenue desc;

---Module 2: Churn analysis by plan tier (what are the top reasons for customers are leaving)


select plan_tier,
       reason_code,
       count(*) as num_churned_accounts,
       round(100.0 * count(*) / (select count(*) from accounts where churn_flag = 'True'),1) as churn_pct
from accounts a
join churn_events c on a.account_id = c.account_id
group by plan_tier, reason_code
order by plan_tier, churn_pct desc;


---Modue 3: which industries are churning the most

SELECT
    industry,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned,
    ROUND(100.0 * SUM(CASE WHEN churn_flag = 'True' 
        THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM accounts
GROUP BY industry
ORDER BY churn_rate_pct DESC;

---Module 4 — Do customers with bad support experience churn more?
WITH abc AS (
    SELECT
        reason_code,
        SUM(CASE WHEN a.plan_tier = 'Pro'        THEN 1 ELSE 0 END) AS pro_count,
        SUM(CASE WHEN a.plan_tier = 'Basic'      THEN 1 ELSE 0 END) AS basic_count,
        SUM(CASE WHEN a.plan_tier = 'Enterprise' THEN 1 ELSE 0 END) AS enterprise_count,
        COUNT(*) AS total
    FROM accounts a
    JOIN churn_events c ON a.account_id = c.account_id
    GROUP BY reason_code
)
SELECT *
FROM abc
ORDER BY total DESC;
       
-- Support damage by plan tier
-- How much has poor support cost us in lost accounts and refunds?

SELECT
    a.plan_tier,
    COUNT(*)                        AS accounts_lost,
    ROUND(SUM(c.refund_amount_usd), 2) AS total_refunds_usd,
    ROUND(AVG(c.refund_amount_usd), 2) AS avg_refund_per_account
FROM accounts a
JOIN churn_events c ON a.account_id = c.account_id
WHERE c.reason_code = 'support'
GROUP BY a.plan_tier
ORDER BY total_refunds_usd DESC;

-- Module 5: Feature usage and error rates
-- Which features are most used and which ones fail the most?

SELECT
    feature_name,
    SUM(usage_count)                    AS total_usage,
    SUM(error_count)                    AS total_errors,
    ROUND(100.0 * SUM(error_count) 
        / SUM(usage_count), 1)          AS error_rate_pct,
    ROUND(AVG(usage_duration_secs), 0)  AS avg_duration_secs
FROM feature_usage
GROUP BY feature_name
ORDER BY total_usage DESC;