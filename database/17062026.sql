-- Add streak freeze tokens to streaks table
ALTER TABLE streaks 
ADD COLUMN freeze_tokens INT NOT NULL DEFAULT 0,
ADD COLUMN last_freeze_used_date DATE NULL;
