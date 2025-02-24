-- DROP DATABASE IF EXISTS
DROP DATABASE IF EXISTS e_kurs;

-- CREATE DATABASE
CREATE DATABASE e_kurs;
USE e_kurs;

-- 1. USERS TABLE
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'center', 'student') NOT NULL DEFAULT 'student',
    profile_picture VARCHAR(255) DEFAULT 'default.png',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. ACTIVE SESSIONS TABLE
CREATE TABLE active_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    device_name VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. CATEGORIES TABLE
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    center_id INT NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (center_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. COURSES TABLE
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    center_id INT NOT NULL,
    category_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255) DEFAULT 'default_course.png',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (center_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- 5. TOPICS TABLE
CREATE TABLE topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 6. LESSON ITEMS TABLE
CREATE TABLE lesson_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic_id INT NOT NULL,
    type ENUM('video', 'post') NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    link VARCHAR(255),
    position INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

-- 7. TESTS TABLE
CREATE TABLE tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    topic_id INT NOT NULL,
    question TEXT NOT NULL,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

-- 8. TEST OPTIONS TABLE
CREATE TABLE test_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE
);

-- 9. STUDENTS TABLE
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 10. RESULTS TABLE
CREATE TABLE results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    topic_id INT NOT NULL,
    total_questions INT NOT NULL,
    answered_questions INT NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
);

-- 11. PAYMENTS TABLE
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    api_trans_id VARCHAR(100) NOT NULL,
    system_trans_id VARCHAR(100) NOT NULL,
    method ENUM('click', 'payme') DEFAULT 'click',
    status ENUM('unpay', 'paid') DEFAULT 'unpay',
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 12. COMMENTS TABLE
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    comment VARCHAR(255) NOT NULL,
    sended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 13. CERTIFICATES TABLE
CREATE TABLE certificates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    certificate_url VARCHAR(255),
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- =============================
-- 📥 DATA INSERTION (Complate)
-- =============================

-- USERS
INSERT INTO users (first_name, last_name, email, username, password, role) VALUES
('Iqbolshoh', 'Ilhomjonov', 'iilhomjonov777@gmail.com', 'iqbolshoh', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'admin'),
('English', 'Center', 'center@iqbolshoh.uz', 'center', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'center'),
('Student', 'Studentjonov', 'student@iqbolshoh.uz', 'student', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'student');

-- ACTIVE SESSIONS
INSERT INTO active_sessions (user_id, device_name, ip_address, session_token) VALUES
(1, 'iPhone 15 Pro Max', '192.168.1.10', 'token123'),
(3, 'Windows Laptop', '192.168.1.20', 'token456');

-- CATEGORIES
INSERT INTO categories (center_id, name) VALUES
(2, 'Programming'),
(2, 'Languages'),
(2, 'Mathematics');

-- COURSES
INSERT INTO courses (center_id, category_id, title, description, price) VALUES
(2, 1, 'Full-Stack Web Development', 'Learn HTML, CSS, JS, PHP, Laravel, and more.', 300.00),
(2, 2, 'English for Beginners', 'Basic English grammar, vocabulary, and speaking.', 200.00),
(2, 3, 'Algebra Basics', 'Master fundamental algebra concepts.', 150.00);

-- TOPICS
INSERT INTO topics (course_id, title) VALUES
(1, 'HTML & CSS Basics'),
(1, 'JavaScript Fundamentals'),
(2, 'English Alphabet & Pronunciation'),
(3, 'Equations and Inequalities');

-- LESSON ITEMS
INSERT INTO lesson_items (topic_id, type, title, description, link, position) VALUES
(1, 'video', 'Introduction to HTML', 'Learn HTML structure and tags.', 'https://example.com/html', 1),
(1, 'post', 'CSS Basics', 'Introduction to styling with CSS.', NULL, 2),
(2, 'video', 'JavaScript Variables', 'Understanding variables in JS.', 'https://example.com/js', 1),
(3, 'post', 'Alphabet Chart', 'Learn English alphabets.', NULL, 1),
(4, 'video', 'Solving Equations', 'Step-by-step guide to solve equations.', 'https://example.com/algebra', 1);

-- TESTS
INSERT INTO tests (topic_id, question) VALUES
(1, 'What does HTML stand for?'),
(2, 'How do you declare a variable in JavaScript?'),
(3, 'Which letter comes after "C" in the alphabet?'),
(4, 'Solve for x: 2x + 3 = 7');

-- TEST OPTIONS
INSERT INTO test_options (test_id, option_text, is_correct) VALUES
(1, 'Hyper Text Markup Language', TRUE),
(1, 'Home Tool Markup Language', FALSE),
(2, 'var x = 5;', TRUE),
(2, 'int x = 5;', FALSE),
(3, 'D', TRUE),
(3, 'E', FALSE),
(4, 'x = 2', TRUE),
(4, 'x = 4', FALSE);

-- STUDENTS
INSERT INTO students (user_id, course_id) VALUES
(3, 1),
(3, 2),
(3, 3);

-- RESULTS
INSERT INTO results (user_id, topic_id, total_questions, answered_questions) VALUES
(3, 1, 5, 5),
(3, 2, 4, 3),
(3, 3, 6, 6),
(3, 4, 3, 2);

-- PAYMENTS
INSERT INTO payments (user_id, course_id, amount, api_trans_id, system_trans_id, method, status) VALUES
(3, 1, 150.00, 'api123', 'sys123', 'click', 'paid'),
(3, 2, 200.00, 'api456', 'sys456', 'payme', 'unpay');

-- COMMENTS
INSERT INTO comments (user_id, course_id, comment) VALUES
(3, 1, 'Amazing course!'),
(3, 2, 'The lessons are easy to follow.'),
(3, 3, 'I finally understand algebra.');

-- CERTIFICATES
INSERT INTO certificates (user_id, course_id, certificate_url) VALUES
(3, 1, md5('user_id=3&course_id=1&2024-01-17 12:00:01')),
(3, 2, md5('user_id=3&course_id=2&2024-02-19 22:22:22'));