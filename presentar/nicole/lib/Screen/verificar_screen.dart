import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class VerificarScreen extends StatefulWidget {
  final String correo;

  const VerificarScreen({super.key, required this.correo});

  @override
  State<VerificarScreen> createState() => _VerificarScreenState();
}

class _VerificarScreenState extends State<VerificarScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verificarCodigo() async {
    setState(() => _isLoading = true);

    final response = await ApiService().verificarCodigo(
      widget.correo,
      _codigoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      _mostrarDialogo(
        "Verificación exitosa",
        "Tu cuenta ha sido verificada correctamente. Ahora puedes iniciar sesión.",
        true,
      );
    } else {
      _mostrarDialogo(
        "Error",
        response['message'] ?? "Código incorrecto o expirado.",
        false,
      );
    }
  }

  void _mostrarDialogo(String titulo, String mensaje, bool exito) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  if (exito) {
                    // Lleva al LoginScreen y elimina el resto de pantallas
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Fondo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fondo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Contenedor blur
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E9).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 0),
                      const Text(
                        "Bienvenido a la verificación de cuenta",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "A continuacion te hemos enviado un código de 6 dígitos a:\n${widget.correo}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _codigoController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Ingresa tu código",
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "VOLVER",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading ? null : _verificarCodigo,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                    : const Text(
                                      "VERIFICAR",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          ApiService().reenviarCodigo(widget.correo);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Código reenviado")),
                          );
                        },
                        child: const Text(
                          "Reenviar código",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "N.I.C.O.L.E | Alpha 22",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Icono superior
          Positioned(
            top: 100,
            child: Image.asset('assets/icono.png', height: 150),
          ),
        ],
      ),
    );
  }
}
