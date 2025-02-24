DROP DATABASE IF EXISTS e_kurs;

CREATE DATABASE e_kurs;

USE e_kurs;

-- 1. Users table: Stores user information
CREATE TABLE IF NOT EXISTS users (
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

-- 2. Active Sessions table: Tracks user login sessions
CREATE TABLE IF NOT EXISTS active_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    device_name VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Courses table: Stores course details
CREATE TABLE IF NOT EXISTS courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    center_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100),
    image VARCHAR(255) DEFAULT 'default_course.png',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (center_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Students table: Links students to courses
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 5. Lessons table: Contains lessons for each course
CREATE TABLE IF NOT EXISTS lessons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    type ENUM('video', 'content') NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    link VARCHAR(255),
    position INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 6. Tests table: Stores quiz questions for lessons
CREATE TABLE IF NOT EXISTS tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lesson_id INT NOT NULL,
    question TEXT NOT NULL,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

-- 7. Test Options table: Stores options for quiz questions
CREATE TABLE IF NOT EXISTS test_options (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE
);

-- 8. Results table: Stores student quiz results
CREATE TABLE IF NOT EXISTS results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    lesson_id INT NOT NULL,
    participant_name VARCHAR(255) NOT NULL,
    total_questions INT NOT NULL,
    answered_questions INT NOT NULL,
    score INT,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

-- 9. Payments table: Records payment transactions
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    api_trans_id VARCHAR(100) NOT NULL,
    system_trans_id VARCHAR(100) NOT NULL,
    method ENUM('click', 'payme') DEFAULT 'click',
    status ENUM('unpay', 'paid') DEFAULT 'unpay',
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 10. Comments table: Stores user comments for courses
CREATE TABLE IF NOT EXISTS comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    comment VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- 11. Certificates table: Stores certificates issued to students
CREATE TABLE IF NOT EXISTS certificates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    certificate_url VARCHAR(255),
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- admin and user (password: 'Iqbolsoh$7')
INSERT INTO
    users (
        first_name,
        last_name,
        email,
        username,
        password,
        role
    )
VALUES
    (
        'Iqbolshoh',
        'Ilhomjonov',
        'iilhomjonov777@gmail.com',
        'iqbolshoh',
        '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231',
        'admin'
    ),
    (
        'English',
        'Center',
        'center@iqbolshoh.uz',
        'center',
        '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231',
        'center'
    ),
    (
        'student',
        'studentjonov',
        'student@iqbolshoh.uz',
        'student',
        '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231',
        'student'
    );

    -- 1. Users table
INSERT INTO users (first_name, last_name, email, username, password, role)
VALUES 
    ('Iqbolshoh', 'Ilhomjonov', 'iilhomjonov777@gmail.com', 'iqbolshoh', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'admin'),
    ('English', 'Center', 'center@iqbolshoh.uz', 'center', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'center'),
    ('Student', 'Studentjonov', 'student@iqbolshoh.uz', 'student', '1f254bb82e64bde20137a2922989f6f57529c98e34d146b523a47898702b7231', 'student');

-- 2. Active Sessions
INSERT INTO active_sessions (user_id, device_name, ip_address, session_token)
VALUES 
    (1, 'iPhone 15 Pro Max', '192.168.1.10', 'token123'),
    (2, 'Windows Laptop', '192.168.1.15', 'token456'),
    (3, 'Android Tablet', '192.168.1.20', 'token789');

-- 3. Courses
INSERT INTO courses (center_id, title, description, price, category)
VALUES 
    (2, 'English for Beginners', 'Learn basic English grammar and vocabulary.', 150.00, 'Languages'),
    (2, 'Advanced English', 'Deep dive into complex grammar and fluent speaking.', 200.00, 'Languages'),
    (2, 'IELTS Preparation', 'Prepare for IELTS exam with expert tips.', 250.00, 'Exams');

-- 4. Students
INSERT INTO students (user_id, course_id)
VALUES 
    (3, 1),
    (3, 2);

-- 5. Lessons
INSERT INTO lessons (course_id, type, title, description, link, position)
VALUES 
    (1, 'video', 'Introduction to English', 'Basic alphabets and greetings.', 'video_link_1', 1),
    (1, 'content', 'Common Phrases', 'Useful daily conversations.', NULL, 2),
    (2, 'video', 'Advanced Grammar', 'Complex tenses and clauses.', 'video_link_2', 1);

-- 6. Tests
INSERT INTO tests (lesson_id, question)
VALUES 
    (1, 'What is the English word for "Salom"?'),
    (2, 'Choose the correct daily greeting.'),
    (3, 'Identify the past perfect tense.');

-- 7. Test Options
INSERT INTO test_options (test_id, option_text, is_correct)
VALUES 
    (1, 'Hello', TRUE),
    (1, 'Goodbye', FALSE),
    (2, 'Good Morning', TRUE),
    (2, 'Good Night', FALSE),
    (3, 'I had eaten', TRUE),
    (3, 'I eat', FALSE);

-- 8. Results
INSERT INTO results (user_id, lesson_id, participant_name, total_questions, answered_questions, score)
VALUES 
    (3, 1, 'Student Studentjonov', 5, 5, 80),
    (3, 2, 'Student Studentjonov', 5, 4, 70);

-- 9. Payments
INSERT INTO payments (user_id, course_id, amount, api_trans_id, system_trans_id, method, status)
VALUES 
    (3, 1, 150.00, 'api123', 'sys123', 'click', 'paid'),
    (3, 2, 200.00, 'api456', 'sys456', 'payme', 'unpay');

-- 10. Comments
INSERT INTO comments (user_id, course_id, comment)
VALUES 
    (3, 1, 'Awesome course!'),
    (3, 2, 'Very informative.');

-- 11. Certificates
INSERT INTO certificates (user_id, course_id, certificate_url)
VALUES 
    (3, 1, 'certificates/student_english.pdf'),
    (3, 2, 'certificates/student_advanced.pdf');