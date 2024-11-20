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
      appBar: AppBar(
        title: const Text("Ajouter un numéro de téléphone"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePhoneNumber,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
