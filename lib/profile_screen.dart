import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userProfile = {};

  Future<void> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://139.59.65.225:8052/user/my-profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userProfile = jsonDecode(response.body)['data'];
      });
    } else {
      // If the API fails, show dummy data
      setState(() {
        userProfile = {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
          'address': '123 Main St, Anytown, USA',
        };
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF2196F3), // Change the background color
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Add SingleChildScrollView to make the content scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://static.vecteezy.com/system/resources/previews/002/002/403/non_2x/man-with-beard-avatar-character-isolated-icon-free-vector.jpg'), // Replace with actual profile image URL
                ),
              ),
              SizedBox(height: 20),
              Text('First Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(userProfile['firstName'] ?? "John", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Last Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(userProfile['lastName'] ?? "Doe", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Email:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(userProfile['email']?? "john.doe@example.com", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Address:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(userProfile['address']?? "123 Main St, Anytown, USA", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/update-profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Update Profile'),
                ),
              ),
            ],
          ),
        )
            // : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}