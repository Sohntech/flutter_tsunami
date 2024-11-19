import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Import pour gérer PlatformException

import '../routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Gestion de l'état utilisateur
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  User? get user => _firebaseUser.value;

  // Gestion des rôles
  final RxBool isDistributor = false.obs;

  // Gestion des erreurs et du chargement
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Liaison de l'état utilisateur Firebase
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  /// **Déterminer l'écran initial en fonction de l'utilisateur et du rôle**
  void _setInitialScreen(User? user) {
    if (user == null) {
      // Si l'utilisateur n'est pas connecté, redirige vers la page de connexion
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // Vérifiez le rôle de l'utilisateur dans Firestore
      checkUserRole(user.uid);
    }
  }

  /// **Vérification du rôle de l'utilisateur**
  Future<void> checkUserRole(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      isDistributor.value = userDoc.data()?['role'] == 'distributor';

      // Rediriger vers la page appropriée
      Get.offAllNamed(
        isDistributor.value ? Routes.DISTRIBUTOR_HOME : Routes.CLIENT_HOME
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la vérification du rôle: ${e.toString()}';
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  /// **Connexion avec Google**
  Future<User?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; 

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        errorMessage.value = 'Connexion Google annulée';
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on PlatformException catch (e) {
      errorMessage.value = 'Erreur de connexion Google (PlatformException): ${e.message}';
      return null;
    } catch (e) {
      errorMessage.value = 'Erreur de connexion Google: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// **Connexion avec Facebook**
  Future<User?> signInWithFacebook() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        final UserCredential userCredential = 
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
      errorMessage.value = 'Connexion Facebook annulée';
      return null;
    } on PlatformException catch (e) {
      errorMessage.value = 'Erreur de connexion Facebook (PlatformException): ${e.message}';
      return null;
    } catch (e) {
      errorMessage.value = 'Erreur de connexion Facebook: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// **Connexion avec téléphone**
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final UserCredential userCredential = 
                await _auth.signInWithCredential(credential);
            _firebaseUser.value = userCredential.user;
          } on PlatformException catch (e) {
            errorMessage.value = 'Erreur d\'authentification (PlatformException): ${e.message}';
          } catch (e) {
            errorMessage.value = 'Erreur d\'authentification: ${e.toString()}';
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage.value = 'Erreur de vérification: ${e.message}';
        },
        codeSent: (String verificationId, int? resendToken) {
          // Redirection pour entrer le code
          Get.toNamed('/verify-code', arguments: verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          errorMessage.value = 'Délai d\'attente dépassé';
        },
      );
    } on PlatformException catch (e) {
      errorMessage.value = 'Erreur (PlatformException): ${e.message}';
    } catch (e) {
      errorMessage.value = 'Erreur: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// **Déconnexion**
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _firebaseUser.value = null;
    } on PlatformException catch (e) {
      errorMessage.value = 'Erreur de déconnexion (PlatformException): ${e.message}';
    } catch (e) {
      errorMessage.value = 'Erreur de déconnexion: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
