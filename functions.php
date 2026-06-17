<?php
require_once __DIR__ . '/config.php';

/* ---------- Constants ---------- */
const STUDENT_FIELDS = ['roll','name','email','phone','class','gender','dob','address'];

/* ---------- XML helpers ---------- */
function load_xml($file) {
    return simplexml_load_file($file);
}
function save_xml(SimpleXMLElement $xml, $file) {
    $dom = new DOMDocument('1.0', 'UTF-8');
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->loadXML($xml->asXML());
    return $dom->save($file) !== false;
}
function next_id(SimpleXMLElement $xml, $childName) {
    $max = 0;
    foreach ($xml->{$childName} as $node) {
        $id = (int)$node->id;
        if ($id > $max) $max = $id;
    }
    return $max + 1;
}

/* ---------- Validation ---------- */
function e($s) { return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8'); }
function clean($s) { return trim((string)$s); }
function is_email($s) { return filter_var($s, FILTER_VALIDATE_EMAIL); }

/* ---------- Auth ---------- */
function current_user() {
    return $_SESSION['user'] ?? null;
}
function require_login() {
    if (!current_user()) { header('Location: login.php'); exit; }
}
function require_admin() {
    require_login();
    if (($_SESSION['user']['role'] ?? '') !== 'admin') {
        http_response_code(403); die('Forbidden — admin only.');
    }
}
function login_user($username, $password) {
    $xml = load_xml(USERS_XML);
    foreach ($xml->user as $u) {
        if (strcasecmp((string)$u->username, $username) === 0
            && password_verify($password, (string)$u->password)) {
            $_SESSION['user'] = [
                'id' => (string)$u->id,
                'username' => (string)$u->username,
                'name' => (string)$u->name,
                'role' => (string)$u->role,
            ];
            return true;
        }
    }
    return false;
}
function register_user($name, $username, $email, $password, $role = 'admin') {
    $xml = load_xml(USERS_XML);
    foreach ($xml->user as $u) {
        if (strcasecmp((string)$u->username, $username) === 0) return 'Username already exists.';
        if (strcasecmp((string)$u->email, $email) === 0) return 'Email already used.';
    }
    $id = next_id($xml, 'user');
    $u = $xml->addChild('user');
    $u->addChild('id', $id);
    $u->addChild('name', htmlspecialchars($name));
    $u->addChild('username', htmlspecialchars($username));
    $u->addChild('email', htmlspecialchars($email));
    $u->addChild('password', password_hash($password, PASSWORD_DEFAULT));
    $u->addChild('role', $role);
    $u->addChild('created_at', date('c'));
    save_xml($xml, USERS_XML);
    return true;
}

/* ---------- Students ---------- */
function all_students($search = '') {
    $xml = load_xml(STUDENTS_XML);
    $out = [];
    foreach ($xml->student as $s) {
        $row = [
            'id' => (string)$s->id,
            'roll' => (string)$s->roll,
            'name' => (string)$s->name,
            'email' => (string)$s->email,
            'phone' => (string)$s->phone,
            'class' => (string)$s->class,
            'gender' => (string)$s->gender,
            'dob' => (string)$s->dob,
            'address' => (string)$s->address,
            'photo' => (string)$s->photo,
        ];
        if ($search === '' ||
            stripos($row['name'], $search) !== false ||
            stripos($row['roll'], $search) !== false ||
            stripos($row['email'], $search) !== false ||
            stripos($row['class'], $search) !== false) {
            $out[] = $row;
        }
    }
    return $out;
}
function find_student($id) {
    $xml = load_xml(STUDENTS_XML);
    foreach ($xml->student as $s) if ((string)$s->id === (string)$id) return $s;
    return null;
}
function save_student_photo($fileField) {
    if (!isset($_FILES[$fileField]) || $_FILES[$fileField]['error'] === UPLOAD_ERR_NO_FILE) return '';
    $f = $_FILES[$fileField];
    if ($f['error'] !== UPLOAD_ERR_OK) return '';
    if ($f['size'] > 2 * 1024 * 1024) return ''; // 2MB
    $info = getimagesize($f['tmp_name']);
    if (!$info) return '';
    $allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp', 'image/gif' => 'gif'];
    if (!isset($allowed[$info['mime']])) return '';
    $name = 'stu_' . bin2hex(random_bytes(6)) . '.' . $allowed[$info['mime']];
    $dest = UPLOAD_PATH . '/' . $name;
    if (!move_uploaded_file($f['tmp_name'], $dest)) return '';
    return UPLOAD_URL . '/' . $name;
}
function add_student($data, $photo) {
    $xml = load_xml(STUDENTS_XML);
    $id = next_id($xml, 'student');
    $s = $xml->addChild('student');
    $s->addChild('id', $id);
    foreach (STUDENT_FIELDS as $k) {
        $s->addChild($k, htmlspecialchars($data[$k] ?? ''));
    }
    $s->addChild('photo', htmlspecialchars($photo));
    save_xml($xml, STUDENTS_XML);
    return $id;
}
function update_student($id, $data, $photo = null) {
    $xml = load_xml(STUDENTS_XML);
    foreach ($xml->student as $s) {
        if ((string)$s->id === (string)$id) {
            foreach (STUDENT_FIELDS as $k) {
                $s->{$k} = htmlspecialchars($data[$k] ?? '');
            }
            if ($photo) $s->photo = htmlspecialchars($photo);
            save_xml($xml, STUDENTS_XML);
            return true;
        }
    }
    return false;
}
function delete_student($id) {
    $xml = load_xml(STUDENTS_XML);
    $dom = dom_import_simplexml($xml);
    foreach ($xml->student as $s) {
        if ((string)$s->id === (string)$id) {
            $photo = (string)$s->photo;
            if ($photo && file_exists(BASE_PATH . '/' . $photo)) @unlink(BASE_PATH . '/' . $photo);
            $node = dom_import_simplexml($s);
            $node->parentNode->removeChild($node);
            save_xml($xml, STUDENTS_XML);
            return true;
        }
    }
    return false;
}

/* ---------- Attendance ---------- */
function mark_attendance($student_id, $date, $status) {
    $xml = load_xml(ATTENDANCE_XML);
    foreach ($xml->record as $r) {
        if ((string)$r->student_id === (string)$student_id && (string)$r->date === $date) {
            $r->status = $status; save_xml($xml, ATTENDANCE_XML); return;
        }
    }
    $r = $xml->addChild('record');
    $r->addChild('id', next_id($xml, 'record'));
    $r->addChild('student_id', $student_id);
    $r->addChild('date', $date);
    $r->addChild('status', $status);
    save_xml($xml, ATTENDANCE_XML);
}
function student_attendance($student_id) {
    $xml = load_xml(ATTENDANCE_XML);
    $out = [];
    foreach ($xml->record as $r) {
        if ((string)$r->student_id === (string)$student_id) {
            $out[] = ['date' => (string)$r->date, 'status' => (string)$r->status];
        }
    }
    usort($out, fn($a,$b) => strcmp($b['date'],$a['date']));
    return $out;
}

/* ---------- Marks ---------- */
function add_marks($student_id, $subject, $score, $total) {
    $xml = load_xml(MARKS_XML);
    $m = $xml->addChild('mark');
    $m->addChild('id', next_id($xml, 'mark'));
    $m->addChild('student_id', $student_id);
    $m->addChild('subject', htmlspecialchars($subject));
    $m->addChild('score', (int)$score);
    $m->addChild('total', (int)$total);
    save_xml($xml, MARKS_XML);
}
function student_marks($student_id) {
    $xml = load_xml(MARKS_XML);
    $out = [];
    foreach ($xml->mark as $m) {
        if ((string)$m->student_id === (string)$student_id) {
            $out[] = [
                'id' => (string)$m->id,
                'subject' => (string)$m->subject,
                'score' => (int)$m->score,
                'total' => (int)$m->total,
            ];
        }
    }
    return $out;
}

/* ---------- Shared form/view utilities ---------- */

/**
 * Collect and clean student POST data using STUDENT_FIELDS.
 */
function collect_student_post(): array {
    $data = [];
    foreach (STUDENT_FIELDS as $k) $data[$k] = clean($_POST[$k] ?? '');
    return $data;
}

/**
 * Validate student data. Returns an error string or empty string on success.
 */
function validate_student(array $data): string {
    if (!$data['name'] || !$data['roll'] || !$data['class']) return 'Name, roll, and class are required.';
    if ($data['email'] && !is_email($data['email'])) return 'Invalid email.';
    return '';
}

/**
 * Lookup student by GET id or respond with 404.
 */
function find_student_or_404(): SimpleXMLElement {
    $id = (int)($_GET['id'] ?? 0);
    $node = find_student($id);
    if (!$node) { http_response_code(404); die('Student not found.'); }
    return $node;
}

/**
 * Convert a student XML node to an associative array.
 */
function student_to_array(SimpleXMLElement $node): array {
    $s = [];
    foreach (array_merge(STUDENT_FIELDS, ['photo']) as $k) $s[$k] = (string)$node->{$k};
    return $s;
}

/**
 * Render a student avatar (photo image or placeholder initial).
 */
function render_avatar(array $student, string $size = ''): string {
    $cls = 'avatar' . ($size ? ' ' . e($size) : '');
    if ($student['photo']) {
        return '<img class="' . $cls . '" src="' . e($student['photo']) . '" alt="">';
    }
    return '<span class="' . $cls . ' ph">' . e(strtoupper(substr($student['name'], 0, 1))) . '</span>';
}

/**
 * Render a flash success message if present.
 */
function render_flash(string $key = 'ok'): void {
    $msg = flash($key);
    if ($msg) echo '<div class="alert ok">' . e($msg) . '</div>';
}

/**
 * Render an error alert.
 */
function render_error(string $err): void {
    if ($err) echo '<div class="alert err">' . e($err) . '</div>';
}

/* ---------- View helpers ---------- */
function header_html($title) {
    $u = current_user();
    ?><!doctype html><html lang="en"><head>
    <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title><?= e($title) ?> — <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="style.css">
    </head><body>
    <nav class="nav">
      <a href="<?= $u ? 'dashboard.php' : 'index.php' ?>" class="brand">🎓 Scholar</a>
      <div class="nav-links">
        <?php if ($u): ?>
          <a href="dashboard.php">Dashboard</a>
          <a href="students.php">Students</a>
          <a href="add-student.php">Add</a>
          <span class="who">Hi, <?= e($u['name']) ?></span>
          <a href="logout.php" class="btn btn-ghost">Logout</a>
        <?php else: ?>
          <a href="login.php">Login</a>
          <a href="register.php" class="btn btn-primary">Sign up</a>
        <?php endif; ?>
      </div>
    </nav>
    <main class="container"><?php
}
function footer_html() {
    ?></main><footer class="footer">© <?= date('Y') ?> Scholar SMS</footer></body></html><?php
}
function flash($key, $msg = null) {
    if ($msg !== null) { $_SESSION['flash'][$key] = $msg; return; }
    $m = $_SESSION['flash'][$key] ?? null;
    unset($_SESSION['flash'][$key]);
    return $m;
}
