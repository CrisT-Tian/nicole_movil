<?php 
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

require_once "db_config.php";

$data = json_decode(file_get_contents("php://input"), true);

$correo = $data["correo"] ?? "";
$gustos = $data["gustos"] ?? [];
$peso = floatval($data["peso"] ?? 0);
$alturaRaw = trim($data["altura"] ?? "");
$alergias = $data["alergias"] ?? [];

// 🔹 Normalizar altura: si viene "175" => 1.75 / si viene "1.75" => 1.75
if (strpos($alturaRaw, ".") === false && strlen($alturaRaw) >= 3) {
  $altura = floatval($alturaRaw) / 100;
} else {
  $altura = floatval($alturaRaw);
}

if (empty($correo)) {
  echo json_encode(["success" => false, "message" => "Correo no recibido"]);
  exit;
}

// 🔹 Obtener ID real del usuario
$stmt = $conn->prepare("SELECT id FROM usuarios WHERE correo = ?");
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode(["success" => false, "message" => "Usuario no encontrado"]);
  exit;
}

$row = $result->fetch_assoc();
$id_usuario = $row["id"];
$stmt->close();

$sabores_preferidos = implode(", ", $gustos);
$alergias_txt = implode(", ", $alergias);

// 🔹 Verificar si ya existen preferencias
$stmt = $conn->prepare("SELECT id FROM preferencias_culinarias WHERE usuario_id = ?");
$stmt->bind_param("i", $id_usuario);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
  // Actualizar registro existente
  $stmt_update = $conn->prepare("
    UPDATE preferencias_culinarias
    SET sabores_preferidos = ?, alergias = ?, peso = ?, altura = ?, fecha_actualizacion = NOW()
    WHERE usuario_id = ?
  ");
  // 🧩 CAMBIO AQUÍ: de "ssdii" a "sssdi"
  $stmt_update->bind_param("sssdi", $sabores_preferidos, $alergias_txt, $peso, $altura, $id_usuario);
  $ok = $stmt_update->execute();
  $stmt_update->close();
} else {
  // Insertar nuevo registro
  $stmt_insert = $conn->prepare("
    INSERT INTO preferencias_culinarias (usuario_id, sabores_preferidos, alergias, peso, altura)
    VALUES (?, ?, ?, ?, ?)
  ");
  $stmt_insert->bind_param("issdd", $id_usuario, $sabores_preferidos, $alergias_txt, $peso, $altura);
  $ok = $stmt_insert->execute();
  $stmt_insert->close();
}

$conn->close();

echo json_encode([
  "success" => $ok,
  "message" => $ok ? "Información actualizada correctamente" : "Error al actualizar",
  "debug" => [
    "altura_recibida" => $alturaRaw,
    "altura_guardada" => $altura
  ]
]);
?>
