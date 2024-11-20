class Transaction {
  final String id;
  final String type;
  final double montant;
  final String etat;
  final String clientId;
  final String? numeroDestinataire; // Pour transfert
  final String? distributeurId; // Pour dépôt ou retrait
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.montant,
    required this.etat,
    required this.clientId,
    this.numeroDestinataire,
    this.distributeurId,
    required this.date,
  });

  factory Transaction.fromJson(String id, Map<String, dynamic> json) {
    return Transaction(
      id: id,
      type: json['type'],
      montant: json['montant'].toDouble(),
      etat: json['etat'],
      clientId: json['client_id'],
      numeroDestinataire: json['numero_destinataire'],
      distributeurId: json['distributeur_id'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'montant': montant,
      'etat': etat,
      'client_id': clientId,
      'numero_destinataire': numeroDestinataire,
      'distributeur_id': distributeurId,
      'date': date.toIso8601String(),
    };
  }

  static bool validateNumeroDestinataire(String numero) {
    final pattern = RegExp(r'^(77|78|70|76|75)\d{7}$');
    return pattern.hasMatch(numero);
  }

  static bool validateTransactionType(
      String type, String? numeroDestinataire, String? distributeurId) {
    if (type == 'transfert' && (numeroDestinataire == null || !validateNumeroDestinataire(numeroDestinataire))) {
      return false;
    }
    if ((type == 'depot' || type == 'retrait') && distributeurId == null) {
      return false;
    }
    return true;
  }
}
