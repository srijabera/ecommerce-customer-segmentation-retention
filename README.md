# Olist E-Commerce Customer Segmentation & Retention Analysis

## Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist to understand customer purchasing behavior, identify valuable customer segments, and discover opportunities to improve customer retention.

The project uses **RFM (Recency, Frequency, Monetary) analysis** and **K-Means clustering** to segment customers. It also explores customer lifetime value (historical spending), customer satisfaction, review sentiment, and delivery performance.

The final outcome is an interactive Power BI dashboard supported by Python analysis, MySQL queries, and business recommendations.

## Objectives

- Analyze customer purchasing behavior using RFM analysis.
- Identify meaningful customer segments using K-Means clustering.
- Understand customer revenue contribution and spending patterns.
- Analyze customer satisfaction and review sentiment.
- Investigate the relationship between delivery delays and customer satisfaction.
- Recommend strategies to improve customer retention and revenue.

## Technology Stack

| Category | Tools |
|---|---|
| Programming | Python |
| Data Analysis | Pandas, NumPy |
| Machine Learning | Scikit-learn, K-Means |
| Visualization | Matplotlib, Seaborn |
| Database | MySQL |
| Dashboard | Power BI |
| Environment | Google Colab, Jupyter Notebook |
| Version Control | Git, GitHub |

## Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The dataset contains approximately 100,000 orders from a Brazilian e-commerce marketplace, covering the period from 2016 to 2018.

The analysis focuses on delivered orders and includes customer, order, payment, product, seller, and review information.

- Total orders: 99,441
- Delivered orders: 96,478
- Unique customers in the delivered-order analysis: 93,358
- Delivery date range: September 15, 2016 – August 29, 2018

The original dataset is not included in this repository because of its size. Users should obtain it from Kaggle.

## Project Workflow

| Notebook | Description |
|---|---|
| `01_dataset_verification.ipynb` | Dataset inspection, data types, missing values, duplicate checks, primary keys, foreign keys, and data quality validation. |
| `02_python_data_preparation.ipynb` | Data preparation, CSV processing, and validation of SQL-generated RFM results. |
| `03_exploratory_data_analysis.ipynb` | Customer spending patterns, RFM distributions, outlier analysis, and revenue exploration. |
| `04_rfm_and_kmeans_segmentation.ipynb` | RFM feature engineering, feature scaling, K selection, K-Means clustering, and customer segment profiling. |
| `05_advanced_customer_analysis.ipynb` | Historical customer value, satisfaction, review sentiment, delivery performance, and business recommendations. |

## Customer Segmentation

Four customer segments were identified using K-Means clustering.

| Customer Segment | Customers | Average Spending (R$) | Revenue Contribution |
|---|---:|---:|---:|
| Recent High-Spenders | 32,369 | 251.13 | 61.48% |
| Hibernating Customers | 27,189 | 109.90 | 22.60% |
| Recent Low-Spenders | 30,999 | 44.40 | 10.41% |
| Repeat Buyers | 2,801 | 260.05 | 5.51% |

**Model evaluation:** The final four-cluster solution achieved a silhouette score of approximately **0.3685** on the full dataset.

## Key Business Findings

- Approximately 97% of customers made only one delivered purchase, highlighting a major repeat-purchase opportunity.
- Recent High-Spenders represent approximately 34.67% of customers but contribute 61.48% of total revenue.
- Hibernating Customers represent 29.12% of customers, making them an important target for re-engagement campaigns.
- Repeat Buyers account for only 3% of customers but have the highest average historical spending.
- Recent High-Spenders have the highest negative review rate among the four segments.

## Customer Satisfaction & Delivery Analysis

Customer reviews and delivery performance were analyzed to understand their relationship with customer satisfaction.

| Delivery Status | Average Review Score |
|---|---:|
| Early Delivery | 4.29 |
| On-Time Delivery | 4.04 |
| Late Delivery | 2.27 |

Very late deliveries (more than 7 days late) received an average review score of approximately 1.70.

This indicates a strong association between delivery delays and lower customer satisfaction.

## Business Recommendations

| Customer Segment | Recommended Strategy |
|---|---|
| Recent High-Spenders | Improve delivery reliability and provide priority customer support. |
| Hibernating Customers | Run personalized re-engagement campaigns and targeted offers. |
| Recent Low-Spenders | Introduce product recommendations, bundles, and small purchase incentives. |
| Repeat Buyers | Offer loyalty rewards and exclusive customer benefits. |

## Power BI Dashboard

The interactive dashboard contains three pages:

1. **Customer Overview** – Customer count, revenue, average spending, and segment distribution.
2. **Customer Segmentation** – Segment-wise customer count, revenue contribution, and RFM comparison.
3. **Retention Analysis** – One-time versus repeat customers, repeat purchase rate, and customer retention indicators.

Dashboard screenshots will be added to this README after the repository files are uploaded.

## Repository Structure

The repository is organized into the following folders:

```text
ecommerce-customer-segmentation-retention/
│
├── notebooks/
├── results/
│   ├── phase6_segmentation/
│   └── phase8_advanced_analysis/
│
├── sql/
├── power_bi/
├── dashboard_screenshots/
│
├── README.md
└── .gitignore
```

## Limitations

- Approximately 97% of customers made only one delivered purchase, resulting in limited frequency variation.
- K-Means clusters show moderate separation, with a full-dataset silhouette score of approximately 0.3685.
- Customer lifetime value analysis represents historical spending, not predicted future lifetime value.
- Monetary value is based on item prices and excludes freight.
- The analysis uses historical data from 2016–2018.
- Review and delivery relationships indicate associations, not proven causation.

## Future Improvements

- Develop predictive customer churn models.
- Explore customer lifetime value prediction.
- Build recommendation systems for personalized offers.
- Experiment with alternative clustering algorithms.
- Automate dashboard data refresh and reporting.

## Author

**Srija Bera**

BCA Student | Aspiring Data Science & Machine Learning Professional

- GitHub: [srijabera](https://github.com/srijabera)
- LinkedIn: Add your LinkedIn profile URL here
