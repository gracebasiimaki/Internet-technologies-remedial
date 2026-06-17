<?php
require_once __DIR__ . '/functions.php';
require_login();
$id = (int)($_GET['id'] ?? 0);
if (!$id) {
    flash('err', 'Invalid student ID.');
} elseif (delete_student($id)) {
    flash('ok', 'Student deleted.');
} else {
    flash('err', 'Student not found or could not be deleted.');
}
header('Location: students.php');
exit;
