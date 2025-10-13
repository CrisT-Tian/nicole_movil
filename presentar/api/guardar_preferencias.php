<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");
require_once "db_config.php";

$data = json_decode(file_get_contents("php://input"), true);

$correo = trim($data["correo"] ?? "");
$sabores = trim($data["sabores_preferidos"] ?? "");
$alergias = trim($data["alergias"] ?? "");
$peso = trim($data["peso"] ?? "");
$altura = trim($data["altura"] ?? "");
$fecha_nacimiento = trim($data["fecha_nacimiento"] ?? "");

// Validar correo
if (empty($correo)) {
  echo json_encode(["success" => false, "message" => "Correo no recibido"]);
  exit;
}

// Buscar usuario por correo
$stmt = $conn->prepare("SELECT id FROM usuarios WHERE correo = ?");
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "Usuario no encontrado"]);
  exit;
}

$user = $result->fetch_assoc();
$usuario_id = $user["id"];
$stmt->close();

// Actualizar fecha de nacimiento si llega
if (!empty($fecha_nacimiento)) {
  $stmt = $conn->prepare("UPDATE usuarios SET fecha_registro = fecha_registro, edad = TIMESTAMPDIFF(YEAR, ?, CURDATE()) WHERE id = ?");
  $stmt->bind_param("si", $fecha_nacimiento, $usuario_id);
  $stmt->execute();
  $stmt->close();
}

// Verificar si existen preferencias
$stmt = $conn->prepare("SELECT id FROM preferencias_culinarias WHERE usuario_id = ?");
$stmt->bind_param("i", $usuario_id);
$stmt->execute();
$exists = $stmt->get_result()->num_rows > 0;
$stmt->close();

if ($exists) {
  // Actualizar
  $stmt = $conn->prepare("
    UPDATE preferencias_culinarias 
    SET sabores_preferidos=?, alergias=?, peso=?, altura=?, fecha_actualizacion=CURRENT_TIMESTAMP 
    WHERE usuario_id=?
  ");
  $stmt->bind_param("ssdsi", $sabores, $alergias, $peso, $altura, $usuario_id);
  $ok = $stmt->execute();
  $stmt->close();
} else {
  // Insertar
  $stmt = $conn->prepare("
    INSERT INTO preferencias_culinarias (usuario_id, sabores_preferidos, alergias, peso, altura) 
    VALUES (?, ?, ?, ?, ?)
  ");
  $stmt->bind_param("issdd", $usuario_id, $sabores, $alergias, $peso, $altura);
  $ok = $stmt->execute();
  $stmt->close();
}

echo json_encode([
  "success" => $ok,
  "message" => $ok ? "Preferencias guardadas correctamente" : "Error al guardar preferencias",
]);
$conn->close();
?>
