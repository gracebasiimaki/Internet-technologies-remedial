<?php
require_once __DIR__ . '/functions.php';
$err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $name = clean($_POST['name'] ?? '');
    $username = clean($_POST['username'] ?? '');
    $email = clean($_POST['email'] ?? '');
    $pass = (string)($_POST['password'] ?? '');
    $pass2 = (string)($_POST['password2'] ?? '');
    if (!$name || !$username || !$email || !$pass) $err = 'Please fill all fields.';
    elseif (!is_email($email)) $err = 'Invalid email.';
    elseif (strlen($pass) < 6) $err = 'Password must be at least 6 characters.';
    elseif ($pass !== $pass2) $err = 'Passwords do not match.';
    else {
        $r = register_user($name, $username, $email, $pass, 'admin');
        if ($r === true) { flash('ok','Account created. Please sign in.'); header('Location: login.php'); exit; }
        else $err = $r;
    }
}
header_html('Register');
?>
<div class="auth-wrap">
  <form class="card auth" method="post" novalidate>
    <?= csrf_field() ?>
    <h2>Create your admin account</h2>
    <p class="muted">First user can register freely. Use a strong password.</p>
    <?php if($err): ?><div class="alert err"><?= e($err) ?></div><?php endif; ?>
    <label>Full name<input name="name" required></label>
    <label>Username<input name="username" required></label>
    <label>Email<input type="email" name="email" required></label>
    <label>Password<input type="password" name="password" required minlength="6"></label>
    <label>Confirm password<input type="password" name="password2" required></label>
    <button class="btn btn-primary" type="submit">Create account</button>
    <p class="muted center">Already registered? <a href="login.php">Sign in</a></p>
  </form>
</div>
<?php footer_html(); ?>
