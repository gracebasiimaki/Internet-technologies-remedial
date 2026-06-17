<?php

use PHPUnit\Framework\TestCase;

class StudentCrudTest extends TestCase
{
    protected function setUp(): void
    {
        TestHelper::resetState();
    }

    public static function tearDownAfterClass(): void
    {
        TestHelper::cleanup();
    }

    /* ---- helper: insert a student row ---- */
    private function insertStudent(array $overrides = []): int
    {
        $defaults = [
            'roll' => 'R001',
            'name' => 'Alice Doe',
            'email' => 'alice@example.com',
            'phone' => '0700123456',
            'class' => '10-A',
            'gender' => 'Female',
            'dob' => '2008-05-15',
            'address' => '123 Main St',
        ];
        return add_student(array_merge($defaults, $overrides), '');
    }

    /* ---------- add_student ---------- */

    public function testAddStudentReturnsId(): void
    {
        $id = $this->insertStudent();
        $this->assertSame(1, $id);
    }

    public function testAddStudentPersistsToXml(): void
    {
        $this->insertStudent();
        $xml = load_xml(STUDENTS_XML);
        $this->assertCount(1, $xml->student);
        $this->assertSame('Alice Doe', (string) $xml->student[0]->name);
    }

    public function testAddStudentAutoIncrementsId(): void
    {
        $id1 = $this->insertStudent(['roll' => 'R001', 'name' => 'A']);
        $id2 = $this->insertStudent(['roll' => 'R002', 'name' => 'B']);
        $this->assertSame(1, $id1);
        $this->assertSame(2, $id2);
    }

    public function testAddStudentEscapesHtmlInXmlFile(): void
    {
        $this->insertStudent(['name' => '<script>alert(1)</script>']);
        $raw = file_get_contents(STUDENTS_XML);
        $this->assertStringNotContainsString('<script>alert', $raw);
        $this->assertStringContainsString('&lt;script&gt;', $raw);
    }

    public function testAddStudentSavesPhoto(): void
    {
        $data = ['roll' => 'R1', 'name' => 'P', 'email' => '', 'phone' => '',
                 'class' => '1', 'gender' => '', 'dob' => '', 'address' => ''];
        add_student($data, 'uploads/photo.jpg');

        $xml = load_xml(STUDENTS_XML);
        $this->assertSame('uploads/photo.jpg', (string) $xml->student[0]->photo);
    }

    /* ---------- all_students ---------- */

    public function testAllStudentsReturnsEmptyForNoStudents(): void
    {
        $this->assertSame([], all_students());
    }

    public function testAllStudentsReturnsAllRows(): void
    {
        $this->insertStudent(['roll' => 'R001', 'name' => 'Alice']);
        $this->insertStudent(['roll' => 'R002', 'name' => 'Bob']);
        $list = all_students();
        $this->assertCount(2, $list);
    }

    public function testAllStudentsReturnsCorrectFields(): void
    {
        $this->insertStudent();
        $s = all_students()[0];
        $expected = ['id', 'roll', 'name', 'email', 'phone', 'class', 'gender', 'dob', 'address', 'photo'];
        foreach ($expected as $key) {
            $this->assertArrayHasKey($key, $s);
        }
    }

    public function testAllStudentsSearchByName(): void
    {
        $this->insertStudent(['name' => 'Alice Doe', 'email' => 'alice@example.com']);
        $this->insertStudent(['roll' => 'R002', 'name' => 'Bob Smith', 'email' => 'bob@example.com']);
        $results = all_students('Alice');
        $this->assertCount(1, $results);
        $this->assertSame('Alice Doe', $results[0]['name']);
    }

    public function testAllStudentsSearchByRoll(): void
    {
        $this->insertStudent(['roll' => 'R001', 'name' => 'A']);
        $this->insertStudent(['roll' => 'R002', 'name' => 'B']);
        $results = all_students('R002');
        $this->assertCount(1, $results);
        $this->assertSame('B', $results[0]['name']);
    }

    public function testAllStudentsSearchByClass(): void
    {
        $this->insertStudent(['roll' => 'R001', 'name' => 'A', 'class' => '10-A']);
        $this->insertStudent(['roll' => 'R002', 'name' => 'B', 'class' => '11-B']);
        $results = all_students('11-B');
        $this->assertCount(1, $results);
    }

