import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Use XFile instead of PickedFile

  // Error tracking variables
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? addressError;

  bool _isPasswordVisible = false; // To toggle the password visibility

  Future<void> register() async {
    // Reset previous error messages
    setState(() {
      firstNameError = null;
      lastNameError = null;
      emailError = null;
      passwordError = null;
      addressError = null;
    });

    // Validation check for empty fields
    bool isValid = true;

    if (firstNameController.text.isEmpty) {
      setState(() {
        firstNameError = 'First Name is required';
      });
      isValid = false;
    }
    if (lastNameController.text.isEmpty) {
      setState(() {
        lastNameError = 'Last Name is required';
      });
      isValid = false;
    }
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required';
      });
      isValid = false;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
      isValid = false;
    }
    if (addressController.text.isEmpty) {
      setState(() {
        addressError = 'Address is required';
      });
      isValid = false;
    }

    if (!isValid) {
      return; // Stop the registration process if any field is invalid
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://139.59.65.225:8052/user/register'),
    );

    request.fields['firstName'] = firstNameController.text;
    request.fields['lastName'] = lastNameController.text;
    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['address'] = addressController.text;

    if (_image != null) {
      // Convert XFile to File and send it as multipart
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
    }

    try {
      // Send the request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      print("Response Status: ${response.statusCode}");
      print("Response Data: $responseData");

      if (response.statusCode == 200) {
        // Show success pop-up
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have been successfully registered!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  clearFields(); // Clear fields after success
                  Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error pop-up if registration fails
        final errorMessage = responseData['message'] ?? 'Registration failed';

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registration Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Show error pop-up in case of exception
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred during registration. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    addressController.clear();
    _image = null;
    setState(() {
      firstNameError = null;
      lastNameError = null;
      emailError = null;
      passwordError = null;
      addressError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // First Name
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  errorText: firstNameError,
                ),
              ),
              // Last Name
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  errorText: lastNameError,
                ),
              ),
              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: emailError,
                ),
              ),
              // Password
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              // Address
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  errorText: addressError,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Use pickImage
                  setState(() {
                    _image = pickedFile;
                  });
                },
                child: Text('Pick Image'),
              ),
              SizedBox(height: 10),
              if (_image != null) ...[
                Text('Image Selected:'),
                Image.file(File(_image!.path), width: 100, height: 100),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
