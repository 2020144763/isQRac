import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro ao realizar login.');
    }
  }

  Future<void> registar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro ao realizar registo.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erro ao enviar email de recuperação.');
    }
  }
}
