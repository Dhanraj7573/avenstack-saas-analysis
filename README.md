# avenstack-saas-analysis

# Ravenstack SaaS Churn Analysis
**SQL Portfolio Project | SQLite | Dhanraj Dodiya**

---

## Project Overview

This project analyses customer churn for **Ravenstack**, a fictional B2B SaaS company, using a 5-table relational dataset containing 500 accounts, 600 churn events, 25,000 feature usage logs, and 2,000 support tickets.

The goal was to answer one core business question:

> **Why are customers leaving, and what can the business do about it?**

All analysis was performed in **SQL (SQLite)** inside VS Code.

---

## Dataset

| Table | Rows | Description |
|---|---|---|
| `accounts` | 500 | Customer accounts — plan tier, industry, churn flag |
| `subscriptions` | 500 | Subscription details — MRR, billing cycle, status |
| `churn_events` | 600 | Cancellation records — reason code, refund amount |
| `feature_usage` | 25,000 | Product usage logs — feature, usage count, errors |
| `support_tickets` | 2,000 | Support history — priority, satisfaction score, resolution time |

**Source:** [Kaggle — Ravenstack SaaS Analytics Dataset](https://www.kaggle.com)

---

## Schema

```
accounts
  └── account_id (PK)
  └── plan_tier, industry, country, seats, churn_flag

churn_events
  └── account_id (FK → accounts)
  └── reason_code, refund_amount_usd, churn_date

support_tickets
  └── account_id (FK → accounts)
  └── satisfaction_score, priority, escalation_flag

subscriptions
  └── account_id (FK → accounts)
  └── subscription_id (PK), mrr, plan_name, status

feature_usage
  └── subscription_id (FK → subscriptions)
  └── feature_name, usage_count, error_count, usage_duration_secs
```

---

## Analysis Modules

### Module 1 — Revenue & Churn by Plan Tier
**Table:** `accounts`
**Question:** Which plan tier has the highest churn rate?

| Plan | Accounts | Total Seats | Churn Rate |
|---|---|---|---|
| Enterprise | 154 | 3,032 | 22.1% |
| Basic | 168 | 3,697 | 22.0% |
| Pro | 178 | 3,551 | 21.9% |

**Finding:** Churn rate is virtually identical across all three plan tiers (~22%). This means **price point alone is not driving cancellations** — the problem lies elsewhere.

---

### Module 2 — Why Are Customers Churning?
**Tables:** `accounts` JOIN `churn_events`
**Question:** What are the top reasons for cancellation by plan tier?

| Plan | #1 Reason | Churn % |
|---|---|---|
| Pro | Support | 39.1% |
| Enterprise | Features | 35.5% |
| Basic | Support | 33.6% |

**Finding:** Support quality is the #1 churn driver for Pro and Basic customers. Enterprise customers churn primarily due to missing features — a different problem requiring a different solution.

---

### Module 3 — Which Industries Churn Most?
**Table:** `accounts`
**Question:** Does industry vertical predict churn?

| Industry | Accounts | Churned | Churn Rate |
|---|---|---|---|
| DevTools | 113 | 35 | 31.0% |
| FinTech | 112 | 25 | 22.3% |
| HealthTech | 96 | 21 | 21.9% |
| EdTech | 79 | 13 | 16.5% |
| Cybersecurity | 100 | 16 | 16.0% |

**Finding:** DevTools companies churn at almost **double the rate** of Cybersecurity companies (31% vs 16%). DevTools is also the largest segment by account count — making it both the biggest opportunity and the biggest risk.

---

### Module 4 — The Cost of Poor Support
**Tables:** `accounts` JOIN `churn_events` (filtered by reason_code = 'support')
**Question:** How much has poor support cost the business?

| Plan | Accounts Lost | Total Refunds | Avg Refund |
|---|---|---|---|
| Pro | 43 | $495.22 | $11.52 |
| Basic | 37 | $449.47 | $12.15 |
| Enterprise | 24 | $274.95 | $11.46 |

**Finding:** Pro plan accounts for the highest support-related churn in both volume (43 accounts) and total refunds ($495). Combined with its high churn rate across all reasons, **Pro is the most at-risk tier** in the business.

---

### Module 5 — Feature Usage & Error Rates
**Table:** `feature_usage`
**Question:** Which features are most used and which have the highest error rates?

| Feature | Total Usage | Error Rate | Avg Duration (secs) |
|---|---|---|---|
| feature_32 | 6,686 | 5.3% | 3,114 |
| feature_15 | 6,621 | 5.3% | 3,073 |
| feature_4 | 6,374 | 6.6% | 3,150 |
| feature_9 | 6,207 | 6.5% | 3,007 |
| feature_26 | 6,470 | 6.4% | 3,045 |

**Finding:** The top features by usage all carry error rates between 5–7%, with average session durations of ~50 minutes. High error rates on the most-used features likely contribute to the support-related churn identified in Module 2.

---

## Key Insights Summary

1. **Churn is not a pricing problem** — all three plan tiers churn at ~22%, ruling out price as the primary driver.

2. **Support quality is the #1 churn driver** — cited by 39% of Pro and 33% of Basic churners. This is a systemic issue, not isolated cases.

3. **Enterprise churns for different reasons** — missing features (35.5%) rather than support (21.8%), suggesting a product roadmap gap at the high end.

4. **DevTools is the most at-risk segment** — 31% churn rate vs 16% for Cybersecurity, despite being the largest customer segment.

5. **Pro plan is the biggest business risk** — highest account count, highest churn across every reason code, and highest total refund cost.

---

## SQL Concepts Used

- `GROUP BY` with `COUNT` and `SUM` aggregations
- `CASE WHEN` for conditional logic and pivoting
- `ROUND` for percentage calculations
- `JOIN` across multiple tables via `account_id` and `subscription_id`
- Subqueries for percentage-of-total calculations
- `WITH` CTEs for multi-step analysis
- `ORDER BY` for ranked outputs
- Filtering with `WHERE` on categorical fields

---

## Tools

- **Database:** SQLite
- **Editor:** VS Code with SQLite extension
- **Language:** SQL

---

## Author

**Dhanraj Dodiya**
Data & Reporting Lead Analyst | Finance + BI + SQL
[GitHub](https://github.com/Dhanraj7573) | [LinkedIn](https://www.linkedin.com/in/dhanrajdodiya)
