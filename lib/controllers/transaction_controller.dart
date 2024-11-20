import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> processSimpleTransfer({
    required double montant,
    required String clientId,
    required String numeroDestinataire,
  }) async {
    try {
      // Validate phone number
      if (!RegExp(r'^(77|78|70|76|75)\d{7}$').hasMatch(numeroDestinataire)) {
        throw Exception("Numéro de destinataire invalide.");
      }

      // Fetch client and recipient details
      final clientSnapshot = await _firestore.collection('users').doc(clientId).get();
      final recipientSnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: numeroDestinataire)
          .limit(1)
          .get();

      if (!clientSnapshot.exists) {
        throw Exception("Client introuvable.");
      }
      if (recipientSnapshot.docs.isEmpty) {
        throw Exception("Destinataire introuvable.");
      }

      final clientData = clientSnapshot.data()!;
      final recipientData = recipientSnapshot.docs.first.data();

      // Check client's balance
      final double clientBalance = clientData['balance'] ?? 0.0;
      if (clientBalance < montant) {
        throw Exception("Solde insuffisant.");
      }

      // Perform balance updates
      final double newClientBalance = clientBalance - montant;
      final double newRecipientBalance = (recipientData['balance'] ?? 0.0) + montant;

      // Update client and recipient balances in Firestore
      await _firestore.collection('users').doc(clientId).update({'balance': newClientBalance});
      await _firestore
          .collection('users')
          .doc(recipientSnapshot.docs.first.id)
          .update({'balance': newRecipientBalance});

      // Add transaction to Firestore
      final newTransactionId = _firestore.collection('transactions').doc().id;
      final transactionData = {
        'id': newTransactionId,
        'type': 'Transfert Simple',
        'montant': montant,
        'etat': 'Réussi',
        'clientId': clientId,
        'numeroDestinataire': numeroDestinataire,
        'date': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('transactions').doc(newTransactionId).set(transactionData);

      // Notify success
      Get.snackbar("Succès", "Transfert simple effectué avec succès !");
    } catch (e) {
      // Handle errors and show messages
      Get.snackbar("Erreur", e.toString());
    }
  }
}
