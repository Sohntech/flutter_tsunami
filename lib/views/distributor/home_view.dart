import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tsunami_money/routes.dart';

class DistributorHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Distributor Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.DEPOSIT),
              child: Text('Deposit'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.WITHDRAW),
              child: Text('Withdraw'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.TRANSACTIONS),
              child: Text('Transactions'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.QR_DEPOSIT),
              child: Text('QR Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
