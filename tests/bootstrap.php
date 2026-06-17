<?php
/**
 * Test bootstrap — sets up an isolated environment so that unit tests
 * never touch the real XML data files.
 *
 * Each test class should call TestHelper::setUp() in its setUp() method
 * and TestHelper::tearDown() in its tearDown() method.
 */

// Start session before anything else (config.php will skip if already started)
session_start();

// Override the XML / upload paths *before* loading config.php so the
// constants point to a temporary sandbox.
define('TEST_TMP_DIR', sys_get_temp_dir() . '/scholar_tests_' . getmypid());

// We cannot redefine constants after config.php defines them, so we load
// config.php with a controlled environment.  The trick: define the constants
// first, then config.php's define() calls are silently ignored (constants
// already exist).
define('BASE_PATH', TEST_TMP_DIR);
define('XML_PATH', TEST_TMP_DIR . '/xml');
define('UPLOAD_PATH', TEST_TMP_DIR . '/uploads');
define('UPLOAD_URL', 'uploads');
define('USERS_XML', XML_PATH . '/users.xml');
define('STUDENTS_XML', XML_PATH . '/students.xml');
define('ATTENDANCE_XML', XML_PATH . '/attendance.xml');
define('MARKS_XML', XML_PATH . '/marks.xml');
define('APP_NAME', 'Scholar — Student Management');

// Create dirs
if (!is_dir(XML_PATH))    mkdir(XML_PATH, 0777, true);
if (!is_dir(UPLOAD_PATH)) mkdir(UPLOAD_PATH, 0777, true);

// Seed empty XML files
function _seed_xml(string $file, string $root): void {
    $xml = new SimpleXMLElement("<?xml version=\"1.0\" encoding=\"UTF-8\"?><{$root}/>");
    $xml->asXML($file);
}
_seed_xml(USERS_XML, 'users');
_seed_xml(STUDENTS_XML, 'students');
_seed_xml(ATTENDANCE_XML, 'attendance');
_seed_xml(MARKS_XML, 'marks');

// Now load the main functions file (config.php will be required inside it,
// but its define()/mkdir calls are no-ops because we already did them).
require_once __DIR__ . '/../functions.php';

/**
 * Shared helpers for tests.
 */
class TestHelper
{
    /** Re-seed all XML files to empty state and clear session. */
    public static function resetState(): void
    {
        if (!is_dir(XML_PATH))    mkdir(XML_PATH, 0777, true);
        if (!is_dir(UPLOAD_PATH)) mkdir(UPLOAD_PATH, 0777, true);
        _seed_xml(USERS_XML, 'users');
        _seed_xml(STUDENTS_XML, 'students');
        _seed_xml(ATTENDANCE_XML, 'attendance');
        _seed_xml(MARKS_XML, 'marks');
        $_SESSION = [];
    }

    /** Remove temp directory tree. */
    public static function cleanup(): void
    {
        self::rmdir_recursive(TEST_TMP_DIR);
    }

    private static function rmdir_recursive(string $dir): void
    {
        if (!is_dir($dir)) return;
        foreach (scandir($dir) as $item) {
            if ($item === '.' || $item === '..') continue;
            $path = $dir . '/' . $item;
            is_dir($path) ? self::rmdir_recursive($path) : unlink($path);
        }
        rmdir($dir);
    }
}
