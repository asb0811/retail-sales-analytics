# Superstore Sales Analytics (2015-2018)

South region's sales fell 32% in 2016 - the worst regional collapse in the dataset. This project investigates why, and finds the answer in product mix, not service quality.

Built with: MySQL, Power BI, Python (Prophet)

## Overview

A 4-year US retail dataset (9,800 transactions, $2.26M sales, 793 customers across 4 regions) analysed end-to-end. SQL diagnostic across 5 business questions, Power BI dashboard for stakeholder communication, and a weekly sales forecast in Python. The original Kaggle brief was a 7-day forecast - that became one component of a wider regional diagnostic.

## Business Questions

The five questions evolved from descriptive to diagnostic as findings emerged. Q1 and Q2 established the baseline. Q3 to Q5 investigated the differences surfaced in Q2.

1. Which categories and sub-categories drive sales, and which are dead weight?
2. How do the four regions compare?
3. What are customers in each region actually buying, and does that explain the AOV gap?
4. Does repeat purchase behaviour differ by region?
5. Is shipping service quality different across regions?

## Key Findings

**The four regions are structurally different markets, not four points on the same curve.**

- **West** is the largest ($710k, 31% of sales) and accelerating - recovered hardest after the 2016 dip.
- **East** is the most reliable. Steady 17 to 20% growth every year, the highest AOV at $489, and the only region that grew in 2016 when everything else fell. The basket is Technology-led (Machines and Copiers in the top 5).
- **South** is small ($389k) but its customers spend well - AOV of $480, second only to East. Took the hardest hit in 2016 (-32%) and took two years to recover.
- **Central** is the concern. Middle revenue ($493k), lowest AOV at $426, flat growth. The top sub-category is Binders at 11.5% of regional sales - the highest single-sub-category concentration in the dataset. Central customers buy cheaper, smaller-basket items.

**Other findings:**

- Three categories carry roughly equal revenue share (Technology 36.6%, Furniture 32.2%, Office Supplies 31.2%) but with completely different volume profiles - Technology is high-ticket low-volume, Office Supplies is the opposite.
- 8 sub-categories drive 78% of revenue. Five (Supplies, Art, Envelopes, Labels, Fasteners) contribute only 4.6% combined and are universal dead weight across every region.
- 2016 was a company-wide down year. East was the only region that grew.
- Shipping time is essentially identical across regions (~4 days average). Service quality does not explain regional performance variance.
- Weekly Prophet forecast achieved ~11% MAPE ($1,623 MAE); daily forecasting failed at ~250% MAPE ($1,531 MAE) due to extreme volatility - the absolute error was similar, but daily values were too small to forecast precisely in percentage terms.

## Recommendations

The data suggests four regional strategies, not one:

- **West** - maintain. The largest region with strong momentum. Protect the engine.
- **East** - defend and replicate. The most reliable and highest-AOV region. Understand what makes East work and see if elements can be applied elsewhere.
- **South** - acquire. Customers are valuable but the base is thin. Focus on customer acquisition rather than basket size.
- **Central** - reposition. Push the product mix toward Technology to lift AOV from $426 toward East's $489. If the market is structurally different, price and serve it differently.

## Methodology

**SQL** ([`sql/01_setup.sql`](sql/01_setup.sql), [`sql/02_eda.sql`](sql/02_eda.sql), [`sql/03_analysis.sql`](sql/03_analysis.sql))

Data loaded into MySQL 8.0. Eight structured EDA checks covering grain, time range, nulls, duplicates, cardinality, outliers, and referential consistency. The standard `IS NULL` check returned zero across all 18 columns, but a follow-up empty-string check (`TRIM(col) = ''`) surfaced 11 records with blank postal codes - all Burlington, Vermont (Vermont ZIPs start with `0`, a known leading-zero issue in CSV preparation). Postal code is not used in any analysis, so the records were retained.

Analysis used CTEs and window functions for cumulative share, ranking, and year-over-year change. Q3 to Q5 were sharpened from descriptive to diagnostic once Q2 surfaced regional differences in AOV and the 2016 dip.

**Power BI** ([`powerbi/superstore_dashboard.pbix`](powerbi/superstore_dashboard.pbix))

Three-page dashboard connected directly to the MySQL database. Built a proper `dim_date` table for time intelligence, marked as date table, with relationships defined manually. Five DAX measures (Total Sales, Order Count, Customer Count, AOV, Sales per Customer) organised in a dedicated `_Measures` table. Slicers (Year, Region) synced across all pages.

**Python** ([`python/forecast.ipynb`](python/forecast.ipynb))

Daily Prophet attempted first; failed at ~250% MAPE due to high day-to-day volatility (std exceeded mean). Aggregated to weekly, which produced ~11% MAPE and ~$1,623 MAE on the held-out week. Forecast for week ending 2019-01-06: ~$12,400, 80% interval $6,000 to $19,000. Reported both MAPE (stakeholder communication) and MAE (technical evaluation) - MAPE is interpretable as a percentage, MAE quantifies the dollar miss.

## Limitations

- **Dataset size.** 9,800 transactions across 4 years is small for retail. Findings are directional, not statistically robust.
- **Retention figure.** ~99% of customers are active in 2+ years across all regions. This is implausibly high for general retail and almost certainly reflects Kaggle's dataset preparation (filtering to multi-year customers) rather than real customer behaviour. Q4 should be treated as a data quirk, not a finding.
- **Forecasting horizon.** A 7-day-ahead forecast with no external regressors (holiday calendar, promotions, regional weather) is inherently limited. Wide intervals reflect this honestly.
- **No causal claims.** Product mix is associated with the AOV gap; this is not the same as proving it causes it. A controlled test would be needed to confirm.

## Dashboard

**Overview** - KPI cards and 48-month sales trend.

![Overview](screenshots/overview.png)

**Regional** - region summary table, sales by category and region, yearly trend by region. The 2016 South collapse and 2018 West acceleration are visible immediately.

![Regional](screenshots/regional.png)

**Customers** - top 10 customers by sales, segment mix (Consumer 51%, Corporate 30%, Home Office 19%), customer count by region.

![Customers](screenshots/customers.png)


---

Arpit Singh - [github.com/asb0811](https://github.com/asb0811)

Dataset: [Superstore Sales by Rohit Sahoo on Kaggle](https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting)