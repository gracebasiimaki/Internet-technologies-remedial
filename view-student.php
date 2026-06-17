<?php
require_once __DIR__ . '/functions.php';
require_login();
$id = (int)($_GET['id'] ?? 0);
$node = find_student($id);
if (!$node) { http_response_code(404); die('Student not found.'); }

// Handle attendance / marks posts
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    if (($_POST['action'] ?? '') === 'attendance') {
        $date = clean($_POST['date'] ?? date('Y-m-d'));
        $status = in_array($_POST['status'] ?? '', ['present','absent','late']) ? $_POST['status'] : 'present';
        mark_attendance($id, $date, $status);
        flash('ok','Attendance saved.');
        header('Location: view-student.php?id=' . $id); exit;
    }
    if (($_POST['action'] ?? '') === 'marks') {
        $subject = clean($_POST['subject'] ?? '');
        $score = (int)($_POST['score'] ?? 0);
        $total = max(1, (int)($_POST['total'] ?? 100));
        if ($subject) add_marks($id, $subject, $score, $total);
        flash('ok','Marks added.');
        header('Location: view-student.php?id=' . $id); exit;
    }
}

$s = [];
foreach (['roll','name','email','phone','class','gender','dob','address','photo'] as $k) $s[$k] = (string)$node->{$k};
$att = student_attendance($id);
$marks = student_marks($id);
$avg = 0; $tot = 0;
foreach ($marks as $m) { $avg += $m['score']; $tot += $m['total']; }
$pct = $tot ? round($avg * 100 / $tot, 1) : null;

header_html($s['name']);
?>
<?php if($msg = flash('ok')): ?><div class="alert ok"><?= e($msg) ?></div><?php endif; ?>
<div class="profile">
  <div class="profile-head card">
    <?php if($s['photo']): ?><img class="avatar xl" src="<?= e($s['photo']) ?>" alt=""><?php else: ?><span class="avatar xl ph"><?= e(strtoupper(substr($s['name'],0,1))) ?></span><?php endif; ?>
    <div>
      <h1><?= e($s['name']) ?></h1>
      <p class="muted">Roll <?= e($s['roll']) ?> · Class <?= e($s['class']) ?></p>
      <div class="chips">
        <?php if($s['email']): ?><span class="chip">✉ <?= e($s['email']) ?></span><?php endif; ?>
        <?php if($s['phone']): ?><span class="chip">📞 <?= e($s['phone']) ?></span><?php endif; ?>
        <?php if($s['gender']): ?><span class="chip"><?= e($s['gender']) ?></span><?php endif; ?>
        <?php if($s['dob']): ?><span class="chip">🎂 <?= e($s['dob']) ?></span><?php endif; ?>
      </div>
      <div class="actions">
        <a class="btn btn-ghost" href="edit-student.php?id=<?= e($id) ?>">Edit</a>
        <form method="post" action="delete-student.php" style="display:inline" onsubmit="return confirm('Delete?')">
          <?= csrf_field() ?>
          <input type="hidden" name="id" value="<?= e($id) ?>">
          <button type="submit" class="btn btn-tiny danger">Delete</button>
        </form>
      </div>
    </div>
  </div>

  <?php if($s['address']): ?>
  <div class="card"><h3>Address</h3><p><?= nl2br(e($s['address'])) ?></p></div>
  <?php endif; ?>

  <div class="grid-2">
    <div class="card">
      <h3>Attendance</h3>
      <form method="post" class="inline-form">
        <?= csrf_field() ?>
        <input type="hidden" name="action" value="attendance">
        <input type="date" name="date" value="<?= date('Y-m-d') ?>" required>
        <select name="status"><option value="present">Present</option><option value="absent">Absent</option><option value="late">Late</option></select>
        <button class="btn btn-primary">Mark</button>
      </form>
      <table class="table mini">
        <thead><tr><th>Date</th><th>Status</th></tr></thead>
        <tbody>
        <?php foreach (array_slice($att,0,12) as $r): ?>
          <tr><td><?= e($r['date']) ?></td><td><span class="badge <?= e($r['status']) ?>"><?= e($r['status']) ?></span></td></tr>
        <?php endforeach; if(!$att): ?><tr><td colspan="2" class="muted center">No records yet.</td></tr><?php endif; ?>
        </tbody>
      </table>
    </div>

    <div class="card">
      <h3>Marks <?php if($pct!==null): ?><span class="muted small">avg <?= e($pct) ?>%</span><?php endif; ?></h3>
      <form method="post" class="inline-form">
        <?= csrf_field() ?>
        <input type="hidden" name="action" value="marks">
        <input name="subject" placeholder="Subject" required>
        <input type="number" name="score" placeholder="Score" min="0" required>
        <input type="number" name="total" placeholder="Total" min="1" value="100" required>
        <button class="btn btn-primary">Add</button>
      </form>
      <table class="table mini">
        <thead><tr><th>Subject</th><th>Score</th><th>%</th></tr></thead>
        <tbody>
        <?php foreach ($marks as $m): ?>
          <tr><td><?= e($m['subject']) ?></td><td><?= e($m['score']) ?>/<?= e($m['total']) ?></td><td><?= e(round($m['score']*100/$m['total'],1)) ?>%</td></tr>
        <?php endforeach; if(!$marks): ?><tr><td colspan="3" class="muted center">No marks yet.</td></tr><?php endif; ?>
        </tbody>
      </table>
    </div>
  </div>
</div>
<?php footer_html(); ?>
