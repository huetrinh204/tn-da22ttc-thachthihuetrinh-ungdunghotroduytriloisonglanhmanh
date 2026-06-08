-- Auto reminder messages and settings
CREATE TABLE IF NOT EXISTS auto_reminder_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message TEXT NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default reminder messages
INSERT INTO auto_reminder_messages (message, is_active) VALUES
('⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! 💪', 1),
('🌟 Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! 🌱', 1),
('🔥 Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! 💚', 1),
('✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! 🚀', 1),
('💡 Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? 📈', 1);

-- Auto reminder settings
CREATE TABLE IF NOT EXISTS auto_reminder_settings (
  id INT PRIMARY KEY DEFAULT 1,
  is_enabled TINYINT(1) DEFAULT 0,
  morning_time TIME DEFAULT '08:00:00',
  evening_time TIME DEFAULT '20:00:00',
  send_morning TINYINT(1) DEFAULT 1,
  send_evening TINYINT(1) DEFAULT 1,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT INTO auto_reminder_settings (id, is_enabled, morning_time, evening_time) VALUES
(1, 0, '08:00:00', '20:00:00')
ON DUPLICATE KEY UPDATE id=id;
