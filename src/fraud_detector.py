
from pathlib import Path
import joblib
import pandas as pd


MODEL_PATH = (
    Path(__file__).resolve().parent.parent
    / "models"
    / "fraud_rf_chronological.joblib"
)


def load_model(model_path=MODEL_PATH):
    """Load the trained fraud detection model artifact."""
    artifact = joblib.load(model_path)

    required_keys = {"model", "features", "threshold"}

    if not required_keys.issubset(artifact):
        raise ValueError("Invalid model artifact.")

    return artifact


def predict_fraud(transactions, artifact=None):
    """
    Predict fraudulent transactions.

    Parameters
    ----------
    transactions : pandas.DataFrame
        Transaction data containing the required model features.
    artifact : dict, optional
        Loaded model artifact.

    Returns
    -------
    pandas.DataFrame
        Fraud probabilities and predicted classes.
    """
    if not isinstance(transactions, pd.DataFrame):
        raise TypeError("transactions must be a pandas DataFrame.")

    if transactions.empty:
        raise ValueError("transactions cannot be empty.")

    if artifact is None:
        artifact = load_model()

    model = artifact["model"]
    features = artifact["features"]
    threshold = artifact["threshold"]

    missing_features = set(features) - set(transactions.columns)

    if missing_features:
        raise ValueError(
            f"Missing required features: {sorted(missing_features)}"
        )

    X = transactions[features]

    if not all(pd.api.types.is_numeric_dtype(dtype)
               for dtype in X.dtypes):
        raise TypeError("All model features must be numeric.")

    if X.isnull().any().any():
        raise ValueError("Input contains missing values.")

    if not X.map(lambda value: pd.notna(value) and abs(value) != float("inf")).all().all():
        raise ValueError("Input contains infinite values.")

    probabilities = model.predict_proba(X)[:, 1]
    predictions = (probabilities >= threshold).astype(int)

    return pd.DataFrame({
        "fraud_probability": probabilities,
        "predicted_class": predictions
    }, index=transactions.index)
