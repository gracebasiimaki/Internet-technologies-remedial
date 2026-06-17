<?php
require_once __DIR__ . '/functions.php';
$err = '';
$ok = flash('ok');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $u = clean($_POST['username'] ?? '');
    $p = (string)($_POST['password'] ?? '');
    if (login_user($u, $p)) { header('Location: dashboard.php'); exit; }
    $err = 'Invalid credentials.';
}
header_html('Login');
?>
<div class="auth-wrap">
  <form class="card auth" method="post">
    <?= csrf_field() ?>
    <h2>Welcome back</h2>
    <?php if($ok): ?><div class="alert ok"><?= e($ok) ?></div><?php endif; ?>
    <?php if($err): ?><div class="alert err"><?= e($err) ?></div><?php endif; ?>
    <label>Username<input name="username" required autofocus></label>
    <label>Password<input type="password" name="password" required></label>
    <button class="btn btn-primary" type="submit">Sign in</button>
    <p class="muted center">New here? <a href="register.php">Create an account</a></p>
  </form>
</div>
<?php footer_html(); ?>
