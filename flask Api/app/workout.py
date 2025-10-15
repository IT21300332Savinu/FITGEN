# Complete workout database with Duration, Reps/Count, and Sets for all categories

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

# Weekly schedule - Monday through Sunday in order
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
        "Easy": [
            {"exercise": "Bodyweight circuit: squats, push-ups, lunges", "duration": "15 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Resistance band light circuit", "duration": "12 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Step-ups + sit-to-stand", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Chair exercises circuit", "duration": "8 min", "reps": "2 rounds", "sets": "3 sets"},
            {"exercise": "Wall exercises circuit", "duration": "6 min", "reps": "2 rounds", "sets": "3 sets"},
            {"exercise": "Balance and flexibility circuit", "duration": "12 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Gentle cardio circuit", "duration": "20 min", "reps": "4 rounds", "sets": "1 session"}
        ],
        "Intermediate": [
            {"exercise": "5-exercise AMRAP circuit", "duration": "20 min", "reps": "Max rounds", "sets": "20 mins"},
            {"exercise": "Dumbbell + plyometric combo", "duration": "25 min", "reps": "4 rounds", "sets": "4 rounds"},
            {"exercise": "Jump rope + weighted squats + burpees", "duration": "18 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "Kettlebell circuit", "duration": "15 min", "reps": "3 rounds", "sets": "3 rounds"},
            {"exercise": "TRX suspension circuit", "duration": "20 min", "reps": "4 rounds", "sets": "4 rounds"},
            {"exercise": "Battle rope circuit", "duration": "12 min", "reps": "6 rounds", "sets": "3 sets"},
            {"exercise": "Medicine ball circuit", "duration": "16 min", "reps": "4 rounds", "sets": "4 rounds"}
        ],
        "Advanced": [
            {"exercise": "CrossFit Murph-style workout", "duration": "60 min", "reps": "1 round", "sets": "1 session"},
            {"exercise": "Tabata circuit with Olympic lifts", "duration": "20 min", "reps": "8 rounds", "sets": "1 session"},
            {"exercise": "HIIT circuit with barbell complexes", "duration": "30 min", "reps": "5 rounds", "sets": "5 rounds"},
            {"exercise": "Advanced functional circuit", "duration": "45 min", "reps": "6 rounds", "sets": "1 session"},
            {"exercise": "Competition-style WOD", "duration": "25 min", "reps": "1 round", "sets": "1 session"},
            {"exercise": "Military-style circuit", "duration": "40 min", "reps": "8 rounds", "sets": "1 session"},
            {"exercise": "Strongman circuit", "duration": "35 min", "reps": "5 rounds", "sets": "1 session"}
        ]
    },
    "core training": {
        "Easy": [
            {"exercise": "Crunches", "duration": "5 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Dead bug", "duration": "4 min", "reps": "3x10 per side", "sets": "3 sets"},
            {"exercise": "Plank (20s)", "duration": "3 min", "reps": "3x20 sec", "sets": "3 sets"},
            {"exercise": "Modified bicycle crunches", "duration": "6 min", "reps": "3x20", "sets": "3 sets"},
            {"exercise": "Seated leg lifts", "duration": "4 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Standing marches", "duration": "5 min", "reps": "3x20 per leg", "sets": "3 sets"},
            {"exercise": "Wall sit with core engagement", "duration": "3 min", "reps": "3x30 sec", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Side plank with leg lift", "duration": "8 min", "reps": "3x30 sec per side", "sets": "3 sets"},
            {"exercise": "Hanging knee raises", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Weighted Russian twists", "duration": "6 min", "reps": "3x25", "sets": "3 sets"},
            {"exercise": "Mountain climbers", "duration": "5 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Plank variations", "duration": "12 min", "reps": "3x45 sec", "sets": "3 sets"},
            {"exercise": "Hollow body holds", "duration": "4 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Bird dog", "duration": "8 min", "reps": "3x15 per side", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Dragon flag negatives", "duration": "15 min", "reps": "3x5", "sets": "3 sets"},
            {"exercise": "Ab rollout from standing", "duration": "12 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Hanging windshield wipers", "duration": "10 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "L-sit progressions", "duration": "20 min", "reps": "3x20 sec", "sets": "3 sets"},
            {"exercise": "Human flag progressions", "duration": "25 min", "reps": "3x10 sec", "sets": "3 sets"},
            {"exercise": "Pistol squat to overhead press", "duration": "18 min", "reps": "3x8 per leg", "sets": "3 sets"},
            {"exercise": "Advanced planche progressions", "duration": "30 min", "reps": "3x15 sec", "sets": "3 sets"}
        ]
    },
    "flexibility training": {
        "Easy": [
            {"exercise": "Seated hamstring stretch", "duration": "3 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Cat-cow stretch", "duration": "2 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Shoulder rolls", "duration": "1 min", "reps": "3x10 each direction", "sets": "3 sets"},
            {"exercise": "Neck stretches", "duration": "2 min", "reps": "3x15 sec each direction", "sets": "3 sets"},
            {"exercise": "Ankle circles", "duration": "1 min", "reps": "3x10 each direction", "sets": "3 sets"},
            {"exercise": "Gentle spinal twist", "duration": "4 min", "reps": "3x30 sec each side", "sets": "3 sets"},
            {"exercise": "Standing forward fold", "duration": "3 min", "reps": "3x30 sec", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Pigeon pose with forward fold", "duration": "8 min", "reps": "3x1 min each side", "sets": "3 sets"},
            {"exercise": "Lizard stretch", "duration": "6 min", "reps": "3x45 sec each side", "sets": "3 sets"},
            {"exercise": "Bridge with chest opener", "duration": "5 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Deep hip flexor stretch", "duration": "7 min", "reps": "3x1 min each leg", "sets": "3 sets"},
            {"exercise": "Thoracic spine mobility", "duration": "8 min", "reps": "3x45 sec", "sets": "3 sets"},
            {"exercise": "Hamstring PNF stretching", "duration": "10 min", "reps": "3x30 sec each leg", "sets": "3 sets"},
            {"exercise": "Shoulder and chest opening", "duration": "6 min", "reps": "3x45 sec", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Oversplits with blocks", "duration": "15 min", "reps": "3x2 min each leg", "sets": "3 sets"},
            {"exercise": "Standing scorpion pose", "duration": "12 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Backbend walkover", "duration": "20 min", "reps": "3x5", "sets": "3 sets"},
            {"exercise": "Full front splits", "duration": "18 min", "reps": "3x2 min each leg", "sets": "3 sets"},
            {"exercise": "Advanced backbend variations", "duration": "25 min", "reps": "3x1 min", "sets": "3 sets"},
            {"exercise": "Contortion-style stretching", "duration": "30 min", "reps": "3x90 sec", "sets": "3 sets"},
            {"exercise": "Dynamic flexibility flow", "duration": "22 min", "reps": "3 flows", "sets": "3 sets"}
        ]
    },
    "functional training": {
        "Easy": [
            {"exercise": "Farmer's carry with light weights", "duration": "2 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Step-ups", "duration": "8 min", "reps": "3x12 each leg", "sets": "3 sets"},
            {"exercise": "Sit-to-stand", "duration": "5 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Grocery bag carries", "duration": "3 min", "reps": "3x45 sec", "sets": "3 sets"},
            {"exercise": "Chair squats", "duration": "6 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Light object lifting", "duration": "4 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Balance reach exercises", "duration": "7 min", "reps": "3x10 each direction", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Kettlebell clean and press", "duration": "15 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Medicine ball rotational throws", "duration": "12 min", "reps": "3x10 each side", "sets": "3 sets"},
            {"exercise": "Walking lunges with twist", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Sandbag carries", "duration": "8 min", "reps": "3x50m", "sets": "3 sets"},
            {"exercise": "Box step-ups with knee drive", "duration": "12 min", "reps": "3x15 each leg", "sets": "3 sets"},
            {"exercise": "TRX suspension squats", "duration": "10 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Functional movement patterns", "duration": "18 min", "reps": "3 rounds", "sets": "3 rounds"}
        ],
        "Advanced": [
            {"exercise": "Heavy Turkish get-up", "duration": "20 min", "reps": "3x5", "sets": "3 sets"},
            {"exercise": "Atlas stone lift", "duration": "15 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Yoke carry", "duration": "10 min", "reps": "3x20 meters", "sets": "3 sets"},
            {"exercise": "Tire flips", "duration": "12 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Sled pushes/pulls", "duration": "15 min", "reps": "3x30m", "sets": "3 sets"},
            {"exercise": "Log press", "duration": "18 min", "reps": "3x6", "sets": "3 sets"},
            {"exercise": "Strongman medley", "duration": "25 min", "reps": "3 rounds", "sets": "3 rounds"}
        ]
    },
    "hiit (high-intensity interval training)": {
        "Easy": [
            {"exercise": "20s jog / 40s walk x5", "duration": "5 min", "reps": "5 intervals", "sets": "3 sets"},
            {"exercise": "Low-impact jumping jacks intervals", "duration": "8 min", "reps": "30s on/30s off", "sets": "3 sets"},
            {"exercise": "Bike sprints light", "duration": "5 min", "reps": "6 intervals", "sets": "3 sets"},
            {"exercise": "Step-up intervals", "duration": "10 min", "reps": "45s on/15s off", "sets": "3 sets"},
            {"exercise": "Arm cycling intervals", "duration": "6 min", "reps": "30s on/30s off", "sets": "3 sets"},
            {"exercise": "Modified burpees", "duration": "8 min", "reps": "20s on/40s off", "sets": "3 sets"},
            {"exercise": "Walking intervals", "duration": "15 min", "reps": "2 min fast/1 min slow", "sets": "5 rounds"}
        ],
        "Intermediate": [
            {"exercise": "40s sprint / 20s rest x12", "duration": "12 min", "reps": "12 intervals", "sets": "3 sets"},
            {"exercise": "HIIT burpee + squat jump circuit", "duration": "15 min", "reps": "4 rounds", "sets": "3 sets"},
            {"exercise": "Row sprints 250m x8", "duration": "20 min", "reps": "8 intervals", "sets": "3 sets"},
            {"exercise": "Cycling power intervals", "duration": "25 min", "reps": "3 min on/1 min off", "sets": "6 rounds"},
            {"exercise": "Jump rope HIIT", "duration": "10 min", "reps": "1 min on/30s off", "sets": "10 rounds"},
            {"exercise": "Bodyweight HIIT circuit", "duration": "18 min", "reps": "45s on/15s off", "sets": "18 rounds"},
            {"exercise": "Swimming sprints", "duration": "30 min", "reps": "50m x 12", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Tabata sprints uphill", "duration": "4 min", "reps": "20 sec sprint, 10 sec rest x8", "sets": "3 sets"},
            {"exercise": "HIIT kettlebell snatch complexes", "duration": "16 min", "reps": "4 rounds", "sets": "3 sets"},
            {"exercise": "CrossFit Fran-style workout", "duration": "20 min", "reps": "1 round", "sets": "3 sets"},
            {"exercise": "Battle rope Tabata", "duration": "8 min", "reps": "20s on/10s off x16", "sets": "2 rounds"},
            {"exercise": "Sprint pyramid", "duration": "30 min", "reps": "100m-200m-300m-200m-100m", "sets": "2 rounds"},
            {"exercise": "Assault bike intervals", "duration": "15 min", "reps": "15 cal sprint/45s rest", "sets": "15 rounds"},
            {"exercise": "Burpee box jump over HIIT", "duration": "12 min", "reps": "30s AMRAP/30s rest", "sets": "12 rounds"}
        ]
    },
    "mobility work": {
        "Easy": [
            {"exercise": "Ankle circles", "duration": "1 min", "reps": "10 each direction", "sets": "3 sets"},
            {"exercise": "Arm swings", "duration": "1 min", "reps": "20 forward/backward", "sets": "3 sets"},
            {"exercise": "Neck rotations", "duration": "1 min", "reps": "10 each direction", "sets": "3 sets"},
            {"exercise": "Hip circles", "duration": "2 min", "reps": "10 each direction", "sets": "3 sets"},
            {"exercise": "Shoulder shrugs", "duration": "1 min", "reps": "15 reps", "sets": "3 sets"},
            {"exercise": "Gentle torso twists", "duration": "2 min", "reps": "10 each side", "sets": "3 sets"},
            {"exercise": "Knee to chest", "duration": "3 min", "reps": "15 each leg", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Deep squat to thoracic rotation", "duration": "5 min", "reps": "30 sec each side", "sets": "3 sets"},
            {"exercise": "90/90 hip flow", "duration": "1 min", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Dynamic hamstring sweeps", "duration": "3 min", "reps": "30 sec each leg", "sets": "3 sets"},
            {"exercise": "Shoulder dislocations with band", "duration": "4 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Hip flexor dynamic stretch", "duration": "6 min", "reps": "3x12 each leg", "sets": "3 sets"},
            {"exercise": "Spinal wave", "duration": "5 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Leg swings multi-directional", "duration": "8 min", "reps": "3x15 each direction", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Loaded Jefferson curl", "duration": "8 min", "reps": "3x5 reps", "sets": "3 sets"},
            {"exercise": "Overhead squat mobility drill", "duration": "5 min", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Cossack squat with reach", "duration": "10 min", "reps": "3x5 each leg", "sets": "3 sets"},
            {"exercise": "Advanced hip capsule work", "duration": "12 min", "reps": "3x8 each position", "sets": "3 sets"},
            {"exercise": "Controlled articular rotations", "duration": "15 min", "reps": "3x10 each joint", "sets": "3 sets"},
            {"exercise": "Dynamic spinal decompression", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Multi-planar movement flow", "duration": "20 min", "reps": "3 complete flows", "sets": "3 sets"}
        ]
    },
    "muscular endurance": {
        "Easy": [
            {"exercise": "Wall sit (20s)", "duration": "20 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Light resistance band rows", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Step-ups", "duration": "10 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Modified push-ups hold", "duration": "5 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Chair squats endurance", "duration": "8 min", "reps": "3x20", "sets": "3 sets"},
            {"exercise": "Standing calf raise endurance", "duration": "6 min", "reps": "3x25", "sets": "3 sets"},
            {"exercise": "Arm endurance circles", "duration": "4 min", "reps": "3x45 sec", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Push-ups max reps with tempo", "duration": "12 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Squats", "duration": "15 min", "reps": "4x25", "sets": "4 sets"},
            {"exercise": "Plank to push-up transitions", "duration": "8 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Lunges endurance", "duration": "12 min", "reps": "3x20 per leg", "sets": "3 sets"},
            {"exercise": "Bodyweight rows endurance", "duration": "10 min", "reps": "3x18", "sets": "3 sets"},
            {"exercise": "Wall sit progression", "duration": "6 min", "reps": "3x1 min", "sets": "3 sets"},
            {"exercise": "Bear crawl endurance", "duration": "8 min", "reps": "3x45 sec", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Pull-ups 10x10 challenge", "duration": "30 min", "reps": "10x10", "sets": "3 sets"},
            {"exercise": "Jump squats", "duration": "20 min", "reps": "5x25", "sets": "3 sets"},
            {"exercise": "Barbell complex", "duration": "25 min", "reps": "5 rounds", "sets": "5 rounds"},
            {"exercise": "Burpee endurance test", "duration": "15 min", "reps": "100 total", "sets": "1 session"},
            {"exercise": "Advanced push-up variations", "duration": "18 min", "reps": "4x20", "sets": "4 sets"},
            {"exercise": "Pistol squat endurance", "duration": "12 min", "reps": "3x12 per leg", "sets": "3 sets"},
            {"exercise": "Plank endurance progression", "duration": "10 min", "reps": "3x2 min", "sets": "3 sets"}
        ]
    },
    "muscular hypertrophy (muscle growth)": {
        "Easy": [
            {"exercise": "Dumbbell curls light", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Bodyweight squats", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Push-ups", "duration": "6 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Assisted pull-ups", "duration": "8 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Dumbbell press light", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Leg raises", "duration": "6 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Tricep dips on chair", "duration": "5 min", "reps": "3x10", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Incline bench press", "duration": "15 min", "reps": "4x10", "sets": "4 sets"},
            {"exercise": "Barbell squats", "duration": "12 min", "reps": "4x8", "sets": "4 sets"},
            {"exercise": "Weighted pull-ups", "duration": "10 min", "reps": "4x8", "sets": "4 sets"},
            {"exercise": "Dumbbell rows", "duration": "12 min", "reps": "4x10", "sets": "4 sets"},
            {"exercise": "Overhead press", "duration": "10 min", "reps": "4x8", "sets": "4 sets"},
            {"exercise": "Romanian deadlifts", "duration": "12 min", "reps": "4x10", "sets": "4 sets"},
            {"exercise": "Dips weighted", "duration": "8 min", "reps": "4x8", "sets": "4 sets"}
        ],
        "Advanced": [
            {"exercise": "Deficit deadlifts", "duration": "25 min", "reps": "5x6", "sets": "5 sets"},
            {"exercise": "Incline dumbbell press heavy", "duration": "20 min", "reps": "5x8", "sets": "5 sets"},
            {"exercise": "Weighted dips", "duration": "30 min", "reps": "5x10", "sets": "5 sets"},
            {"exercise": "Heavy barbell rows", "duration": "18 min", "reps": "5x6", "sets": "5 sets"},
            {"exercise": "Front squats heavy", "duration": "20 min", "reps": "5x8", "sets": "5 sets"},
            {"exercise": "Weighted chin-ups", "duration": "15 min", "reps": "5x6", "sets": "5 sets"},
            {"exercise": "Close-grip bench press", "duration": "18 min", "reps": "5x8", "sets": "5 sets"}
        ]
    },
    "muscular strength": {
        "Easy": [
            {"exercise": "Dumbbell deadlifts light", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Wall push-ups", "duration": "6 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Bodyweight squats", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Assisted squats", "duration": "8 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Light overhead press", "duration": "6 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Modified planks", "duration": "4 min", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Resistance band pulls", "duration": "8 min", "reps": "3x15", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Barbell deadlift", "duration": "15 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Overhead press", "duration": "12 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Weighted chin-ups", "duration": "10 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Barbell squats", "duration": "15 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Bench press", "duration": "12 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Barbell rows", "duration": "10 min", "reps": "5x5", "sets": "5 sets"},
            {"exercise": "Dips", "duration": "8 min", "reps": "5x5", "sets": "5 sets"}
        ],
        "Advanced": [
            {"exercise": "Snatch", "duration": "25 min", "reps": "5x3", "sets": "5 sets"},
            {"exercise": "Clean and jerk", "duration": "30 min", "reps": "5x3", "sets": "5 sets"},
            {"exercise": "Squat/bench/deadlift 1RM training", "duration": "40 min", "reps": "4x1", "sets": "4 sets"},
            {"exercise": "Heavy front squats", "duration": "20 min", "reps": "5x3", "sets": "5 sets"},
            {"exercise": "Weighted pull-ups max", "duration": "15 min", "reps": "5x3", "sets": "5 sets"},
            {"exercise": "Log press", "duration": "25 min", "reps": "5x3", "sets": "5 sets"},
            {"exercise": "Atlas stone lift", "duration": "20 min", "reps": "5x3", "sets": "5 sets"}
        ]
    },
    "plyometrics": {
        "Easy": [
            {"exercise": "Jumping jacks", "duration": "30 sec", "reps": "3x30 sec", "sets": "3 sets"},
            {"exercise": "Squat jumps (light)", "duration": "5 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Lateral hops", "duration": "4 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Step-up jumps", "duration": "6 min", "reps": "3x12 per leg", "sets": "3 sets"},
            {"exercise": "Modified burpees", "duration": "8 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Gentle hop in place", "duration": "3 min", "reps": "3x20", "sets": "3 sets"},
            {"exercise": "Seated leg bounces", "duration": "4 min", "reps": "3x25", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Box jumps 24in", "duration": "12 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Burpee box jumps", "duration": "15 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Skater jumps with distance", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Tuck jumps", "duration": "6 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Lateral bounds", "duration": "10 min", "reps": "3x10 per side", "sets": "3 sets"},
            {"exercise": "Split jump lunges", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Plyometric push-ups", "duration": "6 min", "reps": "3x6", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Depth jumps from 36in", "duration": "15 min", "reps": "3x6", "sets": "3 sets"},
            {"exercise": "Single-leg hurdle hops", "duration": "12 min", "reps": "3x8 each leg", "sets": "3 sets"},
            {"exercise": "Broad jumps into sprint", "duration": "10 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Reactive box jumps", "duration": "8 min", "reps": "3x6", "sets": "3 sets"},
            {"exercise": "Lateral hurdle hops", "duration": "10 min", "reps": "3x8 per side", "sets": "3 sets"},
            {"exercise": "Depth jump to box jump", "duration": "12 min", "reps": "3x5", "sets": "3 sets"},
            {"exercise": "Plyometric muscle-ups", "duration": "15 min", "reps": "3x3", "sets": "3 sets"}
        ]
    },
    "resistance band training": {
        "Easy": [
            {"exercise": "Band pull-aparts", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Seated rows", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Side steps with band", "duration": "10 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Overhead pulls", "duration": "6 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Bicep curls with band", "duration": "5 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Chest press with band", "duration": "8 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Leg press with band", "duration": "10 min", "reps": "3x15", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Banded chest fly", "duration": "12 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Banded thrusters", "duration": "15 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Banded deadlifts", "duration": "15 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Band-assisted squats", "duration": "10 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Banded face pulls", "duration": "8 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Lateral raises with band", "duration": "6 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Band monster walks", "duration": "12 min", "reps": "3x20 steps", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Banded squats with barbell", "duration": "20 min", "reps": "4x10", "sets": "4 sets"},
            {"exercise": "Banded bench press", "duration": "20 min", "reps": "4x8", "sets": "4 sets"},
            {"exercise": "Banded muscle-ups", "duration": "25 min", "reps": "3x5", "sets": "3 sets"},
            {"exercise": "Banded deadlifts heavy", "duration": "18 min", "reps": "4x8", "sets": "4 sets"},
            {"exercise": "Band-resisted sprints", "duration": "15 min", "reps": "5x30m", "sets": "3 sets"},
            {"exercise": "Banded Olympic lifts", "duration": "25 min", "reps": "4x6", "sets": "4 sets"},
            {"exercise": "Advanced band complex", "duration": "30 min", "reps": "3 rounds", "sets": "3 rounds"}
        ]
    },
    "speed & agility drills": {
        "Easy": [
            {"exercise": "High knees (slow)", "duration": "30 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Side shuffles", "duration": "45 sec", "reps": "3 sets", "sets": "3 sets"},
            {"exercise": "Cone step drills", "duration": "5 min", "reps": "3 rounds", "sets": "3 sets"},
            {"exercise": "Marching with arm swings", "duration": "3 min", "reps": "3x1 min", "sets": "3 sets"},
            {"exercise": "Gentle direction changes", "duration": "6 min", "reps": "3x10", "sets": "3 sets"},
            {"exercise": "Walking lunges", "duration": "8 min", "reps": "3x15", "sets": "3 sets"},
            {"exercise": "Balance step patterns", "duration": "10 min", "reps": "3 patterns", "sets": "3 sets"}
        ],
        "Intermediate": [
            {"exercise": "Sprint shuttles 10x20m", "duration": "15 min", "reps": "5x20m", "sets": "3 sets"},
            {"exercise": "Agility ladder with push-ups", "duration": "12 min", "reps": "3 rounds", "sets": "3 sets"},
            {"exercise": "Resisted sled runs", "duration": "10 min", "reps": "5x30m", "sets": "3 sets"},
            {"exercise": "T-drill", "duration": "8 min", "reps": "3x6", "sets": "3 sets"},
            {"exercise": "Box drill", "duration": "6 min", "reps": "3x8", "sets": "3 sets"},
            {"exercise": "Lateral cone hops", "duration": "10 min", "reps": "3x12", "sets": "3 sets"},
            {"exercise": "Sprint intervals", "duration": "18 min", "reps": "6x50m", "sets": "3 sets"}
        ],
        "Advanced": [
            {"exercise": "Cone drills with reaction sprints", "duration": "20 min", "reps": "8 rounds", "sets": "3 sets"},
            {"exercise": "Resisted band sprints", "duration": "15 min", "reps": "6x40m", "sets": "3 sets"},
            {"exercise": "Change of direction drills with ball reaction", "duration": "25 min", "reps": "5 rounds", "sets": "3 sets"},
            {"exercise": "Advanced agility circuit", "duration": "18 min", "reps": "4 rounds", "sets": "3 sets"},
            {"exercise": "Plyometric agility sequence", "duration": "12 min", "reps": "3 sequences", "sets": "3 sets"},
            {"exercise": "Sport-specific movement patterns", "duration": "22 min", "reps": "6 patterns", "sets": "3 sets"},
            {"exercise": "High-intensity direction changes", "duration": "16 min", "reps": "8x30 sec", "sets": "3 sets"}
        ]
    }
}

# Output directory
output_dir = os.path.join(os.getcwd(), 'workouts')  # Save in "workouts" folder in current directory
os.makedirs(output_dir, exist_ok=True)

csv_files_advanced = []

# Generate CSVs with 3 exercises per day for 7 days
for fitness in fitness_types:
    # Loop through each level (Easy, Intermediate, Advanced) to create separate files
    for level, exercises in exercise_database_advanced[fitness].items():
        rows = []
        
        # Ensure we have enough exercises (need at least 7 for variety)
        if len(exercises) < 7:
            print(f"Warning: {fitness} {level} has only {len(exercises)} exercises, need 7")
            continue
            
        # Generate 7 days with 3 different exercises each day
        for day_index, day in enumerate(days):
            # Get 3 exercises for this day
            for exercise_num in range(3):  # 3 exercises per day
                # Calculate exercise index: cycle through all exercises
                # This ensures we use different combinations each day
                ex_index = (day_index * 3 + exercise_num) % len(exercises)
                ex = exercises[ex_index]
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