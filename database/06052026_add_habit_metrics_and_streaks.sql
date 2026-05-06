-- =============================================
-- Migration: Add habit metrics and individual streaks
-- Date: 06/05/2026
-- =============================================

USE viora_app;

-- Add metric columns to habit_logs table
ALTER TABLE habit_logs 
ADD COLUMN metric_value DECIMAL(10,2) NULL COMMENT 'Giá trị metric (ml, km, giờ, calories...)',
ADD COLUMN metric_unit VARCHAR(20) NULL COMMENT 'Đơn vị (ml, km, hours, calories...)';

-- Add current_streak and longest_streak to habits table
ALTER TABLE habits
ADD COLUMN current_streak INT DEFAULT 0 COMMENT 'Streak hiện tại của thói quen này',
ADD COLUMN longest_streak INT DEFAULT 0 COMMENT 'Streak dài nhất của thói quen này',
ADD COLUMN last_completed_date DATE NULL COMMENT 'Ngày hoàn thành gần nhất';

-- Create index for better performance
CREATE INDEX idx_habit_logs_date ON habit_logs(log_date);
CREATE INDEX idx_habits_user_active ON habits(user_id, is_active);
