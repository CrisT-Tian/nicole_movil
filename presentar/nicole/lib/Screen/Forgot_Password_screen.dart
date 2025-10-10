import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  int paso = 1; // 1=enviar, 2=verificar, 3=cambiar
  bool _isLoading = false;

  Future<void> _procesar() async {
    final api = ApiService();

    if (paso == 1) {
      if (correoController.text.isEmpty) {
        _mostrarSnack("Por favor, ingresa tu correo");
        return;
      }

      setState(() => _isLoading = true);
      final res = await api.recuperarPassword(
        correo: correoController.text.trim(),
        etapa: "enviar",
      );
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        _mostrarSnack("Código enviado correctamente a tu correo");
        setState(() => paso = 2);
      } else {
        _mostrarSnack(res['message'] ?? "Error al enviar el código");
      }
    } else if (paso == 2) {
      if (codigoController.text.isEmpty) {
        _mostrarSnack("Ingresa el código de verificación");
        return;
      }

      setState(() => _isLoading = true);
      final res = await api.recuperarPassword(
        correo: correoController.text.trim(),
        codigo: codigoController.text.trim(),
        etapa: "verificar",
      );
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        _mostrarSnack("Código verificado correctamente");
        setState(() => paso = 3);
      } else {
        _mostrarSnack(res['message'] ?? "Código inválido o expirado");
      }
    } else if (paso == 3) {
      if (passController.text.isEmpty || confirmController.text.isEmpty) {
        _mostrarSnack("Completa ambos campos");
        return;
      }

      if (passController.text != confirmController.text) {
        _mostrarSnack("Las contraseñas no coinciden");
        return;
      }

      setState(() => _isLoading = true);
      final res = await api.recuperarPassword(
        correo: correoController.text.trim(),
        nuevaContrasena: passController.text.trim(),
        etapa: "cambiar",
      );
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        _mostrarSnack("Contraseña actualizada correctamente");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _mostrarSnack(res['message'] ?? "Error al cambiar la contraseña");
      }
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.25,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft:Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: const Color(0xFFFFF3E9).withOpacity(0.9),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset('assets/icono.png', height: 100),
                        const SizedBox(height: 20),
                        const Text(
                          "Recuperar Contraseña",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 🔹 Texto explicativo en paso 1 y paso 2
                        if (paso == 1 ) ...[
                          const SizedBox(height: 10),
                          const Text(
                            "¿olvidaste tu contraseña?\n No te preocupes, aquí puedes recuperarla",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                          // 🔹 Texto explicativo en paso 1 y paso 2
                        if (paso == 2 ) ...[
                          const SizedBox(height: 10),
                          const Text(
                            "A continuación enviamos un código de verificación para que puedas recuperar tu contraseña",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                          // 🔹 Texto explicativo en paso 1 y paso 2
                        if (paso == 3 ) ...[
                          const SizedBox(height: 10),
                          const Text(
                            "A continuación ingresa una nueva contraseña.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (paso == 1) _campoCorreo(),
                        if (paso == 2) _campoCodigo(),
                        if (paso == 3) _campoNuevaContrasena(),

                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isLoading ? null : _procesar,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  paso == 1
                                      ? "       ENVIAR CÓDIGO       "
                                      : paso == 2
                                          ? "     VERIFICAR CÓDIGO    "
                                          : "CAMBIAR CONTRASEÑA",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Botón estilizado de "Volver al inicio de sesión"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Volver al inicio de sesión",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                          const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoCorreo() {
    return TextField(
      controller: correoController,
      decoration: InputDecoration(
        hintText: "Correo electrónico",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoCodigo() {
    return TextField(
      controller: codigoController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Código de verificación",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _campoNuevaContrasena() {
    return Column(
      children: [
        TextField(
          controller: passController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Nueva contraseña",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: confirmController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Confirmar contraseña",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
