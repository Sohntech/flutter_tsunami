import 'package:get/get.dart';
import 'middleware/auth_middleware.dart';
import 'views/auth/login_view.dart';
import 'views/auth/add_phone_view.dart'; // Import de la vue pour ajouter un numéro
import 'views/client/home_view.dart';
import 'views/distributor/home_view.dart';
// import 'views/client/transfer_view.dart';
// import 'views/client/multiple_transfer_view.dart';
// import 'views/client/scheduled_transfer_view.dart';
// import 'views/client/transactions_view.dart';
// import 'views/distributor/deposit_view.dart';
// import 'views/distributor/withdraw_view.dart';
// import 'views/distributor/transactions_view.dart';
// import 'views/distributor/qr_deposit_view.dart';

abstract class Routes {
  // Auth routes
  static const LOGIN = '/login';
  static const ADD_PHONE = '/add_phone'; // Nouvelle route pour ajouter un numéro
  
  // Client routes
  static const CLIENT_HOME = '/client_home';
  static const TRANSFER = '/transfer';
  static const MULTIPLE_TRANSFER = '/multiple_transfer';
  static const SCHEDULED_TRANSFER = '/scheduled_transfer';
  static const TRANSACTIONS = '/transactions';
  
  // Distributor routes
  static const DISTRIBUTOR_HOME = '/distributor_home';
  static const DEPOSIT = '/deposit';
  static const WITHDRAW = '/withdraw';
  static const QR_DEPOSIT = '/qr_deposit';
}

abstract class AppPages {
  static final pages = [
    // Auth Routes
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      middlewares: [
        NoAuthMiddleware(), // Redirige vers la page d'accueil si déjà connecté
      ],
    ),
    GetPage(
      name: Routes.ADD_PHONE,
      page: () => AddPhoneView(),
      middlewares: [
        AuthMiddleware(), // S'assurer que l'utilisateur est connecté
      ],
      transition: Transition.fadeIn,
    ),
    
    // Client Routes
    GetPage(
      name: Routes.CLIENT_HOME,
      page: () => ClientHomeView(),
      middlewares: [
        AuthMiddleware(), // Vérifie si l'utilisateur est connecté
        ClientRoleMiddleware(), // Vérifie si l'utilisateur est un client
      ],
      transition: Transition.fadeIn,
    ),
    /*
    GetPage(
      name: Routes.TRANSFER,
      page: () => TransferView(),
      middlewares: [AuthMiddleware(), ClientRoleMiddleware()],
    ),
    GetPage(
      name: Routes.MULTIPLE_TRANSFER,
      page: () => MultipleTransferView(),
      middlewares: [AuthMiddleware(), ClientRoleMiddleware()],
    ),
    GetPage(
      name: Routes.SCHEDULED_TRANSFER,
      page: () => ScheduledTransferView(),
      middlewares: [AuthMiddleware(), ClientRoleMiddleware()],
    ),
    GetPage(
      name: Routes.TRANSACTIONS,
      page: () => TransactionsView(),
      middlewares: [AuthMiddleware(), ClientRoleMiddleware()],
    ),
    */
    
    // Distributor Routes
    GetPage(
      name: Routes.DISTRIBUTOR_HOME,
      page: () => DistributorHomeView(),
      middlewares: [
        AuthMiddleware(), // Vérifie si l'utilisateur est connecté
        DistributorRoleMiddleware(), // Vérifie si l'utilisateur est un distributeur
      ],
      transition: Transition.fadeIn,
    ),
    /*
    GetPage(
      name: Routes.DEPOSIT,
      page: () => DepositView(),
      middlewares: [AuthMiddleware(), DistributorRoleMiddleware()],
    ),
    GetPage(
      name: Routes.WITHDRAW,
      page: () => WithdrawView(),
      middlewares: [AuthMiddleware(), DistributorRoleMiddleware()],
    ),
    GetPage(
      name: Routes.QR_DEPOSIT,
      page: () => QRDepositView(),
      middlewares: [AuthMiddleware(), DistributorRoleMiddleware()],
    ),
    */
  ];
}
