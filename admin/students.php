<?php
session_start();

include '../config.php';
$query = new Database();
$query->check_session('admin');

$students = $query->select("users", '*', "role = ?", ['student'], 's');
$_SESSION['csrf_token'] ??= bin2hex(random_bytes(32));

if (
    $_SERVER["REQUEST_METHOD"] === "POST" &&
    isset($_POST['submit']) &&
    isset($_POST['csrf_token']) &&
    isset($_SESSION['csrf_token']) &&
    hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])
) {
    $first_name = $query->validate($_POST['first_name']);
    $last_name = $query->validate($_POST['last_name']);
    $email = $query->validate($_POST['email']);
    $username = $query->validate($_POST['username']);
    $password = $query->hashPassword($_POST['password']);

    $data = [
        'first_name' => $first_name,
        'last_name' => $last_name,
        'email' => $email,
        'username' => $username,
        'password' => $password,
        'role' => 'student'
    ];

    if ($query->insert("users", $data)) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        ?>
        <script>
            window.onload = function () { Swal.fire({ icon: 'success', title: 'Success!', text: 'New student added successfully!', timer: 1500, showConfirmButton: false }).then(() => { window.location.replace('students.php'); }); };
        </script>
        <?php
    }
} elseif (isset($_POST['submit'])) {
    ?>
    <script>
        window.onload = function () { Swal.fire({ icon: 'error', title: 'Invalid CSRF Token', text: 'Please refresh the page and try again.', showConfirmButton: true }); };
    </script>
    <?php
}
?>

<style>
    #email-message,
    #username-message,
    #password-message {
        color: red;
        font-size: 14px;
        margin-top: 5px;
    }

    .password-container {
        position: relative;
        display: flex;
        align-items: student;
    }

    .password-container input {
        flex: 1;
        padding-right: 40px;
    }

    .password-toggle {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        cursor: pointer;
        border: none;
        background: transparent;
    }
</style>


<?php include './header.php'; ?>

<div class="row">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header bg-dark text-white">Students List</div>
            <div class="card-body">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Username</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($students as $student): ?>
                            <tr>
                                <td><?= $student['id'] ?></td>
                                <td><?= htmlspecialchars($student['first_name'] . ' ' . $student['last_name']) ?></td>
                                <td><?= htmlspecialchars($student['email']) ?></td>
                                <td><?= htmlspecialchars($student['username']) ?></td>
                                <td>
                                    <a href="student_details.php?id=<?= $student['id'] ?>"
                                        class="btn btn-warning btn-sm">Details</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card">
            <div class="card-header bg-dark text-white">Add New Student</div>
            <div class="card-body">
                <form id="signupForm" method="POST">
                    <div class="mb-3">
                        <label for="first_name" class="form-label">First Name</label>
                        <input type="text" id="first_name_input" name="first_name" class="form-control" maxlength="30"
                            required>
                    </div>
                    <div class="mb-3">
                        <label for="last_name" class="form-label">Last Name</label>
                        <input type="text" id="last_name_input" name="last_name" class="form-control" maxlength="30"
                            required>
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" id="email" name="email" class="form-control" maxlength="100" required>
                        <small id="email-message"></small>
                    </div>
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" id="username" name="username" class="form-control" maxlength="30" required>
                        <small id="username-message"></small>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <div class="password-container">
                            <input type="password" id="password" name="password" class="form-control" maxlength="255"
                                required>
                            <button type="button" id="toggle-password" class="password-toggle">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <small id="password-message"></small>
                    </div>
                    <div class="mb-3">
                        <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token']; ?>">
                    </div>
                    <div class="mb-3">
                        <button type="submit" name="submit" id="submit" class="btn btn-primary w-100">Add
                            Student</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const emailField = document.getElementById('email');
        const usernameField = document.getElementById('username');
        const passwordField = document.getElementById('password');
        const emailMessage = document.getElementById('email-message');
        const usernameMessage = document.getElementById('username-message');
        const passwordMessage = document.getElementById('password-message');
        const submitButton = document.getElementById('submit');
        const togglePassword = document.getElementById('toggle-password');

        let emailAvailable = false;
        let usernameAvailable = false;

        function validateEmailFormat(email) {
            return /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/.test(email);
        }

        function validateUsernameFormat(username) {
            return /^[a-zA-Z0-9_]{3,30}$/.test(username);
        }

        function validatePassword() {
            if (passwordField.value.length < 8) {
                passwordMessage.textContent = 'Min 8 characters required.';
                return false;
            }
            passwordMessage.textContent = '';
            return true;
        }

        function checkAvailability(type, value, messageElement, callback) {
            if (!value) return;

            fetch('../signup/check_availability.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `${type}=${encodeURIComponent(value)}`
            })
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        messageElement.textContent = `This ${type} is already taken!`;
                        callback(false);
                    } else {
                        messageElement.textContent = '';
                        callback(true);
                    }
                    updateSubmitButtonState();
                });
        }

        function updateSubmitButtonState() {
            submitButton.disabled = !(emailAvailable && usernameAvailable && validatePassword());
        }

        emailField.addEventListener('input', function () {
            if (!validateEmailFormat(this.value)) {
                emailMessage.textContent = 'Invalid email format!';
                emailAvailable = false;
                updateSubmitButtonState();
                return;
            }
            checkAvailability('email', this.value, emailMessage, status => {
                emailAvailable = status;
            });
        });

        usernameField.addEventListener('input', function () {
            if (!validateUsernameFormat(this.value)) {
                usernameMessage.textContent = 'Username must be 3-30 characters: A-Z, a-z, 0-9, or _.';
                usernameAvailable = false;
                updateSubmitButtonState();
                return;
            }
            checkAvailability('username', this.value, usernameMessage, status => {
                usernameAvailable = status;
            });
        });

        passwordField.addEventListener('input', function () {
            validatePassword();
            updateSubmitButtonState();
        });

        togglePassword.addEventListener('click', function () {
            passwordField.type = passwordField.type === 'password' ? 'text' : 'password';
            this.querySelector('i').classList.toggle('fa-eye');
            this.querySelector('i').classList.toggle('fa-eye-slash');
        });
    });
</script>

<?php include './footer.php'; ?>