import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get user by UID with fallback creation
  static Future<UserModel?> getUserById(
    String uid,
  ) async {
    try {
      print(
        '🔍 Fetching user document for: $uid',
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        print('✅ User document found');
        return UserModel.fromFirestore(doc);
      } else {
        print(
          '⚠️ User document not found, creating fallback user...',
        );

        // Get the current Firebase user info
        User? firebaseUser = FirebaseAuth
            .instance
            .currentUser;
        if (firebaseUser != null) {
          return await _createFallbackUser(
            firebaseUser,
          );
        } else {
          print(
            '❌ No Firebase user found to create fallback',
          );
          return null;
        }
      }
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // Create a fallback user document when one doesn't exist
  static Future<UserModel?>
  _createFallbackUser(
    User firebaseUser,
  ) async {
    try {
      print(
        '🔧 Creating fallback user document for: ${firebaseUser.uid}',
      );

      // Extract name from email or use defaults
      String email =
          firebaseUser.email ?? '';
      String firstName = 'משתמש';
      String lastName = 'חדש';

      // Try to extract name from email
      if (email.isNotEmpty) {
        String localPart = email.split(
          '@',
        )[0];
        if (localPart.contains('.')) {
          List<String> nameParts = localPart
              .split('.');
          firstName = _capitalize(
            nameParts[0],
          );
          if (nameParts.length > 1) {
            lastName = _capitalize(
              nameParts[1],
            );
          }
        } else {
          firstName = _capitalize(localPart);
        }
      }

      // Create user document with default role 'client'
      Map<String, dynamic> userData = {
        'uid': firebaseUser.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role':
            'client', // Default to client
        'createdAt':
            FieldValue.serverTimestamp(),
        'lastLoginAt':
            FieldValue.serverTimestamp(),
        'isActive': true,
        'fcmToken': '',
      };

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);

      // Create client document as well
      await _createDefaultClientData(
        firebaseUser.uid,
      );

      print(
        '✅ Fallback user created successfully',
      );

      // Return the created user
      return UserModel(
        uid: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: 'client',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        fcmToken: '',
      );
    } catch (e) {
      print(
        '❌ Error creating fallback user: $e',
      );
      return null;
    }
  }

  // Create default client data
  static Future<void>
  _createDefaultClientData(
    String uid,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .set({
            'uid': uid,
            'trainerId': '',
            'age': 0,
            'height': 0,
            'weight': 0,
            'fitnessLevel': 'beginner',
            'goals': [],
            'medicalConditions': [],
            'assignedWorkouts': [],
            'completedWorkouts': 0,
            'totalWorkoutTime': 0,
            'currentStreak': 0,
            'lastWorkout': null,
            'joinedAt':
                FieldValue.serverTimestamp(),
          });
      print('✅ Default client data created');
    } catch (e) {
      print(
        '❌ Error creating client data: $e',
      );
    }
  }

  // Create default trainer data
  static Future<void>
  _createDefaultTrainerData(
    String uid,
  ) async {
    try {
      print('🏋️ Creating default trainer data for: $uid');
      
      // Ensure shared workouts database exists
      await _initializeSharedWorkouts();
      
      await _firestore
          .collection('trainers')
          .doc(uid)
          .set({
            'uid': uid,
            'totalClients': 0,
            'rating': 5.0,
            'clientIds': [],
            'specializations': ['כוח', 'קרדיו', 'יוגה'],
            'experience': 3,
            'joinedAt': FieldValue.serverTimestamp(),
          });
      print('✅ Default trainer data created successfully');
    } catch (e) {
      print('❌ Error creating trainer data: $e');
    }
  }

  // Initialize shared workouts and exercises database (one-time setup)
  static Future<void> _initializeSharedWorkouts() async {
    try {
      print('💪 Checking shared workouts and exercises database...');
      
      // Check if our Hebrew exercises already exist
      QuerySnapshot existingHebrewExercises = await _firestore
          .collection('exercises')
          .where('id', isEqualTo: 'exercise_001')
          .limit(1)
          .get();
      
      if (existingHebrewExercises.docs.isNotEmpty) {
        print('✅ Hebrew exercises and workouts already exist, skipping creation');
        return;
      }
      
      print('🔨 Creating shared Hebrew exercises and workouts database...');
      
      // First, create the exercises collection
      await _createExercisesCollection();
      
      // Then, create workouts that reference these exercises
      await _createWorkoutsCollection();

      print('✅ Shared workouts and exercises database created successfully');
    } catch (e) {
      print('❌ Error creating shared workouts and exercises: $e');
    }
  }

  // Create exercises collection
  static Future<void> _createExercisesCollection() async {
    print('🏋️ Creating exercises collection...');
    
    List<Map<String, dynamic>> exercises = [
      {
        'id': 'exercise_001',
        'name': 'דחיפות רגילות',
        'description': 'דחיפות קלאסיות לחיזוק החזה והזרועות. תרגיל בסיסי ויעיל לפיתוח כוח עליון.',
        'instructions': [
          'שכב על הבטן עם כפות הידיים על הרצפה ברוחב הכתפיים',
          'שמור על הגב ישר ורגליים יחד',
          'דחף למעלה עד הארכת הזרועות לחלוטין',
          'חזור למטה בשליטה עד שהחזה כמעט נוגע ברצפה'
        ],
        'targetMuscles': ['חזה', 'זרועות', 'כתפיים'],
        'equipment': [],
        'difficulty': 'בינוני',
        'category': 'כוח עליון',
        'tips': 'שמור על הליבה מתוחה לכל אורך התרגיל',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_002',
        'name': 'כפיפות בטן',
        'description': 'תרגיל קלאסי לחיזוק שרירי הבטן והליבה.',
        'instructions': [
          'שכב על הגב עם ברכיים כפופות',
          'שים ידיים מאחורי הראש או על החזה',
          'הרם את הכתפיים מהרצפה בעזרת שרירי הבטן',
          'חזור למטה בשליטה'
        ],
        'targetMuscles': ['בטן', 'ליבה'],
        'equipment': ['מזרן'],
        'difficulty': 'קל',
        'category': 'ליבה',
        'tips': 'אל תמשוך בצוואר - העבודה צריכה להיות משרירי הבטן',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_003',
        'name': 'סקווטים',
        'description': 'תרגיל בסיסי ויעיל לחיזוק הרגליים והישבן.',
        'instructions': [
          'עמוד עם רגליים ברוחב הכתפיים',
          'ירד למטה כאילו יושב על כיסא',
          'שמור על הברכיים מאחורי הבהונות',
          'עלה חזרה למעלה בעזרת העקבים'
        ],
        'targetMuscles': ['רגליים', 'ישבן', 'ליבה'],
        'equipment': [],
        'difficulty': 'בינוני',
        'category': 'רגליים',
        'tips': 'שמור על החזה מורם והגב ישר',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_004',
        'name': 'ג\'מפינג ג\'קס',
        'description': 'תרגיל קרדיו דינמי לכל הגוף.',
        'instructions': [
          'עמוד זקוף עם רגליים יחד וידיים לצדדים',
          'קפוץ ופתח רגליים ברוחב הכתפיים',
          'בו זמנית הרם ידיים מעל הראש',
          'קפוץ חזרה למצב ההתחלה'
        ],
        'targetMuscles': ['כל הגוף', 'לב ריאות'],
        'equipment': [],
        'difficulty': 'קל',
        'category': 'קרדיו',
        'tips': 'שמור על קצב קבוע ונשימה סדירה',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_005',
        'name': 'ריצה במקום',
        'description': 'תרגיל קרדיו פשוט ויעיל עם הרמת ברכיים.',
        'instructions': [
          'עמוד זקוף במקום',
          'התחל לרוץ במקום תוך הרמת ברכיים גבוה',
          'נסה להגיע עם הברכיים לגובה המותניים',
          'שמור על הזרועות בתנועה'
        ],
        'targetMuscles': ['רגליים', 'לב ריאות'],
        'equipment': [],
        'difficulty': 'קל',
        'category': 'קרדיו',
        'tips': 'התחל בקצב איטי ותגביר בהדרגה',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_006',
        'name': 'ברפי',
        'description': 'תרגיל מורכב המשלב כוח וקרדיו לכל הגוף.',
        'instructions': [
          'עמוד זקוף',
          'ירד לסקוואט ושים ידיים על הרצפה',
          'קפוץ ברגליים לאחור למצב פלאנק',
          'עשה דחיפה (אופציונלי)',
          'קפוץ ברגליים חזרה לסקוואט',
          'קפוץ למעלה עם ידיים מורמות'
        ],
        'targetMuscles': ['כל הגוף', 'לב ריאות'],
        'equipment': [],
        'difficulty': 'קשה',
        'category': 'מורכב',
        'tips': 'שמור על טכניקה נכונה גם כשמתעייף',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_007',
        'name': 'פלאנק',
        'description': 'תרגיל סטטי מעולה לחיזוק הליבה והיציבות.',
        'instructions': [
          'שכב על הבטן',
          'הרם את הגוף על המרפקים ובהונות הרגליים',
          'שמור על הגוף בקו ישר מהראש לעקבים',
          'החזק את המצב לזמן הנדרש'
        ],
        'targetMuscles': ['ליבה', 'כתפיים', 'גב'],
        'equipment': ['מזרן'],
        'difficulty': 'בינוני',
        'category': 'ליבה',
        'tips': 'נשום באופן טבעי ואל תרים את הישבן גבוה מדי',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_008',
        'name': 'לונג\'ס',
        'description': 'תרגיל פונקציונלי מעולה לרגליים ויציבות.',
        'instructions': [
          'עמוד זקוף עם רגליים ברוחב האגן',
          'צעד גדול קדימה ברגל אחת',
          'ירד למטה עד שהברך האחורית כמעט נוגעת ברצפה',
          'דחף חזרה למצב ההתחלה',
          'חלף רגליים'
        ],
        'targetMuscles': ['רגליים', 'ישבן', 'ליבה'],
        'equipment': [],
        'difficulty': 'בינוני',
        'category': 'רגליים',
        'tips': 'שמור על הגב ישר והברך הקדמית מעל הקרסול',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_009',
        'name': 'מאונטיין קליימברס',
        'description': 'תרגיל דינמי המשלב כוח ליבה וקרדיו.',
        'instructions': [
          'התחל במצב פלאנק',
          'הבא ברך אחת לכיוון החזה',
          'החלף רגליים במהירות',
          'המשך בתנועה דינמית'
        ],
        'targetMuscles': ['ליבה', 'כתפיים', 'לב ריאות'],
        'equipment': [],
        'difficulty': 'בינוני',
        'category': 'מורכב',
        'tips': 'שמור על הכתפיים מעל הידיים והליבה מתוחה',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'exercise_010',
        'name': 'תנוחת הכלב הפוך',
        'description': 'תנוחת יוגה בסיסית המותחת את כל הגוף.',
        'instructions': [
          'התחל על ארבע',
          'הרם את הישבן למעלה',
          'יישר את הרגליים והזרועות',
          'צור צורת משולש הפוך',
          'שמור על הראש בין הזרועות'
        ],
        'targetMuscles': ['כל הגוף', 'גמישות'],
        'equipment': ['מזרן יוגה'],
        'difficulty': 'בינוני',
        'category': 'יוגה',
        'tips': 'נשום עמוקות והתמקד בהארכת עמוד השדרה',
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    // Create individual exercise documents
    for (var exercise in exercises) {
      await _firestore
          .collection('exercises')
          .doc(exercise['id'])
          .set(exercise);
    }
    
    print('✅ Created ${exercises.length} exercises');
  }

  // Create workouts collection that references exercises
  static Future<void> _createWorkoutsCollection() async {
    print('💪 Creating workouts collection...');
    
    List<Map<String, dynamic>> workouts = [
      {
        'id': 'workout_001',
        'name': 'אימון כוח עליון',
        'description': 'אימון מקיף לחיזוק שרירי החזה, הכתפיים והזרועות.',
        'duration': 45,
        'difficulty': 'בינוני',
        'isPublic': true,
        'createdBy': 'system',
        'exerciseIds': [
          {
            'exerciseId': 'exercise_001', // דחיפות רגילות
            'sets': 3,
            'reps': '12-15',
            'rest': '60 שניות',
            'order': 1
          },
          {
            'exerciseId': 'exercise_002', // כפיפות בטן
            'sets': 3,
            'reps': '20',
            'rest': '45 שניות',
            'order': 2
          },
          {
            'exerciseId': 'exercise_003', // סקווטים
            'sets': 3,
            'reps': '15',
            'rest': '60 שניות',
            'order': 3
          }
        ],
        'category': 'כוח',
        'equipment': ['מזרן'],
        'targetMuscles': ['חזה', 'זרועות', 'כתפיים'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'workout_002',
        'name': 'קרדיו בסיסי',
        'description': 'אימון קרדיו אינטנסיבי לשריפת קלוריות ושיפור הכושר הלבבי.',
        'duration': 30,
        'difficulty': 'קל',
        'isPublic': true,
        'createdBy': 'system',
        'exerciseIds': [
          {
            'exerciseId': 'exercise_004', // ג'מפינג ג'קס
            'sets': 4,
            'reps': '30 שניות',
            'rest': '30 שניות',
            'order': 1
          },
          {
            'exerciseId': 'exercise_005', // ריצה במקום
            'sets': 3,
            'reps': '60 שניות',
            'rest': '30 שניות',
            'order': 2
          },
          {
            'exerciseId': 'exercise_006', // ברפי
            'sets': 3,
            'reps': '8-10',
            'rest': '60 שניות',
            'order': 3
          }
        ],
        'category': 'קרדיו',
        'equipment': [],
        'targetMuscles': ['כל הגוף'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'workout_003',
        'name': 'אימון פונקציונלי',
        'description': 'אימון המדמה תנועות יומיומיות לשיפור הכוח הפונקציונלי.',
        'duration': 50,
        'difficulty': 'מתקדם',
        'isPublic': true,
        'createdBy': 'system',
        'exerciseIds': [
          {
            'exerciseId': 'exercise_007', // פלאנק
            'sets': 3,
            'reps': '60 שניות',
            'rest': '45 שניות',
            'order': 1
          },
          {
            'exerciseId': 'exercise_008', // לונג'ס
            'sets': 3,
            'reps': '12 לכל רגל',
            'rest': '60 שניות',
            'order': 2
          },
          {
            'exerciseId': 'exercise_009', // מאונטיין קליימברס
            'sets': 4,
            'reps': '20',
            'rest': '45 שניות',
            'order': 3
          }
        ],
        'category': 'פונקציונלי',
        'equipment': ['מזרן'],
        'targetMuscles': ['ליבה', 'רגליים', 'כל הגוף'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'workout_004',
        'name': 'יוגה למתחילים',
        'description': 'אימון יוגה עדין המתמקד בגמישות, נשימה ורגיעה.',
        'duration': 40,
        'difficulty': 'קל',
        'isPublic': true,
        'createdBy': 'system',
        'exerciseIds': [
          {
            'exerciseId': 'exercise_010', // תנוחת הכלב הפוך
            'sets': 3,
            'reps': '30 שניות',
            'rest': '15 שניות',
            'order': 1
          },
          {
            'exerciseId': 'exercise_007', // פלאנק (כתנוחת מנוחה)
            'sets': 2,
            'reps': '30 שניות',
            'rest': '60 שניות',
            'order': 2
          },
          {
            'exerciseId': 'exercise_008', // לונג'ס (כתנוחת לוחם)
            'sets': 2,
            'reps': '30 שניות לכל צד',
            'rest': '30 שניות',
            'order': 3
          }
        ],
        'category': 'יוגה',
        'equipment': ['מזרן יוגה'],
        'targetMuscles': ['גמישות', 'איזון'],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'workout_005',
        'name': 'אימון כוח מלא',
        'description': 'אימון מקיף המשלב תרגילי כוח לכל הגוף.',
        'duration': 55,
        'difficulty': 'קשה',
        'isPublic': true,
        'createdBy': 'system',
        'exerciseIds': [
          {
            'exerciseId': 'exercise_001', // דחיפות רגילות
            'sets': 4,
            'reps': '15-20',
            'rest': '90 שניות',
            'order': 1
          },
          {
            'exerciseId': 'exercise_003', // סקווטים
            'sets': 4,
            'reps': '20',
            'rest': '90 שניות',
            'order': 2
          },
          {
            'exerciseId': 'exercise_006', // ברפי
            'sets': 3,
            'reps': '10-12',
            'rest': '120 שניות',
            'order': 3
          },
          {
            'exerciseId': 'exercise_007', // פלאנק
            'sets': 3,
            'reps': '90 שניות',
            'rest': '60 שניות',
            'order': 4
          }
        ],
        'category': 'כוח',
        'equipment': ['מזרן'],
        'targetMuscles': ['כל הגוף'],
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    // Create individual workout documents
    for (var workout in workouts) {
      await _firestore
          .collection('workouts')
          .doc(workout['id'])
          .set(workout);
    }
    
    print('✅ Created ${workouts.length} workouts');
  }

  // Helper to capitalize first letter
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() +
        text.substring(1).toLowerCase();
  }

  // Get client data
  static Future<Map<String, dynamic>?>
  getClientData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('clients')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data()
            as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting client data: $e');
      return null;
    }
  }

  // Get trainer data
  static Future<Map<String, dynamic>?>
  getTrainerData(String uid) async {
    try {
      print('🔍 Attempting to get trainer data for UID: $uid');
      DocumentSnapshot doc = await _firestore
          .collection('trainers')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        print('✅ Trainer document found');
        Map<String, dynamic> trainerData = doc.data() as Map<String, dynamic>;
        
        // Add shared workouts to trainer data
        List<Map<String, dynamic>> sharedWorkouts = await getAllSharedWorkouts();
        trainerData['workouts'] = sharedWorkouts;
        
        return trainerData;
      } else {
        print('⚠️ Trainer document not found, creating default trainer data...');
        // If trainer document doesn't exist, create it
        await _createDefaultTrainerData(uid);
        
        // Try to fetch it again
        DocumentSnapshot newDoc = await _firestore
            .collection('trainers')
            .doc(uid)
            .get();
        
        if (newDoc.exists) {
          Map<String, dynamic> trainerData = newDoc.data() as Map<String, dynamic>;
          
          // Add shared workouts to trainer data
          List<Map<String, dynamic>> sharedWorkouts = await getAllSharedWorkouts();
          trainerData['workouts'] = sharedWorkouts;
          
          return trainerData;
        }
      }
      return null;
    } catch (e) {
      print(
        'Error getting trainer data: $e',
      );
      return null;
    }
  }

  // Get all shared workouts
  static Future<List<Map<String, dynamic>>> getAllSharedWorkouts() async {
    try {
      print('💪 Fetching shared workouts...');
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('isPublic', isEqualTo: true)
          .get();
      
      List<Map<String, dynamic>> workouts = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
      
      print('✅ Found ${workouts.length} shared workouts');
      return workouts;
    } catch (e) {
      print('❌ Error fetching shared workouts: $e');
      return [];
    }
  }

  // Public method to initialize shared workouts (can be called manually)
  static Future<void> initializeSharedWorkoutsForAllTrainers() async {
    try {
      print('🔧 Manually initializing shared workouts database...');
      await _initializeSharedWorkouts();
    } catch (e) {
      print('❌ Error manually initializing shared workouts: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
    } catch (e) {
      print(
        'Error updating user profile: $e',
      );
      rethrow;
    }
  }

  // Update client data
  static Future<void> updateClientData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .update(data);
    } catch (e) {
      print(
        'Error updating client data: $e',
      );
      rethrow;
    }
  }
}
