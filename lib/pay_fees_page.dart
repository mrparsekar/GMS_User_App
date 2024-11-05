import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PayFeesPage extends StatefulWidget {
  @override
  _PayFeesPageState createState() => _PayFeesPageState();
}

class _PayFeesPageState extends State<PayFeesPage> {
  String? _selectedPaymentMethod = 'Credit/Debit Card';
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int selectedDays = 1;
  double feePerDay = 50.0;
  double totalAmount = 0.0;
  String cardholderName = '';
  String cardNumber = '';
  String expirationDate = '';
  String cvv = '';
  String gpayEmail = '';
  String phonePeNumber = '';
  String paytmNumber = '';
  String upiId = '';
  String? userName;

  @override
  void initState() {
    super.initState();
    totalAmount = feePerDay * selectedDays;
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
        setState(() {
          userName = userSnapshot.get('full_name'); // Fetches user's full name
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  void _calculateTotalAmount() {
    setState(() {
      totalAmount = feePerDay * selectedDays;
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
            color: Colors.black.withOpacity(0.6),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Text(
                    'Pay Fees',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Divider(color: Colors.white, thickness: 1),
                  SizedBox(height: 20),
                  Text(
                    'Select Number of Days',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Slider(
                    value: selectedDays.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: selectedDays.toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedDays = value.toInt();
                        _calculateTotalAmount();
                      });
                    },
                  ),
                  Text(
                    'Total Amount Due: ₹$totalAmount',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue;
                      });
                    },
                    items: <String>[
                      'Credit/Debit Card',
                      'GPay',
                      'PhonePe',
                      'Paytm',
                      'UPI'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Payment Method',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_selectedPaymentMethod == 'Credit/Debit Card') ...[
                    _buildCardPaymentFields(),
                  ] else if (_selectedPaymentMethod == 'GPay') ...[
                    _buildGPayField(),
                  ] else if (_selectedPaymentMethod == 'PhonePe') ...[
                    _buildPhonePeField(),
                  ] else if (_selectedPaymentMethod == 'Paytm') ...[
                    _buildPaytmField(),
                  ] else if (_selectedPaymentMethod == 'UPI') ...[
                    _buildUpiField(),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitPayment,
                      child: Text(
                        'Submit Payment',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.redAccent,
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

  Widget _buildCardPaymentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Cardholder Name', (value) {
          cardholderName = value;
        }),
        SizedBox(height: 10),
        _buildTextField('Card Number', (value) {
          cardNumber = value;
        }),
        SizedBox(height: 10),
        _buildTextField('Expiration Date (MM/YY)', (value) {
          expirationDate = value;
        }),
        SizedBox(height: 10),
        _buildTextField('CVV', (value) {
          cvv = value;
        }),
      ],
    );
  }

  Widget _buildGPayField() {
    return _buildTextField('GPay Email or Phone Number', (value) {
      gpayEmail = value;
    });
  }

  Widget _buildPhonePeField() {
    return _buildTextField('PhonePe Number', (value) {
      phonePeNumber = value;
    });
  }

  Widget _buildPaytmField() {
    return _buildTextField('Paytm Number', (value) {
      paytmNumber = value;
    });
  }

  Widget _buildUpiField() {
    return _buildTextField('UPI ID', (value) {
      upiId = value;
    });
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: onChanged,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  void _submitPayment() async {
    if (_formKey.currentState!.validate() && userName != null) {
      try {
        await _firestore.collection('payments').add({
          'userName': userName,
          'cardholderName': cardholderName,
          'cardNumber': cardNumber,
          'expirationDate': expirationDate,
          'cvv': cvv,
          'gpayEmail': gpayEmail,
          'phonePeNumber': phonePeNumber,
          'paytmNumber': paytmNumber,
          'upiId': upiId,
          'amountDue': totalAmount,
          'daysSelected': selectedDays,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
        _showPaymentStatusDialog('Payment Submitted', 'Your payment is being processed.');
      } catch (e) {
        _showPaymentStatusDialog('Payment Failed', 'An error occurred while processing your payment.');
      }
    }
  }

  void _showPaymentStatusDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
