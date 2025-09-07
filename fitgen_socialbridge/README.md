# FITGEN
RP25-001

FitGen – AI Smart Fitness Companion is a holistic fitness solution combining AI, wearable technology, and gamification. It offers personalized workout plans, real-time feedback, and goal specific guidance to improve fitness. Additionally, it includes healthcare monitoring, dynamic nutrition plans tailored to individual goals, and dedicated support for specially-abled individuals, promoting inclusivity, well-being, and sustainable practices in fitness. 

This research project (R25-001) was developed at Sri Lanka Institute of Information Technology as part of our undergraduate degree program in Information Technology.

Research Team : 
Gamage R.P.D.D - AI Gym Trainer with Gamification
Jayamali P. L. W. - AI Medical Guidance for Smart Gym
Methsandi K. A. N. - AI Nutritionist: Personalized Meal Plan & Grocery List Generator
Gunwardena S. N. A. - Social Bridge for Specially-Abled Youth

Supervised by: Dr. Dinuka Wijendra
Co-Supervised by: Ms. Jenny Krishara
External Supervisor: Dr. A.T. Sudharshana

System Architecture :
FITGEN follows a comprehensive, integrated architecture where each component functions both
independently and as part of the cohesive ecosystem:

The system consists of four main components that work together to provide a holistic fitness
experience:

1. AI Gym Trainer with Gamification - Core workout platform with real-time form analysis
2. AI Medical Guidance - Health risk assessment and workout safety monitoring
3. AI Nutritionist - Personalized meal planning and dietary recommendations
4. Social Bridge for Specially-Abled Youth - Inclusive social connectivity and engagement

Data Flow

The integrated system follows this workflow:
1. User registration and profile creation (basic info, fitness goals, medical history, dietary
preferences)
2. Profile data storage in secure Firebase database
3. AI Gym Trainer generates base workout plan
4. AI Medical Guidance reviews health risks and modifies workouts accordingly
5. AI Nutritionist generates personalized meal plans
6. Social Bridge connects users based on ability type and interests
7. User engages with workouts, receives real-time feedback, and earns gamification
rewards
8. System continuously adapts based on performance, health data, and engagement

Prerequisites :
• Flutter SDK (^3.7.0)
• Dart SDK
• Android Studio / Visual Studio Code
• Firebase account
• Git

Environment Setup:
1. Clone the repository:
git clone https://github.com/SLIIT-FitGen/fitgen.git
cd fitgen
2. Install dependencies:
flutter pub get
3. Configure Firebase:
o Create a Firebase project at Firebase Console
o Add your Android/iOS app to the Firebase project
o Download and add the configuration files to your project
o Enable required Firebase services (Authentication, Firestore, Storage)
4. Run the project:
flutter run

Core Features :
1. AI Gym Trainer with Gamification
• Real-time pose detection and analysis using Google ML Kit
• Form correction feedback and guided workouts
• Rep counting and exercise tracking
• Personalized workout plans that adapt to performance
• Achievement system with badges, XP, and leaderboards
• Progress visualization and statistics
2. AI Medical Guidance for Smart Gym
• Health risk assessment based on user-provided medical history
• Real-time monitoring of workout safety parameters
• Workout modification recommendations based on health conditions
• Integration with wearable devices for physiological monitoring
• Health metrics tracking and goal-based progress reports
• Alert system for potentially dangerous exercise patterns
3. AI Nutritionist
• Personalized meal planning based on fitness goals
• Dietary restriction awareness and allergies management
• Automated grocery list generation
• Nutritional analysis and calorie tracking
• Meal recommendations synchronized with workout intensity
• Hydration tracking and reminders
4. Social Bridge for Specially-Abled Youth
• Inclusive community features for specially-abled users
• AI coach to provide workouts for preferred sports
• Collaborative challenges and support networks
• Accessible interface with multiple interaction modalities
• Achievement sharing and social reinforcement
• Virtual events and community engagement opportunities

Technical Implementation :

Technologies Used :
• Flutter: Cross-platform framework for mobile and web interfaces
• Firebase: Backend services for authentication, database, and storage
• Google ML Kit: AI-powered pose detection and analysis
• TensorFlow Lite: On-device machine learning for form analysis
• Provider: State management
• Camera API: Real-time video processing
• Bluetooth Low Energy: Wearable device integration


Tech Dependencies :

Social Bridge for Special Users to Start and Engage in Sports :

Flutter 3.19.5
Dart 3.2.3
firebase_core: 2.25.2
firebase_auth: 4.17.4
cloud_firestore: 4.15.4
firebase_storage: 11.6.4
firebase_analytics: 10.8.4
google_fonts: 6.1.0
image_picker: 1.1.0
video_player: 2.8.1
camera: 0.10.5+9
path_provider: 2.1.3
shared_preferences: 2.2.2
provider: 6.1.2
flutter_spinkit: 5.2.0
fluttertoast: 8.2.2
Python 3.9.x
mediapipe==0.10.8
opencv-python==4.8.1.78
numpy==1.24.4
matplotlib==3.7.1
ipykernel==6.25.2

AI Gym Trainer with Gamification :

cupertino_icons: 1.0.2
firebase_core: 2.24.2
firebase_auth: 4.15.3
cloud_firestore: 4.13.6
firebase_storage: 11.6.5
camera: 0.10.5
google_mlkit_pose_detection: 0.6.0
google_mlkit_commons: 0.3.0 
image: 4.0.17
path_provider: 2.0.15
provider: 6.0.5
intl: 0.18.0
flutter_blue_plus: 1.35.3
camera_web: 0.3.5


