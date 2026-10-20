<?php
declare(strict_types=1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "db_connect.php";

$sql = "SELECT
            id,
            status,
            requesting_department,
            room_extension,
            requesting_officer,
            requester_designation,
            complaint_description,
            diagnosed_by,
            created_at
        FROM help_requests
        ORDER BY id DESC";

$result = $conn->query($sql);

if (!$result) {
    http_response_code(500);
    echo json_encode([
        'status'  => 'error',
        'message' => 'Query failed: ' . $conn->error,
    ]);
    $conn->close();
    exit;
}

$requests = [];
while ($row = $result->fetch_assoc()) {
    $requests[] = $row;
}

echo json_encode([
    'status' => 'success',
    'data'   => $requests,
]);

$conn->close();
?>