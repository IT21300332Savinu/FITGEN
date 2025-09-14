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
    try:
        result = predict(input_data)
        workout_plans = get_workout_plans(result['predicted_types'], level)
        result['workout_plans'] = workout_plans
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500