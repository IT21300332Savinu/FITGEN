import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer
import numpy as np
import io
import tensorflow as tf
from collections import defaultdict
import glob
import os

# -----------------------------------------------------------------------------
# STEP 1: Load the TFLite Model and Labels
# -----------------------------------------------------------------------------
model_path = 'fitgen.tflite'
labels_path = 'labels.txt'  # Load from text file

print("Loading the TFLite model...")
interpreter = None
try:
    # Load the TFLite model from the file
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading the TFLite model: {e}")
    print("Please ensure 'fitgen.tflite' exists in the same directory.")

# Load labels from the text file.
labels = []
try:
    with open(labels_path, 'r') as f:
        labels = [line.strip() for line in f.readlines() if line.strip()]
    print(f"Labels loaded: {labels}")
except Exception as e:
    print(f"Failed to load labels from '{labels_path}': {e}")
    print("Please ensure 'labels.txt' exists and contains one label per line.")

# Create a MultiLabelBinarizer and fit it with the loaded labels.
mlb = MultiLabelBinarizer()
mlb.fit([labels])
print("MultiLabelBinarizer has been fitted with the loaded labels.")


# -----------------------------------------------------------------------------
# STEP 2: Collect User Inputs
# -----------------------------------------------------------------------------
print("\nPlease provide your details:")

# Get user input for profile data
age = float(input("Age (years): "))
gender = input("Gender (male/female): ").strip().lower()
height = float(input("Height (meters): "))
weight = float(input("Weight (kg): "))

# Input validation for height and weight
if height > 3.0:
    confirm = input(f"You entered a height of {height} meters. Did you mean {height/100:.2f} meters? (y/n): ").strip().lower()
    if confirm == 'y':
        height = height / 100
        print(f"Height updated to {height:.2f} meters.")
    else:
        print("Please restart the script and enter a realistic height in meters.")
        exit()

if weight < 10.0 or weight > 300.0:
    print("Warning: The weight you entered seems unusual. Please verify your input.")


print("\nPersonal Goals:")
print("1. Weight Loss")
print("2. Muscle Gain")
print("3. Maintain Healthy Weight")
goal_input = input("Select goal (1/2/3): ").strip()

# Medical conditions
def yes_no(prompt):
    return input(prompt + " (y/n): ").strip().lower() == 'y'

normal_diabetes = yes_no("Normal Diabetes? (y/n):")
high_diabetes = yes_no("High Diabetes? (y/n):")
liver_disease = yes_no("Liver Disease? (y/n):")
chronic_kidney_disease = yes_no("Chronic Kidney Disease? (y/n):")
hypertension = yes_no("Hypertension? (y/n):")

# Calculate BMI
bmi = weight / (height ** 2)

# Create a DataFrame from the user's inputs
manual_df = pd.DataFrame({
    'age': [age],
    'height': [height],
    'weight': [weight],
    'weight_loss': [1.0 if goal_input=='1' else 0.0],
    'muscle_gain': [1.0 if goal_input=='2' else 0.0],
    'maintain_healthy_weight': [1.0 if goal_input=='3' else 0.0],
    'normal_diabetes': [1.0 if normal_diabetes else 0.0],
    'high_diabetes': [1.0 if high_diabetes else 0.0],
    'liver_disease': [1.0 if liver_disease else 0.0],
    'chronic_kidney_disease': [1.0 if chronic_kidney_disease else 0.0],
    'hypertension': [1.0 if hypertension else 0.0],
    'bmi': [bmi],
    'gender_male': [1.0 if gender == 'male' else 0.0]
})

# Define the order of features to match the training data (13 features)
training_features = [
    'age', 'height', 'weight', 'weight_loss', 'muscle_gain',
    'maintain_healthy_weight', 'normal_diabetes', 'high_diabetes',
    'liver_disease', 'chronic_kidney_disease', 'hypertension',
    'bmi', 'gender_male'
]

# Re-index the dataframe to match the training feature order, filling missing values with 0
X_manual = manual_df.reindex(columns=training_features, fill_value=0)

print(f"\nManual data to predict on:\n{X_manual.to_dict('records')[0]}")


