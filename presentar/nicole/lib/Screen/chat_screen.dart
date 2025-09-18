import 'package:flutter/material.dart';
import 'editar_informacion_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // 👈 Import

class ChatScreen extends StatefulWidget {
  final int edad;
  final double peso;
  final double altura;
  final List<String> gustosSeleccionados;
  final List<String> alergias;

  const ChatScreen({
    super.key,
    this.edad = 0,
    this.peso = 0,
    this.altura = 0,
    this.gustosSeleccionados = const [],
    this.alergias = const [],
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late int _edad;
  late double _peso;
  late double _altura;
  late List<String> _gustos;
  late List<String> _alergias;

  // 👇 Variables de voz
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _edad = widget.edad;
    _peso = widget.peso;
    _altura = widget.altura;
    _gustos = widget.gustosSeleccionados;
    _alergias = widget.alergias;

    _speech = stt.SpeechToText();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿esto es un adiós?'),
          content: const Text('¿estas seguro de que quieres abandonar tu sesión?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('VOLVER', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _messageController.text, 'sender': 'user'});
        if (_messages.length == 1) {
          _messages.add({
            'text': '¡Hola! Bienvenido al chat, estoy aquí para ayudarte 😊',
            'sender': 'bot'
          });
        }
        _messageController.clear();
      });
    }
  }

  // 👇 Método para manejar el micrófono
  void _toggleListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
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

        // Auto stop después de 8 segundos sin hablar
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
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                accountName: const Text('Usuario001'),
                accountEmail: null,
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black, size: 50),
                ),
              ),
              ListTile(
                title: const Text('Edad', style: TextStyle(color: Colors.black)),
                trailing: _infoBox('$_edad'),
              ),
              ListTile(
                title: const Text('Peso', style: TextStyle(color: Colors.black)),
                trailing: _infoBox('$_peso'),
              ),
              ListTile(
                title: const Text('Altura', style: TextStyle(color: Colors.black)),
                trailing: _infoBox('$_altura'),
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
                        builder: (context) => EditarInformacionScreen(
                          gustosSeleccionados: _gustos,
                          peso: _peso,
                          altura: _altura,
                          alergias: _alergias,
                        ),
                      ),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        _edad = result['edad'] ?? _edad;
                        _peso = result['peso'] ?? _peso;
                        _altura = result['altura'] ?? _altura;
                        _gustos = result['gustos'] ?? _gustos;
                        _alergias = result['alergias'] ?? _alergias;
                      });
                    }
                  },
                  child: const Text('EDITAR INFORMACIÓN', style: TextStyle(color: Colors.black)),
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
                  child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
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
              title: const Center(
                child: Text('Chat', style: TextStyle(color: Colors.black)),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _messages.clear();
                    });
                  },
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
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                        color: _isListening ? Colors.red : Colors.black),
                    onPressed: _toggleListening, // 👈 Aquí la acción de voz
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
