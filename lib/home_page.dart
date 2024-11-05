import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'view_activities_page.dart';
import 'trainers_list_page.dart';
import 'register_class_page.dart';
import 'membership_page.dart';
import 'pay_fees_page.dart';
import 'home_workout_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String userName;

  HomePage({required this.userId, required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String email = '';
  String phone = '';
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          email = userDoc['email'] ?? 'Not available';
          phone = userDoc['phone_number'] ?? 'Not available';
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Name: ${widget.userName}'),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email: $email'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone: $phone'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to Edit Profile Page if needed
                },
                child: Text('Edit Profile'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 60),
            FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: Colors.black.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(Icons.person, color: Colors.black, size: 40),
                            onPressed: () => _showProfileDialog(context),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Welcome ${widget.userName}!',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                padding: EdgeInsets.all(20.0),
                children: [
                  _buildOptionCard('View Activities', Icons.event_available, context, ViewActivitiesPage()),
                  _buildOptionCard('Register for Class', Icons.fitness_center, context, RegisterClassPage()),
                  _buildOptionCard('Trainers List', Icons.query_builder, context, TrainersListPage()),
                  _buildOptionCard('Get Memberships', Icons.card_membership, context, MembershipPage()),
                  _buildOptionCard('Pay Fees', Icons.payment, context, PayFeesPage()),
                  _buildOptionCard('Home Workout', Icons.sports_gymnastics, context, HomeWorkoutPage(userId: widget.userId)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(String title, IconData icon, BuildContext context, Widget page) {
    return GestureDetector(
      onTap: () => _navigateTo(context, page),
      child: Card(
        color: Colors.red[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
