<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");
require_once "db_config.php";

$data = json_decode(file_get_contents("php://input"), true);
$correo = trim($data["correo"] ?? '');

if (empty($correo)) {
    echo json_encode(["success" => false, "message" => "Correo no recibido"]);
    exit;
}

$stmt = $conn->prepare("
    SELECT 
        u.id,
        u.nombre_us AS nombre,
        u.correo,
        u.edad,
        p.peso,
        p.altura
    FROM usuarios u
    LEFT JOIN preferencias_culinarias p ON u.id = p.usuario_id
    WHERE u.correo = ?
");
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "user" => $user
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Usuario no encontrado"]);
}

$stmt->close();
$conn->close();
?>
