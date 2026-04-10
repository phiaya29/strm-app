import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  String _errorMsg = '';

  Future<void> _submit() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      if (_isRegisterMode) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMsg = _getFriendlyError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password':  return 'Incorrect password.';
      case 'email-already-in-use': return 'Email is already registered.';
      case 'weak-password':   return 'Password must be at least 6 characters.';
      case 'invalid-email':   return 'Please enter a valid email address.';
      default: return 'An error occurred. Try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegisterMode ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          if (_errorMsg.isNotEmpty)
            Text(_errorMsg, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _submit,
                child: Text(_isRegisterMode ? 'Register' : 'Login'),
              ),
          TextButton(
            onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
            child: Text(_isRegisterMode
              ? 'Already have an account? Login'
              : 'No account? Register here'),
          ),
        ]),
      ),
    );
  }
}