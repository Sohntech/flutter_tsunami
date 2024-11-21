// client_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, String>> fetchClientPhones(
  List<QueryDocumentSnapshot> transactions,
  FirebaseFirestore firestore,
) async {
  Map<String, String> clientPhones = {};
  for (var transaction in transactions) {
    var clientId = transaction['clientId'];
    if (clientId != null && !clientPhones.containsKey(clientId)) {
      var clientSnapshot = await firestore.collection('users').doc(clientId).get();
      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        clientPhones[clientId] = clientData['phone'];
      }
    }
  }
  return clientPhones;
}
