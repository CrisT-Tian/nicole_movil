import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class EditarInformacionScreen extends StatefulWidget {
  final List<String> gustosSeleccionados;
  final String peso;
  final String altura;
  final List<String> alergias;
  final String correo;

  const EditarInformacionScreen({
    super.key,
    required this.gustosSeleccionados,
    required this.peso,
    required this.altura,
    required this.alergias,
    required this.correo,
  });

  @override
  State<EditarInformacionScreen> createState() =>
      _EditarInformacionScreenState();
}

class _EditarInformacionScreenState extends State<EditarInformacionScreen> {
  late List<String> _gustosSeleccionados;
  late String _peso;
  late String _altura;
  late List<String> _alergias;

  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _otraAlergiaController = TextEditingController();

  bool _hayCambios = false;
  bool _mostrarCampoOtraAlergia = false;

  final List<String> _todosLosGustos = [
    "Dulce",
    "Salado",
    "Umami",
    "Amargo",
    "Picante",
    "Ácido",
  ];

  final List<String> _alergiasComunes = [
    "Polen",
    "Lácteos",
    "Gluten",
    "Frutos secos",
    "Mariscos",
    "Huevo",
    "Pescado",
    "Otros",
  ];

  @override
  void initState() {
    super.initState();
    _gustosSeleccionados = List.from(widget.gustosSeleccionados);
    _peso = widget.peso;
    _altura = widget.altura;
    _alergias = List.from(widget.alergias);
    _pesoController.text = _peso;
    _alturaController.text = _altura;
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _otraAlergiaController.dispose();
    super.dispose();
  }

  void _detectarCambios() {
    setState(() {
      _hayCambios =
          _gustosSeleccionados.toString() !=
              widget.gustosSeleccionados.toString() ||
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
      _pesoController.text = _peso;
      _alturaController.text = _altura;
      _otraAlergiaController.clear();
      _mostrarCampoOtraAlergia = false;
      _hayCambios = false;
    });
  }

  Future<void> _guardarCambios() async {
    final result = await ApiService().actualizarUsuario(
      correo: widget.correo,
      gustos: _gustosSeleccionados,
      peso: _pesoController.text.trim(),
      altura: _alturaController.text.trim(),
      alergias: _alergias,
    );

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Información actualizada correctamente")),
      );

      Navigator.pop(context, {
        "gustos": _gustosSeleccionados,
        "peso": _pesoController.text.trim(),
        "altura": _alturaController.text.trim(),
        "alergias": _alergias,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${result['message'] ?? 'No se pudo guardar'}"),
        ),
      );
    }
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
                    "Edita tus gustos, peso, altura y alergias",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // GUSTOS
                  const Text(
                    "Gustos actuales",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        _gustosSeleccionados.map((gusto) {
                          return Chip(
                            label: Text(gusto),
                            onDeleted: () {
                              setState(() {
                                _gustosSeleccionados.remove(gusto);
                                _detectarCambios();
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),

                  const Text("Selecciona más gustos"),
                  Wrap(
                    spacing: 8,
                    children:
                        _todosLosGustos
                            .where((g) => !_gustosSeleccionados.contains(g))
                            .map((g) {
                              return ChoiceChip(
                                label: Text(g),
                                selected: false,
                                onSelected: (_) {
                                  setState(() {
                                    _gustosSeleccionados.add(g);
                                    _detectarCambios();
                                  });
                                },
                              );
                            })
                            .toList(),
                  ),

                  const SizedBox(height: 20),

                  // PESO Y ALTURA
                  const Text(
                    "Características físicas",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pesoController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Peso (kg)",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _peso = val;
                              _detectarCambios();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _alturaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [HeightFormatter(maxRawValue: 300)],
                          decoration: const InputDecoration(
                            labelText: "Altura (m)",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _altura = val;
                              _detectarCambios();
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ALERGIAS
                  const Text(
                    "Alergias",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        _alergias.map((a) {
                          return Chip(
                            label: Text(a),
                            onDeleted: () {
                              setState(() {
                                _alergias.remove(a);
                                _detectarCambios();
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Agregar alergia",
                    ),
                    items:
                        _alergiasComunes.map((a) {
                          return DropdownMenuItem(value: a, child: Text(a));
                        }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        if (value == "Otros") {
                          _mostrarCampoOtraAlergia = true;
                        } else if (!_alergias.contains(value)) {
                          _alergias.add(value);
                          _mostrarCampoOtraAlergia = false;
                        }
                        _detectarCambios();
                      });
                    },
                  ),

                  if (_mostrarCampoOtraAlergia) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _otraAlergiaController,
                      decoration: const InputDecoration(
                        labelText: "Otra alergia",
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

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Volver",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _hayCambios ? _revertirCambios : null,
                        child: const Icon(Icons.refresh),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        onPressed: _hayCambios ? _guardarCambios : null,
                        child: const Text(
                          "Guardar",
                          style: TextStyle(color: Colors.white),
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
    );
  }
}

class HeightFormatter extends TextInputFormatter {
  final int maxRawValue;
  HeightFormatter({this.maxRawValue = 300});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    int raw = int.parse(digits);
    if (raw > maxRawValue) raw = maxRawValue;
    String formatted;
    if (raw <= 99) {
      formatted = '0.${raw.toString().padLeft(2, '0')}';
    } else {
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
