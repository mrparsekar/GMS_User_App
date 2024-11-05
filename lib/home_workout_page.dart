import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeWorkoutPage extends StatefulWidget {
  final String userId; // User ID from Firebase
  const HomeWorkoutPage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeWorkoutPageState createState() => _HomeWorkoutPageState();
}

class _HomeWorkoutPageState extends State<HomeWorkoutPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String fullName = '';
  int pushupsDone = 0;
  int pullupsDone = 0;
  int squatsDone = 0;
  int burpeesDone = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['full_name'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> logWorkout() async {
    String timestamp = DateTime.now().toString();
    try {
      await _firestore.collection('workouts').add({
        'user_id': widget.userId,
        'full_name': fullName,
        'pushups_done': pushupsDone,
        'pullups_done': pullupsDone,
        'squats_done': squatsDone,
        'burpees_done': burpeesDone,
        'timestamp': timestamp,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Workout logged successfully!')));
    } catch (e) {
      print('Error logging workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to log workout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Workout', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Stack(
        children: [
          // Full-Page Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background2.jpg",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, $fullName!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  buildExerciseCard(
                    title: 'Chest Exercise: Push-ups',
                    instructions: 'Instructions: Keep your back straight, lower your body until your chest nearly touches the floor. Perform as many as you can for 3 sets.',
                    repsHint: 'How many Push-ups did you do?',
                    onChanged: (value) => pushupsDone = int.tryParse(value) ?? 0,
                  ),
                  SizedBox(height: 20),
                  buildExerciseCard(
                    title: 'Back Exercise: Pull-ups',
                    instructions: 'Instructions: Hang from a bar with palms facing away. Pull your body up until your chin is above the bar. Perform as many as you can for 3 sets.',
                    repsHint: 'How many Pull-ups did you do?',
                    onChanged: (value) => pullupsDone = int.tryParse(value) ?? 0,
                  ),
                  SizedBox(height: 20),
                  buildExerciseCard(
                    title: 'Leg Exercise: Squats',
                    instructions: 'Instructions: Stand with feet shoulder-width apart, lower your hips back and down as if sitting in a chair. Perform as many as you can for 3 sets.',
                    repsHint: 'How many Squats did you do?',
                    onChanged: (value) => squatsDone = int.tryParse(value) ?? 0,
                  ),
                  SizedBox(height: 20),
                  buildExerciseCard(
                    title: 'Full Body Exercise: Burpees',
                    instructions: 'Instructions: Start standing, drop into a squat, kick your feet back into a plank position, do a push-up, return to squat, and jump up. Perform as many as you can for 3 sets.',
                    repsHint: 'How many Burpees did you do?',
                    onChanged: (value) => burpeesDone = int.tryParse(value) ?? 0,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      logWorkout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Log Workout', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExerciseCard({
    required String title,
    required String instructions,
    required String repsHint,
    required Function(String) onChanged,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(instructions, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: repsHint),
              onChanged: onChanged,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Mark as done functionality can be implemented here if needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Mark as Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
