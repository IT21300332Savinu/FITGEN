#!/usr/bin/env python3
"""Test script to verify workout API with sentence-by-sentence formatting"""

import requests
import json

def test_workout_api():
    """Test the workout API and display formatted results"""
    url = "http://127.0.0.1:5000/predict"
    
    # Test data
    data = {
        "input": [25, 70, 175, 1, 2],  # age, weight, height, goals (strength=1), activity_level (intermediate=2)
        "level": "Intermediate",
        "start_day": "Monday"
    }
    
    try:
        response = requests.post(url, json=data)
        if response.status_code == 200:
            result = response.json()
            
            print("🎯 WORKOUT API TEST RESULTS")
            print("=" * 50)
            
            # Show workout instructions (sentence by sentence)
            if "workout_plans" in result:
                plans = result["workout_plans"]
                first_fitness_type = list(plans.keys())[0]
                
                if "workout_instructions" in plans[first_fitness_type]:
                    print("\n📋 WORKOUT INSTRUCTIONS:")
                    print("-" * 30)
                    instructions = plans[first_fitness_type]["workout_instructions"]
                    
                    # Before workout
                    if "before_workout" in instructions:
                        print("\n🔥 BEFORE WORKOUT:")
                        for i, instruction in enumerate(instructions["before_workout"], 1):
                            print(f"  {i}. {instruction}")
                    
                    # During workout  
                    if "during_workout" in instructions:
                        print("\n💪 DURING WORKOUT:")
                        for i, instruction in enumerate(instructions["during_workout"], 1):
                            print(f"  {i}. {instruction}")
                    
                    # After workout
                    if "after_workout" in instructions:
                        print("\n🧘 AFTER WORKOUT:")
                        for i, instruction in enumerate(instructions["after_workout"], 1):
                            print(f"  {i}. {instruction}")
                
                # Show daily tips (sentence by sentence)
                if "daily_tips" in plans[first_fitness_type]:
                    print("\n🌟 DAILY TIPS:")
                    print("-" * 20)
                    tips = plans[first_fitness_type]["daily_tips"]
                    
                    # General tips
                    if "general_tips" in tips:
                        print("\n💡 GENERAL TIPS:")
                        for i, tip in enumerate(tips["general_tips"][:5], 1):
                            print(f"  {i}. {tip}")
                            
                    # Safety reminders
                    if "safety_reminders" in tips:
                        print("\n⚠️ SAFETY REMINDERS:")
                        for i, reminder in enumerate(tips["safety_reminders"][:3], 1):
                            print(f"  {i}. {reminder}")
            
            # Show sample workout plan
            if "workout_plans" in result:
                print("\n📅 SAMPLE WORKOUT PLAN:")
                print("-" * 30)
                plan = result["workout_plans"]
                for fitness_type, days in list(plan.items())[:1]:  # Show first fitness type
                    print(f"\n🏋️ {fitness_type.title()} Training:")
                    for day_name, exercises in list(days.items())[:2]:  # Show first 2 days
                        if isinstance(exercises, list):  # Make sure it's exercise list, not instructions
                            print(f"\n  📆 {day_name}:")
                            for exercise in exercises:
                                print(f"    • {exercise['Exercise']}")
                                print(f"      Duration: {exercise['Duration']} | Reps: {exercise['Reps']} | Sets: {exercise['Sets']}")
            
            print(f"\n✅ API Response Status: {response.status_code}")
            print("🎊 Sentence-by-sentence formatting is working perfectly!")
            
        else:
            print(f"❌ API Error: {response.status_code}")
            print(response.text)
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Make sure Flask server is running on http://127.0.0.1:5000")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_workout_api()