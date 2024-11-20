import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Import du modèle
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

  // Code de vérification pour l'authentification par téléphone
  String _verificationId = '';

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  /// **Déterminer l'écran initial en fonction de l'utilisateur et du rôle**
  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      checkUserRole(user.uid);
    }
  }

  /// **Vérification du rôle de l'utilisateur**
  Future<void> checkUserRole(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      isDistributor.value = userDoc.data()?['userType'] == 'distributor';
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
        errorMessage.value = '';
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          // Si l'utilisateur n'existe pas, créer un nouveau document
          await userRef.set({
            'uid': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'phone': '',
            'userType': 'client',
            'authProvider': 'google',
            'balance': 0.0,
          });
          // Redirige vers le formulaire pour ajouter un numéro de téléphone
          Get.offAllNamed(Routes.ADD_PHONE);
        } else if ((userDoc.data() as Map<String, dynamic>)['phone'] == '') {
          // Redirige vers le formulaire si le numéro de téléphone est vide
          Get.offAllNamed(Routes.ADD_PHONE);
        } else {
          // Sinon, redirige vers le tableau de bord approprié
          checkUserRole(firebaseUser.uid);
        }
      }

      return firebaseUser;
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
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

        final UserCredential userCredential = 
            await _auth.signInWithCredential(credential);
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          await _createOrUpdateUserInFirestore(firebaseUser, 'facebook');
        }

        return firebaseUser;
      } else {
        errorMessage.value = 'Connexion Facebook annulée ou échouée.';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Erreur de connexion Facebook: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// **Connexion avec Téléphone**
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final UserCredential userCredential = 
              await _auth.signInWithCredential(credential);
          final User? firebaseUser = userCredential.user;

          if (firebaseUser != null) {
            await _createOrUpdateUserInFirestore(firebaseUser, 'phone');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage.value = 'Échec de la vérification du téléphone: ${e.message}';
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          Get.snackbar('Code envoyé', 'Veuillez entrer le code reçu par SMS.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      errorMessage.value = 'Erreur de connexion téléphone: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// **Vérification du code SMS**
  Future<User?> verifySmsCode(String smsCode) async {
    try {
      isLoading.value = true;
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _createOrUpdateUserInFirestore(firebaseUser, 'phone');
      }

      return firebaseUser;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la vérification du code SMS: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// **Créer ou mettre à jour un utilisateur dans Firestore**
  Future<void> _createOrUpdateUserInFirestore(User firebaseUser, String authProvider) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          balance: 0.0,
          userType: 'client',
          authProvider: authProvider,
        );

        await userRef.set(newUser.toMap());
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la création/mise à jour de l\'utilisateur: ${e.toString()}';
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
    } catch (e) {
      errorMessage.value = 'Erreur de déconnexion: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
