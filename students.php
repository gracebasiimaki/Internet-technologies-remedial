<?php
require_once __DIR__ . '/functions.php';
require_login();
$q = clean($_GET['q'] ?? '');
$list = all_students($q);
header_html('Students');
?>
<div class="page-head">
  <div><h1 class="page-title">Students</h1><p class="muted"><?= count($list) ?> result<?= count($list)===1?'':'s' ?></p></div>
  <a class="btn btn-primary" href="add-student.php">+ Add student</a>
</div>
<form class="searchbar" method="get">
  <input name="q" value="<?= e($q) ?>" placeholder="Search by name, roll, email, class…">
  <button class="btn btn-ghost">Search</button>
  <?php if($q): ?><a class="btn btn-ghost" href="students.php">Clear</a><?php endif; ?>
</form>
<?php if($msg = flash('ok')): ?><div class="alert ok"><?= e($msg) ?></div><?php endif; ?>
<?php if($msg = flash('err')): ?><div class="alert err"><?= e($msg) ?></div><?php endif; ?>
<div class="card">
<table class="table">
  <thead><tr><th></th><th>Roll</th><th>Name</th><th>Class</th><th>Email</th><th>Phone</th><th></th></tr></thead>
  <tbody>
  <?php foreach ($list as $s): ?>
    <tr>
      <td><?php if($s['photo']): ?><img class="avatar" src="<?= e($s['photo']) ?>" alt=""><?php else: ?><span class="avatar ph"><?= e(strtoupper(substr($s['name'],0,1))) ?></span><?php endif; ?></td>
      <td><?= e($s['roll']) ?></td>
      <td><a href="view-student.php?id=<?= e($s['id']) ?>"><?= e($s['name']) ?></a></td>
      <td><?= e($s['class']) ?></td>
      <td><?= e($s['email']) ?></td>
      <td><?= e($s['phone']) ?></td>
      <td class="row-actions">
        <a class="btn btn-tiny" href="view-student.php?id=<?= e($s['id']) ?>">View</a>
        <a class="btn btn-tiny" href="edit-student.php?id=<?= e($s['id']) ?>">Edit</a>
        <a class="btn btn-tiny danger" href="delete-student.php?id=<?= e($s['id']) ?>" onclick="return confirm('Delete this student?')">Delete</a>
      </td>
    </tr>
  <?php endforeach; if(!$list): ?>
    <tr><td colspan="7" class="muted center">No students found.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
</div>
<?php footer_html(); ?>
