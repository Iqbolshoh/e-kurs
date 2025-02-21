<?php
session_start();

include '../config.php';
$query = new Database();
$query->checkUserSession('admin');

$centers = $query->select("users", '*', "role = ?", ['center'], 's');
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
        'role' => 'center'
    ];

    if ($query->insert("users", $data)) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        ?>
        <script>
            window.onload = function () { Swal.fire({ icon: 'success', title: 'Success!', text: 'New center added successfully!', timer: 1500, showConfirmButton: false }).then(() => { window.location.replace('center.php'); }); };
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
        align-items: center;
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
            <div class="card-header bg-dark text-white">Centers List</div>
            <div class="card-body">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Username</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($centers as $center): ?>
                            <tr>
                                <td><?= $center['id'] ?></td>
                                <td><?= htmlspecialchars($center['first_name'] . ' ' . $center['last_name']) ?>
                                </td>
                                <td><?= htmlspecialchars($center['email']) ?></td>
                                <td><?= htmlspecialchars($center['username']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card">
            <div class="card-header bg-dark text-white">Add New Center</div>
            <div class="card-body">
                <form id="signupForm" method="POST">
                    <div class="mb-3">
                        <label for="first_name" class="form-label">First Name</label>
                        <input type="text" id="first_name" name="first_name" class="form-control" maxlength="30"
                            required>
                    </div>
                    <div class="mb-3">
                        <label for="last_name" class="form-label">Last Name</label>
                        <input type="text" id="last_name" name="last_name" class="form-control" maxlength="30" required>
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
                        <button type="submit" name="submit" class="btn btn-primary w-100">Add
                            Center</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    let isEmailAvailable = false;
    let isUsernameAvailable = false;

    function validateUsernameFormat(username) {
        const usernamePattern = /^[a-zA-Z0-9_]+$/;
        return usernamePattern.test(username);
    }

    function validateEmailFormat(email) {
        const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        return emailPattern.test(email);
    }

    function checkAvailability(type, value, messageElement, callback) {
        fetch('../signup/check_availability.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `${type}=${encodeURIComponent(value)}`
        })
            .then(response => response.json())
            .then(data => {
                if (data.exists) {
                    messageElement.textContent = `This ${type} exists!`;
                    callback(false);
                } else {
                    messageElement.textContent = '';
                    callback(true);
                }
            });
    }

    function calculatePasswordStrength(password) {
        let strength = 0;
        const lengthBonus = password.length > 7 ? 1 : 0;
        const numberBonus = /[0-9]/.test(password) ? 1 : 0;
        const lowercaseBonus = /[a-z]/.test(password) ? 1 : 0;
        const uppercaseBonus = /[A-Z]/.test(password) ? 1 : 0;
        const specialCharBonus = /[!@#$%^&*(),.?":{}|<>]/.test(password) ? 1 : 0;
        const repetitionPenalty = /(.)\1{2,}/.test(password) ? -1 : 0;

        strength = lengthBonus + numberBonus + lowercaseBonus + uppercaseBonus + specialCharBonus + repetitionPenalty;
        return strength;
    }

    document.getElementById('email').addEventListener('input', function () {
        const email = this.value;
        const emailMessageElement = document.getElementById('email-message');

        if (!validateEmailFormat(email)) {
            emailMessageElement.textContent = 'Email format is incorrect!';
            isEmailAvailable = false;
            return;
        }

        checkAvailability('email', email, emailMessageElement, status => isEmailAvailable = status);
    });

    document.getElementById('username').addEventListener('input', function () {
        const username = this.value;
        const usernameMessageElement = document.getElementById('username-message');

        if (!validateUsernameFormat(username)) {
            usernameMessageElement.textContent = 'Username can only contain letters, numbers, and underscores!';
            isUsernameAvailable = false;
            return;
        }

        checkAvailability('username', username, usernameMessageElement, status => isUsernameAvailable = status);
    });

    document.getElementById('password').addEventListener('input', function () {
        const password = this.value;
        const passwordMessageElement = document.getElementById('password-message');
        let message = '';

        if (password.length < 8) {
            passwordMessageElement.textContent = 'Password must be at least 8 characters long!';
            passwordMessageElement.className = 'strength-weak';
            return;
        }

        passwordMessageElement.textContent = message;
    });

    document.getElementById('signupForm').addEventListener('submit', function (event) {
        const email = document.getElementById('email').value;
        const emailMessageElement = document.getElementById('email-message');
        const username = document.getElementById('username').value;
        const usernameMessageElement = document.getElementById('username-message');
        const password = document.getElementById('password').value;
        const passwordMessageElement = document.getElementById('password-message');

        if (!validateEmailFormat(email)) {
            emailMessageElement.textContent = 'Email format is incorrect!';
            event.preventDefault();
        }

        if (!validateUsernameFormat(username)) {
            usernameMessageElement.textContent = 'Username can only contain letters, numbers, and underscores!';
            event.preventDefault();
        }

        if (!isEmailAvailable) {
            emailMessageElement.textContent = 'This email exists!';
            event.preventDefault();
        }

        if (!isUsernameAvailable) {
            usernameMessageElement.textContent = 'This username exists!';
            event.preventDefault();
        }

        if (password.length < 8) {
            passwordMessageElement.textContent = 'Password must be at least 8 characters long!';
            event.preventDefault();
        }
    });

    document.getElementById('toggle-password').addEventListener('click', function () {
        const passwordField = document.getElementById('password');
        const toggleIcon = this.querySelector('i');

        if (passwordField.type === 'password') {
            passwordField.type = 'text';
            toggleIcon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            passwordField.type = 'password';
            toggleIcon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    });
</script>

<?php include './footer.php'; ?>