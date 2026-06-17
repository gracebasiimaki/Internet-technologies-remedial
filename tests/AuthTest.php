<?php

use PHPUnit\Framework\TestCase;

class AuthTest extends TestCase
{
    protected function setUp(): void
    {
        TestHelper::resetState();
    }

    public static function tearDownAfterClass(): void
    {
        TestHelper::cleanup();
    }

    /* ---------- current_user ---------- */

    public function testCurrentUserReturnsNullWhenNotLoggedIn(): void
    {
        $this->assertNull(current_user());
    }

    public function testCurrentUserReturnsSessionData(): void
    {
        $_SESSION['user'] = ['id' => '1', 'username' => 'admin', 'name' => 'Admin', 'role' => 'admin'];
        $user = current_user();
        $this->assertSame('admin', $user['username']);
    }

    /* ---------- register_user ---------- */

    public function testRegisterUserCreatesNewUser(): void
    {
        $result = register_user('Grace B', 'grace', 'grace@example.com', 'secret123');
        $this->assertTrue($result);

        $xml = load_xml(USERS_XML);
        $this->assertCount(1, $xml->user);
        $this->assertSame('grace', (string) $xml->user[0]->username);
        $this->assertSame('grace@example.com', (string) $xml->user[0]->email);
        $this->assertSame('admin', (string) $xml->user[0]->role);
    }

    public function testRegisterUserHashesPassword(): void
    {
        register_user('Test User', 'testuser', 'test@example.com', 'mypassword');

        $xml = load_xml(USERS_XML);
        $hash = (string) $xml->user[0]->password;
        $this->assertNotSame('mypassword', $hash);
        $this->assertTrue(password_verify('mypassword', $hash));
    }

    public function testRegisterUserAutoIncrementsId(): void
    {
        register_user('User One', 'user1', 'u1@example.com', 'pass1');
        register_user('User Two', 'user2', 'u2@example.com', 'pass2');

        $xml = load_xml(USERS_XML);
        $this->assertSame('1', (string) $xml->user[0]->id);
        $this->assertSame('2', (string) $xml->user[1]->id);
    }

    public function testRegisterUserRejectsDuplicateUsername(): void
    {
        register_user('User One', 'grace', 'g1@example.com', 'pass1');
        $result = register_user('User Two', 'grace', 'g2@example.com', 'pass2');
        $this->assertSame('Username already exists.', $result);
    }

    public function testRegisterUserRejectsDuplicateUsernameCaseInsensitive(): void
    {
        register_user('User One', 'Grace', 'g1@example.com', 'pass1');
        $result = register_user('User Two', 'grace', 'g2@example.com', 'pass2');
        $this->assertSame('Username already exists.', $result);
    }

    public function testRegisterUserRejectsDuplicateEmail(): void
    {
        register_user('User One', 'user1', 'same@example.com', 'pass1');
        $result = register_user('User Two', 'user2', 'same@example.com', 'pass2');
        $this->assertSame('Email already used.', $result);
    }

    public function testRegisterUserSetsCreatedAt(): void
    {
        register_user('Timestamped', 'ts', 'ts@example.com', 'pass');
        $xml = load_xml(USERS_XML);
        $this->assertNotEmpty((string) $xml->user[0]->created_at);
    }

    /* ---------- login_user ---------- */

    public function testLoginUserSucceeds(): void
    {
        register_user('Admin', 'admin', 'admin@example.com', 'password123');
        $result = login_user('admin', 'password123');
        $this->assertTrue($result);

        $user = current_user();
        $this->assertSame('admin', $user['username']);
        $this->assertSame('Admin', $user['name']);
        $this->assertSame('admin', $user['role']);
    }

    public function testLoginUserIsCaseInsensitive(): void
    {
        register_user('Admin', 'Admin', 'admin@example.com', 'password123');
        $this->assertTrue(login_user('admin', 'password123'));
    }

    public function testLoginUserFailsWithWrongPassword(): void
    {
        register_user('Admin', 'admin', 'admin@example.com', 'password123');
        $this->assertFalse(login_user('admin', 'wrong'));
    }

    public function testLoginUserFailsWithNonexistentUser(): void
    {
        $this->assertFalse(login_user('nobody', 'password'));
    }

    /* ---------- flash ---------- */

    public function testFlashSetAndGet(): void
    {
        flash('ok', 'Account created.');
        $msg = flash('ok');
        $this->assertSame('Account created.', $msg);
    }

    public function testFlashIsConsumedAfterRead(): void
    {
        flash('ok', 'Hello');
        flash('ok'); // consume
        $this->assertNull(flash('ok'));
    }

    public function testFlashReturnsNullIfNotSet(): void
    {
        $this->assertNull(flash('missing'));
    }
}
