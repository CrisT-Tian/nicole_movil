import 'dart:ui';
import 'package:flutter/material.dart';
import 'preferencias2_screen.dart';

class Preferencias1Screen extends StatefulWidget {
  const Preferencias1Screen({super.key});

  @override
  State<Preferencias1Screen> createState() => _Preferencias1ScreenState();
}

class _Preferencias1ScreenState extends State<Preferencias1Screen> {
  String? _selectedSabor;
  bool? _esAlergico;
  String? _selectedAlergia;
  final TextEditingController _otraAlergiaController = TextEditingController();

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
    "otras"
  ];

  final List<String> _alergiasSeleccionadas = [];

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

          // Contenedor con blur
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
                        const SizedBox(height: 60),
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

                        // Sabores
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            "Salado", "Dulce", "Amargo", "Ácido", "Picante", "Umami"
                          ].map((sabor) {
                            return ChoiceChip(
                              label: Text(sabor),
                              selected: _selectedSabor == sabor,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSabor = selected ? sabor : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Pregunta alergias
                        const Text(
                          "¿Eres alérgico a algo?",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _esAlergico == false ? Colors.black : Colors.white,
                                foregroundColor: _esAlergico == false ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _esAlergico = false;
                                  _alergiasSeleccionadas.clear();
                                  _selectedAlergia = null;
                                });
                              },
                              child: const Text("No"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _esAlergico == true ? Colors.black : Colors.white,
                                foregroundColor: _esAlergico == true ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black),
                                ),
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
                        const SizedBox(height: 15),

                        // Dropdown de alergias
                        if (_esAlergico == true) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedAlergia,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            hint: const Text("Selecciona una alergia"),
                            items: _alergiasComunes.map((alergia) {
                              return DropdownMenuItem(
                                value: alergia,
                                child: Text(alergia),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAlergia = value;
                                if (value != null &&
                                    value != "otras" &&
                                    value != "Ninguna" &&
                                    !_alergiasSeleccionadas.contains(value)) {
                                  _alergiasSeleccionadas.add(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 10),

                          // Campo de texto cuando selecciona "otras"
                          if (_selectedAlergia == "otras") ...[
                            const Text(
                              "Si su alergia no se muestra en la lista, escriba aquí brevemente en qué consiste su alergia",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _otraAlergiaController,
                              maxLength: 20,
                              decoration: InputDecoration(
                                hintText: 'Escribe tu alergia (máx 20 caracteres)',
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (val) {
                                if (val.isNotEmpty &&
                                    !_alergiasSeleccionadas.contains(val)) {
                                  setState(() {
                                    _alergiasSeleccionadas.add(val);
                                    _otraAlergiaController.clear();
                                  });
                                }
                              },
                            ),
                          ],

                          // Chips con alergias seleccionadas
                          if (_alergiasSeleccionadas.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: _alergiasSeleccionadas.map((a) {
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
                        ],

                        const SizedBox(height: 20),

                        // Botones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'VOLVER',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Preferencias2Screen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'SIGUIENTE',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("N.I.C.O.L.E  | Alpha 22"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Icono flotante
          Positioned(
            top: 40,
            child: Image.asset(
              'assets/icono.png',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}
