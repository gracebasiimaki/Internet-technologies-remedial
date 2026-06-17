<?php
require_once __DIR__ . '/functions.php';
require_login();
$err = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = collect_student_post();
    $err = validate_student($data);
    if (!$err) {
        $photo = save_student_photo('photo');
        $id = add_student($data, $photo);
        flash('ok','Student added.');
        header('Location: view-student.php?id=' . $id); exit;
    }
}
header_html('Add student');
?>
<h1 class="page-title">Add student</h1>
<form class="card form" method="post" enctype="multipart/form-data">
  <?php render_error($err); ?>
  <div class="grid-2">
    <label>Roll no *<input name="roll" required></label>
    <label>Full name *<input name="name" required></label>
    <label>Class *<input name="class" required placeholder="e.g. 10-A"></label>
    <label>Gender
      <select name="gender"><option value="">—</option><option>Female</option><option>Male</option><option>Other</option></select>
    </label>
    <label>Date of birth<input type="date" name="dob"></label>
    <label>Phone<input name="phone"></label>
    <label>Email<input type="email" name="email"></label>
    <label>Photo (max 2MB)<input type="file" name="photo" accept="image/*"></label>
  </div>
  <label>Address<textarea name="address" rows="3"></textarea></label>
  <div class="actions">
    <button class="btn btn-primary">Save student</button>
    <a class="btn btn-ghost" href="students.php">Cancel</a>
  </div>
</form>
<?php footer_html(); ?>
