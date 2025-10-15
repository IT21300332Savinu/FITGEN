from flask import Blueprint, request, jsonify
from app.model import predict, get_workout_plans  # <-- Add get_workout_plans here


bp = Blueprint('main', __name__)

@bp.route('/predict', methods=['POST'])
def make_prediction():
    data = request.get_json()
    print(data)
    if not data or 'input' not in data or 'level' not in data:
        return jsonify({'error': 'Invalid input'}), 400
    input_data = data['input']
    level = data['level']
    
    # Check if client wants simple format (for backward compatibility)
    simple_format = data.get('simple_format', False)
    
    # Check if client specifies a start day (e.g., user joined on Saturday)
    start_day = data.get('start_day', None)  # e.g., "Saturday"
    
    try:
        result = predict(input_data)
        print(f"Predict result: {result}")  # Debug print
        workout_plans = get_workout_plans(result['predicted_types'], level, simple_format, start_day)
        print(f"Workout plans result: {workout_plans}")  # Debug print
        result['workout_plans'] = workout_plans
        return jsonify(result)
    except Exception as e:
        print(f"Error: {e}")  # Debug print
        import traceback
        traceback.print_exc()  # Full error traceback
        return jsonify({'error': str(e)}), 500