<?php
declare(strict_types=1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "db_connect.php";

$from = trim($_GET['from'] ?? '');
$to   = trim($_GET['to'] ?? '');

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="help_desk_requests.csv"');

$output = fopen('php://output', 'w');

// CSV header row
fputcsv($output, [
    'ID',
    'Requesting Department',
    'Room / Extension',
    'Requesting Officer',
    'Requester Designation',
    'Complaint Description',
    'Action Taken',
    'Diagnosed By',
    'Technician Designation',
    'Date Out',
    'Satisfaction Level',
    'Comment',
    'Status',
    'Created At',
]);

$sql    = "SELECT
                id,
                requesting_department,
                room_extension,
                requesting_officer,
                requester_designation,
                complaint_description,
                action_taken,
                diagnosed_by,
                technician_designation,
                date_time_out,
                satisfaction_level,
                comment,
                status,
                created_at
           FROM help_requests";

$params = [];
$types  = "";

if ($from !== '' && $to !== '') {
    $sql   .= " WHERE created_at >= ? AND created_at < DATE_ADD(?, INTERVAL 1 DAY)";
    $params = [$from, $to];
    $types  = "ss";
} elseif ($from !== '') {
    $sql   .= " WHERE created_at >= ?";
    $params = [$from];
    $types  = "s";
} elseif ($to !== '') {
    $sql   .= " WHERE created_at < DATE_ADD(?, INTERVAL 1 DAY)";
    $params = [$to];
    $types  = "s";
}

$sql .= " ORDER BY id DESC";

$stmt = $conn->prepare($sql);

if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

while ($row = $result->fetch_assoc()) {
    fputcsv($output, [
        $row['id'],
        $row['requesting_department'],
        $row['room_extension'],
        $row['requesting_officer'],
        $row['requester_designation'],
        $row['complaint_description'],
        $row['action_taken']              ?? '',
        $row['diagnosed_by'],
        $row['technician_designation']    ?? '',
        $row['date_time_out']             ?? '',
        $row['satisfaction_level']        ?? '',
        $row['comment']                   ?? '',
        $row['status'],
        $row['created_at'],
    ]);
}

fclose($output);
$stmt->close();
$conn->close();
exit;
?>