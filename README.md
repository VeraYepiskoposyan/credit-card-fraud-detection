# Credit Card Fraud Detection

## Overview

A machine learning project focused on detecting fraudulent credit card transactions in a highly imbalanced dataset.

The project explores classification algorithms, class imbalance handling, chronological evaluation, decision threshold optimization, and SQL-based performance analysis.

## Dataset

- Source: Kaggle Credit Card Fraud Detection dataset
- Total transactions: 284,807
- Legitimate transactions: 284,315
- Fraudulent transactions: 492
- Fraud prevalence: approximately 0.173%
- Features: Time, V1–V28, Amount
- Target: Class (0 = legitimate, 1 = fraud)

The V1–V28 features are anonymized PCA-transformed variables.

## Machine Learning Models

- Logistic Regression
- Random Forest
- Gradient Boosting
- Multi-Layer Perceptron (MLP)

### Handling Class Imbalance

- Class weighting
- Random Undersampling
- SMOTE
- Random Oversampling (used for the MLP experiment)

### Evaluation Strategy

A chronological 60/20/20 split was used. Transactions were sorted by elapsed transaction time before splitting.

The validation set was used for decision threshold selection. The test set was used for final evaluation. It was also used in subsequent retrospective model comparisons, so those comparisons should be interpreted with this limitation in mind.

Evaluation metrics included Average Precision (AP), precision, recall, F1-score, and confusion matrix. Bootstrap confidence intervals and temporal error analysis were also performed.

## Final Model: Random Forest

The selected model uses `balanced_subsample` class weighting.

| Metric | Chronological Test |
|---|---:|
| Average Precision | 0.8130 |
| Precision | 0.9048 |
| Recall | 0.7600 |
| F1-score | 0.8261 |
| False Positives | 6 |
| False Negatives | 18 |

Selected decision threshold: **0.18999**

The model detected 57 out of 75 fraudulent transactions in the chronological test set.

### Imbalance Experiment Comparison

| Approach | Average Precision | Precision | Recall | F1-score |
|---|---:|---:|---:|---:|
| Class weighting | 0.8130 | 0.9048 | 0.7600 | 0.8261 |
| Random Undersampling | 0.7939 | 0.8438 | 0.7200 | 0.7770 |
| SMOTE | 0.8116 | 0.8406 | 0.7733 | 0.8056 |

Class weighting achieved the best overall balance in these experiments, while SMOTE achieved slightly higher recall.

### MLP Comparison

- Average Precision: 0.7820
- Precision: 0.9608
- Recall: 0.6533
- F1-score: 0.7778

The Random Forest performed better overall, while the MLP produced fewer false positives.

## SQL Analysis

SQLite was used to store and analyze model predictions.

- Confusion matrix calculations
- Precision, recall, and F1-score
- Performance across early, middle, and late transaction periods
- False-positive and false-negative analysis
- Fraud detection by transaction amount
- Transaction-level prediction analysis

## Project Structure

```text
credit-card-fraud-detection/
├── data/
│   ├── fraud_predictions.csv
│   └── fraud_analysis.db
├── models/
│   └── fraud_rf_chronological.joblib
├── notebooks/
│   └── credit_card_fraud_detection.ipynb
├── sql/
│   └── fraud_analysis.sql
├── src/
│   ├── __init__.py
│   └── fraud_detector.py
├── tests/
│   └── test_fraud_detector.py
└── README.md
```

## How to Run

1. Clone this repository.
2. Install the required dependencies.
3. Open the Jupyter notebook to explore the analysis.
4. Use src/fraud_detector.py to load the trained model and predict fraud probabilities.

### Requirements

- Python
- pandas
- numpy
- scikit-learn
- imbalanced-learn
- joblib
- matplotlib
- seaborn
- pytest

## Limitations

- The dataset covers approximately two days of transactions.
- V1–V28 are anonymized PCA components, limiting direct feature interpretation.
- The model has not been tested in a live payment environment.
- Fraud patterns may change over time, requiring periodic model evaluation and retraining.

## Future Improvements

- Evaluate the model on newer transaction data.
- Explore additional threshold optimization strategies.
- Monitor model performance and potential data drift.
- Develop a simple interface for transaction predictions.
