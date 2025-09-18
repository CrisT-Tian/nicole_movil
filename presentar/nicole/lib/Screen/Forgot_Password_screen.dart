import 'package:flutter/material.dart';
import 'dart:ui';
import 'login_screen.dart';
import 'chat_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool emailEntered = false;
  bool codeEntered = false;
  bool passwordEntered = false;

  void _checkEmail() {
    setState(() {
      emailEntered = emailController.text.isNotEmpty;
    });
  }

  void _checkCode() {
    setState(() {
      codeEntered = codeController.text.isNotEmpty;
    });
  }

  void _checkPassword() {
    setState(() {
      passwordEntered = passwordController.text.isNotEmpty;
    });
  }

  void _submit() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenedor superior redondeado
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: const Color.fromARGB(255, 255, 240, 210).withOpacity(0.85),
                ),
              ),
            ),
          ),
          // Contenido
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/icono.png', height: 80),
                const SizedBox(height: 20),
                const Text(
                  "Recupera tu contraseña",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Campo de correo
                TextField(
                  controller: emailController,
                  onChanged: (_) => _checkEmail(),
                  decoration: InputDecoration(
                    hintText: "Correo",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "A continuación enviamos un código de verificación para que puedas recuperar tu contraseña",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: emailEntered ? () {} : null,
                    child: const Text(
                      "Reenviar Código",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                // Código
                TextField(
                  controller: codeController,
                  onChanged: (_) => _checkCode(),
                  enabled: emailEntered,
                  decoration: InputDecoration(
                    hintText: "Código",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Contraseña
                TextField(
                  controller: passwordController,
                  onChanged: (_) => _checkPassword(),
                  enabled: codeEntered,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Nueva Contraseña",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Confirmar contraseña
                TextField(
                  controller: confirmPasswordController,
                  enabled: passwordEntered,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirmar Contraseña",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),                                                    
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("VOLVER", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: (emailEntered && codeEntered && passwordEntered && confirmPasswordController.text.isNotEmpty)
                          ? _submit
                          : null,
                      child: const Text("SIGUIENTE", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
