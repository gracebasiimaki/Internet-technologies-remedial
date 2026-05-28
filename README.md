# Scholar — Student Management System (PHP + XML)

A complete, database-free student management system. All data is stored in
human-readable XML files. Perfect for learning PHP, deploying to shared
hosting, or using on a USB stick with XAMPP.

## Folder structure
```
sms/
├── index.php           Landing page
├── register.php        Create an admin account
├── login.php           Sign in
├── logout.php          End session
├── dashboard.php       Overview + stats
├── students.php        List + search students
├── add-student.php     Create a student (with photo upload)
├── edit-student.php    Update a student
├── view-student.php    Profile + attendance + marks
├── delete-student.php  Remove a student
├── functions.php       All helpers (auth, XML, validation)
├── config.php          Paths, constants, session bootstrap
├── style.css           Modern responsive UI
├── uploads/            Student photos (writable)
└── xml/
    ├── users.xml
    ├── students.xml
    ├── attendance.xml
    └── marks.xml
```

## Setup (XAMPP / WAMP / MAMP)
1. Copy the `sms/` folder into your web root (e.g. `htdocs/`).
2. Make sure `uploads/` and `xml/` are writable by PHP.
3. Visit `http://localhost/sms/` in your browser.
4. Click **Sign up** to create your first admin account.
   (The sample `users.xml` placeholder hash will not log in — register a
   fresh account on first run.)

## Security highlights
- Passwords hashed with `password_hash` (bcrypt) and verified with `password_verify`.
- All output escaped with `htmlspecialchars` to prevent XSS.
- Session-based authentication, `require_login()` guards every protected page.
- Photo uploads validated by MIME + size (max 2MB), random filenames.
- All form inputs trimmed & validated server-side.

## Features
- Registration / Login / Logout
- Admin dashboard with live counts
- Add / Edit / Delete / Search students
- Rich student profile pages with photo
- Daily attendance marking (present / absent / late)
- Subject-wise marks with auto percentage
- Responsive, modern card-and-table UI

Happy hacking! 🎓
