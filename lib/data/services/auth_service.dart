import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';
import '../models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'user_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  
  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;
  StreamSubscription<UserProfile?>? _profileSubscription;

  User? get currentUser => _auth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String stylePreference,
    String role = 'Customer',
    String? mobile,
    String? occupation,
    String? brands,
    String? address,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        UserProfile newUser = UserProfile(
          uid: user.uid,
          name: name,
          email: email,
          gender: gender,
          stylePreference: stylePreference,
          role: role,
          createdAt: DateTime.now(),
          mobile: mobile,
          occupation: occupation,
          brands: brands,
          address: address,
        );

        await _firestoreService.createUser(newUser);
        _currentUserProfile = newUser;
        await _saveSession(user.uid);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
         final uid = result.user!.uid;
         _currentUserProfile = await _firestoreService.getUser(uid);
         _profileSubscription?.cancel();
         _profileSubscription = _firestoreService.userProfileStream(uid).listen((p) {
           _currentUserProfile = p;
           notifyListeners();
         });
         await _saveSession(uid);
         notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserProfile = null;
    await _profileSubscription?.cancel();
    await _clearSession();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) return;
    
    final userId = prefs.getString('userId');
    if (userId != null && _auth.currentUser != null) {
       _currentUserProfile = await _firestoreService.getUser(userId);
       _profileSubscription?.cancel();
       _profileSubscription = _firestoreService.userProfileStream(userId).listen((p) {
         _currentUserProfile = p;
         notifyListeners();
       });
       notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _currentUserProfile = await _firestoreService.getUser(uid);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? mobile,
    String? occupation,
    String? brands,
    String? address,
    String? gender,
    String? stylePreference,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (occupation != null) 'occupation': occupation,
      if (brands != null) 'brands': brands,
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (stylePreference != null) 'stylePreference': stylePreference,
    };
    if (fields.isEmpty) return;
    await _firestoreService.updateUserFields(uid, fields);
    await refreshProfile();
  }

  Future<bool> isProfileComplete() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    return _userService.isProfileComplete(uid);
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', uid);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
