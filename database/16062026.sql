-- Add post_type column to community_posts
ALTER TABLE community_posts 
ADD COLUMN post_type ENUM('normal', 'achievement') NOT NULL DEFAULT 'normal';

-- Update existing achievement posts (those with #thanhTich hashtag)
UPDATE community_posts 
SET post_type = 'achievement'
WHERE JSON_SEARCH(hashtags, 'one', '#thanhTich') IS NOT NULL;
