<?php

use PHPUnit\Framework\TestCase;

class ValidationTest extends TestCase
{
    /* ---------- e() — HTML escaping ---------- */

    public function testEscapesHtmlEntities(): void
    {
        $this->assertSame('&lt;b&gt;hi&lt;/b&gt;', e('<b>hi</b>'));
    }

    public function testEscapesQuotes(): void
    {
        $this->assertSame('a &amp; &quot;b&quot; &#039;c&#039;', e('a & "b" \'c\''));
    }

    public function testEscapesEmptyString(): void
    {
        $this->assertSame('', e(''));
    }

    public function testEscapesNonStringInput(): void
    {
        $this->assertSame('42', e(42));
    }

    /* ---------- clean() ---------- */

    public function testCleanTrimsWhitespace(): void
    {
        $this->assertSame('hello', clean('  hello  '));
    }

    public function testCleanTrimsTabsAndNewlines(): void
    {
        $this->assertSame('world', clean("\t\nworld\r\n"));
    }

    public function testCleanReturnsEmptyStringForBlank(): void
    {
        $this->assertSame('', clean('   '));
    }

    public function testCleanCastsNonString(): void
    {
        $this->assertSame('0', clean(0));
    }

    /* ---------- is_email() ---------- */

    public function testIsEmailValid(): void
    {
        $this->assertNotFalse(is_email('user@example.com'));
    }

    public function testIsEmailWithSubdomain(): void
    {
        $this->assertNotFalse(is_email('a.b@sub.example.co.uk'));
    }

    public function testIsEmailInvalid(): void
    {
        $this->assertFalse(is_email('not-an-email'));
    }

    public function testIsEmailEmpty(): void
    {
        $this->assertFalse(is_email(''));
    }

    public function testIsEmailMissingDomain(): void
    {
        $this->assertFalse(is_email('user@'));
    }

    public function testIsEmailMissingAt(): void
    {
        $this->assertFalse(is_email('user.example.com'));
    }
}
