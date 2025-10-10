import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verificar_screen.dart';

class Preferencias2Screen extends StatefulWidget {
  final String correo;
  final String sabor;
  final String alergias;

  const Preferencias2Screen({
    super.key,
    required this.correo,
    required this.sabor,
    required this.alergias,
  });

  @override
  State<Preferencias2Screen> createState() => _Preferencias2ScreenState();
}

class _Preferencias2ScreenState extends State<Preferencias2Screen> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _fechaNacController = TextEditingController();
  bool _isLoading = false;
  DateTime? _fechaNacimiento;

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _fechaNacController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _guardarPreferencias() async {
    if (_pesoController.text.isEmpty ||
        _alturaController.text.isEmpty ||
        _fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService().guardarPreferencias(
      correo: widget.correo,
      sabor: widget.sabor,
      alergias: widget.alergias,
      peso: _pesoController.text.trim(),
      altura: _alturaController.text.trim(),
      fechaNacimiento: _fechaNacimiento!.toIso8601String(),
    );

    setState(() => _isLoading = false);

    if (response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Datos guardados.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificarScreen(correo: widget.correo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Error al guardar.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo general
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

          // Contenedor blur principal
          Positioned.fill(
            top: 140,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E9).withOpacity(0.35),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "Ayúdanos a conocerte más",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Texto descriptivo
                        const Text(
                          "¡Por fin! Estás a un solo paso de degustar nuevos platillos, solo déjanos saber un poco más sobre ti.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campos del formulario
                        TextField(
                          controller: _fechaNacController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(context),
                          decoration: _inputDecoration(
                            hint: "Fecha de nacimiento",
                            icon: Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pesoController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(hint: "Peso (kg)"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _alturaController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  hint: "Altura (m)",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'VOLVER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _guardarPreferencias,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : const Text(
                                        'FINALIZAR',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🆕 Icono encima del contenedor blur
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icono.png',
                height: 100,
                width: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: icon != null ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }
}
