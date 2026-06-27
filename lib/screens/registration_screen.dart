// lib/screens/registration_screen.dart

import 'package:flutter/material.dart';
import '../models/gender.dart'; // ✅ Gender comes from here (matches auth_controller)
import '../validators/app_validator.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Gender? _selectedGender;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String? error = AuthController.register(
        fullName: _nameController.text
            .trim(), // ✅ FIXED: was 'name:', now 'fullName:'
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender!,
      );
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registered! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (v) => Validators.required(v, 'Full Name'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => Validators.email(v),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                validator: (v) => Validators.password(v),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: 'Re-type Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                obscureText: !_showConfirmPassword,
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: [
                  DropdownMenuItem(value: Gender.male, child: Text('Male')),
                  DropdownMenuItem(value: Gender.female, child: Text('Female')),
                  DropdownMenuItem(
                      value: Gender.preferNotToSay,
                      child: Text('Prefer not to say')),
                  DropdownMenuItem(value: Gender.other, child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
                validator: (v) => v == null ? 'Please select gender' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: Text('SIGN UP')),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
