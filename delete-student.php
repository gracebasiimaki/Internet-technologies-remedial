<?php
require_once __DIR__ . '/functions.php';
require_login();
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); die('Method not allowed.'); }
verify_csrf();
$id = (int)($_POST['id'] ?? 0);
if ($id && delete_student($id)) flash('ok','Student deleted.');
header('Location: students.php');
exit;
