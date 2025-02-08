import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5), // Fondo con disabledColor
        child: Column(
          children: [
            // Texto de bienvenida
            Padding(
              padding:
                  const EdgeInsets.only(top: 100.0, left: 20.0, right: 20.0),
              child: Text(
                'Bienvenido a la nueva app de viajes y entrega de paquetes, fácil y económica!',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 30,
                  color: Color(0xFF222223), // Texto con primaryColor
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón "Comenzar"
            SizedBox(
              width: 180,
              child: ButtonWidget(
                transparent: true,
                textColor: const Color(0xFF2f76f1),
                showBorder: true,
                radius: 100,
                borderColor: Colors.white.withOpacity(0.5),
                buttonText: 'Comenzar',
                onPressed: () {
                  Get.offAll(() => const SignInScreen());
                },
              ),
            ),

            // Espacio flexible para la imagen
            Expanded(
              flex: 3, // Aumenta el flex para dar más espacio a la imagen
              child: Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                child: Image.asset(
                  'assets/image/bienvenida.png',
                  fit: BoxFit
                      .contain, // Cambia a BoxFit.contain para evitar que se corte
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
