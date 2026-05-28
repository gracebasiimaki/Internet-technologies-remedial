<?php
require_once __DIR__ . '/functions.php';
require_login();
$id = (int)($_GET['id'] ?? 0);
$node = find_student($id);
if (!$node) { http_response_code(404); die('Student not found.'); }
$err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = [];
    foreach (['roll','name','email','phone','class','gender','dob','address'] as $k) $data[$k] = clean($_POST[$k] ?? '');
    if (!$data['name'] || !$data['roll'] || !$data['class']) $err = 'Name, roll, and class are required.';
    elseif ($data['email'] && !is_email($data['email'])) $err = 'Invalid email.';
    else {
        $photo = save_student_photo('photo');
        update_student($id, $data, $photo ?: null);
        flash('ok','Student updated.');
        header('Location: view-student.php?id=' . $id); exit;
    }
}
$s = [];
foreach (['roll','name','email','phone','class','gender','dob','address','photo'] as $k) $s[$k] = (string)$node->{$k};
header_html('Edit student');
?>
<h1 class="page-title">Edit student</h1>
<form class="card form" method="post" enctype="multipart/form-data">
  <?php if($err): ?><div class="alert err"><?= e($err) ?></div><?php endif; ?>
  <?php if($s['photo']): ?><img class="avatar lg" src="<?= e($s['photo']) ?>" alt=""><?php endif; ?>
  <div class="grid-2">
    <label>Roll no *<input name="roll" required value="<?= e($s['roll']) ?>"></label>
    <label>Full name *<input name="name" required value="<?= e($s['name']) ?>"></label>
    <label>Class *<input name="class" required value="<?= e($s['class']) ?>"></label>
    <label>Gender
      <select name="gender">
        <?php foreach (['','Female','Male','Other'] as $g): ?>
          <option <?= $g===$s['gender']?'selected':'' ?>><?= e($g ?: '—') ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Date of birth<input type="date" name="dob" value="<?= e($s['dob']) ?>"></label>
    <label>Phone<input name="phone" value="<?= e($s['phone']) ?>"></label>
    <label>Email<input type="email" name="email" value="<?= e($s['email']) ?>"></label>
    <label>Replace photo<input type="file" name="photo" accept="image/*"></label>
  </div>
  <label>Address<textarea name="address" rows="3"><?= e($s['address']) ?></textarea></label>
  <div class="actions">
    <button class="btn btn-primary">Save changes</button>
    <a class="btn btn-ghost" href="view-student.php?id=<?= e($id) ?>">Cancel</a>
  </div>
</form>
<?php footer_html(); ?>
