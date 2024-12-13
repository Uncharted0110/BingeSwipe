import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginPage.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  // Reset password logic
  void _resetPassword() async {
    if (_newPasswordController.text == _retypePasswordController.text) {
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/reset_password'), // Your Flask server URL
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': _usernameController.text,
            'new_password': _newPasswordController.text,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _successMessage = 'Password has been reset successfully.';
            _errorMessage = '';
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (response.statusCode == 404){
          final responseBody = json.decode(response.body);
          setState(() {
            _errorMessage = responseBody['error'] ?? 'Username not found.';
            _successMessage = '';
          });
        } else {
          final responseBody = json.decode(response.body);
          setState(() {
            _errorMessage = responseBody['error'] ?? 'Failed to reset password. Please try again.';
            _successMessage = '';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _successMessage = '';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _successMessage = '';
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
                      'Reset Password',
                      style: const TextStyle(
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
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Enter your new password',
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
                    controller: _retypePasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Retype New Password',
                      hintText: 'Re-enter your new password',
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
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      backgroundColor: const Color.fromARGB(255, 28, 15, 21),
                    ),
                    child: Text('Reset Password', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _successMessage,
                        style: const TextStyle(color: Colors.green),
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
                      'Back to Login',
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
