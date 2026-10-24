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

$id           = trim($_POST['id'] ?? '');
$status       = trim($_POST['status'] ?? '');
$diagnosed_by = isset($_POST['diagnosed_by']) ? trim($_POST['diagnosed_by']) : null;

$allowedStatuses = ['pending', 'in_progress', 'resolved', 'closed'];

if ($id === '') {
    http_response_code(400);
    echo "Missing request ID";
    exit;
}

// Case 1: Status provided and diagnosed_by provided
if ($status !== '' && $diagnosed_by !== null) {
    if (!in_array($status, $allowedStatuses, true)) {
        http_response_code(400);
        echo "Invalid status";
        exit;
    }
    $stmt = $conn->prepare("UPDATE help_requests SET status = ?, diagnosed_by = ? WHERE id = ?");
    $stmt->bind_param("ssi", $status, $diagnosed_by, $id);
}
// Case 2: Only status provided
elseif ($status !== '') {
    if (!in_array($status, $allowedStatuses, true)) {
        http_response_code(400);
        echo "Invalid status";
        exit;
    }
    $stmt = $conn->prepare("UPDATE help_requests SET status = ? WHERE id = ?");
    $stmt->bind_param("si", $status, $id);
}
// Case 3: Only diagnosed_by provided (assign/reassign technician directly)
elseif ($diagnosed_by !== null) {
    $stmt = $conn->prepare("UPDATE help_requests SET diagnosed_by = ? WHERE id = ?");
    $stmt->bind_param("si", $diagnosed_by, $id);
}
// Neither provided
else {
    http_response_code(400);
    echo "Missing status or technician";
    exit;
}

if ($stmt->execute()) {
    echo "success";
} else {
    http_response_code(500);
    echo "error: " . $conn->error;
}

$stmt->close();
$conn->close();
?>
