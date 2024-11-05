import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login_page.dart'; // Import your login page here
import 'register_page.dart';
import 'trainers_list_page.dart'; // Import your trainers list page here
import 'membership_page.dart'; // Import the membership page
import 'home_workout_page.dart'; // Import the home workout page

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Uncomment the following line to add sample trainers once.
  // await addSampleTrainers();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // Set your login page as the home screen
      routes: {
        '/register': (context) => RegisterPage(),
        '/trainers': (context) => TrainersListPage(), // Add route for trainers list
        '/membership': (context) => MembershipPage(), // Add route for membership page
        '/homeWorkout': (context) => HomeWorkoutPage(userId: '',), // Add route for home workout page
      },
    );
  }
}
