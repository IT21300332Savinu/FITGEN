import os
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import MultiLabelBinarizer
import pandas as pd

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "models", "fitgen.tflite")
LABELS_PATH = os.path.join(BASE_DIR, "labels.txt")

# Load labels
with open(LABELS_PATH, "r") as f:
    labels = [line.strip() for line in f if line.strip()]

mlb = MultiLabelBinarizer()
mlb.fit([labels])

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

def get_dynamic_threshold(probabilities):
    sorted_probs = np.sort(probabilities)[::-1]
    if sorted_probs[0] < 0.1:
        return 0.05
    largest_gap = 0.0
    threshold = 0.15
    for i in range(len(sorted_probs) - 1):
        gap = sorted_probs[i] - sorted_probs[i+1]
        if gap > largest_gap:
            largest_gap = gap
            threshold = sorted_probs[i+1]
    return max(0.05, threshold + 0.01)

def predict(input_data):
    # input_data: dict with keys matching the 13 features
    feature_order = [
        'age', 'height', 'weight', 'weight_loss', 'muscle_gain',
        'maintain_healthy_weight', 'normal_diabetes', 'high_diabetes',
        'liver_disease', 'chronic_kidney_disease', 'hypertension',
        'bmi', 'gender_male'
    ]
    # Compute BMI if not provided
    if 'bmi' not in input_data or input_data['bmi'] is None:
        input_data['bmi'] = input_data['weight'] / (input_data['height'] ** 2)
    # Ensure all features are present
    features = [float(input_data.get(f, 0.0)) for f in feature_order]
    arr = np.array([features], dtype=np.float32)
    interpreter.set_tensor(input_details[0]['index'], arr)
    interpreter.invoke()
    probs = interpreter.get_tensor(output_details[0]['index'])[0]
    threshold = get_dynamic_threshold(probs)
    predicted_binarized = (probs >= threshold).astype(int)
    predicted_labels = mlb.inverse_transform(predicted_binarized.reshape(1, -1))
    return {
        "probabilities": {labels[i]: float(probs[i]) for i in range(len(labels))},
        "predicted_types": list(predicted_labels[0]),
        "threshold": float(threshold)
    }

def get_workout_plans(predicted_types, level):
    output_dir = os.path.join(os.path.dirname(__file__), 'workouts')
    plans = {}
    for fitness_type in predicted_types:
        filename = f"{fitness_type.replace(' ', '_')}_{level}.csv"
        file_path = os.path.join(output_dir, filename)
        if os.path.exists(file_path):
            df = pd.read_csv(file_path)
            # Group by day for easier frontend display
            plan = df.groupby('Day')['Exercise'].apply(list).to_dict()
            plans[fitness_type] = plan
        else:
            plans[fitness_type] = {"error": "Workout plan not found"}
    return plans