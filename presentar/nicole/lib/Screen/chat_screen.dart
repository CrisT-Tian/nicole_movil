import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'editar_informacion_screen.dart';

class ChatScreen extends StatefulWidget {
  final String correo;

  const ChatScreen({super.key, required this.correo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService api = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _nombre = "";
  String _correo = "";
  int _edad = 0;
  String _peso = "0";
  String _altura = "0";
  List<String> _gustos = [];
  List<String> _alergias = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final correoActual = widget.correo;
    final data = await api.obtenerUsuario(correoActual);

    if (data["success"] != false) {
      setState(() {
        _correo = data["correo"] ?? correoActual;
        _nombre = data["nombre"] ?? "Usuario";
        _edad = int.tryParse(data["edad"]?.toString() ?? "0") ?? 0;
        _peso = data["peso"]?.toString() ?? "0";
        _altura = data["altura"]?.toString() ?? "0";
      });

      await prefs.setString("correo", _correo);
      await prefs.setString("nombre_us", _nombre);
    }

    setState(() => _loadingUser = false);
  }

  void _showLogoutDialog() async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Cerrar sesión?'),
            content: const Text('¿Estás seguro de que quieres salir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
  }

  void _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'text': userMessage, 'sender': 'user'});
      _messageController.clear();
    });

    try {
      final botReply = await api.sendMessage(userMessage);
      setState(() {
        _messages.add({'text': botReply, 'sender': 'bot'});
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': '❌ Error: $e', 'sender': 'bot'});
      });
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _messageController.text = val.recognizedWords;
            });
          },
        );

        Future.delayed(const Duration(seconds: 8), () {
          if (_isListening) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondo.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
                accountName: Text(_nombre),
                accountEmail: Text(_correo),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black, size: 45),
                ),
              ),
              ListTile(
                title: const Text('Edad'),
                trailing: _infoBox('$_edad años'),
              ),
              ListTile(
                title: const Text('Peso'),
                trailing: _infoBox('$_peso kg'),
              ),
              ListTile(
                title: const Text('Altura'),
                trailing: _infoBox('$_altura m'),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditarInformacionScreen(
                              gustosSeleccionados: _gustos,
                              peso: _peso,
                              altura: _altura,
                              alergias: _alergias,
                              correo: _correo,
                            ),
                      ),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        _peso = result['peso']?.toString() ?? _peso;
                        _altura = result['altura']?.toString() ?? _altura;
                        _gustos = List<String>.from(
                          result['gustos'] ?? _gustos,
                        );
                        _alergias = List<String>.from(
                          result['alergias'] ?? _alergias,
                        );
                      });
                    }
                  },
                  child: const Text(
                    'EDITAR INFORMACIÓN',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _showLogoutDialog,
                  child: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text('Chat', style: TextStyle(color: Colors.black)),
              centerTitle: true,
              actions: [
                GestureDetector(
                  onTap: () => setState(() => _messages.clear()),
                  child: Image.asset('assets/icono.png', height: 40),
                ),
                const SizedBox(width: 10),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUser = _messages[index]['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.yellow[100] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _messages[index]['text'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: _isListening ? Colors.red : Colors.black,
                    ),
                    onPressed: _toggleListening,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
