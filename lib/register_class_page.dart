import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/gym_class.dart';

class RegisterClassPage extends StatefulWidget {
  @override
  _RegisterClassPageState createState() => _RegisterClassPageState();
}

class _RegisterClassPageState extends State<RegisterClassPage> {
  List<GymClass> classes = [];
  String currentUserName = ""; // Store the user's name here

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _fetchCurrentUserName(); // Fetch the current user's name
  }

  void _fetchClasses() async {
    final snapshot = await FirebaseFirestore.instance.collection('activities').get();
    setState(() {
      classes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GymClass(
          name: data['activityName'] ?? 'No Name',
          instructor: data['instructor'] ?? 'No Instructor',
          schedule: data['time'] ?? 'No Schedule',
          isRegistered: false,
        );
      }).toList();
    });
  }

  // Fetch the current user's name from Firestore
  void _fetchCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        currentUserName = userDoc['full_name'] ?? 'No Name'; // Set the user's name
      });
    }
  }

  void _registerForClass(int index) {
    final gymClass = classes[index];

    // Save registration to Firestore
    FirebaseFirestore.instance.collection('registrations').add({
      'userName': currentUserName, // Use the fetched user's name
      'className': gymClass.name,
      'instructor': gymClass.instructor,
      'schedule': gymClass.schedule,
      'registeredAt': FieldValue.serverTimestamp(), // Optional: Timestamp of registration
    }).then((_) {
      // Update the state to reflect registration
      setState(() {
        gymClass.isRegistered = true; // Update the registration status
      });
      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully registered for ${gymClass.name}')),
      );
    }).catchError((error) {
      print("Failed to register for class: $error");
      // Optionally, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register for class')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background2.jpg'), // Background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Dark overlay for readability
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 80),
                Text(
                  'Register for Class',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Divider(color: Colors.white, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final gymClass = classes[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gymClass.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Instructor: ${gymClass.instructor}",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "Schedule: ${gymClass.schedule}",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: gymClass.isRegistered
                                  ? null // Disable button if already registered
                                  : () => _registerForClass(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gymClass.isRegistered ? Colors.red : Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                gymClass.isRegistered ? 'Registered' : 'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
