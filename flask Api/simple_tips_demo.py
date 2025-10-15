#!/usr/bin/env python3
"""Quick demo of the new simple common tips"""

from app.model import get_daily_workout_tips

def show_simple_tips():
    """Show the new simple common tips format"""
    
    tips = get_daily_workout_tips()
    
    print("🎯 NEW SIMPLE COMMON TIPS")
    print("=" * 40)
    
    print("\n💡 GENERAL TIPS (Simple Daily Actions):")
    for tip in tips['general_tips']:
        print(f"  • {tip}")
    
    print("\n⚠️ SAFETY REMINDERS:")
    for reminder in tips['safety_reminders']:
        print(f"  • {reminder}")
        
    print("\n💪 MOTIVATION:")
    for motivational in tips['motivation']:
        print(f"  • {motivational}")
    
    print("\n✅ Updated to show simple daily actions like:")
    print("   • Drink water")
    print("   • Get sleep") 
    print("   • Eat healthy")
    print("\n🚀 Perfect for mobile app display!")

if __name__ == "__main__":
    show_simple_tips()