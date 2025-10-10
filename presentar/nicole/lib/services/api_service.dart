// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia si tu ruta es distinta
  final String apiUrl = "https://nicole.sytes.net/api";
  final String baseUrl = "http://nicoleia.servehttp.com:90/v1/chat/completions";

  // ---------- IA (Chat) ----------
  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer lm-studio",
      },
      body: jsonEncode({
        "model": "meta-llama-3.1-8b-instruct",
        "messages": [
          {"role": "user", "content": message},
        ],
        "temperature": 0.3,
        "max_tokens": 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Asegúrate de que la respuesta viene con esta estructura
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("Error al conectar con IA: ${response.statusCode}");
    }
  }

  // ---------- LOGIN ----------
  // Tu login.php de API (según dashboard) espera 'correo' y 'pass'
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email, // 👈 tiene que ser 'email'
          "password": password, // 👈 y 'password'
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ---------- REGISTER ----------
  // register.php espera: nombre_us, correo, pass, edad, usuario
  Future<Map<String, dynamic>> register({
    required String nombreUs,
    required String correo,
    required String pass,
    int edad = 0,
    required String usuario,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/register.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre_us": nombreUs,
          "correo": correo,
          "pass": pass,
          "edad": edad,
          "usuario": usuario,
        }),
      );
      return jsonDecode(resp.body);
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ---------- VERIFICAR CÓDIGO ----------
  // Algunas versiones de PHP podían esperar 'email' o 'correo' => enviamos ambos
  Future<Map<String, dynamic>> verificarCodigo(
    String correo,
    String codigo,
  ) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/verificar.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, "email": correo, "codigo": codigo}),
      );
      return jsonDecode(resp.body);
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ---------- REENVIAR CÓDIGO ----------
  Future<Map<String, dynamic>> reenviarCodigo(String correo) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/reenviar_codigo.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo, "email": correo}),
      );
      return jsonDecode(resp.body);
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ---------- GUARDAR PREFERENCIAS ----------
  Future<Map<String, dynamic>> guardarPreferencias({
    required String correo,
    String? sabor,
    String? alergias,
    String? peso,
    String? altura,
    String? fechaNacimiento,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/guardar_preferencias.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correo,
          "sabores_preferidos": sabor ?? "",
          "alergias": alergias ?? "",
          "peso": peso ?? "",
          "altura": altura ?? "",
          "fecha_nacimiento": fechaNacimiento ?? "",
        }),
      );

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        return {"success": false, "message": "Error ${resp.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ---------- OLVIDÉ CONTRASEÑA (3 etapas) ----------
  // etapa = "enviar" | "verificar" | "cambiar"
  Future<Map<String, dynamic>> recuperarPassword({
    required String correo,
    String? codigo,
    String? nuevaContrasena,
    required String etapa,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/forgot_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": correo, // tu forgot_password.php usa 'email'
          "correo": correo, // por compatibilidad
          "codigo": codigo,
          "nueva_contrasena": nuevaContrasena,
          "etapa": etapa,
        }),
      );
      return jsonDecode(resp.body);
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  // ---------- OBTENER USUARIO ----------
  Future<Map<String, dynamic>> obtenerUsuario(String correo) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/obtener_usuario.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": correo}),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data["success"] == true) {
        return data["user"];
      } else {
        return {"success": false, "message": data["message"] ?? "Error"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ---------- ACTUALIZAR USUARIO ----------
  Future<Map<String, dynamic>> actualizarUsuario({
    required String correo,
    required List<String> gustos,
    required String peso,
    required String altura,
    required List<String> alergias,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse("$apiUrl/actualizar_usuario.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correo,
          "gustos": gustos,
          "peso": peso,
          "altura": altura,
          "alergias": alergias,
        }),
      );

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        return {
          "success": false,
          "message": "Error ${resp.statusCode}: No se pudo actualizar usuario",
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
