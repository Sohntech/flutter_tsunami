import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tsunami_money/views/client/simple_transfer_view.dart';

import '../../controllers/auth_controller.dart';
import '../../routes.dart';

class ClientHomeView extends StatefulWidget {
  @override
  _ClientHomeViewState createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;

  User? currentUser;

  bool isScanning = false;
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    currentUser = _auth.currentUser;
  }

  @override
  void dispose() {
    _animationController.dispose();
    scannerController?.dispose();
    super.dispose();
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await authController.signOut();
                Get.offAllNamed(Routes.LOGIN);
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  void _openQrModal() {
    scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QR Code de l\'utilisateur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_mobile_English_Wikipedia.svg/800px-QR_code_for_mobile_English_Wikipedia.svg.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 24),
                if (isScanning)
                  SizedBox(
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: scannerController!,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            print('QR Code scanné: ${barcode.rawValue}');
                          }
                        },
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner un code QR'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isScanning = true;
                      });
                    },
                  ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    scannerController?.dispose();
                    Get.back();
                  },
                  child: const Text('Fermer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToSimpleTransfer() {
    Get.to(() => SimpleTransferView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Transfert\nSimple',
                      Icons.send,
                      const Color(0xFF4A3AFF),
                      _navigateToSimpleTransfer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Transfert\nMultiple',
                      Icons.group_add,
                      const Color(0xFF4CAF50),
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      'Transfert\nPlanifié',
                      Icons.schedule,
                      const Color(0xFFFF6B6B),
                      () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildTransactionHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A3AFF), Color(0xFF6B10FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : null,
                    child: currentUser?.photoURL == null
                        ? const Icon(Icons.person, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentUser?.displayName ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _showLogoutConfirmationDialog,
                tooltip: 'Déconnexion',
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Solde du compte',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return const Text('••••••••', style: TextStyle(color: Colors.white, fontSize: 25));
              }
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          _isBalanceVisible
                              ? '${data['balance'] ?? 0.0} FCFA'
                              : '••••••••',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR Code'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _openQrModal,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        var userPhone = userData['phone']; // Numéro de téléphone de l'utilisateur

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('transactions')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, transactionSnapshot) {
            if (!transactionSnapshot.hasData || transactionSnapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }

            var transactions = transactionSnapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              // Inclure les transactions envoyées ou reçues
              return data['clientId'] == currentUser?.uid ||
                  data['numeroDestinataire'] == userPhone;
            }).toList();

            if (transactions.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune transaction récente.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index].data() as Map<String, dynamic>;
                var isReceived = transaction['numeroDestinataire'] == userPhone;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReceived ? Colors.green : Colors.indigo,
                    child: Icon(
                      isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(isReceived ? 'Montant reçu' : transaction['type']),
                  subtitle: Text(
                    '${transaction['montant']} FCFA - ${transaction['date']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            );
          },
        );
      },
    ),
  );
}

}
