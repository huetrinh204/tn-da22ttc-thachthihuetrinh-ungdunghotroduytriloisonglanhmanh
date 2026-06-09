-- App Settings Table
-- Date: 09/06/2026
-- Purpose: Store application settings (name, logo, etc.)

CREATE TABLE IF NOT EXISTS app_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default values
INSERT INTO app_settings (setting_key, setting_value) VALUES
('app_name', 'Viora'),
('app_logo_url', NULL)
ON DUPLICATE KEY UPDATE setting_key = setting_key;
