import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'preferencias1_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Variables de validación
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  // Controlar visibilidad de los indicadores
  bool _showValidationIndicators = false;

  // Checkboxes
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  // Función para validar la contraseña
  void _validatePassword(String password) {
    setState(() {
      _showValidationIndicators = password.isNotEmpty;
      _hasMinLength = password.length >= 8;
      _hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  Future<void> _registrarUsuario() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (!(_hasMinLength && _hasLetter && _hasNumber && _hasSpecialChar)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña no cumple los requisitos")),
      );
      return;
    }

    if (!_acceptedTerms || !_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Debes aceptar los términos y la política de privacidad")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService().register(
      nombreUs: _nameController.text.trim(),
      correo: _emailController.text.trim(),
      pass: _passwordController.text.trim(),
      usuario: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => Preferencias1Screen(correo: _emailController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Error al registrarse")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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

          // Formulario
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.35,
            ),
            height: MediaQuery.of(context).size.height * 0.65,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E9).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          '¡Regístrate ya!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          "NOMBRE:",
                          "Ingrese su Nombre",
                          _nameController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          "CORREO:",
                          "Ingrese su Correo",
                          _emailController,
                        ),
                        const SizedBox(height: 20),

                        // Campo de contraseña
                        _buildPasswordField(
                          "CONTRASEÑA:",
                          _passwordController,
                          true,
                        ),

                        // Validaciones solo si hay texto
                        if (_showValidationIndicators) ...[
                          const SizedBox(height: 10),
                          _buildPasswordValidationIndicators(),
                        ],

                        const SizedBox(height: 20),
                        _buildPasswordField(
                          "CONFIRMA CONTRASEÑA:",
                          _confirmPasswordController,
                          false,
                        ),

                        const SizedBox(height: 10),

                        // ✅ Botones de aceptación de políticas
                        _buildCheckBox(
                          value: _acceptedTerms,
                          text: "Acepto los Términos y Condiciones",
                          onChanged: (val) =>
                              setState(() => _acceptedTerms = val!),
                        ),
                        _buildCheckBox(
                          value: _acceptedPrivacy,
                          text: "Acepto la Política de Privacidad",
                          onChanged: (val) =>
                              setState(() => _acceptedPrivacy = val!),
                        ),

                        const SizedBox(height: 30),

                        // Botones de navegación
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
                              onPressed: _isLoading ? null : _registrarUsuario,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text(
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

          // Icono del hámster
          Positioned(
            top: MediaQuery.of(context).size.height * 0.13,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/icono.png', height: 150),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto normal
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Campo de contraseña
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isMain,
  ) {
    bool obscure = isMain ? _obscurePassword : _obscureConfirmPassword;
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: isMain ? _validatePassword : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              if (isMain) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }

  // Indicadores de validación
  Widget _buildPasswordValidationIndicators() {
    TextStyle baseStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationPoint("Mínimo 8 caracteres", _hasMinLength, baseStyle),
        _buildValidationPoint("Una letra", _hasLetter, baseStyle),
        _buildValidationPoint("Un número", _hasNumber, baseStyle),
        _buildValidationPoint("Un símbolo especial", _hasSpecialChar, baseStyle),
      ],
    );
  }

  Widget _buildValidationPoint(String text, bool isValid, TextStyle style) {
    return Row(
      children: [
        Icon(Icons.circle,
            size: 10, color: isValid ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: style.copyWith(
            color: isValid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  // ✅ Checkboxes personalizados
  Widget _buildCheckBox({
    required bool value,
    required String text,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
