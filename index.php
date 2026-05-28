<?php
require_once __DIR__ . '/functions.php';
if (current_user()) { header('Location: dashboard.php'); exit; }
header_html('Welcome');
?>
<section class="hero">
  <div class="hero-text">
    <span class="pill">Student Management, simplified</span>
    <h1>Run your school with <span class="grad">clarity & calm</span>.</h1>
    <p>Manage students, attendance, marks and profiles — all stored as portable XML. No database, no fuss.</p>
    <div class="hero-cta">
      <a class="btn btn-primary" href="register.php">Get started — it's free</a>
      <a class="btn btn-ghost" href="login.php">I already have an account</a>
    </div>
  </div>
  <div class="hero-card">
    <div class="mini-card">
      <h4>Today</h4>
      <p class="big"><?= count(all_students()) ?></p>
      <span class="muted">Students enrolled</span>
    </div>
    <div class="mini-card alt">
      <h4>Photos, marks & attendance</h4>
      <p>Everything lives in clean XML files you can back up by copying a folder.</p>
    </div>
  </div>
</section>
<section class="features">
  <div class="feature"><h3>📇 Profiles</h3><p>Rich student profiles with photo uploads.</p></div>
  <div class="feature"><h3>✅ Attendance</h3><p>One-click daily attendance marking.</p></div>
  <div class="feature"><h3>📊 Marks</h3><p>Track subject-wise scores per student.</p></div>
  <div class="feature"><h3>🔐 Secure</h3><p>Hashed passwords & session-based auth.</p></div>
</section>
<?php footer_html(); ?>
