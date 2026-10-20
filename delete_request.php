<?php
declare(strict_types=1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "db_connect.php";

$id = trim($_POST['id'] ?? '');

if ($id === '') {
    http_response_code(400);
    echo "Missing request ID";
    exit;
}

$stmt = $conn->prepare("DELETE FROM help_requests WHERE id = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo "success";
} else {
    http_response_code(500);
    echo "error: " . $conn->error;
}

$stmt->close();
$conn->close();
?>