import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // קל לשינוי - תמונות ולוגו
  static const String backgroundImage =
      'assets/images/login_background.jpg';
  static const String logoImage =
      'assets/images/app_logo.png';

  // צבעים
  static const Color primaryNeon = Color(
    0xFFf3ff00,
  ); // צהוב ניאון
  static const Color primaryPurple = Color(
    0xFF714bf2,
  ); // סגול מעודן

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryPurple,
              Color(
                0xFF9C7BF7,
              ), // גרדיאנט עדין
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height:
                  MediaQuery.of(
                    context,
                  ).size.height -
                  MediaQuery.of(
                    context,
                  ).padding.top,
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // לוגו
                  _buildLogo(),

                  const SizedBox(height: 40),

                  // כותרת
                  _buildTitle(),

                  const SizedBox(height: 8),

                  // כותרת משנה
                  _buildSubtitle(),

                  const SizedBox(height: 40),

                  // טופס התחברות
                  _buildLoginForm(),

                  const SizedBox(height: 24),

                  // כפתור התחברות
                  _buildLoginButton(),

                  const SizedBox(height: 16),

                  // קישור שכחתי סיסמה
                  _buildForgotPassword(),

                  const Spacer(flex: 1),

                  // קישור הרשמה
                  _buildSignUpLink(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          25,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          25,
        ),
        child: Image.asset(
          logoImage,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) {
                // לוגו דיפולטיבי אם התמונה לא נמצאת
                return const Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: primaryPurple,
                );
              },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'ברוכה השובה!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'התחברי כדי להמשיך במסע הכושר שלך',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // שדה אימייל
          _buildEmailField(),
          const SizedBox(height: 16),
          // שדה סיסמה
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType:
          TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: 'אימייל',
        prefixIcon: const Icon(
          Icons.email_outlined,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: primaryPurple,
        ),
        prefixIconColor: primaryPurple,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'נא להזין אימייל';
        }
        if (!RegExp(
          r'^[^@]+@[^@]+\.[^@]+',
        ).hasMatch(value)) {
          return 'נא להזין אימייל תקין';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: 'סיסמה',
        prefixIcon: const Icon(
          Icons.lock_outlined,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible =
                  !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: primaryPurple,
        ),
        prefixIconColor: primaryPurple,
        suffixIconColor: primaryPurple,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'נא להזין סיסמה';
        }
        if (value.length < 6) {
          return 'הסיסמה חייבת להכיל לפחות 6 תווים';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<
                        Color
                      >(primaryPurple),
                ),
              )
            : const Text(
                'התחברות',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'אפשרות זו תהיה זמינה בקרוב',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      },
      child: const Text(
        'שכחת את הסיסמה?',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text(
          'עדיין אין לך חשבון? ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'מסך הרשמה יבנה בהמשך',
                ),
                backgroundColor:
                    Colors.green,
              ),
            );
          },
          child: const Text(
            'הירשמי כאן',
            style: TextStyle(
              color: primaryNeon,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // סימולציה של טעינה
    await Future.delayed(
      const Duration(seconds: 1),
    );

    setState(() {
      _isLoading = false;
    });

    // הודעה זמנית
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'כפתור עדיין לא פעיל - בפיתוח',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