    public function testAllStudentsSearchByEmail(): void
    {
        $this->insertStudent(['roll' => 'R001', 'name' => 'A', 'email' => 'alice@school.com']);
        $this->insertStudent(['roll' => 'R002', 'name' => 'B', 'email' => 'bob@school.com']);
        $results = all_students('bob@school');
        $this->assertCount(1, $results);
    }

    public function testAllStudentsSearchIsCaseInsensitive(): void
    {
        $this->insertStudent(['name' => 'Alice']);
        $results = all_students('alice');
        $this->assertCount(1, $results);
    }

    public function testAllStudentsSearchNoMatch(): void
    {
        $this->insertStudent(['name' => 'Alice']);
        $this->assertSame([], all_students('zzz'));
    }

    /* ---------- find_student ---------- */

    public function testFindStudentReturnsNode(): void
    {
        $id = $this->insertStudent();
        $node = find_student($id);
        $this->assertInstanceOf(SimpleXMLElement::class, $node);
        $this->assertSame('Alice Doe', (string) $node->name);
    }

    public function testFindStudentReturnsNullForMissing(): void
    {
        $this->assertNull(find_student(999));
    }

    public function testFindStudentMatchesStringId(): void
    {
        $id = $this->insertStudent();
        $this->assertNotNull(find_student((string) $id));
    }

    /* ---------- update_student ---------- */

    public function testUpdateStudentChangesFields(): void
    {
        $id = $this->insertStudent();
        $ok = update_student($id, [
            'roll' => 'R999', 'name' => 'Alice Updated',
            'email' => 'new@example.com', 'phone' => '', 'class' => '12-A',
            'gender' => 'Female', 'dob' => '2008-05-15', 'address' => 'New St',
        ]);
        $this->assertTrue($ok);

        $node = find_student($id);
        $this->assertSame('Alice Updated', (string) $node->name);
        $this->assertSame('R999', (string) $node->roll);
    }

    public function testUpdateStudentChangesPhoto(): void
    {
        $id = $this->insertStudent();
        update_student($id, [
            'roll' => 'R001', 'name' => 'Alice', 'email' => '', 'phone' => '',
            'class' => '10-A', 'gender' => '', 'dob' => '', 'address' => '',
        ], 'uploads/new_photo.png');

        $node = find_student($id);
        $this->assertSame('uploads/new_photo.png', (string) $node->photo);
    }

    public function testUpdateStudentReturnsFalseForMissing(): void
    {
        $this->assertFalse(update_student(999, [
            'roll' => 'R1', 'name' => 'X', 'email' => '', 'phone' => '',
            'class' => '1', 'gender' => '', 'dob' => '', 'address' => '',
        ]));
    }

    public function testUpdateStudentKeepsPhotoWhenNull(): void
    {
        $data = ['roll' => 'R1', 'name' => 'P', 'email' => '', 'phone' => '',
                 'class' => '1', 'gender' => '', 'dob' => '', 'address' => ''];
        $id = add_student($data, 'uploads/old.jpg');
        update_student($id, $data, null);

        $node = find_student($id);
        $this->assertSame('uploads/old.jpg', (string) $node->photo);
    }

    /* ---------- delete_student ---------- */

    public function testDeleteStudentRemovesFromXml(): void
    {
        $id = $this->insertStudent();
        $ok = delete_student($id);
        $this->assertTrue($ok);
        $this->assertNull(find_student($id));
        $this->assertSame([], all_students());
    }

    public function testDeleteStudentReturnsFalseForMissing(): void
    {
        $this->assertFalse(delete_student(999));
    }

    public function testDeleteStudentOnlyDeletesTarget(): void
    {
        $id1 = $this->insertStudent(['roll' => 'R001', 'name' => 'Alice']);
        $id2 = $this->insertStudent(['roll' => 'R002', 'name' => 'Bob']);
        delete_student($id1);
        $this->assertNull(find_student($id1));
        $this->assertNotNull(find_student($id2));
        $this->assertCount(1, all_students());
    }
}
