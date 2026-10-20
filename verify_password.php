<?php
declare(strict_types=1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ── Access password ───────────────────────────────────────────────────────────
// Change this to whatever portal password you want to use.
$correctPassword = 'samson';
// ─────────────────────────────────────────────────────────────────────────────

$password = trim($_POST['password'] ?? '');

if ($password === $correctPassword) {
    echo "success";
} else {
    echo "invalid";
}
?>