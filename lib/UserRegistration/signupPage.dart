import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginPage.dart';

// SignupPage (Sign Up)
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  // Sign up logic
  void _signup() async {
  //final email = _emailController.text;
  //final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//
  //if (!emailRegex.hasMatch(email)) {
  //  setState(() {
  //    _errorMessage = 'Please enter a valid email address.';
  //  });
  //  return;
  //}

  if (_passwordController.text == _confirmPasswordController.text) {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/signup'), // Your Flask server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'confirm_password': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else if (response.statusCode == 401) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'All fields are required';
        });
      } else if (response.statusCode == 402) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Password must be at least 8 characters long';
        });
      } else if (response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Invalid email format';
        });
      } else if (response.statusCode == 405) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Username already exists';
        });
      } else if (response.statusCode == 406) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Email already exists';
        });
      } else if (response.statusCode == 407) {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'A duplicate key error occurred';
        });
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = responseBody['message'] ?? 'Signup failed, please try again.';
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  } else {
    setState(() {
      _errorMessage = 'Passwords do not match';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color.fromARGB(255, 28, 15, 21),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Oswald',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      floatingLabelStyle: TextStyle(
                        color: Color.fromARGB(255, 28, 15, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 28, 15, 21)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      floatingLabelStyle: TextStyle(
                        color: Color.fromARGB(255, 28, 15, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 28, 15, 21)),
                      ),
                    ),
                    
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      floatingLabelStyle: TextStyle(
                        color: Color.fromARGB(255, 28, 15, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 28, 15, 21)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      floatingLabelStyle: TextStyle(
                        color: Color.fromARGB(255, 28, 15, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 28, 15, 21)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      backgroundColor: Color.fromARGB(255, 28, 15, 21)
                    ),
                    child: Text('Sign up', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(color: Color.fromARGB(255, 28, 15, 21)),
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
}
