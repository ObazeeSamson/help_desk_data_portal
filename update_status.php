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

$id     = trim($_POST['id'] ?? '');
$status = trim($_POST['status'] ?? '');

$allowedStatuses = ['pending', 'in_progress', 'resolved', 'closed'];

if ($id === '' || $status === '') {
    http_response_code(400);
    echo "Missing request ID or status";
    exit;
}

if (!in_array($status, $allowedStatuses, true)) {
    http_response_code(400);
    echo "Invalid status";
    exit;
}

$stmt = $conn->prepare("UPDATE help_requests SET status = ? WHERE id = ?");
$stmt->bind_param("si", $status, $id);

if ($stmt->execute()) {
    echo "success";
} else {
    http_response_code(500);
    echo "error: " . $conn->error;
}

$stmt->close();
$conn->close();
?>