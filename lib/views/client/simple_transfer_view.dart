import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SimpleTransferView extends StatefulWidget {
  @override
  _SimpleTransferViewState createState() => _SimpleTransferViewState();
}

class _SimpleTransferViewState extends State<SimpleTransferView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  double _fee = 0.0;
  bool _isProcessing = false;

  void _calculateFee() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _fee = amount * 0.01; // 1% fee
    });
  }

  Future<void> _processTransfer() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isProcessing = true;
      });

      final phoneNumber = _phoneController.text;
      final amount = double.parse(_amountController.text);
      final clientId = FirebaseAuth.instance.currentUser?.uid;

      if (clientId == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(clientId).get();
        final recipientDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (!userDoc.exists) throw Exception("Utilisateur introuvable.");
        if (recipientDoc.docs.isEmpty) throw Exception("Destinataire introuvable.");

        final userBalance = userDoc.data()?['balance'] ?? 0.0;
        final recipientId = recipientDoc.docs.first.id;
        final recipientBalance = recipientDoc.docs.first.data()['balance'] ?? 0.0;

        if (userBalance < amount) {
          throw Exception("Solde insuffisant pour effectuer le transfert.");
        }

        // Mise à jour des soldes dans une transaction Firestore
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userRef = FirebaseFirestore.instance.collection('users').doc(clientId);
          final recipientRef = FirebaseFirestore.instance.collection('users').doc(recipientId);

          transaction.update(userRef, {'balance': userBalance - amount});
          transaction.update(recipientRef, {'balance': recipientBalance + amount});

          // Ajout de la transaction
          final transactionRef = FirebaseFirestore.instance.collection('transactions').doc();
          transaction.set(transactionRef, {
            'type': 'transfert simple',
            'montant': amount,
            'fee': _fee,
            'clientId': clientId,
            'numeroDestinataire': phoneNumber,
            'date': DateTime.now(),
          });
        });

        Get.back(); // Retourner à la page précédente
        Get.snackbar(
          'Succès',
          'Transfert effectué avec succès.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A3AFF),
        title: const Text(
          'Transfert Simple',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        labelStyle: TextStyle(color: Colors.indigo),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro de téléphone.';
                        }
                        if (!RegExp(r'^(77|78|70|76|75)\d{7}$').hasMatch(value)) {
                          return 'Numéro invalide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Montant',
                        labelStyle: TextStyle(color: Colors.indigo),
                        suffixText: 'FCFA',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateFee(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Montant invalide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frais : $_fee FCFA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.info_outline, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: _isProcessing
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _processTransfer,
                        child: const Text(
                          'Effectuer le Transfert',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
