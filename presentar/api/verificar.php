<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

require_once "db_config.php";

$data = json_decode(file_get_contents("php://input"), true);
$correo = trim($data['email'] ?? '');
$codigo = trim($data['codigo'] ?? '');

if (!$correo || !$codigo) {
    echo json_encode(["success" => false, "message" => "Faltan datos"]);
    exit;
}

$stmt = $conn->prepare("SELECT id, expiracion_codigo FROM usuarios WHERE correo = ? AND codigo_verificacion = ?");
$stmt->bind_param("ss", $correo, $codigo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Código incorrecto"]);
    exit;
}

$row = $result->fetch_assoc();
if (strtotime($row['expiracion_codigo']) < time()) {
    echo json_encode(["success" => false, "message" => "El código ha expirado"]);
    exit;
}

$update = $conn->prepare("UPDATE usuarios SET verificado = 1, codigo_verificacion = NULL, expiracion_codigo = NULL WHERE correo = ?");
$update->bind_param("s", $correo);
$update->execute();

echo json_encode(["success" => true, "message" => "Cuenta verificada exitosamente"]);
$conn->close();
?>
