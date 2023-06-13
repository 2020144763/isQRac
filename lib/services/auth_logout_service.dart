  import 'dart:async';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'auth_service.dart';


  /// Service for handling user auto logout based on user activity
  class AutoLogoutService extends ChangeNotifier{
    static Timer? _timer;
    static const autoLogoutTimer = 5;
    AuthService auth = AuthService();

    void initState() { 
      
    }

    /// Resets the existing timer and starts a new timer
    void startNewTimer() {
      stopTimer();
      if (FirebaseAuth.instance.currentUser?.email!="") {
        _timer = Timer.periodic(const Duration(seconds: autoLogoutTimer), (timer) {
          stopTimer();
          //print('Vais abaixo');
          //auth.logout();
        },
        );
      }
    }

    /// Stops the existing timer if it exists
    void stopTimer() {
      if (_timer != null || (_timer?.isActive != null && _timer!.isActive)) {
        _timer?.cancel();
      }
    }

    /// Track user activity and reset timer
    void trackUserActivity([_]) async {
      //print('User Activity Detected!');
      
      if (FirebaseAuth.instance.currentUser?.email!="" && _timer != null) {
        //print('Inicia novo tempo');
        startNewTimer();
      }
    }

  }