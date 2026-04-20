-- =============================================
-- Viora App - Database Schema
-- =============================================

CREATE DATABASE IF NOT EXISTS viora_app;
USE viora_app;

-- =============================================
-- USERS
-- =============================================
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255),
  gender VARCHAR(10),
  birth_year INT,
  height DECIMAL(5,2),
  weight DECIMAL(5,2),
  goals JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- HABITS
-- =============================================
CREATE TABLE IF NOT EXISTS habits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  category ENUM('eat', 'exercise', 'sleep', 'mental', 'hydration', 'other') DEFAULT 'other',
  frequency ENUM('daily', 'weekly') DEFAULT 'daily',
  target_count INT DEFAULT 1,
  icon VARCHAR(10),
  color VARCHAR(20),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- HABIT LOGS
-- =============================================
CREATE TABLE IF NOT EXISTS habit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  habit_id INT NOT NULL,
  user_id INT NOT NULL,
  log_date DATE NOT NULL,
  completed_count INT DEFAULT 1,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_log (habit_id, log_date),
  FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- STREAKS
-- =============================================
CREATE TABLE IF NOT EXISTS streaks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  last_active_date DATE,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- PLANTS
-- =============================================
CREATE TABLE IF NOT EXISTS plants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  plant_type VARCHAR(50) DEFAULT 'sprout',
  health INT DEFAULT 100,
  level INT DEFAULT 1,
  experience INT DEFAULT 0,
  last_watered DATE,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- ACHIEVEMENTS
-- =============================================
CREATE TABLE IF NOT EXISTS achievements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  achievement_key VARCHAR(50) NOT NULL,
  title VARCHAR(100),
  description TEXT,
  icon VARCHAR(10),
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- NOTIFICATIONS
-- =============================================
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(100),
  body TEXT,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
