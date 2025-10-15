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

def get_workout_plans(predicted_types, level, simple_format=False, start_day=None):
    output_dir = os.path.join(os.path.dirname(__file__), 'workouts')
    plans = {}
    
    # Define correct day order
    day_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    
    # If start_day is provided, reorder the days to start from that day
    if start_day and start_day in day_order:
        start_index = day_order.index(start_day)
        # Reorder to start from the specified day
        custom_day_order = day_order[start_index:] + day_order[:start_index]
    else:
        custom_day_order = day_order
    
    for fitness_type in predicted_types:
        filename = f"{fitness_type.replace(' ', '_')}_{level}.csv"
        file_path = os.path.join(output_dir, filename)
        if os.path.exists(file_path):
            df = pd.read_csv(file_path)
            
            if simple_format:
                # Return simple format for backward compatibility (just exercise names)
                plan = {}
                for i, display_day in enumerate(custom_day_order):
                    # Map to actual day in CSV (always Monday-Sunday order)
                    actual_day = day_order[i]
                    day_exercises = df[df['Day'] == actual_day]['Exercise'].tolist()
                    if day_exercises:  # Only include days that have exercises
                        plan[display_day] = day_exercises
            else:
                # Return detailed format with all exercise information
                plan = {}
                for i, display_day in enumerate(custom_day_order):
                    # Map to actual day in CSV (always Monday-Sunday order)
                    actual_day = day_order[i]
                    day_exercises = df[df['Day'] == actual_day]
                    if not day_exercises.empty:  # Only include days that have exercises
                        plan[display_day] = []
                        for _, row in day_exercises.iterrows():
                            exercise_detail = {
                                'Exercise': row['Exercise'],
                                'Duration': row['Duration'],
                                'Reps': row['Reps'],
                                'Sets': row['Sets']
                            }
                            plan[display_day].append(exercise_detail)
            
            # Store the plan for this fitness type
            plans[fitness_type] = plan
            
            # Add user-friendly workout instructions and tips (only for detailed format)
            if not simple_format:
                plans[fitness_type]['workout_instructions'] = get_workout_instructions()
                plans[fitness_type]['daily_tips'] = get_daily_workout_tips()
        else:
            plans[fitness_type] = {"error": "Workout plan not found"}
    return plans

def get_workout_instructions():
    """Return common workout instructions for users - clear sentence by sentence"""
    return {
        "before_workout": [
            "🔥 Warm up for 5-10 minutes with light cardio.",
            "🔥 Do dynamic stretching to prepare your muscles.",
            "💧 Drink water before starting your workout.",
            "👕 Wear comfortable, breathable workout clothes.",
            "🎵 Put on motivational music to energize yourself.",
            "📱 Keep your phone nearby for timing exercises."
        ],
        "during_workout": [
            "✅ Focus on proper form rather than speed.",
            "🌬️ Breathe out during exertion.",
            "🌬️ Breathe in during the release phase.",
            "⏸️ Take 30-60 second rest between sets.",
            "💪 Listen to your body signals.",
            "📱 Stay focused and avoid distractions.",
            "🎯 Complete each exercise with control."
        ],
        "after_workout": [
            "🧘 Cool down with 5-10 minutes of light stretching.",
            "💧 Rehydrate with plenty of water immediately.",
            "🍎 Eat a healthy post-workout snack within 30 minutes.",
            "📝 Log your workout progress in a journal.",
            "🛁 Take a shower to refresh yourself.",
            "😌 Take a moment to appreciate your effort.",
            "💤 Rest and allow your muscles to recover."
        ]
    }

def get_daily_workout_tips():
    """Return daily motivational tips and reminders - short and sweet attractive sentences"""
    return {
        "general_tips": [
            "� Drink plenty of water",
            "� Get enough sleep",
            "🥗 Eat healthy foods"
        ],
        "safety_reminders": [
            "⚠️ Listen to your body signals",
            "🔄 Rest days build strength",
            "🏥 When in doubt, ask a pro"
        ],
        "motivation": [
            "🌟 You're stronger than you think!",
            "🚀 Small steps, big changes",
            "💪 Your future self will thank you"
        ]
    }