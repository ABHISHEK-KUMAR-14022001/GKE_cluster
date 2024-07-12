
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import pickle
import os

# Load the data
try:
    data = pd.read_json(r'D:\New folder\POC\jenkins_build_data.json')
except Exception as e:
    print(f"Error loading JSON data: {e}")
    raise

# Print information about the loaded data for debugging
print(f"Columns in data: {data.columns}")
print(f"Sample data:\n{data.head()}")

# Check if 'result' column exists
if 'result' not in data.columns:
    raise ValueError("Expected 'result' column not found in the loaded data.")

# Preprocess the data
try:
    data['duration'] = data['duration'] / 1000  # Convert duration to seconds
    data = pd.get_dummies(data, columns=['result'], drop_first=True)
except Exception as e:
    print(f"Error preprocessing data: {e}")
    raise

# Determine the target column after one-hot encoding
target_column = [col for col in data.columns if col.startswith('result_')]
if not target_column:
    raise ValueError("No target column found after one-hot encoding.")

# Convert timestamp to numerical if necessary
if 'timestamp' in data.columns:
    data['timestamp'] = pd.to_numeric(data['timestamp'])

# Split the data
X = data.drop(target_column, axis=1)
y = data[target_column[0]]  # Assuming only one target column exists
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = RandomForestClassifier(n_estimators=100, random_state=42)
try:
    model.fit(X_train, y_train)
except Exception as e:
    print(f"Error fitting model: {e}")
    raise

# Evaluate the model
y_pred = model.predict(X_test)
print(f'Accuracy: {accuracy_score(y_test, y_pred)}')

# Save the model and important features
try:
    model_path = r'D:\New folder\POC\model.pkl'
    with open(model_path, 'wb') as f:
        pickle.dump(model, f)
    print(f"Model saved to {model_path}")

    feature_importances = model.feature_importances_
    feature_names = X_train.columns
    important_features = pd.DataFrame({'Feature': feature_names, 'Importance': feature_importances})
    important_features.sort_values(by='Importance', ascending=False, inplace=True)
    
    # Attempt to save to the original path
    features_path = r'D:\New folder\POC\important_features.csv'
    try:
        important_features.to_csv(features_path, index=False)
        print(f"Important features saved to {features_path}")
    except PermissionError as e:
        # Try saving to an alternative path
        alternative_path = r'D:\New folder\POC\important_features_alt.csv'
        important_features.to_csv(alternative_path, index=False)
        print(f"Permission denied for the original path. Important features saved to {alternative_path}")
        print(f"Original error: {e}")
except Exception as e:
    print(f"Error saving model or features: {e}")
    raise
