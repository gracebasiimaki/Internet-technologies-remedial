<?php

use PHPUnit\Framework\TestCase;

class MarksTest extends TestCase
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

    /* ---------- add_marks ---------- */

    public function testAddMarksCreatesRecord(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Mathematics', 85, 100);

        $xml = load_xml(MARKS_XML);
        $this->assertCount(1, $xml->mark);
        $this->assertSame((string) $sid, (string) $xml->mark[0]->student_id);
        $this->assertSame('Mathematics', (string) $xml->mark[0]->subject);
        $this->assertSame('85', (string) $xml->mark[0]->score);
        $this->assertSame('100', (string) $xml->mark[0]->total);
    }

    public function testAddMarksAutoIncrementsId(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Math', 80, 100);
        add_marks($sid, 'Science', 90, 100);

        $xml = load_xml(MARKS_XML);
        $this->assertSame('1', (string) $xml->mark[0]->id);
        $this->assertSame('2', (string) $xml->mark[1]->id);
    }

    public function testAddMarksEscapesSubject(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Art & Design', 70, 100);

        $xml = load_xml(MARKS_XML);
        $subject = (string) $xml->mark[0]->subject;
        $this->assertStringContainsString('Art', $subject);
    }

    public function testAddMarksMultipleStudents(): void
    {
        $sid1 = $this->addTestStudent();
        $sid2 = add_student([
            'roll' => 'R002', 'name' => 'Other', 'email' => '', 'phone' => '',
            'class' => '10-B', 'gender' => '', 'dob' => '', 'address' => '',
        ], '');

        add_marks($sid1, 'Math', 80, 100);
        add_marks($sid2, 'Math', 90, 100);

        $xml = load_xml(MARKS_XML);
        $this->assertCount(2, $xml->mark);
    }

    public function testAddMarksCastsScoreToInt(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Math', '85', '100');

        $xml = load_xml(MARKS_XML);
        $this->assertSame('85', (string) $xml->mark[0]->score);
        $this->assertSame('100', (string) $xml->mark[0]->total);
    }

    /* ---------- student_marks ---------- */

    public function testStudentMarksReturnsEmptyForNoRecords(): void
    {
        $sid = $this->addTestStudent();
        $this->assertSame([], student_marks($sid));
    }

    public function testStudentMarksReturnsRecords(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Math', 80, 100);
        add_marks($sid, 'Science', 90, 100);

        $marks = student_marks($sid);
        $this->assertCount(2, $marks);
    }

    public function testStudentMarksReturnsCorrectFields(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'English', 75, 100);

        $marks = student_marks($sid);
        $m = $marks[0];
        $this->assertArrayHasKey('id', $m);
        $this->assertArrayHasKey('subject', $m);
        $this->assertArrayHasKey('score', $m);
        $this->assertArrayHasKey('total', $m);
        $this->assertSame('English', $m['subject']);
        $this->assertSame(75, $m['score']);
        $this->assertSame(100, $m['total']);
    }

    public function testStudentMarksFiltersToCorrectStudent(): void
    {
        $sid1 = $this->addTestStudent();
        $sid2 = add_student([
            'roll' => 'R002', 'name' => 'Other', 'email' => '', 'phone' => '',
            'class' => '10-B', 'gender' => '', 'dob' => '', 'address' => '',
        ], '');

        add_marks($sid1, 'Math', 80, 100);
        add_marks($sid2, 'Math', 90, 100);

        $marks = student_marks($sid1);
        $this->assertCount(1, $marks);
        $this->assertSame(80, $marks[0]['score']);
    }

    public function testStudentMarksReturnsIntegerValues(): void
    {
        $sid = $this->addTestStudent();
        add_marks($sid, 'Physics', 42, 50);

        $marks = student_marks($sid);
        $this->assertIsInt($marks[0]['score']);
        $this->assertIsInt($marks[0]['total']);
    }
}
