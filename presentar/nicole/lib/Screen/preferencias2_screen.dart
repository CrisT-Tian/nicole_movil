import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class Preferencias2Screen extends StatefulWidget {
  const Preferencias2Screen({super.key});

  @override
  State<Preferencias2Screen> createState() => _Preferencias2ScreenState();
}

class _Preferencias2ScreenState extends State<Preferencias2Screen> {
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _fechaNacController = TextEditingController();

  DateTime? _fechaNacimiento;

  @override
  void dispose() {
    _alturaController.dispose();
    _fechaNacController.dispose();
    super.dispose();
  }

  void _formatAltura(String value) {
    if (value.isEmpty) return;

    String cleanValue = value.replaceAll('.', '').replaceAll(',', '');
    int? numValue = int.tryParse(cleanValue);
    if (numValue == null) return;

    if (numValue > 300) {
      numValue = 300;
    }

    String formatted;
    if (numValue <= 99) {
      formatted = numValue.toString();
    } else {
      String strVal = numValue.toString().padLeft(3, '0');
      String metros = strVal.substring(0, strVal.length - 2);
      String centimetros = strVal.substring(strVal.length - 2);
      formatted = "$metros.$centimetros";
    }

    if (_alturaController.text != formatted) {
      _alturaController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime fechaInicial = DateTime(2000, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 110;
    const double iconTop = 60;
    final double blurTop = iconTop + iconSize * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // 1) Fondo con imagen
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

          Positioned(
            top: blurTop,
            left: 0,
            right: 0,
            bottom: 0,
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
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "¡Por fin! Estás a un solo paso de degustar nuevos platillos, solo déjanos saber un poco más sobre ti.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 25),

                        // CAMPO NUEVO: Fecha de nacimiento
                        TextField(
                          controller: _fechaNacController,
                          readOnly: true,
                          onTap: () => _seleccionarFecha(context),
                          decoration: InputDecoration(
                            hintText: "Fecha de nacimiento",
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(Icons.calendar_today),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.black, width: 1.2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(child: _buildTextField("Peso (kilos)", TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _alturaController,
                                keyboardType: TextInputType.number,
                                onChanged: _formatAltura,
                                decoration: InputDecoration(
                                  hintText: "Altura (metros)",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(color: Colors.black, width: 1.2),
                                  ),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'VOLVER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                                ),
                                child: const Text(
                                  'FINALIZAR',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("N.I.C.O.L.E  |  Alpha 22",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: iconTop,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icono.png',
                height: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Inputs normales
  Widget _buildTextField(String hint, TextInputType type) {
    return TextField(
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
      ),
    );
  }
}
