import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<
                      Color
                    >(
                      Color(
                        0xFF714bf2,
                      ), // TooFit purple
                    ),
              ),
            ),
          );
        }

        // Show login if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Show appropriate dashboard based on user role
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Show loading while fetching user data
        if (userProvider.isLoading ||
            userProvider.currentUser ==
                null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<
                      Color
                    >(Color(0xFF714bf2)),
              ),
            ),
          );
        }

        final user =
            userProvider.currentUser!;

        // Navigate based on role
        if (user.role == 'client') {
          // Import and use your ClientLandingPage here
          return const ClientDashboardPlaceholder();
        } else if (user.role == 'trainer') {
          // Import and use your TrainerDashboard here
          return const TrainerDashboardPlaceholder();
        } else {
          // Unknown role - back to login
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
    final userProvider =
        Provider.of<UserProvider>(context);
    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ברוכה הבאה ${user.firstName}!',
        ),
        actions: [
          IconButton(
            onPressed: () async {
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
        child: Text(
          'Client Dashboard\n(בקרוב...)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
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
    final userProvider =
        Provider.of<UserProvider>(context);
    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ברוך הבא ${user.firstName}!',
        ),
        actions: [
          IconButton(
            onPressed: () async {
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
        child: Text(
          'Trainer Dashboard\n(בקרוב...)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
