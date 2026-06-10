-- Add progressive wilting system
-- Date: 10/06/2026

-- Add columns for tracking days without check-in and penalty
ALTER TABLE plants 
ADD COLUMN days_without_checkin INT DEFAULT 0 COMMENT 'Number of consecutive days without completing any habit',
ADD COLUMN last_penalty_date DATE NULL COMMENT 'Last date when EXP penalty was applied';

-- Update existing plants to have default values
UPDATE plants SET days_without_checkin = 0 WHERE days_without_checkin IS NULL;
