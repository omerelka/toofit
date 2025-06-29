import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
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
          return const TrainerDashboardPlaceholder();
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

// Temporary placeholders until we create the actual dashboards
class ClientDashboardPlaceholder
    extends StatelessWidget {
  const ClientDashboardPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print('🏠 Building Client Dashboard');
    final userProvider =
        Provider.of<UserProvider>(context);
    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ברוכה הבאה ${user.firstName}!',
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
              Icons.fitness_center,
              size: 80,
              color: Color(0xFF714bf2),
            ),
            SizedBox(height: 20),
            Text(
              'Client Dashboard',
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
