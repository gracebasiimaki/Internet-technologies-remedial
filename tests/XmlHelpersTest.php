<?php

use PHPUnit\Framework\TestCase;

class XmlHelpersTest extends TestCase
{
    protected function setUp(): void
    {
        TestHelper::resetState();
    }

    public static function tearDownAfterClass(): void
    {
        TestHelper::cleanup();
    }

    /* ---------- load_xml ---------- */

    public function testLoadXmlReturnsSimpleXmlElement(): void
    {
        $xml = load_xml(USERS_XML);
        $this->assertInstanceOf(SimpleXMLElement::class, $xml);
    }

    public function testLoadXmlPreservesRootName(): void
    {
        $xml = load_xml(STUDENTS_XML);
        $this->assertSame('students', $xml->getName());
    }

    /* ---------- save_xml ---------- */

    public function testSaveXmlWritesFileAndFormatsOutput(): void
    {
        $xml = load_xml(STUDENTS_XML);
        $s = $xml->addChild('student');
        $s->addChild('id', '1');
        $s->addChild('name', 'Alice');

        $result = save_xml($xml, STUDENTS_XML);
        $this->assertTrue($result);

        $raw = file_get_contents(STUDENTS_XML);
        $this->assertStringContainsString('<name>Alice</name>', $raw);
        $this->assertStringContainsString('<?xml version="1.0" encoding="UTF-8"?>', $raw);
    }

    public function testSaveXmlRoundTrip(): void
    {
        $xml = load_xml(MARKS_XML);
        $m = $xml->addChild('mark');
        $m->addChild('id', '1');
        $m->addChild('subject', 'Math');
        save_xml($xml, MARKS_XML);

        $reloaded = load_xml(MARKS_XML);
        $this->assertSame('Math', (string) $reloaded->mark[0]->subject);
    }

    /* ---------- next_id ---------- */

    public function testNextIdReturnsOneForEmptyXml(): void
    {
        $xml = load_xml(STUDENTS_XML);
        $this->assertSame(1, next_id($xml, 'student'));
    }

    public function testNextIdReturnsMaxPlusOne(): void
    {
        $xml = load_xml(STUDENTS_XML);
        foreach ([3, 7, 5] as $id) {
            $s = $xml->addChild('student');
            $s->addChild('id', $id);
        }
        save_xml($xml, STUDENTS_XML);

        $xml = load_xml(STUDENTS_XML);
        $this->assertSame(8, next_id($xml, 'student'));
    }

    public function testNextIdIgnoresUnrelatedChildren(): void
    {
        $xml = load_xml(USERS_XML);
        $u = $xml->addChild('user');
        $u->addChild('id', '10');
        save_xml($xml, USERS_XML);

        $xml = load_xml(USERS_XML);
        // asking for 'other' child returns 1 since there are no 'other' nodes
        $this->assertSame(1, next_id($xml, 'other'));
    }
}
