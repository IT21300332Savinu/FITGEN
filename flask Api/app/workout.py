# Updating exercise database with more advanced exercises for Intermediate and Advanced levels

import pandas as pd
import os

# Fitness types list
fitness_types = [
    'balance training', 'bodyweight exercises', 'cardiovascular fitness',
    'circuit training', 'core training', 'flexibility training',
    'functional training', 'hiit (high-intensity interval training)',
    'mobility work', 'muscular endurance',
    'muscular hypertrophy (muscle growth)', 'muscular strength', 'plyometrics',
    'resistance band training', 'speed & agility drills'
]

# Weekly schedule
days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

exercise_database_advanced = {
    "balance training": {
        "Easy": ["Single-leg stand (10–20 sec)", "Heel-to-toe walk", "Seated leg lift"],
        "Intermediate": ["Single-leg Romanian deadlift with dumbbell", "Bosu ball single-leg squats", "Standing knee lift with overhead press"],
        "Advanced": ["Pistol squat on Bosu ball", "One-legged plank with shoulder taps", "Single-leg hop to balance on unstable surface"]
    },
    "bodyweight exercises": {
        "Easy": ["Wall push-ups", "Knee push-ups", "Glute bridges"],
        "Intermediate": ["Decline push-ups", "Jump squats", "Clapping push-ups"],
        "Advanced": ["One-arm push-ups", "Pistol squats with jump", "Handstand push-ups freestanding"]
    },
    "cardiovascular fitness": {
        "Easy": ["Brisk walking 20 min", "Low-intensity cycling", "Marching in place"],
        "Intermediate": ["Tempo running 30 min", "Rowing sprints 500m x 5", "Jump rope double unders"],
        "Advanced": ["Sprint intervals with hill runs", "Stair sprints with weighted vest", "Burpee pull-ups 3x20"]
    },
    "circuit training": {
        "Easy": ["Bodyweight circuit: squats, push-ups, lunges", "Resistance band light circuit", "Step-ups + sit-to-stand"],
        "Intermediate": ["5-exercise AMRAP circuit", "Dumbbell + plyometric combo", "Jump rope + weighted squats + burpees"],
        "Advanced": ["CrossFit Murph-style workout", "Tabata circuit with Olympic lifts", "HIIT circuit with barbell complexes"]
    },
    "core training": {
        "Easy": ["Crunches", "Dead bug", "Plank (20s)"],
        "Intermediate": ["Side plank with leg lift", "Hanging knee raises", "Weighted Russian twists"],
        "Advanced": ["Dragon flag negatives", "Ab rollout from standing", "Hanging windshield wipers"]
    },
    "flexibility training": {
        "Easy": ["Seated hamstring stretch", "Cat-cow stretch", "Shoulder rolls"],
        "Intermediate": ["Pigeon pose with forward fold", "Lizard stretch", "Bridge with chest opener"],
        "Advanced": ["Oversplits with blocks", "Standing scorpion pose", "Backbend walkover"]
    },
    "functional training": {
        "Easy": ["Farmer’s carry with light weights", "Step-ups", "Sit-to-stand"],
        "Intermediate": ["Kettlebell clean and press", "Medicine ball rotational throws", "Walking lunges with twist"],
        "Advanced": ["Heavy Turkish get-up", "Atlas stone lift", "Yoke carry"]
    },
    "hiit (high-intensity interval training)": {
        "Easy": ["20s jog / 40s walk x5", "Low-impact jumping jacks intervals", "Bike sprints light"],
        "Intermediate": ["40s sprint / 20s rest x12", "HIIT burpee + squat jump circuit", "Row sprints 250m x8"],
        "Advanced": ["Tabata sprints uphill", "HIIT kettlebell snatch complexes", "CrossFit Fran-style workout"]
    },
    "mobility work": {
        "Easy": ["Ankle circles", "Arm swings", "Neck rotations"],
        "Intermediate": ["Deep squat to thoracic rotation", "90/90 hip flow", "Dynamic hamstring sweeps"],
        "Advanced": ["Loaded Jefferson curl", "Overhead squat mobility drill", "Cossack squat with reach"]
    },
    "muscular endurance": {
        "Easy": ["Wall sit (20s)", "Light resistance band rows", "Step-ups"],
        "Intermediate": ["Push-ups max reps with tempo", "Squats 4x25", "Plank to push-up transitions"],
        "Advanced": ["Pull-ups 10x10 challenge", "Jump squats 5x25", "Barbell complex 5 rounds"]
    },
    "muscular hypertrophy (muscle growth)": {
        "Easy": ["Dumbbell curls light", "Bodyweight squats 3x12", "Push-ups 3x10"],
        "Intermediate": ["Incline bench press 4x10", "Barbell squats 4x8", "Weighted pull-ups 4x8"],
        "Advanced": ["Deficit deadlifts 5x6", "Incline dumbbell press heavy 5x8", "Weighted dips 5x10"]
    },
    "muscular strength": {
        "Easy": ["Dumbbell deadlifts light", "Wall push-ups", "Bodyweight squats"],
        "Intermediate": ["Barbell deadlift 5x5", "Overhead press 5x5", "Weighted chin-ups"],
        "Advanced": ["Snatch", "Clean and jerk", "Squat/bench/deadlift 1RM training"]
    },
    "plyometrics": {
        "Easy": ["Jumping jacks", "Squat jumps (light)", "Lateral hops"],
        "Intermediate": ["Box jumps 24in", "Burpee box jumps", "Skater jumps with distance"],
        "Advanced": ["Depth jumps from 36in", "Single-leg hurdle hops", "Broad jumps into sprint"]
    },
    "resistance band training": {
        "Easy": ["Band pull-aparts", "Seated rows", "Side steps with band"],
        "Intermediate": ["Banded chest fly", "Banded thrusters", "Banded deadlifts"],
        "Advanced": ["Banded squats with barbell", "Banded bench press", "Banded muscle-ups"]
    },
    "speed & agility drills": {
        "Easy": ["High knees (slow)", "Side shuffles", "Cone step drills"],
        "Intermediate": ["Sprint shuttles 10x20m", "Agility ladder with push-ups", "Resisted sled runs"],
        "Advanced": ["Cone drills with reaction sprints", "Resisted band sprints", "Change of direction drills with ball reaction"]
    }
}
# Re-generate CSVs with updated exercises in current directory
output_dir = os.path.join(os.getcwd(), 'workouts')  # Save in "workouts" folder in current directory
os.makedirs(output_dir, exist_ok=True)

csv_files_advanced = []

for fitness in fitness_types:
    # Loop through each level (Easy, Intermediate, Advanced) to create separate files
    for level, exercises in exercise_database_advanced[fitness].items():
        rows = []
        for day in days:
            for ex in exercises:
                rows.append({"Day": day, "Level": level, "Exercise": ex})

        df = pd.DataFrame(rows)
        # Create a new file path that includes both fitness type and level
        file_path = os.path.join(output_dir, f"{fitness.replace(' ', '_')}_{level}.csv")
        df.to_csv(file_path, index=False)
        csv_files_advanced.append(file_path)

print("\nSuccessfully generated the following files in current directory:")
for f in csv_files_advanced:
    print(f)
