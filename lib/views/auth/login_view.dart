import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tsunami_money/controllers/auth_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan animé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF4A148C),
                ],
              ),
            ),
          ),
          // Motif d'arrière-plan animé
          CustomPaint(
            size: Size(1.sw, 1.sh),
            painter: BackgroundPainter(),
          ),
          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h),
                    // Logo animé
                    TweenAnimationBuilder(
                      duration: const Duration(seconds: 1),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Hero(
                            tag: 'app_logo',
                            child: Container(
                              height: 140.h,
                              width: 140.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF4A148C),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.bolt,
                                size: 70.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40.h),
                    // Titre de l'application avec animation
                    Text(
                      'TSUNAMI MONEY',
                      style: GoogleFonts.orbitron(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFF6C63FF),
                            ],
                          ).createShader(
                            Rect.fromLTWH(0, 0, 200.w, 70.h),
                          ),
                        letterSpacing: 3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Le futur du transfert d\'argent',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60.h),

                    // Affichage des messages d'erreur
                    Obx(() {
                      if (authController.errorMessage.isNotEmpty) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.red.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            authController.errorMessage.value,
                            style: GoogleFonts.poppins(
                              color: Colors.red[300],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Boutons de connexion avec états de chargement
                    Obx(() => _buildLoginButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.signInWithGoogle(),
                      icon: Icons.g_mobiledata,
                      label: 'Continuer avec Google',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                      ),
                    )),
                    SizedBox(height: 16.h),
                    Obx(() => _buildLoginButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.signInWithFacebook(),
                      icon: Icons.facebook,
                      label: 'Continuer avec Facebook',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1877F2), Color(0xFF00C6FF)],
                      ),
                    )),
                    SizedBox(height: 16.h),
                    Obx(() => _buildLoginButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.signInWithPhone('+1234567890'),
                      icon: Icons.phone_android,
                      label: 'Continuer avec Téléphone',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFE1306C)],
                      ),
                    )),
                    SizedBox(height: 40.h),
                    
                    // Conditions d'utilisation
                    Text(
                      'En continuant, vous acceptez nos conditions d\'utilisation\net notre politique de confidentialité',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
          // Overlay de chargement
          Obx(() {
            if (authController.isLoading.value) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        gradient: onPressed == null 
            ? LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.5),
                  Colors.grey.withOpacity(0.3),
                ],
              )
            : gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: onPressed == null 
            ? [] 
            : [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Création d'un motif de grille futuriste
    final spacing = size.width / 20;
    for (var i = 0; i < size.width; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Ajout de cercles décoratifs
    final circlePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6C63FF).withOpacity(0.1),
          const Color(0xFF4A148C).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(size.center(Offset(0, 0)), size.width * 0.3, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
