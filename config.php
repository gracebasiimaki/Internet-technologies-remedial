<?php
// config.php — global configuration & session bootstrap
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

define('BASE_PATH', __DIR__);
define('XML_PATH', BASE_PATH . '/xml');
define('UPLOAD_PATH', BASE_PATH . '/uploads');
define('UPLOAD_URL', 'uploads');

define('USERS_XML',      XML_PATH . '/users.xml');
define('STUDENTS_XML',   XML_PATH . '/students.xml');
define('ATTENDANCE_XML', XML_PATH . '/attendance.xml');
define('MARKS_XML',      XML_PATH . '/marks.xml');

define('APP_NAME', 'Scholar — Student Management');

// Ensure folders & XML files exist on first run
if (!is_dir(XML_PATH))    mkdir(XML_PATH, 0777, true);
if (!is_dir(UPLOAD_PATH)) mkdir(UPLOAD_PATH, 0777, true);

function init_xml($file, $root) {
    if (!file_exists($file)) {
        $xml = new SimpleXMLElement("<?xml version=\"1.0\" encoding=\"UTF-8\"?><{$root}/>");
        $xml->asXML($file);
    }
}
init_xml(USERS_XML,      'users');
init_xml(STUDENTS_XML,   'students');
init_xml(ATTENDANCE_XML, 'attendance');
init_xml(MARKS_XML,      'marks');
