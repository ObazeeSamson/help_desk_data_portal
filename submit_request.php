<?php

require_once "db_connect.php";

$requesting_department = $_POST['requesting_department'] ?? '';
$room_extension = $_POST['room_extension'] ?? '';
$requesting_officer = $_POST['requesting_officer'] ?? '';
$requester_designation = $_POST['requester_designation'] ?? '';
$complaint_description = $_POST['complaint_description'] ?? '';

$sql = "INSERT INTO help_requests (
    status,
    date,
    requesting_department,
    room_extension,
    requesting_officer,
    requester_designation,
    complaint_description
) VALUES ('Pending', CURDATE(), ?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);

$stmt->bind_param(
    "sssss",
    $requesting_department,
    $room_extension,
    $requesting_officer,
    $requester_designation,
    $complaint_description
);

if ($stmt->execute()) {
    echo "Request submitted successfully!";
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();

?>
