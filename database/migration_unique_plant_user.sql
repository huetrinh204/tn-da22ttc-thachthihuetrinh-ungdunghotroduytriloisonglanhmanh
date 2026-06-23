-- Migration: Add UNIQUE constraint on user_id in plants table
-- This prevents duplicate plant records per user

-- Step 1: Remove duplicate plants, keeping only the one with highest experience per user
DELETE p1 FROM plants p1
INNER JOIN plants p2 ON p1.user_id = p2.user_id AND p1.id < p2.id
WHERE p1.experience <= p2.experience;

-- Step 2: Remove remaining duplicates (same exp, keep lowest id)
DELETE p1 FROM plants p1
INNER JOIN plants p2 ON p1.user_id = p2.user_id AND p1.id > p2.id;

-- Step 3: Add UNIQUE constraint
ALTER TABLE plants ADD UNIQUE INDEX idx_user_id_unique (user_id);
