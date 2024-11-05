import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool _isLoading = false;
  bool showSuccessAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> registerUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Send verification email
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
        }

        // Save user details in Firestore (Optional)
        await _firestore.collection('users').doc(user!.uid).set({
          'full_name': fullNameController.text,
          'email': emailController.text,
          'phone_number': phoneNumberController.text,
          'age': ageController.text,
          'uid': user!.uid,
          'emailVerified': user.emailVerified,  // Add this field to track verification status
        });

        setState(() {
          _isLoading = false;
          showSuccessAnimation = true;
        });

        _animationController.forward();

        await Future.delayed(Duration(milliseconds: 1500));

        // Notify the user to check their email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification email sent. Please verify to complete registration."),
          ),
        );

        // Navigate to Login Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background2.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/app_icon/GYM FREAK Logo.png",
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField("Full Name", fullNameController, Icons.person),
                          SizedBox(height: 20),
                          buildTextField("Phone Number", phoneNumberController, Icons.phone, isPhone: true),
                          SizedBox(height: 20),
                          buildTextField("Email", emailController, Icons.email, isEmail: true),
                          SizedBox(height: 20),
                          buildTextField("Password", passwordController, Icons.lock, isPassword: true),
                          SizedBox(height: 20),
                          buildTextField("Age", ageController, Icons.calendar_today, isAge: true),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          registerUser(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      )
                          : Text(
                        "REGISTER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (showSuccessAnimation)
                    ScaleTransition(
                      scale: _animation,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller, IconData icon,
      {bool isPassword = false, bool isPhone = false, bool isEmail = false, bool isAge = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone
          ? TextInputType.phone
          : isEmail
          ? TextInputType.emailAddress
          : isAge
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[300],
        hintText: labelText,
        hintStyle: TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }
}
