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
        "Easy": [
            {"exercise": "Single-leg stand", "duration": "10–20 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Heel-to-toe walk", "duration": "1 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Seated leg lift", "duration": "30 sec each leg", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Standing on one foot with eyes closed", "duration": "15 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Tandem walk", "duration": "2 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Balance beam walk", "duration": "1 min", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Single-leg glute bridge", "duration": "20 sec each leg", "reps": "3 sets", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Single-leg Romanian deadlift with dumbbell", "duration": "30 sec hold", "reps": "3x12", "sets": "2-3 sets"},
            {"exercise": "Bosu ball single-leg squats", "duration": "45 sec", "reps": "5-8 per leg", "sets": "2 sets"},
            {"exercise": "Standing knee lift with overhead press", "duration": "1 min", "reps": "8-10 per leg", "sets": "2-3 sets"},
            {"exercise": "Single-leg deadlift with reach", "duration": "45 sec", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Warrior III pose hold", "duration": "30 sec each leg", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Single-leg calf raises", "duration": "1 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Balance board squats", "duration": "2 min", "reps": "3x12", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Pistol squat on Bosu ball", "duration": "1 min", "reps": "3-5 per leg", "sets": "2 sets"},
            {"exercise": "One-legged plank with shoulder taps", "duration": "30 sec", "reps": "3x8", "sets": "2-3 sets"},
            {"exercise": "Single-leg hop to balance on unstable surface", "duration": "2 min", "reps": "5-8 hops per leg", "sets": "2 sets"},
            {"exercise": "Single-leg Turkish get-up", "duration": "3 min", "reps": "3x3 per leg", "sets": "3 sets"},
            {"exercise": "Handstand wall hold", "duration": "30 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Single-leg burpees", "duration": "2 min", "reps": "3x5 per leg", "sets": "3 sets"},
            {"exercise": "Advanced balance beam routine", "duration": "5 min", "reps": "3 rounds", "sets": "3 rounds"}
        ]
    },
    "bodyweight exercises": {
        "Easy": [
            {"exercise": "Wall push-ups", "duration": "5 min", "reps": "8-12", "sets": "3 sets"},
            {"exercise": "Knee push-ups", "duration": "4 min", "reps": "8-12", "sets": "3 sets"},
            {"exercise": "Glute bridges", "duration": "6 min", "reps": "10-15", "sets": "3 sets"},
            {"exercise": "Modified planks", "duration": "30 sec", "reps": "3 holds", "sets": "3 sets"},
            {"exercise": "Chair squats", "duration": "5 min", "reps": "10-15", "sets": "3 sets"},
            {"exercise": "Standing calf raises", "duration": "3 min", "reps": "15-20", "sets": "3 sets"},
            {"exercise": "Arm circles", "duration": "2 min", "reps": "20 each direction", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Decline push-ups", "duration": "8 min", "reps": "8-12", "sets": "3 sets"},
            {"exercise": "Jump squats", "duration": "10 min", "reps": "10-15", "sets": "3 sets"},
            {"exercise": "Clapping push-ups", "duration": "6 min", "reps": "6-10", "sets": "3 sets"},
            {"exercise": "Pike push-ups", "duration": "7 min", "reps": "8-12", "sets": "3 sets"},
            {"exercise": "Single-leg squats", "duration": "12 min", "reps": "5-8 per leg", "sets": "3 sets"},
            {"exercise": "Diamond push-ups", "duration": "5 min", "reps": "6-10", "sets": "3 sets"},
            {"exercise": "Plyometric lunges", "duration": "8 min", "reps": "10-12 per leg", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "One-arm push-ups", "duration": "15 min", "reps": "5-8 per arm", "sets": "3 sets"},
            {"exercise": "Pistol squats with jump", "duration": "12 min", "reps": "6-8 per leg", "sets": "3 sets"},
            {"exercise": "Handstand push-ups freestanding", "duration": "10 min", "reps": "5-8", "sets": "3 sets"},
            {"exercise": "Archer push-ups", "duration": "8 min", "reps": "5-8 per side", "sets": "3 sets"},
            {"exercise": "Shrimp squats", "duration": "15 min", "reps": "3-5 per leg", "sets": "3 sets"},
            {"exercise": "Planche push-ups", "duration": "20 min", "reps": "3-5", "sets": "3 sets"},
            {"exercise": "Human flag holds", "duration": "10 min", "reps": "5-10 sec holds", "sets": "3 sets"}
        ]
    },
    "cardiovascular fitness": {
        "Easy": [
            {"exercise": "Brisk walking", "duration": "20 min", "reps": "1 session", "sets": "Daily"},
            {"exercise": "Low-intensity cycling", "duration": "20 min", "reps": "1 session", "sets": "3-4x/week"},
            {"exercise": "Marching in place", "duration": "5 min", "reps": "3 intervals", "sets": "3x daily"},
            {"exercise": "Step-ups on low step", "duration": "10 min", "reps": "3x15 per leg", "sets": "3 sets"},
            {"exercise": "Arm bike", "duration": "15 min", "reps": "1 session", "sets": "3x/week"},
            {"exercise": "Water walking", "duration": "25 min", "reps": "1 session", "sets": "Daily"},
            {"exercise": "Dancing", "duration": "30 min", "reps": "1 session", "sets": "3x/week"}
        ],
        "Intermediate": [
            {"exercise": "Tempo running", "duration": "30 min", "reps": "1 session", "sets": "3x/week"},
            {"exercise": "Rowing sprints", "duration": "15 min", "reps": "500m x 5", "sets": "3 sets"},
            {"exercise": "Jump rope double unders", "duration": "5 min", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Cycling intervals", "duration": "25 min", "reps": "2 min hard/1 min easy x 8", "sets": "1 session"},
            {"exercise": "Swimming laps", "duration": "35 min", "reps": "50m x 20", "sets": "3x/week"},
            {"exercise": "Elliptical HIIT", "duration": "20 min", "reps": "1 min hard/30 sec easy", "sets": "1 session"},
            {"exercise": "Stair climbing", "duration": "15 min", "reps": "3 min intervals", "sets": "5 sets"}
        ],
        "Advanced": [
            {"exercise": "Sprint intervals with hill runs", "duration": "25 min", "reps": "15 sec sprint / 45 sec rest x 10", "sets": "1 session"},
            {"exercise": "Stair sprints with weighted vest", "duration": "5 min", "reps": "10 rounds", "sets": "3 sets"},
            {"exercise": "Burpee pull-ups", "duration": "15 min", "reps": "3x20", "sets": "3 sets"},
            {"exercise": "Mountain sprints", "duration": "30 min", "reps": "5 min climb/2 min rest", "sets": "5 rounds"},
            {"exercise": "Battle rope intervals", "duration": "20 min", "reps": "30 sec on/30 sec off", "sets": "20 rounds"},
            {"exercise": "Kettlebell swings HIIT", "duration": "12 min", "reps": "20 sec on/10 sec off", "sets": "36 rounds"},
            {"exercise": "Boxing combinations", "duration": "45 min", "reps": "3 min rounds", "sets": "15 rounds"}
        ]
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
        # Assign different exercises to different days (7 days, 7 different exercises)
        for i, day in enumerate(days):
            if i < len(exercises):  # Use different exercise for each day
                ex = exercises[i]
                rows.append({
                    "Day": day, 
                    "Level": level, 
                    "Exercise": ex["exercise"],
                    "Duration": ex["duration"],
                    "Reps": ex["reps"],
                    "Sets": ex["sets"]
                })
            else:  # If we have fewer than 7 exercises, cycle through them
                ex = exercises[i % len(exercises)]
                rows.append({
                    "Day": day, 
                    "Level": level, 
                    "Exercise": ex["exercise"],
                    "Duration": ex["duration"],
                    "Reps": ex["reps"],
                    "Sets": ex["sets"]
                })

        df = pd.DataFrame(rows)
        # Create a new file path that includes both fitness type and level
        file_path = os.path.join(output_dir, f"{fitness.replace(' ', '_')}_{level}.csv")
        df.to_csv(file_path, index=False)
        csv_files_advanced.append(file_path)

print("\nSuccessfully generated the following files in current directory:")
for f in csv_files_advanced:
    print(f)
