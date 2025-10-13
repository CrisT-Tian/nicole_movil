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
$nombre = trim($data['nombre_us'] ?? '');
$correo = trim($data['correo'] ?? '');
$password = trim($data['pass'] ?? '');
$edad = intval($data['edad'] ?? 0);
$usuario = trim($data['usuario'] ?? '');
$codigo = generarCodigo();
$expira = date('Y-m-d H:i:s', strtotime('+10 minutes'));

if (empty($nombre) || empty($correo) || empty($password) || empty($usuario)) {
    echo json_encode(["success" => false, "message" => "Faltan datos"]);
    exit;
}

$check = $conn->prepare("SELECT id FROM usuarios WHERE correo = ? OR usuario = ?");
$check->bind_param("ss", $correo, $usuario);
$check->execute();
$result = $check->get_result();
if ($result->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "El correo o usuario ya está registrado"]);
    exit;
}
$check->close();

$hashed = password_hash($password, PASSWORD_DEFAULT);

$conn->begin_transaction();
try {
    $stmt = $conn->prepare("INSERT INTO usuarios (nombre_us, correo, pass, edad, usuario, codigo_verificacion, expiracion_codigo) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssisss", $nombre, $correo, $hashed, $edad, $usuario, $codigo, $expira);
    $stmt->execute();
    $user_id = $conn->insert_id;
    $stmt->close();

    $pref = $conn->prepare("INSERT INTO preferencias_culinarias (usuario_id) VALUES (?)");
    $pref->bind_param("i", $user_id);
    $pref->execute();
    $pref->close();

    if (enviarCodigo($correo, $codigo)) {
        $conn->commit();
        echo json_encode(["success" => true, "message" => "Registro exitoso. Se envió un código de verificación."]);
    } else {
        throw new Exception("No se pudo enviar el correo de verificación.");
    }
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
$conn->close();
?>
