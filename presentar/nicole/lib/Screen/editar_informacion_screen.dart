import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditarInformacionScreen extends StatefulWidget {
  final List<String> gustosSeleccionados;
  final double peso;
  final double altura;
  final List<String> alergias;

  const EditarInformacionScreen({
    super.key,
    required this.gustosSeleccionados,
    required this.peso,
    required this.altura,
    required this.alergias,
  });

  @override
  State<EditarInformacionScreen> createState() => _EditarInformacionScreenState();
}

class _EditarInformacionScreenState extends State<EditarInformacionScreen> {
  late List<String> _gustosSeleccionados;
  late double _peso;
  late double _altura;
  late List<String> _alergias;

  final TextEditingController _otraAlergiaController = TextEditingController();

  // === NUEVO: controlador fijo SOLO para altura ===
  final TextEditingController _alturaController = TextEditingController();

  bool _hayCambios = false;
  bool _mostrarCampoOtraAlergia = false;

  final List<String> _todosLosGustos = [
    "Dulce",
    "Salado",
    "Umami",
    "Amargo",
    "Picante",
    "Ácido"
  ];
  final List<String> _alergiasComunes = [
    "Polen",
    "Lácteos",
    "Gluten",
    "Frutos secos",
    "Mariscos",
    "Huevo",
    "Pescado",
    "otros"
  ];

  @override
  void initState() {
    super.initState();
    _gustosSeleccionados = List.from(widget.gustosSeleccionados);
    _peso = widget.peso;
    _altura = widget.altura;
    _alergias = List.from(widget.alergias);

    // Mostrar la altura inicial con 2 decimales en el campo
    _alturaController.text = _altura.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _otraAlergiaController.dispose();
    _alturaController.dispose(); // liberar
    super.dispose();
  }

  void _detectarCambios() {
    setState(() {
      _hayCambios =
          _gustosSeleccionados.toString() != widget.gustosSeleccionados.toString() ||
          _peso != widget.peso ||
          _altura != widget.altura ||
          _alergias.toString() != widget.alergias.toString();
    });
  }

  void _revertirCambios() {
    setState(() {
      _gustosSeleccionados = List.from(widget.gustosSeleccionados);
      _peso = widget.peso;
      _altura = widget.altura;
      _alergias = List.from(widget.alergias);
      _otraAlergiaController.clear();
      _mostrarCampoOtraAlergia = false;
      _hayCambios = false;

      // también reflejar la altura original en el campo
      _alturaController.text = _altura.toStringAsFixed(2);
      _alturaController.selection = TextSelection.collapsed(offset: _alturaController.text.length);
    });
  }

  void _guardarCambios() {
    Navigator.pop(context, {
      "gustos": _gustosSeleccionados,
      "peso": _peso,
      "altura": _altura,
      "alergias": _alergias,
    });
  }

  // Helper para pasar de texto formateado a double
  double _parseAltura(String txt) {
    final val = double.tryParse(txt.replaceAll(',', '.'));
    return val ?? _altura;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Editar perfil",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Bienvenido, aquí podrás editar tus gustos, peso, altura y alergias",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Gustos actuales
                  const Text("Gustos actuales", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _gustosSeleccionados
                        .map((gusto) => Chip(
                              label: Text(gusto),
                              onDeleted: () {
                                setState(() {
                                  _gustosSeleccionados.remove(gusto);
                                  _detectarCambios();
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Otros gustos disponibles
                  const Text("Selecciona más gustos"),
                  Wrap(
                    spacing: 8,
                    children: _todosLosGustos
                        .where((g) => !_gustosSeleccionados.contains(g))
                        .map((g) => ChoiceChip(
                              label: Text(g),
                              selected: false,
                              onSelected: (val) {
                                setState(() {
                                  _gustosSeleccionados.add(g);
                                  _detectarCambios();
                                });
                              },
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Peso y Altura
                  const Text("Características físicas", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Peso (kg)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          controller: TextEditingController(text: _peso.toString())
                            ..selection = TextSelection.collapsed(offset: _peso.toString().length),
                          onChanged: (val) {
                            setState(() {
                              // permitir coma o punto
                              _peso = double.tryParse(val.replaceAll(',', '.')) ?? _peso;
                              _detectarCambios();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // === CAMPO DE ALTURA MODIFICADO ===
                      Expanded(
                        child: TextField(
                          controller: _alturaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            HeightFormatter(maxRawValue: 300), // 3.00 m
                          ],
                          decoration: InputDecoration(
                            labelText: "Altura (m)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: (txtFormateado) {
                            setState(() {
                              _altura = _parseAltura(txtFormateado);
                              _detectarCambios();
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text("Alergias", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _alergias
                        .map((a) => Chip(
                              label: Text(a),
                              onDeleted: () {
                                setState(() {
                                  _alergias.remove(a);
                                  _detectarCambios();
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Alergias?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: _alergiasComunes
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          if (value == "otros") {
                            _mostrarCampoOtraAlergia = true;
                          } else {
                            _alergias.add(value);
                            _mostrarCampoOtraAlergia = false;
                          }
                          _detectarCambios();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Campo oculto para otra alergia
                  if (_mostrarCampoOtraAlergia) ...[
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
                        labelText: "Otra alergia",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.isNotEmpty && !_alergias.contains(val)) {
                          setState(() {
                            _alergias.add(val);
                            _otraAlergiaController.clear();
                            _mostrarCampoOtraAlergia = false;
                            _detectarCambios();
                          });
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("VOLVER", style: TextStyle(color: Colors.white)),
                      ),
                      OutlinedButton(
                        onPressed: _hayCambios ? _revertirCambios : null,
                        child: const Icon(Icons.refresh),
                      ),
                      OutlinedButton(
                        onPressed: _hayCambios ? _guardarCambios : null,
                        child: const Text("Guardar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// TextInputFormatter que:
/// - Acepta solo dígitos que el usuario teclea.
/// - Muestra 0.xx para 1–2 dígitos (cm).
/// - Para 3+ dígitos, inserta punto entre metros y centímetros (m.cc).
/// - Limita a 300 (== 3.00 m).
class HeightFormatter extends TextInputFormatter {
  final int maxRawValue; // e.g., 300 => 3.00 m

  HeightFormatter({this.maxRawValue = 300});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Mantener solo dígitos del input
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    int raw = int.parse(digits);
    if (raw > maxRawValue) raw = maxRawValue;

    String formatted;
    if (raw <= 99) {
      // 1–2 dígitos: 0.xx
      final cm = raw.toString().padLeft(2, '0');
      formatted = '0.$cm';
    } else {
      // 3+ dígitos: m.cc
      final s = raw.toString();
      final m = s.substring(0, s.length - 2);
      final cm = s.substring(s.length - 2);
      formatted = '$m.$cm';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
