import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import '../routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (authController.user == null) {
      // Si l'utilisateur n'est pas connecté, redirige vers la page de connexion
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

class NoAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (authController.user != null) {
      // Si l'utilisateur est déjà connecté, redirige vers la page appropriée
      if (authController.isDistributor.value) {
        return const RouteSettings(name: Routes.DISTRIBUTOR_HOME);
      } else {
        return const RouteSettings(name: Routes.CLIENT_HOME);
      }
    }
    return null;
  }
}



class ClientRoleMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (authController.user != null && authController.isDistributor.value) {
      // Si l'utilisateur est un distributeur essayant d'accéder à une route client
      return const RouteSettings(name: Routes.DISTRIBUTOR_HOME);
    }
    return null;
  }
}

class DistributorRoleMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (authController.user != null && !authController.isDistributor.value) {
      // Si l'utilisateur est un client essayant d'accéder à une route distributeur
      return const RouteSettings(name: Routes.CLIENT_HOME);
    }
    return null;
  }
}