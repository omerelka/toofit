import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/trainer_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform,
    );
    print(
      '✅ Firebase initialized successfully',
    );
  } catch (e) {
    print(
      '❌ Firebase initialization failed: $e',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎯 Building MyApp...');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print(
              '🔧 Creating AuthProvider...',
            );
            return AuthProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            print(
              '🔧 Creating UserProvider...',
            );
            return UserProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'TooFit - אפליקציית כושר',
        debugShowCheckedModeBanner: false,

        // הגדרות עברית מלאות
        locale: const Locale('he', 'IL'),
        supportedLocales: const [
          Locale('he', 'IL'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations
              .delegate,
          GlobalWidgetsLocalizations
              .delegate,
          GlobalCupertinoLocalizations
              .delegate,
        ],

        theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily:
              'Assistant', // Hebrew-friendly font
        ),

        // Use AuthWrapper to handle authentication state
        home: const AuthWrapper(),
      ),
    );
  }
}

// Authentication wrapper to handle login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔍 Building AuthWrapper...');

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print(
          '🔍 AuthWrapper state: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}',
        );

        // Show loading while checking auth state
        if (authProvider.isLoading) {
          print(
            '⏳ Showing loading screen...',
          );
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<
                          Color
                        >(
                          Color(
                            0xFF714bf2,
                          ), // TooFit purple
                        ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'טוען...',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show login if not authenticated
        if (!authProvider.isAuthenticated) {
          print(
            '🔑 User not authenticated, showing login screen',
          );
          return const LoginScreen();
        }

        // Show appropriate dashboard based on user role
        print(
          '✅ User authenticated, navigating to role-based navigation',
        );
        return const RoleBasedNavigation();
      },
    );
  }
}

// Navigate to correct dashboard based on user role
class RoleBasedNavigation
    extends StatelessWidget {
  const RoleBasedNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    print(
      '🎯 Building RoleBasedNavigation...',
    );

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        print(
          '🔍 UserProvider state: isLoading=${userProvider.isLoading}, user=${userProvider.currentUser?.firstName ?? 'null'}',
        );

        // Show loading while fetching user data
        if (userProvider.isLoading ||
            userProvider.currentUser ==
                null) {
          print('⏳ Loading user data...');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<
                          Color
                        >(Color(0xFF714bf2)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'טוען נתוני משתמש...',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final user =
            userProvider.currentUser!;
        print(
          '👤 User loaded: ${user.firstName} ${user.lastName}, role: ${user.role}',
        );

        // Navigate based on role
        if (user.role == 'client') {
          print(
            '🏃‍♀️ Navigating to client dashboard',
          );
          return const ClientDashboardPlaceholder();
        } else if (user.role == 'trainer') {
          print(
            '💪 Navigating to trainer dashboard',
          );
          return const TrainerDashboardScreen();
        } else {
          print(
            '❌ Unknown role: ${user.role}, returning to login',
          );
          return const LoginScreen();
        }
      },
    );
  }
}

// Client Dashboard Screen
class ClientDashboardPlaceholder extends StatefulWidget {
  const ClientDashboardPlaceholder({super.key});

  @override
  State<ClientDashboardPlaceholder> createState() => _ClientDashboardPlaceholderState();
}

class _ClientDashboardPlaceholderState extends State<ClientDashboardPlaceholder> {
  int _selectedIndex = 0;
  
