import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'workout_recommendations_screen.dart';

class FitnessAssessmentScreen extends StatefulWidget {
  final UserProfile? userProfile;

  const FitnessAssessmentScreen({super.key, this.userProfile});

  @override
  State<FitnessAssessmentScreen> createState() =>
      _FitnessAssessmentScreenState();
}

class _FitnessAssessmentScreenState extends State<FitnessAssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _currentQuestionIndex = 0;
  bool _showSuggestion = false;
  String? _suggestedLevel;
  String? _suggestionReason;
  String? _selectedLevel;

  // Question responses
  String? _gymExperience;
  String? _exerciseDays;
  String? _fatigueLevel;

  // Updated questions - removed workout preference and time questions
  List<Question> get _questions => [
    Question(
      title: "What is your current level of gym experience?",
      icon: Icons.fitness_center,
      gradient: [Colors.purple.shade400, Colors.purple.shade600],
      options: [
        "Never exercised before",
        "Some experience with basic workouts",
        "Regular gym-goer",
        "Advanced training experience",
      ],
    ),
    Question(
      title: "How many days per week can you commit to exercise?",
      icon: Icons.calendar_today,
      gradient: [Colors.blue.shade400, Colors.blue.shade600],
      options: ["1-2 days", "3-4 days", "5-6 days", "7 days"],
    ),
    Question(
      title:
          "Do you experience fatigue, dizziness, or discomfort during physical activity?",
      icon: Icons.health_and_safety,
      gradient: [Colors.red.shade400, Colors.red.shade600],
      options: ["Frequently", "Sometimes", "Rarely", "Never"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _calculateSuggestion();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _calculateSuggestion() {
    int score = 0;
    List<String> reasons = [];

    // Gym experience scoring
    switch (_gymExperience) {
      case "Never exercised before":
        score += 0;
        reasons.add("no prior gym experience");
        break;
      case "Some experience with basic workouts":
        score += 1;
        reasons.add("basic workout experience");
        break;
      case "Regular gym-goer":
        score += 2;
        reasons.add("regular gym experience");
        break;
      case "Advanced training experience":
        score += 3;
        reasons.add("advanced training background");
        break;
    }

    // Exercise days scoring
    switch (_exerciseDays) {
      case "1-2 days":
        score += 0;
        reasons.add("limited time availability");
        break;
      case "3-4 days":
        score += 1;
        reasons.add("moderate time commitment");
        break;
      case "5-6 days":
        score += 2;
        reasons.add("good time availability");
        break;
      case "7 days":
        score += 3;
        reasons.add("high time commitment");
        break;
    }

    // Fatigue level scoring (inverted)
    switch (_fatigueLevel) {
      case "Frequently":
        score += 0;
        reasons.add("frequent fatigue during activity");
        break;
      case "Sometimes":
        score += 1;
        reasons.add("occasional discomfort");
        break;
      case "Rarely":
        score += 2;
        reasons.add("good exercise tolerance");
        break;
      case "Never":
        score += 3;
        reasons.add("excellent exercise tolerance");
        break;
    }

    // Check for medical conditions
    if (widget.userProfile != null) {
      bool hasConditions =
          widget.userProfile!.diabetes ||
          widget.userProfile!.hypertension ||
          widget.userProfile!.ckd ||
          widget.userProfile!.liverDisease;

      if (hasConditions) {
        score = (score * 0.7).round(); // Reduce score for safety
        reasons.add("medical conditions requiring caution");
      }
    }

    // Determine level and create personalized reason
    String level;
    String reason;

    if (score <= 3) {
      level = "Easy";
      reason =
          "Based on your ${reasons.take(3).join(", ")}, I recommend starting with an Easy level to build a safe foundation.";
    } else if (score <= 6) {
      level = "Intermediate";
      reason =
          "Given your ${reasons.take(3).join(", ")}, an Intermediate level would challenge you appropriately while ensuring steady progress.";
    } else {
      level = "Advanced";
      reason =
          "With your ${reasons.take(3).join(", ")}, you're ready for an Advanced level that will maximize your fitness potential.";
    }

    setState(() {
      _suggestedLevel = level;
      _suggestionReason = reason;
      _selectedLevel = level; // Auto-select the suggested level
      _showSuggestion = true;
    });

    _pulseController.repeat(reverse: true);
  }

  void _selectAnswer(String answer) {
    setState(() {
      switch (_currentQuestionIndex) {
        case 0:
          _gymExperience = answer;
          break;
        case 1:
          _exerciseDays = answer;
          break;
        case 2:
          _fatigueLevel = answer;
          break;
      }
    });
  }

  String? _getCurrentAnswer() {
    switch (_currentQuestionIndex) {
      case 0:
        return _gymExperience;
      case 1:
        return _exerciseDays;
      case 2:
        return _fatigueLevel;
      default:
        return null;
    }
  }

  void _proceedToWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutRecommendationsScreen(
          userProfile: widget.userProfile,
          selectedLevel: _selectedLevel, // Pass only the selected level
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Fitness Assessment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _showSuggestion ? _buildSuggestionView() : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildProgressHeader(),
                Expanded(child: _buildQuestionContent()),
                _buildNavigationButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader() {
    final question = _questions[_currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: question.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: question.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: question.gradient[0].withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(question.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  question.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _getCurrentAnswer() == option;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? question.gradient[0]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? question.gradient[1]
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? question.gradient[0].withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: isSelected ? 15 : 8,
                              offset: Offset(0, isSelected ? 8 : 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                      color: question.gradient[0],
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final currentAnswer = _getCurrentAnswer();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.indigo[600]!),
                  foregroundColor: Colors.indigo[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentQuestionIndex > 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: currentAnswer != null ? _nextQuestion : null,
              icon: Icon(
                _currentQuestionIndex == _questions.length - 1
                    ? Icons.psychology
                    : Icons.arrow_forward,
              ),
              label: Text(
                _currentQuestionIndex == _questions.length - 1
                    ? 'Get AI Suggestion'
                    : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: currentAnswer != null ? 4 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionView() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'AI Analysis Complete',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Based on your responses, here\'s my recommendation',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Suggestion Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getLevelColor().withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getLevelColor().withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getLevelColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.verified,
                            color: _getLevelColor(),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI Recommends',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_suggestedLevel Level',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _suggestionReason!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Level Selection
              const Text(
                'Choose Your Level',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can choose the AI suggestion or select a different level',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.fitness_center),
                    hintText: 'Select your fitness level',
                  ),
                  items: ['Easy', 'Intermediate', 'Advanced'].map((level) {
                    final isRecommended = level == _suggestedLevel;
                    return DropdownMenuItem(
                      value: level,
                      child: Row(
                        children: [
                          Text(
                            level,
                            style: TextStyle(
                              fontWeight: isRecommended
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isRecommended
                                  ? _getLevelColor()
                                  : Colors.black,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getLevelColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'AI Pick',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getLevelColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedLevel != null ? _proceedToWorkout : null,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text(
                    'Generate My Workout Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getLevelColor() {
    switch (_suggestedLevel) {
      case 'Easy':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }
}

class Question {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final List<String> options;

  Question({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.options,
  });
}
