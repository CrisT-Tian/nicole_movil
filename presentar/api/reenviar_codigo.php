<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

require_once "db_config.php";
require_once "../dashboard/mail.php";

function generarCodigo() {
    return strval(rand(100000, 999999));
}

$data = json_decode(file_get_contents("php://input"), true);
$correo = trim($data['email'] ?? '');

if (!$correo) {
    echo json_encode(["success" => false, "message" => "Falta el correo"]);
    exit;
}

$codigo = generarCodigo();
$expira = date('Y-m-d H:i:s', strtotime('+10 minutes'));

$stmt = $conn->prepare("UPDATE usuarios SET codigo_verificacion = ?, expiracion_codigo = ? WHERE correo = ?");
$stmt->bind_param("sss", $codigo, $expira, $correo);

if ($stmt->execute() && enviarCodigo($correo, $codigo)) {
    echo json_encode(["success" => true, "message" => "Código reenviado"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al reenviar el código"]);
}
$stmt->close();
$conn->close();
?>