  static const Color primaryPurple = Color(0xFF714bf2);
  static const Color primaryNeon = Color(0xFFf3ff00);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    print('🏠 Building Client Dashboard');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildWorkoutsTab(),
            _buildProgressTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'בית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'אימונים',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'התקדמות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;
        final clientData = userProvider.clientData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.firstName ?? 'מתאמן'),
              const SizedBox(height: 24),
              _buildStatsCards(clientData),
              const SizedBox(height: 24),
              _buildTodayWorkout(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String firstName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primaryPurple,
            primaryPurple.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'שלום $firstName! 🔥',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'מוכן להתחיל את האימון של היום?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: primaryPurple,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic>? clientData) {
    final workoutsCompleted = clientData?['workoutsCompleted'] ?? 0;
    final currentStreak = clientData?['currentStreak'] ?? 0;
    final totalWorkouts = clientData?['totalWorkouts'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'בוצעו',
            value: workoutsCompleted.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'רצף',
            value: currentStreak.toString(),
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'סה״כ',
            value: totalWorkouts.toString(),
            icon: Icons.fitness_center,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'האימון של היום',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'אימון כוח עליון',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '45 דקות • 8 תרגילים',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _startWorkout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'התחל אימון',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'פעולות מהירות',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'יומן אימונים',
                subtitle: 'צפה בהיסטוריה',
                icon: Icons.history,
                color: Colors.blue,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'המדידות שלי',
                subtitle: 'עקוב אחר ההתקדמות',
                icon: Icons.trending_up,
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'פעילות אחרונה',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                title: 'אימון כוח תחתון',
                subtitle: 'בוצע לפני יומיים',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                title: 'מדידת משקל',
                subtitle: 'לפני 3 ימים',
                icon: Icons.monitor_weight,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                title: 'אימון קרדיו',
                subtitle: 'לפני שבוע',
                icon: Icons.directions_run,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'האימונים שלי',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 20),
          _buildWorkoutCard(
            title: 'אימון כוח עליון',
            description: 'חזה, כתפיים וזרועות',
            duration: '45 דקות',
            exercises: 8,
            isCompleted: false,
          ),
          _buildWorkoutCard(
            title: 'אימון כוח תחתון',
            description: 'רגליים וישבן',
            duration: '50 דקות',
            exercises: 6,
            isCompleted: true,
          ),
          _buildWorkoutCard(
            title: 'אימון קרדיו',
            description: 'שרף קלוריות ושפר כושר',
            duration: '30 דקות',
            exercises: 5,
            isCompleted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard({
    required String title,
    required String description,
    required String duration,
    required int exercises,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.green : primaryPurple).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.fitness_center,
                  color: isCompleted ? Colors.green : primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.list, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$exercises תרגילים',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCompleted ? null : () {
                _startWorkout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.grey[300] : primaryPurple,
                foregroundColor: isCompleted ? Colors.grey[600] : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCompleted ? 'הושלם' : 'התחל אימון',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ההתקדמות שלי',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressCard(
            title: 'משקל',
            value: '75 ק״ג',
            change: '-2 ק״ג החודש',
            icon: Icons.monitor_weight,
            color: Colors.blue,
            isPositive: true,
          ),
          _buildProgressCard(
            title: 'אחוזי שומן',
            value: '15%',
            change: '-3% החודש',
            icon: Icons.trending_down,
            color: Colors.green,
            isPositive: true,
          ),
          _buildProgressCard(
            title: 'מסת שריר',
            value: '62 ק״ג',
            change: '+1.5 ק״ג החודש',
            icon: Icons.fitness_center,
            color: Colors.orange,
            isPositive: true,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'מטרות השבוע',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGoalItem('3 אימונים', 2, 3),
                _buildGoalItem('10,000 צעדים ליום', 7, 7),
                _buildGoalItem('8 כוסות מים ליום', 6, 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, int current, int target) {
    final progress = current / target;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current/$target',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : primaryPurple,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: primaryPurple.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: primaryPurple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.fullName ?? 'משתמש',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              _buildProfileOption(
                icon: Icons.person,
                title: 'פרטים אישיים',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.notifications,
                title: 'התראות',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.settings,
                title: 'הגדרות',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'עזרה ותמיכה',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'התנתק',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryPurple),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _startWorkout() {
    print('🏃‍♂️ Starting workout...');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('התחלת אימון'),
          content: const Text('האם אתה מוכן להתחיל את האימון?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('לא עכשיו'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('האימון התחיל! בהצלחה! 💪'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('בוא נתחיל!'),
            ),
          ],
        );
      },
    );
  }
}

class TrainerDashboardPlaceholder
    extends StatelessWidget {
  const TrainerDashboardPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print('🏠 Building Trainer Dashboard');
    final userProvider =
        Provider.of<UserProvider>(context);
    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ברוך הבא ${user.firstName}!',
        ),
        backgroundColor: const Color(
          0xFF714bf2,
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              print(
                '🚪 User logging out...',
              );
              await Provider.of<
                    AuthProvider
                  >(context, listen: false)
                  .signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 80,
              color: Color(0xFF714bf2),
            ),
            SizedBox(height: 20),
            Text(
              'Trainer Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '(בקרוב...)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
