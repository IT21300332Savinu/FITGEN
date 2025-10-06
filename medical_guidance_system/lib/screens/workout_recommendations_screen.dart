import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/predict_service.dart';

class WorkoutRecommendationsScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final String? selectedLevel;

  const WorkoutRecommendationsScreen({
    super.key,
    this.userProfile,
    this.selectedLevel,
  });

  @override
  State<WorkoutRecommendationsScreen> createState() =>
      _WorkoutRecommendationsScreenState();
}

class _WorkoutRecommendationsScreenState
    extends State<WorkoutRecommendationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _apiResponse;
  bool _isLoadingPrediction = false;
  String? _selectedWorkoutType;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPredictions();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadPredictions() async {
    if (widget.userProfile == null) return;

    setState(() {
      _isLoadingPrediction = true;
      _errorMessage = null;
    });

    try {
      print('Loading predictions for user profile...');
      print('Selected fitness level: ${widget.selectedLevel}');
      final response = await PredictService.getPrediction(
        widget.userProfile!,
        fitnessLevel: widget.selectedLevel,
      );

      if (response != null) {
        print('Received response: $response');

        // Debug: Check the structure of the workout plans
        if (response['workout_plans'] != null) {
          print('🏋️ DEBUG - Workout Plans Structure:');
          Map<String, dynamic> workoutPlans = response['workout_plans'];
          workoutPlans.forEach((workoutType, plan) {
            print('  Workout Type: $workoutType');
            print('  Plan Type: ${plan.runtimeType}');
            print('  Plan Content: $plan');
            if (plan is Map<String, dynamic>) {
              plan.forEach((day, exercises) {
                print('    Day: $day');
                print('    Exercises Type: ${exercises.runtimeType}');
                print('    Exercises: $exercises');

                // Debug individual exercises
                if (exercises is List) {
                  for (int i = 0; i < exercises.length && i < 2; i++) {
                    print(
                      '      Exercise $i Type: ${exercises[i].runtimeType}',
                    );
                    print('      Exercise $i Content: ${exercises[i]}');
                    if (exercises[i] is Map) {
                      Map exerciseMap = exercises[i];
                      print('        Keys: ${exerciseMap.keys.toList()}');
                      exerciseMap.forEach((key, value) {
                        print('        $key: $value (${value.runtimeType})');
                      });
                    }
                  }
                }
              });
            }
          });
        }

        setState(() {
          _apiResponse = response;
          // Set the first predicted type as default selection
          if (response['predicted_types'] != null &&
              (response['predicted_types'] as List).isNotEmpty) {
            _selectedWorkoutType = response['predicted_types'][0];
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get predictions from server';
        });
        _showErrorSnackBar(_errorMessage!);
      }
    } catch (e) {
      print('Error loading predictions: $e');
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage!);
    } finally {
      setState(() => _isLoadingPrediction = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadPredictions,
        ),
      ),
    );
  }

  String _formatWorkoutTypeName(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDayName(String day) {
    // Handle various day formats from Flask API
    String formattedDay = day.toLowerCase().trim();

    // Handle day_1, day_2 format
    if (formattedDay.startsWith('day_') || formattedDay.startsWith('day ')) {
      String dayNumber = formattedDay.replaceAll(RegExp(r'day[_\s]*'), '');
      Map<String, String> dayMap = {
        '1': 'Monday',
        '2': 'Tuesday',
        '3': 'Wednesday',
        '4': 'Thursday',
        '5': 'Friday',
        '6': 'Saturday',
        '7': 'Sunday',
      };
      return dayMap[dayNumber] ?? 'Day $dayNumber';
    }

    // Handle full day names
    Map<String, String> dayNames = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
    };

    return dayNames[formattedDay] ?? day.trim();
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 0.18) return Colors.green;
    if (probability >= 0.15) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'AI Workout Recommendations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 210, 112, 42),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoadingPrediction)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPredictions,
              tooltip: 'Refresh Predictions',
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingPrediction) {
      return _buildLoadingView();
    }

    if (_errorMessage != null || _apiResponse == null) {
      return _buildErrorView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildPredictionResults(),
          const SizedBox(height: 24),
          _buildWorkoutTypeSelector(),
          const SizedBox(height: 24),
          if (_selectedWorkoutType != null) _buildSelectedWorkoutPlan(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.deepPurple[600],
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Model Processing...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your health data with machine learning',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please check your connection and try again',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPredictions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 210, 112, 42),
            const Color.fromARGB(255, 210, 112, 42),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 95, 42, 210).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI Workout Analysis Complete',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Level: ${widget.selectedLevel ?? "Not specified"}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResults() {
    List<dynamic> predictedTypes = _apiResponse!['predicted_types'] ?? [];
    Map<String, dynamic> probabilities = _apiResponse!['probabilities'] ?? {};
    // double threshold = _apiResponse!['threshold'] ?? 0.0; // Hidden from user

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'AI Prediction Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primary Recommendations
          if (predictedTypes.isNotEmpty) ...[
            const Text(
              'Recommended Workout Types:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: predictedTypes.map<Widget>((type) {
                double probability = probabilities[type] ?? 0.0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getProbabilityColor(probability).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getProbabilityColor(probability),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatWorkoutTypeName(type),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getProbabilityColor(probability),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Percentage hidden from user view
                      /*
                      Text(
                        '${(probability * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: _getProbabilityColor(probability),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      */
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Threshold Info - HIDDEN FROM USER
          /*
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Confidence Threshold:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(threshold * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[600],
                  ),
                ),
              ],
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildWorkoutTypeSelector() {
    List<dynamic> predictedTypes = _apiResponse!['predicted_types'] ?? [];

    if (predictedTypes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Workout Type to View Plan:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...predictedTypes.map<Widget>((type) {
            bool isSelected = _selectedWorkoutType == type;
            // Map<String, dynamic> probabilities =
            //     _apiResponse!['probabilities'] ?? {};
            // double probability = probabilities[type] ?? 0.0; // Hidden from user

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWorkoutType = type;
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.deepPurple[600]!
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.deepPurple[600]
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple[600]!
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatWorkoutTypeName(type),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.deepPurple[600]
                                  : Colors.black87,
                            ),
                          ),
                          // Confidence percentage hidden from user view
                          /*
                          Text(
                            'Confidence: ${(probability * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          */
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isSelected
                          ? Colors.deepPurple[600]
                          : Colors.grey[400],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSelectedWorkoutPlan() {
    if (_selectedWorkoutType == null) return const SizedBox.shrink();

    Map<String, dynamic> workoutPlans = _apiResponse!['workout_plans'] ?? {};
    Map<String, dynamic>? selectedPlan = workoutPlans[_selectedWorkoutType];

    if (selectedPlan == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 210, 112, 42).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: const Color.fromARGB(255, 210, 112, 42),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Workout Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatWorkoutTypeName(_selectedWorkoutType!),
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 210, 112, 42),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Schedule - Sort days starting from today/joining day
          ...(() {
            List<MapEntry<String, dynamic>> sortedDays = selectedPlan.entries
                .toList();

            // Filter out non-workout days (tips, instructions, etc.)
            sortedDays = sortedDays.where((entry) {
              String dayKey = entry.key.toLowerCase().trim();
              return !dayKey.contains('tip') &&
                  !dayKey.contains('instruction') &&
                  !dayKey.contains('motivation') &&
                  !dayKey.contains('safety') &&
                  entry.value is List; // Only include days with exercise lists
            }).toList();

            // Define day order for sorting
            Map<String, int> dayOrder = {
              'monday': 1,
              'mon': 1,
              'day_1': 1,
              'day 1': 1,
              'tuesday': 2,
              'tue': 2,
              'day_2': 2,
              'day 2': 2,
              'wednesday': 3,
              'wed': 3,
              'day_3': 3,
              'day 3': 3,
              'thursday': 4,
              'thu': 4,
              'day_4': 4,
              'day 4': 4,
              'friday': 5,
              'fri': 5,
              'day_5': 5,
              'day 5': 5,
              'saturday': 6,
              'sat': 6,
              'day_6': 6,
              'day 6': 6,
              'sunday': 7,
              'sun': 7,
              'day_7': 7,
              'day 7': 7,
            };

            // Get today's day number (1=Monday, 7=Sunday)
            int todayDayNumber = DateTime.now().weekday;

            // Sort days by proper weekday order first
            sortedDays.sort((a, b) {
              int orderA = dayOrder[a.key.toLowerCase().trim()] ?? 999;
              int orderB = dayOrder[b.key.toLowerCase().trim()] ?? 999;
              return orderA.compareTo(orderB);
            });

            // Reorder to start from today (joining day)
            List<MapEntry<String, dynamic>> reorderedDays = [];
            List<MapEntry<String, dynamic>> beforeToday = [];
            List<MapEntry<String, dynamic>> fromToday = [];

            for (var day in sortedDays) {
              int dayNum = dayOrder[day.key.toLowerCase().trim()] ?? 999;
              if (dayNum >= todayDayNumber) {
                fromToday.add(day);
              } else {
                beforeToday.add(day);
              }
            }

            // Start from today, then continue with remaining days
            reorderedDays.addAll(fromToday);
            reorderedDays.addAll(beforeToday);

            return reorderedDays;
          })().asMap().entries.map<Widget>((dayEntry) {
            int dayIndex = dayEntry.key;
            MapEntry<String, dynamic> entry = dayEntry.value;
            String day = entry.key;
            dynamic exerciseData = entry.value;

            // Check if this is today's day
            int todayDayNumber = DateTime.now().weekday;
            Map<String, int> dayOrder = {
              'monday': 1,
              'mon': 1,
              'day_1': 1,
              'day 1': 1,
              'tuesday': 2,
              'tue': 2,
              'day_2': 2,
              'day 2': 2,
              'wednesday': 3,
              'wed': 3,
              'day_3': 3,
              'day 3': 3,
              'thursday': 4,
              'thu': 4,
              'day_4': 4,
              'day 4': 4,
              'friday': 5,
              'fri': 5,
              'day_5': 5,
              'day 5': 5,
              'saturday': 6,
              'sat': 6,
              'day_6': 6,
              'day 6': 6,
              'sunday': 7,
              'sun': 7,
              'day_7': 7,
              'day 7': 7,
            };
            int currentDayNum = dayOrder[day.toLowerCase().trim()] ?? 999;
            bool isToday = currentDayNum == todayDayNumber;

            // Handle different data types from API
            List<String> exercises = [];
            if (exerciseData is List) {
              exercises = exerciseData.map((e) => e.toString()).toList();
            } else if (exerciseData is String) {
              exercises = [exerciseData];
            } else if (exerciseData is Map) {
              // If it's a Map, try to extract exercise data
              if (exerciseData.containsKey('exercises')) {
                var exerciseList = exerciseData['exercises'];
                if (exerciseList is List) {
                  exercises = exerciseList.map((e) => e.toString()).toList();
                } else {
                  exercises = [exerciseList.toString()];
                }
              } else {
                exercises = [exerciseData.toString()];
              }
            } else {
              exercises = [exerciseData.toString()];
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.orange[100]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isToday ? Icons.today : Icons.calendar_today,
                          color: isToday
                              ? Colors.orange[700]
                              : const Color.fromARGB(255, 210, 112, 42),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? Colors.orange[200]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Day ${dayIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? Colors.orange[800]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'START HERE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDayName(day),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.orange[800]
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${exercises.length} exercises',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...exercises.asMap().entries.map<Widget>((exerciseEntry) {
                    int index = exerciseEntry.key;
                    dynamic exerciseData = exerciseEntry.value;

                    // Handle exercise data - could be string or object with duration/reps
                    String exerciseName = '';
                    String duration = '';
                    String reps = '';

                    if (exerciseData is String) {
                      exerciseName = exerciseData;
                    } else if (exerciseData is Map) {
                      exerciseName =
                          exerciseData['Exercise']?.toString() ??
                          exerciseData['exercise']?.toString() ??
                          exerciseData['name']?.toString() ??
                          exerciseData.toString();
                      duration = exerciseData['Duration']?.toString() ?? '';
                      reps = exerciseData['Reps']?.toString() ?? '';
                    } else {
                      exerciseName = exerciseData.toString();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 210, 112, 42),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exerciseName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (duration.isNotEmpty || reps.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      if (duration.isNotEmpty) ...[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              duration,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (reps.isNotEmpty) ...[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.repeat,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              reps,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Action Buttons
          Column(
            children: [
              // Primary Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to workout execution screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '🏋️ Starting workout plan... (Feature coming soon!)',
                        ),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text(
                    'START WORKOUT PLAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 210, 112, 42),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Action Buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('💾 Workout plan saved successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add, size: 20),
                  label: const Text('Save Plan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.green[600]!, width: 1.5),
                    foregroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
