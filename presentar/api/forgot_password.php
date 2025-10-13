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
$email = trim($data['email'] ?? '');
$codigo = trim($data['codigo'] ?? '');
$nueva = trim($data['nueva_contrasena'] ?? '');
$etapa = trim($data['etapa'] ?? '');

if (!$email || !$etapa) {
    echo json_encode(["success" => false, "message" => "Faltan datos"]);
    exit;
}

if ($etapa === "enviar") {
    $codigo = generarCodigo();
    $expira = date('Y-m-d H:i:s', strtotime('+10 minutes'));
    $stmt = $conn->prepare("UPDATE usuarios SET codigo_verificacion=?, expiracion_codigo=? WHERE correo=?");
    $stmt->bind_param("sss", $codigo, $expira, $email);
    if ($stmt->execute() && enviarCodigo($email, $codigo)) {
        echo json_encode(["success" => true, "message" => "Código enviado"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al enviar el código"]);
    }
}

elseif ($etapa === "verificar") {
    $stmt = $conn->prepare("SELECT expiracion_codigo FROM usuarios WHERE correo=? AND codigo_verificacion=?");
    $stmt->bind_param("ss", $email, $codigo);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($res->num_rows === 0) {
        echo json_encode(["success" => false, "message" => "Código inválido"]);
    } else {
        $row = $res->fetch_assoc();
        if (strtotime($row['expiracion_codigo']) < time()) {
            echo json_encode(["success" => false, "message" => "Código expirado"]);
        } else {
            echo json_encode(["success" => true, "message" => "Código válido"]);
        }
    }
}

elseif ($etapa === "cambiar") {
    $hashed = password_hash($nueva, PASSWORD_DEFAULT);
    $stmt = $conn->prepare("UPDATE usuarios SET pass=?, codigo_verificacion=NULL, expiracion_codigo=NULL WHERE correo=?");
    $stmt->bind_param("ss", $hashed, $email);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Contraseña actualizada"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al cambiar la contraseña"]);
    }
}

$conn->close();
?>