# -----------------------------------------------------------------------------
# STEP 3: Make TFLite Prediction & Display Confidence
# -----------------------------------------------------------------------------
# New function to get a dynamic threshold
def get_dynamic_threshold(probabilities):
    """
    Analyzes the prediction probabilities to determine a suitable threshold.
    - If no predictions are strong, provides a low threshold.
    - If many predictions are strong, uses a higher, more selective threshold.
    """
    sorted_probs = np.sort(probabilities)[::-1]
    
    # Check if the highest confidence is very low.
    if sorted_probs[0] < 0.1:
        return 0.05
    
    # Find the largest gap in confidence to set a dynamic threshold.
    largest_gap = 0.0
    threshold = 0.15  # Default threshold
    
    for i in range(len(sorted_probs) - 1):
        gap = sorted_probs[i] - sorted_probs[i+1]
        if gap > largest_gap:
            largest_gap = gap
            # Set the threshold just below the current probability
            # to filter out everything else below the gap.
            threshold = sorted_probs[i+1]
            
    # Add a small buffer to the threshold
    return max(0.05, threshold + 0.01)


if interpreter:
    # Get input and output tensor details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Prepare input data for the model
    input_data = X_manual.to_numpy().astype(np.float32)

    # Set the input tensor and run inference
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    # Get the prediction results
    prediction_probabilities = interpreter.get_tensor(output_details[0]['index'])[0]

    # Check for a zero-confidence prediction and provide an informative message.
    if np.max(prediction_probabilities) == 0.0:
        print("\nModel Prediction Confidence:")
        print("The model could not make a confident prediction based on your input. This may be because your health data is outside the range of the model's training data.")
        print("Please consider adjusting your inputs or consulting a health professional for a personalized workout plan.")
    else:
        # Display prediction confidence for all predictions
        sorted_indices = np.argsort(prediction_probabilities)[::-1]
        print("\nModel Prediction Confidence (all types):")
        for rank, idx in enumerate(sorted_indices):
            label = labels[idx]
            confidence = prediction_probabilities[idx] * 100
            print(f"{rank + 1}. {label.title()}: {confidence:.2f}%")

        # Use the new function to get a dynamic threshold
        threshold = get_dynamic_threshold(prediction_probabilities)
        print(f"\nUsing a dynamic threshold of: {threshold:.2f} ({threshold*100:.0f}%)")

        predicted_binarized = (prediction_probabilities >= threshold).astype(int)
        predicted_labels = mlb.inverse_transform(predicted_binarized.reshape(1, -1))
        final_predicted_types = list(predicted_labels[0])

        print("\nPredicted Fitness Types:")
        if not final_predicted_types:
            print("No fitness types met the threshold. Please try adjusting your inputs.")
        else:
            for label in final_predicted_types:
                print(f"- {label}")

            # -----------------------------------------------------------------------------
            # STEP 4: Ask for Desired Fitness Level
            # -----------------------------------------------------------------------------
            levels = ["Easy", "Intermediate", "Advanced"]
            print("\nFitness Levels:")
            for i, lvl in enumerate(levels):
                print(f"{i+1}. {lvl}")

            try:
                selected_level_index = int(input("Select fitness level (1/2/3): ").strip()) - 1
                selected_level = levels[selected_level_index]
            except (ValueError, IndexError):
                print("Invalid selection. Defaulting to Intermediate level.")
                selected_level_index = 1
                selected_level = levels[selected_level_index]

            # -----------------------------------------------------------------------------
            # STEP 5: Display Workout Plans
            # -----------------------------------------------------------------------------
            print(f"\nDisplaying {selected_level} workout plans:")

            # Loop through each predicted fitness type and display the corresponding CSV.
            for fitness_type in final_predicted_types:
                print(f"\n--- Your {selected_level} {fitness_type.upper()} Plan ---")

                # Construct the file pattern and search for the file in the 'workouts' folder
                file_name = f"{fitness_type.replace(' ', '_')}_{selected_level}.csv"
                file_path = os.path.join('workouts', file_name)

                try:
                    # Use pandas to read the CSV and display it
                    df = pd.read_csv(file_path)
                    print(df)
                except FileNotFoundError:
                    print(f"Error: No file found at '{file_path}'.")
                except Exception as e:
                    print(f"An error occurred while reading the CSV file: {e}")
else:
    print("\nPrediction skipped: TFLite model not loaded.")
