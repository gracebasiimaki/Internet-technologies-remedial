<?php
require_once __DIR__ . '/functions.php';
require_login();
$students = all_students();
$att = load_xml(ATTENDANCE_XML);
$marks = load_xml(MARKS_XML);
$today = date('Y-m-d');
$presentToday = 0;
foreach ($att->record as $r) if ((string)$r->date === $today && (string)$r->status === 'present') $presentToday++;
header_html('Dashboard');
?>
<h1 class="page-title">Dashboard</h1>
<p class="muted">A quick look at your school.</p>
<div class="stats">
  <div class="stat"><span>Total students</span><strong><?= count($students) ?></strong></div>
  <div class="stat"><span>Present today</span><strong><?= $presentToday ?></strong></div>
  <div class="stat"><span>Marks entries</span><strong><?= count($marks->mark) ?></strong></div>
  <div class="stat"><span>Date</span><strong><?= date('M j') ?></strong></div>
</div>

<div class="grid-2">
  <div class="card">
    <div class="card-head"><h3>Recent students</h3><a href="students.php">View all →</a></div>
    <table class="table">
      <thead><tr><th></th><th>Roll</th><th>Name</th><th>Class</th></tr></thead>
      <tbody>
      <?php foreach (array_slice(array_reverse($students), 0, 6) as $s): ?>
        <tr>
          <td><?= render_avatar($s) ?></td>
          <td><?= e($s['roll']) ?></td>
          <td><a href="view-student.php?id=<?= e($s['id']) ?>"><?= e($s['name']) ?></a></td>
          <td><?= e($s['class']) ?></td>
        </tr>
      <?php endforeach; if (!$students): ?>
        <tr><td colspan="4" class="muted center">No students yet — <a href="add-student.php">add your first</a>.</td></tr>
      <?php endif; ?>
      </tbody>
    </table>
  </div>
  <div class="card alt">
    <h3>Quick actions</h3>
    <div class="actions">
      <a class="btn btn-primary" href="add-student.php">+ Add student</a>
      <a class="btn btn-ghost" href="students.php">Manage students</a>
    </div>
    <hr>
    <h4>Tip</h4>
    <p class="muted">Open a student profile to mark attendance and record marks.</p>
  </div>
</div>
<?php footer_html(); ?>
