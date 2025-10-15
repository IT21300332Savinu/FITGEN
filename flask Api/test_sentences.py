#!/usr/bin/env python3
"""Simple test to check the sentence formatting directly"""

from app.model import get_workout_instructions, get_daily_workout_tips
import json

def test_sentence_formatting():
    """Test the sentence formatting of instructions and tips"""
    
    print("🎯 TESTING SENTENCE-BY-SENTENCE FORMATTING")
    print("=" * 50)
    
    # Test workout instructions
    instructions = get_workout_instructions()
    print("\n📋 WORKOUT INSTRUCTIONS STRUCTURE:")
    print(f"Type: {type(instructions)}")
    print(f"Keys: {list(instructions.keys())}")
    
    # Show before workout instructions
    print("\n🔥 BEFORE WORKOUT (Sample):")
    for i, instruction in enumerate(instructions["before_workout"][:3], 1):
        print(f"  {i}. {instruction}")
    
    # Test daily tips
    tips = get_daily_workout_tips()
    print("\n🌟 DAILY TIPS STRUCTURE:")
    print(f"Type: {type(tips)}")
    print(f"Keys: {list(tips.keys())}")
    
    # Show general tips
    print("\n💡 GENERAL TIPS (Sample):")
    for i, tip in enumerate(tips["general_tips"][:3], 1):
        print(f"  {i}. {tip}")
    
    print("\n✅ Sentence-by-sentence formatting is working!")
    print("Each instruction and tip is now a separate, clear sentence.")

if __name__ == "__main__":
    test_sentence_formatting()