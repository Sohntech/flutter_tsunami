import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsunami_money/routes.dart';

class AddPhoneView extends StatefulWidget {
  @override
  _AddPhoneViewState createState() => _AddPhoneViewState();
}

class _AddPhoneViewState extends State<AddPhoneView> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  void _savePhoneNumber() async {
    final String phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 8) {
      Get.snackbar("Erreur", "Veuillez entrer un numéro de téléphone valide.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            'phone': phone,
          },
          SetOptions(merge: true),
        );

        Get.offAllNamed(Routes.CLIENT_HOME); // Redirigez vers le tableau de bord
      }
    } catch (e) {
      print("Erreur lors de l'enregistrement du numéro de téléphone: $e");
      Get.snackbar("Erreur", "Impossible de sauvegarder le numéro. Réessayez.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Permet de faire défiler le contenu quand le clavier est ouvert
        child: Container(
          height: MediaQuery.of(context).size.height, // Utiliser toute la hauteur de l'écran
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[800]!, Colors.indigo[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.flash_on,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Ajouter un téléphone\n     à votre compte",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Numéro de téléphone",
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple[800]!.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _savePhoneNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Enregistrer",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "En continuant, vous acceptez nos conditions d'utilisation et notre politique de confidentialité",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
