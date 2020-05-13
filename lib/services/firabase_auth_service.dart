import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/auth_base.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User> currentUser() async {
    try {
      FirebaseUser user = await _firebaseAuth.currentUser();
      return _userFromFirebase(user);
    } catch (e) {
      debugPrint('Hata: firebase_auth_service -> currentUser' + e.toString());
      return null;
    }
  }

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    } else{
      
    }

    User convertedUser = User(userID: user.uid, email: user.email);

    return convertedUser;
  }

  @override
  Future<bool> signOut() async {
    try {
      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();
      final _facebookLogin = FacebookLogin();
      await _facebookLogin.logOut();

      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      debugPrint('Hata: firebase_auth_service -> signOut' + e.toString());
      return false;
    }
  }

  @override
  Future<User> signInAnonymously() async {
    try {
      AuthResult result = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(result.user);
    } catch (e) {
      debugPrint(
          'Hata: firebase_auth_service -> signInAnonymously' + e.toString());
      return null;
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount _googleUser = await _googleSignIn.signIn();

    if (_googleUser != null) {
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
        AuthResult result = await _firebaseAuth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: _googleAuth.idToken,
                accessToken: _googleAuth.accessToken));
        FirebaseUser _user = result.user;
        return _userFromFirebase(_user);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    final _facebookLogin = FacebookLogin();
    FacebookLoginResult _faceResult =
        await _facebookLogin.logIn(['public_profile', 'email']);

    switch (_faceResult.status) {
      case FacebookLoginStatus.loggedIn:
        if (_faceResult.accessToken != null) {
          AuthResult _firebaseResult = await _firebaseAuth.signInWithCredential(
              FacebookAuthProvider.getCredential(
                  accessToken: _faceResult.accessToken.token));
          FirebaseUser _user = _firebaseResult.user;
          return _userFromFirebase(_user);
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Facebook ile giriş iptal edildi. ');
        break;
      case FacebookLoginStatus.error:
        print('Hata: firebase_auth_service -> signInWithFacebook' +
            _faceResult.errorMessage);
        break;
    }
    //return null;
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    debugPrint('FirebaseAuthService sayfasındaki email: $email' +
        'Result.user.email: ' +
        authResult.user.email);

    FirebaseUser firebaseUser = authResult.user;

    User createdUser = _userFromFirebase(firebaseUser);
    String emailOfCreatedEmail = createdUser.email;

    debugPrint(emailOfCreatedEmail);

    return createdUser;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(result.user);
  }
}
