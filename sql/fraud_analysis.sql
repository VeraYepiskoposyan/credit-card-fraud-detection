
-- Credit Card Fraud Detection
-- SQL analysis queries
-- Database: fraud_analysis.db
-- Table: predictions

-- SQL analysis from notebook cell 180
SELECT *
FROM predictions
LIMIT 5;

-- SQL analysis from notebook cell 181
SELECT 
    CASE
        WHEN Actual = 1 AND Predicted = 1 THEN 'True Positive'
        WHEN Actual = 0 AND Predicted = 0 THEN 'True Negative'
        WHEN Actual = 0 AND Predicted = 1 THEN 'False Positive'
        WHEN Actual = 1 AND Predicted = 0 THEN 'False Negative'
    END AS prediction_type,
    COUNT(*) AS total
FROM predictions
GROUP BY prediction_type;

-- SQL analysis from notebook cell 182
SELECT
    SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN Actual = 0 AND Predicted = 1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN Actual = 1 AND Predicted = 0 THEN 1 ELSE 0 END) AS FN,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS precision,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS recall

FROM predictions;;

-- SQL analysis from notebook cell 183
WITH metrics AS (
    SELECT
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END), 0) AS precision,

        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END), 0) AS recall

    FROM predictions
)

SELECT
    ROUND(precision, 4) AS precision,
    ROUND(recall, 4) AS recall,
    ROUND(
        2.0 * precision * recall /
        NULLIF(precision + recall, 0),
        4
    ) AS f1_score

FROM metrics;;

-- SQL analysis from notebook cell 184
SELECT
    period,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END) AS actual_fraud,

    SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) AS detected_fraud,

    SUM(CASE WHEN Actual = 1 AND Predicted = 0 THEN 1 ELSE 0 END) AS missed_fraud,

    SUM(CASE WHEN Actual = 0 AND Predicted = 1 THEN 1 ELSE 0 END) AS false_alarms

FROM predictions
GROUP BY period
ORDER BY
    CASE period
        WHEN 'Early' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Late' THEN 3
    END;;

-- SQL analysis from notebook cell 185
SELECT
    period,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS precision,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS recall,

    ROUND(
        2.0 *
        SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(
            SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END) +
            SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END),
            0
        ),
        4
    ) AS f1_score

FROM predictions
GROUP BY period
ORDER BY
    CASE period
        WHEN 'Early' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Late' THEN 3
    END;;

-- SQL analysis from notebook cell 186
SELECT
    CASE
        WHEN Actual = 1 AND Predicted = 0 THEN 'False Negative'
        WHEN Actual = 0 AND Predicted = 1 THEN 'False Positive'
        WHEN Actual = 1 AND Predicted = 1 THEN 'True Positive'
        ELSE 'True Negative'
    END AS prediction_type,

    COUNT(*) AS transaction_count,

    ROUND(AVG(Amount), 2) AS average_amount,

    ROUND(MIN(Amount), 2) AS minimum_amount,

    ROUND(MAX(Amount), 2) AS maximum_amount

FROM predictions

WHERE Actual = 1 AND Predicted = 0
   OR Actual = 0 AND Predicted = 1
   OR Actual = 1 AND Predicted = 1

GROUP BY prediction_type
ORDER BY transaction_count DESC;;

-- SQL analysis from notebook cell 187
SELECT
    period,
    COUNT(*) AS false_positive_count,
    ROUND(AVG(Amount), 2) AS average_amount,
    ROUND(MIN(Amount), 2) AS minimum_amount,
    ROUND(MAX(Amount), 2) AS maximum_amount

FROM predictions

WHERE Actual = 0 AND Predicted = 1

GROUP BY period
ORDER BY
    CASE period
        WHEN 'Early' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Late' THEN 3
    END;;

-- SQL analysis from notebook cell 188
SELECT
    period,

    CASE
        WHEN Predicted = 1 THEN 'Detected Fraud'
        ELSE 'Missed Fraud'
    END AS fraud_status,

    COUNT(*) AS transaction_count,

    ROUND(AVG(Amount), 2) AS average_amount,

    ROUND(AVG(Probability), 4) AS average_probability

FROM predictions

WHERE Actual = 1

GROUP BY period, fraud_status

ORDER BY
    CASE period
        WHEN 'Early' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Late' THEN 3
    END,
    fraud_status;;

-- SQL analysis from notebook cell 189
SELECT
    CASE
        WHEN Amount < 10 THEN 'Under $10'
        WHEN Amount < 100 THEN '$10-$100'
        WHEN Amount < 500 THEN '$100-$500'
        ELSE 'Above $500'
    END AS amount_range,

    COUNT(*) AS actual_fraud,

    SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END) AS detected_fraud,

    SUM(CASE WHEN Predicted = 0 THEN 1 ELSE 0 END) AS missed_fraud,

    ROUND(
        1.0 * SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(COUNT(*), 0),
        4
    ) AS recall

FROM predictions

WHERE Actual = 1

GROUP BY amount_range

ORDER BY
    CASE amount_range
        WHEN 'Under $10' THEN 1
        WHEN '$10-$100' THEN 2
        WHEN '$100-$500' THEN 3
        WHEN 'Above $500' THEN 4
    END;;

-- SQL analysis from notebook cell 190
SELECT
    CASE
        WHEN Amount < 10 THEN 'Under $10'
        WHEN Amount < 100 THEN '$10-$100'
        WHEN Amount < 500 THEN '$100-$500'
        ELSE 'Above $500'
    END AS amount_range,

    COUNT(*) AS total_transactions,

    SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END) AS actual_fraud,

    SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) AS TP,

    SUM(CASE WHEN Actual = 0 AND Predicted = 1 THEN 1 ELSE 0 END) AS FP,

    SUM(CASE WHEN Actual = 1 AND Predicted = 0 THEN 1 ELSE 0 END) AS FN,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Predicted = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS precision,

    ROUND(
        1.0 * SUM(CASE WHEN Actual = 1 AND Predicted = 1 THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN Actual = 1 THEN 1 ELSE 0 END), 0),
        4
    ) AS recall

FROM predictions

GROUP BY amount_range

ORDER BY
    CASE amount_range
        WHEN 'Under $10' THEN 1
        WHEN '$10-$100' THEN 2
        WHEN '$100-$500' THEN 3
        WHEN 'Above $500' THEN 4
    END;;
