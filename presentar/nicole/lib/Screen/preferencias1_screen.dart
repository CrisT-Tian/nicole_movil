import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'preferencias2_screen.dart';

class Preferencias1Screen extends StatefulWidget {
  final String correo;
  const Preferencias1Screen({super.key, required this.correo});

  @override
  State<Preferencias1Screen> createState() => _Preferencias1ScreenState();
}

class _Preferencias1ScreenState extends State<Preferencias1Screen> {
  // 🔹 Cambiado: antes era String? _selectedSabor;
  final List<String> _saboresSeleccionados = [];

  bool? _esAlergico;
  final List<String> _alergiasSeleccionadas = [];

  final List<String> _alergiasComunes = [
    "Ninguna",
    "Polen",
    "Ácaros",
    "Lácteos",
    "Gluten",
    "Frutos secos",
    "Mariscos",
    "Huevo",
    "Pescado",
    "Otras",
  ];

  final TextEditingController _otraAlergiaController = TextEditingController();

  @override
  void dispose() {
    _otraAlergiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
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
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E9).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 2),
                        const Text(
                          "Ayúdanos\na conocerte más",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Cuéntanos qué se adapta más a ti",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Sabores (MULTISELECCIÓN)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            "Salado",
                            "Dulce",
                            "Amargo",
                            "Ácido",
                            "Picante",
                            "Umami",
                          ].map((sabor) {
                            final isSelected =
                                _saboresSeleccionados.contains(sabor);
                            return ChoiceChip(
                              label: Text(sabor),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _saboresSeleccionados.add(sabor);
                                  } else {
                                    _saboresSeleccionados.remove(sabor);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "¿Eres alérgico a algo?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _esAlergico == false
                                        ? Colors.black
                                        : Colors.white,
                                foregroundColor:
                                    _esAlergico == false
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _esAlergico = false;
                                  _alergiasSeleccionadas.clear();
                                });
                              },
                              child: const Text("No"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _esAlergico == true
                                        ? Colors.black
                                        : Colors.white,
                                foregroundColor:
                                    _esAlergico == true
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _esAlergico = true;
                                });
                              },
                              child: const Text("Sí"),
                            ),
                          ],
                        ),

                        if (_esAlergico == true) ...[
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            hint: const Text("Selecciona una alergia"),
                            items:
                                _alergiasComunes.map((a) {
                                  return DropdownMenuItem(
                                    value: a,
                                    child: Text(a),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null &&
                                    value != "Ninguna" &&
                                    !_alergiasSeleccionadas.contains(value)) {
                                  _alergiasSeleccionadas.add(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 10),

                          if (_alergiasSeleccionadas.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children:
                                  _alergiasSeleccionadas.map((a) {
                                    return Chip(
                                      label: Text(a),
                                      onDeleted: () {
                                        setState(() {
                                          _alergiasSeleccionadas.remove(a);
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                        ],

                        const SizedBox(height: 25),
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
                                'VOLVER',
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => Preferencias2Screen(
                                          correo: widget.correo,
                                          // 🔹 Ahora enviamos varios sabores
                                          sabor:
                                              _saboresSeleccionados.join(', '),
                                          alergias:
                                              _alergiasSeleccionadas.join(', '),
                                        ),
                                  ),
                                );
                              },
                              child: const Text(
                                'SIGUIENTE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
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

          Positioned(
            top: 60,
            child: Image.asset('assets/icono.png', height: 120),
          ),
        ],
      ),
    );
  }
}
