<?php
require_once __DIR__ . '/functions.php';
require_login();
$id = (int)($_GET['id'] ?? 0);
if ($id && delete_student($id)) flash('ok','Student deleted.');
header('Location: students.php');
exit;
