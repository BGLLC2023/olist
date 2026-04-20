# Olist E-Commerce Analysis

SQL and Tableau analysis of the Brazilian Olist marketplace with business recommendations.

---

## Full Case Study

For the complete analysis, findings, and recommendations, see the full write-up:

**[View the Olist E-Commerce Analysis Case Study](https://docs.google.com/document/d/1l6B1RMAvpEtwTlNvIShaVVeyX6uMdXco7NbAQRmad9g/edit?usp=sharing)**

## Interactive Dashboard

**[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/greg.lauray4016/viz/olistanalysis2/locationmetrics)**

---

## Project Summary

This project analyzes the Brazilian E-Commerce Public Dataset by Olist (~96,000 orders, 2016–2018) to answer three core business questions for Olist's marketplace team:

1. Which product categories are underperforming on customer reviews, and what are the next steps to address them?
2. How does demand for seasonal categories (air conditioning) trend over time, and how should Olist prepare for peak season?
3. Which Brazilian states drive the most customer volume, and what does performance look like in those key markets?

## Tools & Techniques

- **Database:** MySQL Workbench (normalized schema, 8 tables, foreign key constraints)
- **Visualization:** Tableau Public
- **Version Control:** GitHub
- **SQL Techniques:** CTEs, joins, window functions (DENSE_RANK with PARTITION BY), conditional aggregation

## Key Findings

1. **São Paulo dominates customer volume** — ~54% of top-state customers, far outpacing Rio de Janeiro and Minas Gerais.
2. **Air conditioning revenue is sharply seasonal** — revenue surged 347% from August to November 2017 (Black Friday), then contracted 66% into December.
3. **Five categories show chronically low review scores** — alimentos, cama_mesa_banho, fraldas_higiene, moveis_decoracao, and telefonia all average below 3.0.
4. **Top SP sellers maintain consistently high review scores** — ranging from 4.75 to 4.96.
5. **Platform-wide baseline** — ~$1.3M total revenue across 8,981 delivered orders, $145 AOV, 4.0 average review score.
6. **On-time delivery rates vary significantly by state** — northern states achieve near-100%, while AL and other northeastern states are weakest.
7. **Top SP categories** — automotivo and esporte_lazer lead in most-purchased categories across São Paulo cities.

## Recommendations

1. **Apply NLP (topic modeling + sentiment analysis) to diagnose low-review categories** using the Portuguese `review_comment_message` field, converting a flagged-product list into an action plan by failure mode.
2. **Align air conditioning marketing and inventory with the Q4 demand curve** — launch campaigns in September, stage inventory in October, taper in December.

See the [full case study](https://docs.google.com/document/d/1l6B1RMAvpEtwTlNvIShaVVeyX6uMdXco7NbAQRmad9g/edit?usp=sharing) for detailed analysis, recommendations, and limitations.

---

## Repository Contents

- `olist_analysis.sql` — Schema creation, data migration, and all analysis queries
- `README.md` — This file

## Dataset

[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Author

**Greg Lauray**

- Email: [greglaurayjr@gmail.com](mailto:greglaurayjr@gmail.com)
- LinkedIn: [linkedin.com/in/greg-lauray-040285254](https://www.linkedin.com/in/greg-lauray-040285254/)

**Skills:** SQL · Python · scikit-learn · FastAPI · Pydantic · SQLAlchemy · Tableau