AI Personalized Medical Guidance :

firebase_core: 3.13.0
cloud_firestore: 5.6.6
firebase_auth: 5.5.2
provider: 6.1.4
intl: 0.18.1
go_router: 12.1.1 
flutter_animate: 4.0.0
google_fonts: 6.1.0 
image_picker: 0.8.7+5 
cupertino_icons: 1.0.8
firebase_storage: 12.4.5

AI Nutritionist :

fastapi 	For building the backend RESTful API
uvicorn	ASGI server to run FastAPI applications
pandas	Data manipulation and preprocessing
joblib	Saving/loading ML models efficiently
numpy	Numerical computations
scikit-learn==1.2.2	Machine Learning models (e.g., regressors used in calorie prediction)
sentence-transformers	Semantic similarity for meal suggestions using BERT-based models
python-multipart	Handling form data uploads in FastAPI
dio: 5.70

![FitGen AI-Copy of FitGen AI final drawio](https://github.com/user-attachments/assets/6d7d302a-b183-4950-8e31-9204f0e0c785) 

Functional Dependancies :

Social Bridge for Special Users to Start and Engage in Sports x AI Gym Trainer with Gamification - Making gym schedules for users

Social Bridge for Special Users to Start and Engage in Sports x AI Personalized Medical Guidance - Give health advice for special users

Social Bridge for Special Users to Start and Engage in Sports x Diet Planner - Make diet plans for special users

AI Gym Trainer with Gamification x AI Personalized Medical Guidance - Create workouts for users with certain health conditions

AI Gym Trainer with Gamification x Diet Planner - Make diet plans for regular users

AI Personalized Medical Guidance x Diet Planner - Provides dietary restrictions based on medical conditions

Data Sharing Between Components :

1. User Profile Data - Shared across all components for personalized experiences
o Basic information (name, age, weight, height)
o Fitness goals and preferences
o Medical history and dietary preferences
o Accessibility requirements
2. AI Gym Trainer ↔ AI Medical Guidance
o Workout plans modified based on health risk assessment
o Real-time physiological data shared for safety monitoring
o Exercise form quality assessed against medical guidelines
3. AI Gym Trainer ↔ AI Nutritionist
o Calorie expenditure data informs meal planning
o Workout intensity levels guide nutritional requirements
o Performance metrics influence dietary recommendations
4. AI Gym Trainer ↔ Social Bridge
o Achievement data shared for community engagement
o Workout statistics used for challenge matching
o User ability type informs workout recommendations
5. AI Medical Guidance ↔ AI Nutritionist
o Health conditions inform dietary restrictions
o Nutritional needs adjusted based on medical guidance
o Combined health metrics for comprehensive wellness tracking
6. AI Medical Guidance ↔ Social Bridge
o Health-based activity recommendations for social groups
o Safety guidelines for specially-abled community challenges
o Accessible workout modifications shared with community
7. AI Nutritionist ↔ Social Bridge
o Group meal planning for community challenges
o Dietary achievement sharing
o Collaborative grocery lists for social events

Feature Branches

This project is organized into the following feature branches:
• feature/ai-trainer-firebase: Firebase integration for the AI Trainer component
• feature/ai-trainer-gamification: Gamification elements for the AI Trainer
• feature/ai-trainer-pose: Pose detection and analysis implementation
• feature/ai-trainer: Core functionality of the AI Trainer
• feature/medical-guidance: AI Medical Guidance component implementation
• feature/nutritionist: AI Nutritionist component implementation
• feature/social-bridge/ai-coach: AI coach for specially-abled children
• feature/social-bridge/risk-assessment-model: Safety feature for movements
• feature/social-bridge/meetup: Meetup hosting funtion for specially-abled users to gather together

Usage Guide
User Flow
1. Registration and Profile Setup
o Create an account or log in
o Select whether special or normal user
o Complete personal profile with measurements
o Input fitness goals, medical history, and dietary preferences
3. Initial Assessment
o AI Gym Trainer generates base workout plan
o AI Medical Guidance reviews health risks
o AI Nutritionist creates personalized meal plan
o Social Bridge AI Coach generates workouts for sports
4. Daily Usage
o Access personalized dashboard with workout plan, meal suggestions, and social
challenges
o Perform guided workouts with real-time form feedback
o Track nutrition and follow meal recommendations
o Engage with community and participate in challenges
5. Progress and Adaptation
o Review performance metrics and health improvements
o Earn achievements and advance in gamification elements
o System adapts recommendations based on progress and feedback
o Connect with community and share achievements

Research Outcomes
Our initial results indicate:
• 20% improvement in workout effectiveness compared to traditional fitness apps
• 35% increase in user engagement through integrated gamification
• 28% better adherence to fitness programs through personalized guidance
• 42% higher community engagement for specially-abled users

Future Work
• Advanced machine learning models for more precise form detection
• Integration with additional wearable devices for comprehensive health monitoring
• Expanded exercise and nutrition libraries
• Enhanced social features with AR/VR capabilities
• Offline functionality for areas with limited connectivity
• Integration with healthcare providers for medical supervision

License
This project is part of academic research at Sri Lanka Institute of Information Technology.
Acknowledgments
• Department of Information Technology, SLIIT
• Faculty advisors and supervisors
• Testing participants and beta users
• Open-source libraries and frameworks used in development
