import pandas as pd
import pytest

from src.fraud_detector import load_model, predict_fraud


def test_model_loads():
    artifact = load_model()

    assert artifact["model"] is not None
    assert len(artifact["features"]) == 30
    assert 0 <= artifact["threshold"] <= 1


def test_valid_prediction():
    artifact = load_model()

    sample = pd.DataFrame(
        [[0.0] * 30],
        columns=artifact["features"]
    )

    result = predict_fraud(sample, artifact)

    assert len(result) == 1
    assert "fraud_probability" in result.columns
    assert "predicted_class" in result.columns
    assert result["predicted_class"].iloc[0] in [0, 1]


def test_missing_features():
    artifact = load_model()

    sample = pd.DataFrame({"Time": [100]})

    with pytest.raises(ValueError, match="Missing required features"):
        predict_fraud(sample, artifact)


def test_empty_input():
    artifact = load_model()
    sample = pd.DataFrame(columns=artifact["features"])

    with pytest.raises(ValueError, match="cannot be empty"):
        predict_fraud(sample, artifact)


def test_non_dataframe_input():
    artifact = load_model()

    with pytest.raises(TypeError, match="pandas DataFrame"):
        predict_fraud([[0] * 30], artifact)

def test_missing_values():
    artifact = load_model()
    sample = pd.DataFrame(
        [[0.0] * 30],
        columns=artifact["features"]
    )
    sample.iloc[0, 0] = float("nan")

    with pytest.raises(ValueError, match="missing values"):
        predict_fraud(sample, artifact)


def test_infinite_values():
    artifact = load_model()
    sample = pd.DataFrame(
        [[0.0] * 30],
        columns=artifact["features"]
    )
    sample.iloc[0, 0] = float("inf")

    with pytest.raises(ValueError, match="infinite values"):
        predict_fraud(sample, artifact)


def test_probability_range():
    artifact = load_model()
    sample = pd.DataFrame(
        [[0.0] * 30],
        columns=artifact["features"]
    )

    result = predict_fraud(sample, artifact)

    assert result["fraud_probability"].between(0, 1).all()
