import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthHelper {
  FirebaseAuthHelper._();
  static final FirebaseAuthHelper instance = FirebaseAuthHelper._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ===============================
  /// CURRENT USER
  /// ===============================
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  /// ===============================
  /// EMAIL & PASSWORD SIGN UP
  /// ===============================
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, s) {
      log("Email SignUp Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ===============================
  /// EMAIL & PASSWORD SIGN IN
  /// ===============================
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, s) {
      log("Email SignIn Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ===============================
  /// EMAIL LINK (PASSWORDLESS LOGIN)
  /// ===============================
  Future<void> sendSignInLinkToEmail({
    required String email,
    required String deepLinkUrl,
    required String packageName,
  }) async {
    try {
      final ActionCodeSettings acs = ActionCodeSettings(
        url: deepLinkUrl,
        handleCodeInApp: true,
        androidPackageName: packageName,
        androidInstallApp: true,
        androidMinimumVersion: '1',
        iOSBundleId: packageName,
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );
    } catch (e, s) {
      log("Email Link Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      return await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
    } catch (e, s) {
      log("Email Link SignIn Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ===============================
  /// PHONE AUTHENTICATION
  /// ===============================
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e, s) {
      log("OTP Verification Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ===============================
  /// GOOGLE SIGN IN
  /// ===============================
  ///  Requires google_sign_in package
  Future<UserCredential?> signInWithGoogle({
    required AuthCredential credential,
  }) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e, s) {
      log("Google SignIn Error", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  Future<void> logout() async {
    await _auth.signOut();
  }
}
