<?php
declare(strict_types=1);

// ── AlwaysData MySQL credentials ─────────────────────────────────────────────
$host     = "mysql-npa-helpdesk-requestform.alwaysdata.net";
$username = "npa-helpdesk-requestform_samson";
$password = "Kyrieirving@11";
$database = "npa-helpdesk-requestform_database";
// ─────────────────────────────────────────────────────────────────────────────

$conn = new mysqli($host, $username, $password, $database);
$conn->set_charset("utf8mb4");

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        'status'  => 'error',
        'message' => 'Database connection failed: ' . $conn->connect_error,
    ]));
}
?>
