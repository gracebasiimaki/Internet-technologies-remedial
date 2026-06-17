<?php

use PHPUnit\Framework\TestCase;

class AttendanceTest extends TestCase
{
    protected function setUp(): void
    {
        TestHelper::resetState();
    }

    public static function tearDownAfterClass(): void
    {
        TestHelper::cleanup();
    }

    private function addTestStudent(): int
    {
        return add_student([
            'roll' => 'R001', 'name' => 'Test', 'email' => '', 'phone' => '',
            'class' => '10-A', 'gender' => '', 'dob' => '', 'address' => '',
        ], '');
    }

    /* ---------- mark_attendance ---------- */

    public function testMarkAttendanceCreatesRecord(): void
    {
        $sid = $this->addTestStudent();
        mark_attendance($sid, '2025-06-15', 'present');

        $xml = load_xml(ATTENDANCE_XML);
        $this->assertCount(1, $xml->record);
        $this->assertSame((string) $sid, (string) $xml->record[0]->student_id);
        $this->assertSame('2025-06-15', (string) $xml->record[0]->date);
        $this->assertSame('present', (string) $xml->record[0]->status);
    }

    public function testMarkAttendanceUpdatesExistingRecord(): void
    {
        $sid = $this->addTestStudent();
        mark_attendance($sid, '2025-06-15', 'present');
        mark_attendance($sid, '2025-06-15', 'absent');

        $xml = load_xml(ATTENDANCE_XML);
        $this->assertCount(1, $xml->record);
        $this->assertSame('absent', (string) $xml->record[0]->status);
    }

    public function testMarkAttendanceMultipleDates(): void
    {
        $sid = $this->addTestStudent();
        mark_attendance($sid, '2025-06-15', 'present');
        mark_attendance($sid, '2025-06-16', 'late');

        $xml = load_xml(ATTENDANCE_XML);
        $this->assertCount(2, $xml->record);
    }

    public function testMarkAttendanceMultipleStudents(): void
    {
        $sid1 = $this->addTestStudent();
        $sid2 = add_student([
            'roll' => 'R002', 'name' => 'Student2', 'email' => '', 'phone' => '',
            'class' => '10-B', 'gender' => '', 'dob' => '', 'address' => '',
        ], '');

        mark_attendance($sid1, '2025-06-15', 'present');
        mark_attendance($sid2, '2025-06-15', 'absent');

        $xml = load_xml(ATTENDANCE_XML);
        $this->assertCount(2, $xml->record);
    }

    /* ---------- student_attendance ---------- */

    public function testStudentAttendanceReturnsEmptyForNoRecords(): void
    {
        $sid = $this->addTestStudent();
        $this->assertSame([], student_attendance($sid));
    }

    public function testStudentAttendanceReturnsRecords(): void
    {
        $sid = $this->addTestStudent();
        mark_attendance($sid, '2025-06-15', 'present');
        mark_attendance($sid, '2025-06-16', 'absent');

        $records = student_attendance($sid);
        $this->assertCount(2, $records);
        $this->assertArrayHasKey('date', $records[0]);
        $this->assertArrayHasKey('status', $records[0]);
    }

    public function testStudentAttendanceSortsMostRecentFirst(): void
    {
        $sid = $this->addTestStudent();
        mark_attendance($sid, '2025-06-10', 'present');
        mark_attendance($sid, '2025-06-15', 'absent');
        mark_attendance($sid, '2025-06-12', 'late');

        $records = student_attendance($sid);
        $this->assertSame('2025-06-15', $records[0]['date']);
        $this->assertSame('2025-06-12', $records[1]['date']);
        $this->assertSame('2025-06-10', $records[2]['date']);
    }

    public function testStudentAttendanceFiltersToCorrectStudent(): void
    {
        $sid1 = $this->addTestStudent();
        $sid2 = add_student([
            'roll' => 'R002', 'name' => 'Other', 'email' => '', 'phone' => '',
            'class' => '10-B', 'gender' => '', 'dob' => '', 'address' => '',
        ], '');

        mark_attendance($sid1, '2025-06-15', 'present');
        mark_attendance($sid2, '2025-06-15', 'absent');

        $records = student_attendance($sid1);
        $this->assertCount(1, $records);
        $this->assertSame('present', $records[0]['status']);
    }
}
