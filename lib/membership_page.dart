import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, canLaunchUrl, launchUrl;

class MembershipPage extends StatefulWidget {
  @override
  _MembershipPageState createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> membershipOptions = [
    {'duration': '1 Month', 'price': 999, 'originalPrice': 3000, 'discount': '0%', 'paymentLink': 'https://rzp.io/rzp/cPdq8K1'},
    {'duration': '3 Months', 'price': 2500, 'originalPrice': 3000, 'discount': '15% Off', 'paymentLink': 'https://rzp.io/rzp/45nhw1oq'},
    {'duration': '6 Months', 'price': 4500, 'originalPrice': 6000, 'discount': '20% Off', 'paymentLink': 'https://rzp.io/rzp/OkDLHmyc'},
    {'duration': '1 Year', 'price': 8000, 'originalPrice': 12000, 'discount': '25% Off', 'paymentLink': 'https://rzp.io/rzp/ABz1Vjk'},
  ];

  String? selectedMembership;
  String? userFullName;

  @override
  void initState() {
    super.initState();
    fetchUserFullName(); // Call fetchUserFullName to get the user’s name
  }

  Future<void> fetchUserFullName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userFullName = userDoc['full_name'];
        });
      } else {
        print('User document does not exist or has no data');
      }
    }
  }

  void purchaseMembership() async {
    if (selectedMembership == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a membership option.')),
      );
      return;
    }

    int durationDays = getDurationDays(selectedMembership!);
    DateTime purchaseDate = DateTime.now();
    DateTime expiryDate = purchaseDate.add(Duration(days: durationDays));

    await _firestore.collection('memberships').add({
      'user_id': _auth.currentUser!.uid,
      'user_name': userFullName,
      'duration': selectedMembership,
      'price': membershipOptions.firstWhere((option) => option['duration'] == selectedMembership)['price'],
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'remaining_days': durationDays,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membership purchased: $selectedMembership')),
    );

    String paymentLink = membershipOptions.firstWhere((option) => option['duration'] == selectedMembership)['paymentLink'];
    Uri paymentUri = Uri.parse(paymentLink);

    try {
      if (await canLaunchUrl(paymentUri)) {
        await launchUrl(
          paymentUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch payment link. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching payment link: $e')),
      );
    }

    setState(() {
      selectedMembership = null;
    });
  }

  int getDurationDays(String duration) {
    switch (duration) {
      case '1 Month':
        return 30;
      case '3 Months':
        return 90;
      case '6 Months':
        return 180;
      case '1 Year':
        return 365;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background2.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      "Memberships",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(color: Colors.white, thickness: 1),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: membershipOptions.length,
                  itemBuilder: (context, index) {
                    final option = membershipOptions[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${option['duration']} - Rs.${option['price']}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (option['discount'] != '0%')
                                Text(
                                  "Rs.${option['originalPrice']} (${option['discount']})",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          Radio<String>(
                            value: option['duration'],
                            groupValue: selectedMembership,
                            onChanged: (value) {
                              setState(() {
                                selectedMembership = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.9),
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rs. ${selectedMembership == null ? '0' : membershipOptions.firstWhere((option) => option['duration'] == selectedMembership)['price']}",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: purchaseMembership,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
