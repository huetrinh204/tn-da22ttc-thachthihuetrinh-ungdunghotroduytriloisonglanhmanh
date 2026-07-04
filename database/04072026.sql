-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: viora_app
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `icon` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unlocked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `achieved_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,6,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:17:12','2026-04-28 06:17:12'),(2,7,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:29:14','2026-04-28 06:29:14'),(3,6,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-04-30 11:14:53','2026-04-30 11:14:53'),(4,12,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(5,12,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(6,6,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-05-06 05:01:16','2026-05-06 05:01:16'),(7,12,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-05-13 04:38:14','2026-05-13 04:38:14'),(12,25,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-26 05:19:30','2026-05-26 05:19:30'),(19,32,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-28 12:48:55','2026-05-28 12:48:55'),(30,45,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-06 04:46:05','2026-06-06 04:46:05'),(31,47,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-10 04:50:30','2026-06-10 04:50:30'),(32,12,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 05:39:33','2026-06-10 05:39:33'),(33,43,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-10 06:12:19','2026-06-10 06:12:19'),(34,7,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 10:06:18','2026-06-10 10:06:18'),(35,43,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 10:10:10','2026-06-10 10:10:10'),(36,43,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 10:10:41','2026-06-10 10:10:41'),(37,32,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:24:49','2026-06-10 11:24:49'),(38,32,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 11:24:49','2026-06-10 11:24:49'),(39,47,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:39:07','2026-06-10 11:39:07'),(40,47,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 11:40:58','2026-06-10 11:40:58'),(41,6,'checkin_50','Nửa trăm','Hoàn thành 50 check-ins','?','2026-06-10 11:58:47','2026-06-10 11:58:47'),(42,6,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:59:42','2026-06-10 11:59:42'),(43,50,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 04:24:59','2026-06-14 04:24:59'),(44,53,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 09:52:57','2026-06-14 09:52:57'),(45,54,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 10:17:19','2026-06-14 10:17:19'),(46,58,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-24 08:09:34','2026-06-24 08:09:34'),(47,60,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-24 08:28:10','2026-06-24 08:28:10'),(48,61,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-24 08:34:28','2026-06-24 08:34:28'),(49,62,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-24 08:35:53','2026-06-24 08:35:53'),(50,63,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-25 07:35:59','2026-06-25 07:35:59'),(51,65,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-27 05:08:12','2026-06-27 05:08:12'),(52,66,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-28 09:36:55','2026-06-28 09:36:55'),(53,67,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-29 13:19:45','2026-06-29 13:19:45'),(54,68,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-29 13:30:34','2026-06-29 13:30:34'),(55,69,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-30 07:36:29','2026-06-30 07:36:29'),(56,70,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-03 09:19:03','2026-07-03 09:19:03'),(57,70,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-07-03 09:21:27','2026-07-03 09:21:27'),(58,70,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-07-04 09:36:38','2026-07-04 09:36:38'),(59,71,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-04 10:27:51','2026-07-04 10:27:51'),(60,72,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-05 02:35:06','2026-07-05 02:35:06'),(61,73,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-04 03:12:12','2026-07-04 03:12:12'),(62,74,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-04 03:15:01','2026-07-04 03:15:01'),(63,74,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-07-04 07:01:52','2026-07-04 07:01:52'),(64,75,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-04 07:42:58','2026-07-04 07:42:58'),(65,75,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-07-04 07:42:58','2026-07-04 07:42:58'),(66,76,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-07-04 09:59:50','2026-07-04 09:59:50'),(67,76,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-07-04 10:02:38','2026-07-04 10:02:38');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auto_reminder_messages`
--

DROP TABLE IF EXISTS `auto_reminder_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auto_reminder_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auto_reminder_messages`
--

LOCK TABLES `auto_reminder_messages` WRITE;
/*!40000 ALTER TABLE `auto_reminder_messages` DISABLE KEYS */;
INSERT INTO `auto_reminder_messages` VALUES (1,'⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?',1,'2026-06-08 05:54:32','2026-06-08 05:54:32'),(2,'? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?',1,'2026-06-08 05:54:32','2026-06-08 05:54:32'),(3,'? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?',1,'2026-06-08 05:54:32','2026-06-08 05:54:32'),(4,'✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?',1,'2026-06-08 05:54:32','2026-06-08 05:54:32'),(5,'? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?',1,'2026-06-08 05:54:32','2026-06-08 05:54:32'),(6,'⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?',1,'2026-06-08 05:56:13','2026-06-08 05:56:13'),(7,'? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?',1,'2026-06-08 05:56:13','2026-06-08 05:56:13'),(8,'? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?',1,'2026-06-08 05:56:13','2026-06-08 05:56:13'),(9,'✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?',1,'2026-06-08 05:56:13','2026-06-08 05:56:13'),(10,'? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?',1,'2026-06-08 05:56:13','2026-06-08 05:56:13'),(11,'Dzo thực hiện thói quen liền cho tui ?',1,'2026-06-08 05:59:28','2026-06-08 06:00:03');
/*!40000 ALTER TABLE `auto_reminder_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auto_reminder_settings`
--

DROP TABLE IF EXISTS `auto_reminder_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auto_reminder_settings` (
  `id` int NOT NULL DEFAULT '1',
  `is_enabled` tinyint(1) DEFAULT '0',
  `morning_time` time DEFAULT '08:00:00',
  `evening_time` time DEFAULT '20:00:00',
  `send_morning` tinyint(1) DEFAULT '1',
  `send_evening` tinyint(1) DEFAULT '1',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auto_reminder_settings`
--

LOCK TABLES `auto_reminder_settings` WRITE;
/*!40000 ALTER TABLE `auto_reminder_settings` DISABLE KEYS */;
INSERT INTO `auto_reminder_settings` VALUES (1,1,'07:00:00','20:00:00',1,1,'2026-07-03 07:52:12');
/*!40000 ALTER TABLE `auto_reminder_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_comment_likes`
--

DROP TABLE IF EXISTS `community_comment_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_comment_likes` (
  `user_id` int NOT NULL,
  `comment_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`comment_id`),
  KEY `comment_id` (`comment_id`),
  CONSTRAINT `community_comment_likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `community_comment_likes_ibfk_2` FOREIGN KEY (`comment_id`) REFERENCES `community_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_comment_likes`
--

LOCK TABLES `community_comment_likes` WRITE;
/*!40000 ALTER TABLE `community_comment_likes` DISABLE KEYS */;
INSERT INTO `community_comment_likes` VALUES (6,4,'2026-06-03 10:19:40');
/*!40000 ALTER TABLE `community_comment_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_comment_replies`
--

DROP TABLE IF EXISTS `community_comment_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_comment_replies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `comment_id` (`comment_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `community_comment_replies_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `community_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `community_comment_replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_comment_replies`
--

LOCK TABLES `community_comment_replies` WRITE;
/*!40000 ALTER TABLE `community_comment_replies` DISABLE KEYS */;
INSERT INTO `community_comment_replies` VALUES (1,3,6,'Tui ở Châu Thành - Trà Vinh nè','2026-06-03 10:46:53'),(2,4,12,'Cảm ơn bạn <3','2026-06-03 11:02:13'),(3,5,12,'Hihi cũng không sâu sắc lắm đâu','2026-06-03 11:02:30'),(4,3,12,'Vậy hẹn bạn 5h sáng mai tại Công Viên Nguyễn Trãi nha','2026-06-03 11:42:48'),(5,7,12,'Cảm ơn người đẹp nhaa ?','2026-06-03 11:59:26');
/*!40000 ALTER TABLE `community_comment_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_comments`
--

DROP TABLE IF EXISTS `community_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `community_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `community_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_comments`
--

LOCK TABLES `community_comments` WRITE;
/*!40000 ALTER TABLE `community_comments` DISABLE KEYS */;
INSERT INTO `community_comments` VALUES (3,12,12,'Tui nè, bạn ở đâu?','2026-06-03 10:09:54'),(4,13,6,'Câu nói hay lắm','2026-06-03 10:16:27'),(5,13,32,'Sâu sắc!','2026-06-03 10:54:39'),(6,14,12,'???','2026-06-03 11:16:38'),(7,13,7,'Ý nghĩa lắm nha người đẹp ?','2026-06-03 11:57:20'),(8,13,70,'Chao ban','2026-07-03 09:10:32');
/*!40000 ALTER TABLE `community_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_post_likes`
--

DROP TABLE IF EXISTS `community_post_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post_likes` (
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `community_post_likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `community_post_likes_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post_likes`
--

LOCK TABLES `community_post_likes` WRITE;
/*!40000 ALTER TABLE `community_post_likes` DISABLE KEYS */;
INSERT INTO `community_post_likes` VALUES (6,12,'2026-06-02 05:32:39'),(6,13,'2026-06-15 09:14:35'),(7,13,'2026-06-03 11:53:37'),(12,12,'2026-06-22 06:41:11'),(12,13,'2026-07-02 07:54:42'),(12,14,'2026-07-02 07:54:47'),(32,13,'2026-06-03 10:53:51'),(45,13,'2026-06-06 04:46:40'),(45,14,'2026-06-06 04:46:53'),(70,13,'2026-07-03 09:10:09'),(76,13,'2026-07-04 10:03:09');
/*!40000 ALTER TABLE `community_post_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_posts`
--

DROP TABLE IF EXISTS `community_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hashtags` json DEFAULT NULL,
  `challenge_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `days_streak` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `post_type` enum('normal','achievement') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal',
  `is_warned` tinyint(1) DEFAULT '0',
  `edited_after_warn` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `community_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_posts`
--

LOCK TABLES `community_posts` WRITE;
/*!40000 ALTER TABLE `community_posts` DISABLE KEYS */;
INSERT INTO `community_posts` VALUES (12,6,'Chạy bộ mỗi sáng giúp mình cảm thấy có nhiều năng lưongj hơn để bắt đầu công việc.','http://10.0.2.2:3000/uploads/1780378232788-178490186.jpg',NULL,NULL,2,'2026-06-02 05:30:33','normal',0,0),(13,12,'Hơi thở chính là cây cầu kết nối sự sống và ý thức của con người. Khi gặp phải những chuyện buồn trong cuộc sống, hãy hít một hơi thật sâu, thở ra và cho qua mọi thứ','http://10.0.2.2:3000/uploads/1780481276384-741277433.jpg',NULL,NULL,3,'2026-06-03 10:07:57','normal',0,0),(14,32,'?','http://10.0.2.2:3000/uploads/1780484789156-731392882.jpg',NULL,NULL,1,'2026-06-03 11:06:30','normal',0,0),(15,43,'Mình muốn tăng cân thì cần tập những bài tập và tùy chọn khẩu phần ăn như thế nào ạ? \nMọi người share tip mình biết với\n#tangcanlanhmanh',NULL,'[\"#tangcanlanhmanh\"]',NULL,1,'2026-06-10 10:41:41','normal',0,0),(27,6,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1781599176618-631895994.png','[\"#thanhTich\", \"#achievement\"]',NULL,2,'2026-06-16 08:39:38','achievement',0,0),(29,12,'? Đa nhiệm\nTạo 5 thói quen','http://10.0.2.2:3000/uploads/1782030811883-329779242.png','[\"#thanhTich\", \"#achievement\"]',NULL,1,'2026-06-21 08:33:33','achievement',0,0),(31,12,'Chia sẻ giúp em vài bài tập để tăng cân với.',NULL,NULL,NULL,1,'2026-06-22 06:41:57','normal',0,0),(32,67,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1782739211877-82366289.png','[\"#thanhTich\", \"#achievement\"]',NULL,1,'2026-06-29 13:20:13','achievement',0,0),(33,6,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1782739761091-172904067.png','[\"#thanhTich\", \"#achievement\"]',NULL,1,'2026-06-29 13:29:22','achievement',0,0),(36,69,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1782804997550-403947278.png','[\"#thanhTich\", \"#achievement\"]',NULL,1,'2026-06-30 07:36:38','achievement',0,0),(37,69,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1782805620138-661652005.png','[\"#thanhTich\", \"#achievement\"]',NULL,1,'2026-06-30 07:47:02','achievement',0,0),(38,12,'Có vẻ không hiếm lắm','http://10.0.2.2:3000/uploads/1782968014884-286787113.png',NULL,NULL,1,'2026-07-02 04:53:58','achievement',0,0),(39,12,'? 3 ngày liên tiếp\nDuy trì streak 3 ngày liên tiếp','http://10.0.2.2:3000/uploads/1782969707263-965743358.png',NULL,NULL,1,'2026-07-02 05:21:52','achievement',0,0),(40,70,'? Đa nhiệm\nTạo 5 thói quen\nHo Ly Minh Lu Hihi','http://10.0.2.2:3000/uploads/1783070562714-631089041.png',NULL,NULL,1,'2026-07-03 09:23:13','achievement',0,0),(41,74,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1783135247091-17003728.png',NULL,NULL,1,'2026-07-04 03:20:54','achievement',0,0),(42,74,'Wowwwwwwww\n? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1783136370064-601914745.png',NULL,NULL,1,'2026-07-04 03:39:45','achievement',0,0),(43,74,'Hi mọi người\n? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1783137036389-450350688.png',NULL,NULL,1,'2026-07-04 03:50:58','achievement',0,0);
/*!40000 ALTER TABLE `community_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `habit_logs`
--

DROP TABLE IF EXISTS `habit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `habit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `habit_id` int NOT NULL,
  `user_id` int NOT NULL DEFAULT '0',
  `log_date` date NOT NULL,
  `value` int DEFAULT '0',
  `is_completed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `note` text COLLATE utf8mb4_unicode_ci,
  `metric_value` decimal(10,2) DEFAULT NULL,
  `metric_unit` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `habit_id` (`habit_id`,`log_date`),
  UNIQUE KEY `unique_log` (`habit_id`,`log_date`),
  KEY `idx_logs_habit` (`habit_id`),
  KEY `idx_habit_logs_date` (`log_date`),
  CONSTRAINT `habit_logs_ibfk_1` FOREIGN KEY (`habit_id`) REFERENCES `habits` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=318 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habit_logs`
--

LOCK TABLES `habit_logs` WRITE;
/*!40000 ALTER TABLE `habit_logs` DISABLE KEYS */;
INSERT INTO `habit_logs` VALUES (6,2,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(7,1,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(8,3,7,'2026-04-20',0,0,'2026-04-20 09:29:15',NULL,NULL,NULL),(15,4,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(16,5,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(18,7,12,'2026-04-21',0,0,'2026-04-21 05:31:52',NULL,NULL,NULL),(19,6,12,'2026-04-21',0,0,'2026-04-21 05:31:53',NULL,NULL,NULL),(20,8,12,'2026-04-21',0,0,'2026-04-21 05:39:24',NULL,NULL,NULL),(40,3,7,'2026-04-28',0,0,'2026-04-28 06:29:14',NULL,NULL,NULL),(41,2,7,'2026-04-28',0,0,'2026-04-28 06:29:19',NULL,NULL,NULL),(42,1,7,'2026-04-28',0,0,'2026-04-28 06:30:01',NULL,NULL,NULL),(48,3,7,'2026-04-30',0,0,'2026-04-30 11:16:41',NULL,NULL,NULL),(49,8,12,'2026-04-30',0,0,'2026-04-30 11:35:42',NULL,NULL,NULL),(50,7,12,'2026-04-30',0,0,'2026-04-30 11:35:48',NULL,NULL,NULL),(65,3,7,'2026-05-10',0,0,'2026-05-10 06:19:46',NULL,NULL,NULL),(69,8,12,'2026-05-11',0,0,'2026-05-11 05:44:56',NULL,NULL,NULL),(70,7,12,'2026-05-11',0,0,'2026-05-11 05:44:58',NULL,NULL,NULL),(71,5,12,'2026-05-11',0,0,'2026-05-11 05:45:00',NULL,NULL,NULL),(72,4,12,'2026-05-12',0,0,'2026-05-12 04:49:52',NULL,NULL,NULL),(73,21,12,'2026-05-12',0,0,'2026-05-12 04:50:49',NULL,500.00,'m'),(74,22,12,'2026-05-12',0,0,'2026-05-12 05:01:49',NULL,100.00,'cal'),(75,22,12,'2026-05-13',0,0,'2026-05-13 04:38:14',NULL,150.00,'cal'),(76,21,12,'2026-05-13',0,0,'2026-05-13 04:41:30',NULL,500.00,'m'),(80,3,7,'2026-05-13',0,0,'2026-05-13 05:28:37',NULL,NULL,NULL),(81,2,7,'2026-05-13',0,0,'2026-05-13 05:31:50',NULL,100.00,'cal'),(82,1,7,'2026-05-13',0,0,'2026-05-13 05:33:43',NULL,NULL,NULL),(83,23,12,'2026-05-13',0,0,'2026-05-13 05:40:49',NULL,100.00,'ml'),(84,24,12,'2026-05-13',0,0,'2026-05-13 05:41:54',NULL,1.00,'giờ'),(96,37,25,'2026-05-26',0,0,'2026-05-26 05:19:30',NULL,NULL,NULL),(106,47,32,'2026-05-28',0,0,'2026-05-28 12:48:55',NULL,50.00,'ml'),(130,47,32,'2026-05-30',0,0,'2026-05-30 04:40:06',NULL,50.00,'ml'),(139,21,12,'2026-06-03',0,0,'2026-06-03 10:08:33',NULL,50.00,'m'),(142,47,32,'2026-06-03',0,0,'2026-06-03 11:05:54',NULL,100.00,'ml'),(143,24,12,'2026-06-03',0,0,'2026-06-03 11:37:14',NULL,2.00,'giờ'),(144,24,12,'2026-06-04',0,0,'2026-06-04 07:56:39',NULL,NULL,'giờ'),(145,23,12,'2026-06-04',0,0,'2026-06-04 07:56:44',NULL,NULL,'ml'),(146,22,12,'2026-06-04',0,0,'2026-06-04 07:56:46',NULL,NULL,'cal'),(149,75,45,'2026-06-06',0,0,'2026-06-06 04:46:05',NULL,90.00,'cal'),(152,77,47,'2026-06-10',0,0,'2026-06-10 04:50:30',NULL,500.00,'m'),(153,24,12,'2026-06-10',0,0,'2026-06-10 05:39:33',NULL,1.00,'giờ'),(154,79,43,'2026-06-10',0,0,'2026-06-10 06:12:19',NULL,120.00,'m'),(155,78,43,'2026-06-10',0,0,'2026-06-10 06:14:35',NULL,80.00,'m'),(156,80,7,'2026-06-10',0,0,'2026-06-10 10:06:18',NULL,200.00,'m'),(157,81,43,'2026-06-10',0,0,'2026-06-10 10:08:31',NULL,400.00,'ml'),(158,82,43,'2026-06-10',0,0,'2026-06-10 10:09:32',NULL,120.00,'cal'),(159,83,43,'2026-06-10',0,0,'2026-06-10 10:10:10',NULL,8.00,'giờ'),(160,84,43,'2026-06-10',0,0,'2026-06-10 10:10:41',NULL,NULL,NULL),(161,86,43,'2026-06-10',0,0,'2026-06-10 10:37:18',NULL,NULL,NULL),(162,87,43,'2026-06-10',0,0,'2026-06-10 10:37:51',NULL,NULL,NULL),(163,23,12,'2026-06-10',0,0,'2026-06-10 10:43:59',NULL,200.00,'ml'),(164,22,12,'2026-06-10',0,0,'2026-06-10 10:44:04',NULL,120.00,'cal'),(165,21,12,'2026-06-10',0,0,'2026-06-10 10:44:10',NULL,100.00,'m'),(166,88,12,'2026-06-10',0,0,'2026-06-10 11:02:22',NULL,NULL,NULL),(167,89,12,'2026-06-10',0,0,'2026-06-10 11:03:40',NULL,NULL,NULL),(168,73,32,'2026-06-10',0,0,'2026-06-10 11:08:38',NULL,70.00,'m'),(169,47,32,'2026-06-10',0,0,'2026-06-10 11:09:02',NULL,200.00,'ml'),(170,90,32,'2026-06-10',0,0,'2026-06-10 11:14:41',NULL,NULL,NULL),(171,91,32,'2026-06-10',0,0,'2026-06-10 11:24:13',NULL,NULL,NULL),(172,92,32,'2026-06-10',0,0,'2026-06-10 11:24:49',NULL,NULL,'m'),(173,76,47,'2026-06-10',0,0,'2026-06-10 11:37:50',NULL,200.00,'m'),(174,93,47,'2026-06-10',0,0,'2026-06-10 11:39:07',NULL,7.00,'giờ'),(175,94,47,'2026-06-10',0,0,'2026-06-10 11:39:16',NULL,600.00,'ml'),(176,95,47,'2026-06-10',0,0,'2026-06-10 11:39:19',NULL,NULL,NULL),(177,96,47,'2026-06-10',0,0,'2026-06-10 11:40:58',NULL,120.00,'cal'),(188,104,50,'2026-06-14',0,0,'2026-06-14 04:24:59',NULL,150.00,'ml'),(189,109,53,'2026-06-14',0,0,'2026-06-14 09:52:57',NULL,123.00,'cal'),(190,108,53,'2026-06-14',0,0,'2026-06-14 09:53:07',NULL,400.00,'m'),(191,111,54,'2026-06-14',0,0,'2026-06-14 10:17:19',NULL,120.00,'cal'),(192,110,54,'2026-06-14',0,0,'2026-06-14 10:17:35',NULL,120.00,'cal'),(193,113,54,'2026-06-14',0,0,'2026-06-14 11:46:01',NULL,142.00,'ml'),(194,114,54,'2026-06-14',0,0,'2026-06-14 12:10:36',NULL,200.00,'ml'),(195,116,54,'2026-06-14',0,0,'2026-06-14 12:17:07',NULL,100.00,'ml'),(196,117,54,'2026-06-14',0,0,'2026-06-14 12:26:15',NULL,100.00,'ml'),(197,118,54,'2026-06-14',0,0,'2026-06-14 12:37:59',NULL,100.00,'ml'),(198,119,54,'2026-06-14',0,0,'2026-06-14 12:39:09',NULL,500.00,'ml'),(218,140,6,'2026-06-19',0,0,'2026-06-19 04:52:26',NULL,100.00,'ml'),(219,141,6,'2026-06-19',0,1,'2026-06-19 07:40:29',NULL,200.00,'ml'),(220,23,12,'2026-06-19',0,1,'2026-06-19 07:43:53',NULL,1.00,'ml'),(221,24,12,'2026-06-19',0,1,'2026-06-19 07:44:05',NULL,12.00,'phút'),(222,22,12,'2026-06-19',0,1,'2026-06-19 07:44:18',NULL,12.00,'cal'),(223,21,12,'2026-06-19',0,1,'2026-06-19 07:44:48',NULL,200.00,'m'),(224,142,12,'2026-06-19',0,1,'2026-06-19 07:55:14',NULL,10.00,'phút'),(225,146,6,'2026-06-19',0,1,'2026-06-19 08:30:32',NULL,10.00,'m'),(226,145,12,'2026-06-19',0,1,'2026-06-19 08:32:00',NULL,100.00,'ml'),(227,144,12,'2026-06-19',0,1,'2026-06-19 08:32:59',NULL,10.00,'m'),(228,143,12,'2026-06-19',0,1,'2026-06-19 08:33:04',NULL,10.00,'m'),(229,151,6,'2026-06-19',0,1,'2026-06-19 09:47:22',NULL,15.00,'phút'),(230,151,6,'2026-06-21',0,1,'2026-06-21 04:55:52',NULL,20.00,'phút'),(231,146,6,'2026-06-21',0,1,'2026-06-21 04:58:45',NULL,20.00,'phút'),(232,141,6,'2026-06-21',0,1,'2026-06-21 04:58:58',NULL,200.00,'ml'),(233,154,6,'2026-06-21',0,1,'2026-06-21 04:59:07',NULL,20.00,'phút'),(234,155,12,'2026-06-21',0,1,'2026-06-21 05:10:39',NULL,700.00,'ml'),(235,157,12,'2026-06-21',0,1,'2026-06-21 05:16:19',NULL,10.00,'phút'),(236,156,12,'2026-06-21',0,1,'2026-06-21 05:17:07',NULL,500.00,'ml'),(237,158,12,'2026-06-21',0,1,'2026-06-21 05:30:27',NULL,2000.00,'ml'),(238,159,12,'2026-06-21',0,1,'2026-06-21 05:34:53',NULL,100.00,'ml'),(239,160,12,'2026-06-21',0,1,'2026-06-21 05:35:12',NULL,100.00,'ml'),(240,161,12,'2026-06-21',0,1,'2026-06-21 05:36:23',NULL,600.00,'ml'),(241,162,12,'2026-06-21',0,1,'2026-06-21 07:53:38',NULL,25.00,'phút'),(242,163,12,'2026-06-21',0,1,'2026-06-21 07:55:31',NULL,2200.00,'ml'),(243,164,12,'2026-06-21',0,1,'2026-06-21 08:05:38',NULL,100.00,'ml'),(244,165,12,'2026-06-21',0,1,'2026-06-21 08:09:12',NULL,100.00,'ml'),(245,154,6,'2026-06-22',0,1,'2026-06-22 05:09:59',NULL,20.00,'phút'),(246,141,6,'2026-06-22',0,1,'2026-06-22 05:11:18',NULL,200.00,'ml'),(247,166,6,'2026-06-22',0,1,'2026-06-22 05:11:48',NULL,30.00,'phút'),(248,167,6,'2026-06-22',0,1,'2026-06-22 05:19:01',NULL,20.00,'phút'),(249,168,6,'2026-06-22',0,1,'2026-06-22 05:19:23',NULL,5.00,NULL),(250,168,6,'2026-06-24',0,1,'2026-06-24 04:55:59',NULL,5.00,NULL),(251,167,6,'2026-06-24',0,1,'2026-06-24 04:56:05',NULL,20.00,'phút'),(252,141,6,'2026-06-24',0,1,'2026-06-24 04:59:20',NULL,200.00,'ml'),(253,169,6,'2026-06-24',0,1,'2026-06-24 05:03:42',NULL,300.00,'ml'),(254,170,6,'2026-06-24',0,1,'2026-06-24 05:18:24',NULL,400.00,'ml'),(255,171,6,'2026-06-24',0,1,'2026-06-24 05:23:46',NULL,30.00,'phút'),(256,174,56,'2026-06-24',0,1,'2026-06-24 07:04:34',NULL,170.00,'cal'),(257,177,57,'2026-06-24',0,1,'2026-06-24 07:06:24',NULL,140.00,'cal'),(258,180,58,'2026-06-24',0,1,'2026-06-24 08:09:34',NULL,1.00,'cal'),(259,183,60,'2026-06-24',0,1,'2026-06-24 08:28:10',NULL,1.00,'cal'),(260,186,61,'2026-06-24',0,1,'2026-06-24 08:34:28',NULL,1.00,'cal'),(261,188,62,'2026-06-24',0,1,'2026-06-24 08:35:53',NULL,100.00,'ml'),(262,191,63,'2026-06-25',0,1,'2026-06-25 07:35:59',NULL,300.00,'cal'),(263,190,63,'2026-06-25',0,1,'2026-06-25 09:20:15',NULL,11.00,'min'),(264,189,63,'2026-06-25',0,1,'2026-06-25 09:20:21',NULL,30.00,'min'),(265,192,63,'2026-06-25',0,1,'2026-06-25 09:21:21',NULL,10.00,NULL),(266,167,6,'2026-06-25',0,1,'2026-06-25 09:31:29',NULL,20.00,'phút'),(267,168,6,'2026-06-25',0,1,'2026-06-25 09:49:09',NULL,5.00,NULL),(268,141,6,'2026-06-25',0,1,'2026-06-25 09:49:15',NULL,300.00,'ml'),(269,168,6,'2026-06-26',0,1,'2026-06-26 09:25:25',NULL,5.00,NULL),(270,167,6,'2026-06-26',0,1,'2026-06-26 09:25:48',NULL,20.00,'min'),(271,193,65,'2026-06-27',0,1,'2026-06-27 05:08:12',NULL,1.00,'phút'),(272,168,6,'2026-06-28',0,1,'2026-06-28 09:10:34',NULL,5.00,NULL),(273,167,6,'2026-06-28',0,1,'2026-06-28 09:11:18',NULL,25.00,'phút'),(274,196,66,'2026-06-28',0,1,'2026-06-28 09:36:55',NULL,2.00,'cal'),(275,194,66,'2026-06-28',0,1,'2026-06-28 09:37:05',NULL,1.00,NULL),(276,141,6,'2026-06-28',0,0,'2026-06-28 09:38:29',NULL,100.00,'ml'),(277,167,6,'2026-06-29',0,0,'2026-06-29 09:40:18',NULL,10.00,'phút'),(278,199,67,'2026-06-29',0,1,'2026-06-29 13:19:45',NULL,10.00,'phút'),(279,201,68,'2026-06-29',0,1,'2026-06-29 13:30:34',NULL,30.00,'phút'),(280,203,69,'2026-06-30',0,1,'2026-06-30 07:36:29',NULL,30.00,'phút'),(281,162,12,'2026-07-01',0,0,'2026-07-01 07:17:09',NULL,12.00,'phút'),(282,162,12,'2026-07-02',0,0,'2026-07-02 04:49:45',NULL,20.00,'phút'),(283,208,70,'2026-07-03',0,1,'2026-07-03 09:19:03',NULL,120.00,'phút'),(284,207,70,'2026-07-03',0,1,'2026-07-03 09:19:15',NULL,1.00,'phút'),(285,206,70,'2026-07-03',0,1,'2026-07-03 09:19:21',NULL,1.00,'cal'),(286,209,70,'2026-07-03',0,1,'2026-07-03 09:21:27',NULL,111.00,'phút'),(287,210,70,'2026-07-03',0,1,'2026-07-03 09:21:34',NULL,44.00,'phút'),(288,211,70,'2026-07-03',0,1,'2026-07-03 09:25:39',NULL,20.00,NULL),(289,211,70,'2026-07-04',0,1,'2026-07-04 09:30:20',NULL,20.00,NULL),(290,210,70,'2026-07-04',0,1,'2026-07-04 09:30:24',NULL,35.00,'phút'),(291,209,70,'2026-07-04',0,1,'2026-07-04 09:34:09',NULL,90.00,'phút'),(292,208,70,'2026-07-04',0,1,'2026-07-04 09:34:12',NULL,120.00,'phút'),(293,207,70,'2026-07-04',0,1,'2026-07-04 09:34:15',NULL,1.00,'phút'),(294,206,70,'2026-07-04',0,1,'2026-07-04 09:34:17',NULL,1.00,'cal'),(295,213,70,'2026-07-04',0,1,'2026-07-04 09:35:57',NULL,800.00,'cal'),(296,212,70,'2026-07-04',0,1,'2026-07-04 09:36:00',NULL,800.00,'ml'),(297,214,70,'2026-07-04',0,1,'2026-07-04 09:36:38',NULL,2.00,NULL),(298,216,71,'2026-07-04',0,1,'2026-07-04 10:27:51',NULL,1.00,NULL),(299,217,72,'2026-07-05',0,1,'2026-07-05 02:35:06',NULL,60.00,'ml'),(300,223,73,'2026-07-04',0,1,'2026-07-04 03:01:15',NULL,2000.00,'cal'),(301,225,74,'2026-07-04',0,1,'2026-07-04 03:14:55',NULL,30.00,'phút'),(302,227,74,'2026-07-04',0,1,'2026-07-04 06:50:42',NULL,1.00,NULL),(303,226,74,'2026-07-04',0,1,'2026-07-04 06:50:49',NULL,30.00,'phút'),(304,224,74,'2026-07-04',0,1,'2026-07-04 06:50:53',NULL,1.00,'phút'),(305,228,74,'2026-07-04',0,1,'2026-07-04 07:01:52',NULL,1400.00,'cal'),(306,229,75,'2026-07-04',0,1,'2026-07-04 07:42:58',NULL,100.00,'phút'),(307,231,75,'2026-07-04',0,1,'2026-07-04 07:43:11',NULL,59.00,'phút'),(308,232,75,'2026-07-04',0,1,'2026-07-04 07:43:16',NULL,1000.00,'cal'),(309,233,75,'2026-07-04',0,1,'2026-07-04 07:43:20',NULL,10.00,'phút'),(310,234,75,'2026-07-04',0,1,'2026-07-04 07:43:23',NULL,10.00,NULL),(311,235,75,'2026-07-04',0,1,'2026-07-04 08:38:13',NULL,20.00,'phút'),(312,230,75,'2026-07-04',0,0,'2026-07-04 08:38:21',NULL,100.00,'ml'),(313,238,76,'2026-07-04',0,1,'2026-07-04 09:59:50',NULL,20.00,'phút'),(314,236,76,'2026-07-04',0,1,'2026-07-04 09:59:58',NULL,520.00,'phút'),(315,237,76,'2026-07-04',0,1,'2026-07-04 10:00:17',NULL,40.00,'phút'),(316,239,76,'2026-07-04',0,1,'2026-07-04 10:00:49',NULL,300.00,'ml'),(317,240,76,'2026-07-04',0,1,'2026-07-04 10:02:38',NULL,20.00,'phút');
/*!40000 ALTER TABLE `habit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `habits`
--

DROP TABLE IF EXISTS `habits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `habits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('eat','exercise','sleep','mental','hydration','other') COLLATE utf8mb4_unicode_ci DEFAULT 'other',
  `target_value` int DEFAULT '1',
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reminder_time` time DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `icon` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT '⭐',
  `color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '#4CAF50',
  `frequency` enum('daily','weekly') COLLATE utf8mb4_unicode_ci DEFAULT 'daily',
  `target_count` int DEFAULT '1',
  `current_streak` int DEFAULT '0',
  `longest_streak` int DEFAULT '0',
  `last_completed_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_habits_user` (`user_id`),
  KEY `idx_habits_user_active` (`user_id`,`is_active`),
  CONSTRAINT `habits_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habits`
--

LOCK TABLES `habits` WRITE;
/*!40000 ALTER TABLE `habits` DISABLE KEYS */;
INSERT INTO `habits` VALUES (1,7,'aa','other',1,NULL,NULL,0,'2026-04-20 09:24:10','⭐','#4CAF50','daily',1,1,1,'2026-05-13'),(2,7,'b','eat',1,NULL,NULL,0,'2026-04-20 09:24:33','?','#4CAF50','daily',1,1,1,'2026-05-13'),(3,7,'c','other',1,NULL,NULL,0,'2026-04-20 09:29:10','?','#4CAF50','daily',1,1,1,'2026-05-13'),(4,12,'testphone','other',1,NULL,NULL,0,'2026-04-21 05:27:55','⭐','#4CAF50','daily',1,1,1,'2026-05-12'),(5,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:28:09','?','#4CAF50','daily',1,1,1,'2026-05-11'),(6,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:31:39','⭐','#4CAF50','daily',1,0,0,NULL),(7,12,'ok','other',1,NULL,NULL,0,'2026-04-21 05:31:45','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(8,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:37:23','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(21,12,'Chạy bộ','exercise',1,NULL,NULL,0,'2026-05-12 04:50:35','?','#4CAF50','daily',1,1,1,'2026-06-19'),(22,12,'Ăn healthy','eat',1,NULL,NULL,0,'2026-05-12 05:01:36','?','#4CAF50','daily',1,1,1,'2026-06-19'),(23,12,'Uống nước','hydration',1,NULL,NULL,0,'2026-05-13 05:40:31','?','#4CAF50','daily',1,1,1,'2026-06-19'),(24,12,'Ngủ trưa','sleep',1,NULL,NULL,0,'2026-05-13 05:41:45','?','#4CAF50','daily',1,1,1,'2026-06-19'),(37,25,'Học tập 1 giờ','other',1,NULL,NULL,1,'2026-05-26 05:19:15','✏️','#4CAF50','daily',1,1,1,'2026-05-26'),(47,32,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-05-28 12:48:45','?','#4CAF50','daily',1,1,1,'2026-06-10'),(73,32,'Chạy 500m','exercise',1,NULL,NULL,1,'2026-05-30 04:40:18','?','#4CAF50','daily',1,1,1,'2026-06-10'),(74,45,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-06 04:45:48','?','#4CAF50','daily',1,0,0,NULL),(75,45,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-06 04:45:49','?','#4CAF50','daily',1,1,1,'2026-06-06'),(76,47,'Vận động 30 phút','exercise',1,NULL,NULL,0,'2026-06-10 04:50:13','?','#4CAF50','daily',1,1,1,'2026-06-10'),(77,47,'Đi bộ 20 phút','exercise',1,NULL,NULL,0,'2026-06-10 04:50:14','?','#4CAF50','daily',1,1,1,'2026-06-10'),(78,43,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-10 06:12:09','?','#4CAF50','daily',1,1,1,'2026-06-10'),(79,43,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-10 06:12:10','?','#4CAF50','daily',1,1,1,'2026-06-10'),(80,7,'Chạy 200m','exercise',1,NULL,NULL,1,'2026-06-10 10:05:47','?','#4CAF50','daily',1,1,1,'2026-06-10'),(81,43,'Uống 2l nước','hydration',1,NULL,NULL,1,'2026-06-10 10:08:23','?','#4CAF50','daily',1,1,1,'2026-06-10'),(82,43,'Ăn 2 đĩa rau','eat',1,NULL,NULL,1,'2026-06-10 10:09:16','?','#4CAF50','daily',1,1,1,'2026-06-10'),(83,43,'Ngủ đủ 8 tiếng','sleep',1,NULL,NULL,1,'2026-06-10 10:10:04','?','#4CAF50','daily',1,1,1,'2026-06-10'),(84,43,'Thiền 20 phút','mental',1,NULL,NULL,1,'2026-06-10 10:10:36','?','#4CAF50','daily',1,1,1,'2026-06-10'),(85,43,'Đọc sách 20 phút','other',1,NULL,NULL,0,'2026-06-10 10:36:52','?','#4CAF50','daily',1,0,0,NULL),(86,43,'Đọc sách 20 phút','other',1,NULL,NULL,0,'2026-06-10 10:37:12','?','#4CAF50','daily',1,1,1,'2026-06-10'),(87,43,'Đọc sách 10 phút','other',1,NULL,NULL,1,'2026-06-10 10:37:48','?','#4CAF50','daily',1,1,1,'2026-06-10'),(88,12,'hehe','other',1,NULL,NULL,0,'2026-06-10 11:02:16','?','#4CAF50','daily',1,1,1,'2026-06-10'),(89,12,'ci ly','other',1,NULL,NULL,0,'2026-06-10 11:03:37','?','#4CAF50','daily',1,1,1,'2026-06-10'),(90,32,'Đọc sách 20 phút','other',1,NULL,NULL,1,'2026-06-10 11:14:30','?','#4CAF50','daily',1,1,1,'2026-06-10'),(91,32,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-10 11:24:06','?','#4CAF50','daily',1,1,1,'2026-06-10'),(92,32,'Tập gym','exercise',1,NULL,NULL,1,'2026-06-10 11:24:37','?','#4CAF50','daily',1,1,1,'2026-06-10'),(93,47,'Ngủ đủ giấc','sleep',1,NULL,NULL,0,'2026-06-10 11:38:30','?','#4CAF50','daily',1,1,1,'2026-06-10'),(94,47,'Uống đủ nước','hydration',1,NULL,NULL,0,'2026-06-10 11:38:43','?','#4CAF50','daily',1,1,1,'2026-06-10'),(95,47,'Thiền 20 phút','mental',1,NULL,NULL,0,'2026-06-10 11:39:03','?','#4CAF50','daily',1,1,1,'2026-06-10'),(96,47,'Ăn rau','eat',1,NULL,NULL,0,'2026-06-10 11:40:51','?','#4CAF50','daily',1,1,1,'2026-06-10'),(101,48,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-11 04:19:05','?','#4CAF50','daily',1,0,0,NULL),(104,50,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-06-14 04:24:49','?','#4CAF50','daily',1,1,1,'2026-06-14'),(105,51,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-14 04:35:06','?','#4CAF50','daily',1,0,0,NULL),(106,51,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-14 04:35:08','?','#4CAF50','daily',1,0,0,NULL),(107,52,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-14 04:45:45','?','#4CAF50','daily',1,0,0,NULL),(108,53,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-14 05:05:49','?','#4CAF50','daily',1,1,1,'2026-06-14'),(109,53,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-14 05:05:50','?','#4CAF50','daily',1,1,1,'2026-06-14'),(110,54,'Ăn sáng lành mạnh','eat',1,NULL,NULL,0,'2026-06-14 10:16:54','?','#4CAF50','daily',1,1,1,'2026-06-14'),(111,54,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,0,'2026-06-14 10:16:55','?','#4CAF50','daily',1,1,1,'2026-06-14'),(112,54,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-14 11:40:01','?','#4CAF50','daily',1,0,0,NULL),(113,54,'Uống 1 ly nước','hydration',1,NULL,NULL,0,'2026-06-14 11:41:16','?','#4CAF50','daily',1,1,1,'2026-06-14'),(114,54,'Uống nước','hydration',1,NULL,NULL,0,'2026-06-14 12:10:29','?','#4CAF50','daily',700,1,1,'2026-06-14'),(115,54,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-06-14 12:16:17','?','#4CAF50','daily',10,0,0,NULL),(116,54,'Uống nước hàng ngày','hydration',1,NULL,NULL,0,'2026-06-14 12:17:00','?','#4CAF50','daily',600,1,1,'2026-06-14'),(117,54,'Uống nước mỗi buổi sáng','hydration',1,NULL,NULL,0,'2026-06-14 12:26:10','?','#4CAF50','daily',400,1,1,'2026-06-14'),(118,54,'Uống nước buổi sáng','hydration',1,NULL,NULL,1,'2026-06-14 12:37:53','?','#4CAF50','daily',400,1,1,'2026-06-14'),(119,54,'Uống nước buổi chiều','hydration',1,NULL,NULL,1,'2026-06-14 12:39:04','?','#4CAF50','daily',2000,1,1,'2026-06-14'),(140,6,'Uống 200ml nước buổi trưa','hydration',1,NULL,'11:50:00',0,'2026-06-19 04:46:12','?','#4CAF50','daily',200,0,0,NULL),(141,6,'Uống 200 ml buổi trưa','hydration',1,NULL,'16:30:00',1,'2026-06-19 07:40:04','?','#4CAF50','daily',200,2,2,'2026-06-25'),(142,12,'Ngủ trưa 10 phút 2h55','sleep',1,NULL,'14:55:00',0,'2026-06-19 07:55:07','?','#4CAF50','daily',10,1,1,'2026-06-19'),(143,12,'Chạy bộ 10 phút tại nhà','exercise',1,NULL,'15:07:00',0,'2026-06-19 08:05:27','?','#4CAF50','daily',10,1,1,'2026-06-19'),(144,12,'Chạy bộ 10 phút','exercise',1,NULL,'15:15:00',0,'2026-06-19 08:12:24','?','#4CAF50','daily',5,1,1,'2026-06-19'),(145,12,'Uông nước 3h16','hydration',1,NULL,'15:17:00',0,'2026-06-19 08:16:18','?','#4CAF50','daily',100,1,1,'2026-06-19'),(146,6,'Chạy bộ 10 phút tại nhà','exercise',1,NULL,'15:25:00',0,'2026-06-19 08:22:42','?','#4CAF50','daily',10,1,1,'2026-06-21'),(147,55,'Ăn xế','eat',1,NULL,'16:35:00',1,'2026-06-19 09:21:12','?','#4CAF50','daily',700,0,0,NULL),(148,55,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-19 09:21:12','?','#4CAF50','daily',200,0,0,NULL),(149,55,'Vận động 30 phút','exercise',1,NULL,'16:35:00',1,'2026-06-19 09:21:13','?','#4CAF50','daily',30,0,0,NULL),(150,12,'Ngủ chiều 4h41','sleep',1,NULL,'16:41:00',0,'2026-06-19 09:40:54','?','#4CAF50','daily',15,0,0,NULL),(151,6,'Chạy chiều 4h45','exercise',1,NULL,'16:45:00',0,'2026-06-19 09:42:44','?','#4CAF50','daily',15,1,1,'2026-06-21'),(152,6,'Ăn trưa','eat',1,NULL,'11:12:00',0,'2026-06-21 04:12:18','?','#4CAF50','daily',1000,0,0,NULL),(153,6,'test','hydration',1,NULL,'11:31:00',0,'2026-06-21 04:30:45','?','#4CAF50','daily',2000,0,0,NULL),(154,6,'Chạy','exercise',1,NULL,'11:50:00',0,'2026-06-21 04:34:21','?','#4CAF50','daily',20,2,2,'2026-06-22'),(155,12,'Uống nước','hydration',1,NULL,'13:11:00',1,'2026-06-21 05:01:46','?','#4CAF50','daily',700,1,1,'2026-06-21'),(156,12,'Uống nước','hydration',1,NULL,'14:20:00',0,'2026-06-21 05:09:53','?','#4CAF50','daily',499,1,1,'2026-06-21'),(157,12,'Chạy bộ','exercise',1,NULL,'12:15:00',0,'2026-06-21 05:12:04','?','#4CAF50','daily',10,1,1,'2026-06-21'),(158,12,'tt','hydration',1,NULL,'08:00:00',0,'2026-06-21 05:30:22','?','#4CAF50','daily',2000,1,1,'2026-06-21'),(159,12,'tt','hydration',1,NULL,'08:00:00',0,'2026-06-21 05:34:48','?','#4CAF50','daily',100,1,1,'2026-06-21'),(160,12,'yy','hydration',1,NULL,'08:00:00',0,'2026-06-21 05:35:07','?','#4CAF50','daily',100,1,1,'2026-06-21'),(161,12,'uu','hydration',1,NULL,'08:00:00',0,'2026-06-21 05:36:17','?','#4CAF50','daily',600,1,1,'2026-06-21'),(162,12,'Ngủ trưa','sleep',1,NULL,'14:15:00',1,'2026-06-21 07:26:51','?','#4CAF50','daily',25,1,1,'2026-06-21'),(163,12,'tet','hydration',1,NULL,'08:00:00',0,'2026-06-21 07:55:25','?','#4CAF50','daily',2000,1,1,'2026-06-21'),(164,12,'tt','hydration',1,NULL,'08:00:00',0,'2026-06-21 08:05:31','?','#4CAF50','daily',100,1,1,'2026-06-21'),(165,12,'t','hydration',1,NULL,'08:00:00',0,'2026-06-21 08:09:05','?','#4CAF50','daily',100,1,1,'2026-06-21'),(166,6,'ngủ trưa','sleep',1,NULL,'08:00:00',0,'2026-06-22 05:11:44','?','#4CAF50','daily',20,1,1,'2026-06-22'),(167,6,'Ngủ trưa','sleep',1,NULL,'08:00:00',1,'2026-06-22 05:18:57','?','#4CAF50','daily',20,1,1,'2026-06-28'),(168,6,'Thiền','mental',1,NULL,'08:00:00',1,'2026-06-22 05:19:19','?','#4CAF50','daily',100,1,1,'2026-06-28'),(169,6,'test','hydration',1,NULL,'12:01:00',0,'2026-06-24 05:00:44','?','#4CAF50','daily',300,1,1,'2026-06-24'),(170,6,'test','hydration',1,NULL,'12:05:00',0,'2026-06-24 05:04:15','?','#4CAF50','daily',400,1,1,'2026-06-24'),(171,6,'demo','exercise',1,NULL,'12:20:00',0,'2026-06-24 05:18:15','?','#4CAF50','daily',30,1,1,'2026-06-24'),(172,56,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-24 07:04:15','?','#4CAF50','daily',1,0,0,NULL),(173,56,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-24 07:04:16','?','#4CAF50','daily',1,0,0,NULL),(174,56,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-24 07:04:17','?','#4CAF50','daily',1,1,1,'2026-06-24'),(175,57,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-06-24 07:06:13','?','#4CAF50','daily',1,0,0,NULL),(176,57,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-24 07:06:14','?','#4CAF50','daily',1,0,0,NULL),(177,57,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-24 07:06:15','?','#4CAF50','daily',1,1,1,'2026-06-24'),(178,58,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-06-24 08:09:22','?','#4CAF50','daily',1,0,0,NULL),(179,58,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-24 08:09:23','?','#4CAF50','daily',1,0,0,NULL),(180,58,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-24 08:09:24','?','#4CAF50','daily',1,1,1,'2026-06-24'),(181,60,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-24 08:28:01','?','#4CAF50','daily',1,0,0,NULL),(182,60,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-24 08:28:02','?','#4CAF50','daily',1,0,0,NULL),(183,60,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-24 08:28:03','?','#4CAF50','daily',1,1,1,'2026-06-24'),(184,61,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-24 08:34:18','?','#4CAF50','daily',1,0,0,NULL),(185,61,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-24 08:34:19','?','#4CAF50','daily',1,0,0,NULL),(186,61,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-24 08:34:20','?','#4CAF50','daily',1,1,1,'2026-06-24'),(187,62,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-24 08:35:37','?','#4CAF50','daily',1,0,0,NULL),(188,62,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-06-24 08:35:38','?','#4CAF50','daily',1,1,1,'2026-06-24'),(189,63,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-25 07:14:25','?','#4CAF50','daily',1,1,1,'2026-06-25'),(190,63,'Đi bộ 20 phút','exercise',1,NULL,'15:30:00',1,'2026-06-25 07:14:26','?','#4CAF50','daily',1,1,1,'2026-06-25'),(191,63,'Ăn sáng lành mạnh','eat',1,NULL,'14:30:00',1,'2026-06-25 07:14:27','?','#4CAF50','daily',300,1,1,'2026-06-25'),(192,63,'Thiền 10 phút','mental',1,NULL,'08:00:00',1,'2026-06-25 09:21:14','?','#4CAF50','daily',10,1,1,'2026-06-25'),(193,65,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-27 05:07:44','?','#4CAF50','daily',1,1,1,'2026-06-27'),(194,66,'Thiền','mental',1,NULL,NULL,1,'2026-06-28 09:36:40','?','#4CAF50','daily',1,1,1,'2026-06-28'),(195,66,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-28 09:36:41','?','#4CAF50','daily',1,0,0,NULL),(196,66,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-28 09:36:42','?','#4CAF50','daily',1,1,1,'2026-06-28'),(197,6,'thư giãn','mental',1,NULL,'08:00:00',1,'2026-06-29 09:42:57','?','#4CAF50','daily',100,0,0,NULL),(198,67,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-29 13:19:30','?','#4CAF50','daily',1,0,0,NULL),(199,67,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-29 13:19:31','?','#4CAF50','daily',1,1,1,'2026-06-29'),(200,68,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-29 13:30:25','?','#4CAF50','daily',1,0,0,NULL),(201,68,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-29 13:30:26','?','#4CAF50','daily',1,1,1,'2026-06-29'),(202,69,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-30 07:36:20','?','#4CAF50','daily',1,0,0,NULL),(203,69,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-30 07:36:21','?','#4CAF50','daily',1,1,1,'2026-06-30'),(204,12,'demo','hydration',1,NULL,'08:00:00',0,'2026-07-01 07:36:41','?','#4CAF50','daily',499,0,0,NULL),(205,12,'ok','hydration',1,NULL,'08:00:00',0,'2026-07-01 07:40:03','?','#4CAF50','daily',2000,0,0,NULL),(206,70,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-07-03 09:08:39','?','#4CAF50','daily',1,2,2,'2026-07-04'),(207,70,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-07-03 09:08:40','?','#4CAF50','daily',1,2,2,'2026-07-04'),(208,70,'The duc nhe truoc khi ngu','exercise',1,NULL,'16:20:00',1,'2026-07-03 09:17:06','?','#4CAF50','daily',120,2,2,'2026-07-04'),(209,70,'The duc buoi sang','exercise',1,NULL,'07:00:00',1,'2026-07-03 09:20:22','?','#4CAF50','daily',90,2,2,'2026-07-04'),(210,70,'Ngu trua ti','sleep',1,NULL,'12:00:00',1,'2026-07-03 09:21:07','?','#4CAF50','daily',35,2,2,'2026-07-04'),(211,70,'Ngoi thien','mental',1,NULL,'08:00:00',1,'2026-07-03 09:25:35','?','#4CAF50','daily',20,2,2,'2026-07-04'),(212,70,'Uong du nuoc','hydration',1,NULL,'08:00:00',1,'2026-07-04 09:35:21','?','#4CAF50','daily',800,1,1,'2026-07-04'),(213,70,'An dung gio','eat',1,NULL,'08:00:00',1,'2026-07-04 09:35:53','?','#4CAF50','daily',800,1,1,'2026-07-04'),(214,70,'Ngu bu','other',1,NULL,'08:00:00',1,'2026-07-04 09:36:34','?','#4CAF50','daily',2,1,1,'2026-07-04'),(215,71,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-07-04 10:25:08','?','#4CAF50','daily',1,0,0,NULL),(216,71,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-07-04 10:25:09','?','#4CAF50','daily',1,1,1,'2026-07-04'),(217,72,'Uống đủ 2 lít nước','hydration',1,NULL,'09:50:00',1,'2026-07-05 02:34:45','?','#4CAF50','daily',1,1,1,'2026-07-05'),(218,72,'Ăn sáng','eat',1,NULL,'09:40:00',1,'2026-07-05 02:39:23','?','#4CAF50','daily',1000,0,0,NULL),(219,72,'Chạy bộ buổi sáng','exercise',1,NULL,'06:30:00',1,'2026-07-05 02:39:55','?','#4CAF50','daily',30,0,0,NULL),(220,72,'Ăn trưa','hydration',1,NULL,'08:00:00',1,'2026-07-04 02:49:27','?','#4CAF50','daily',400,0,0,NULL),(221,73,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-07-04 02:51:48','?','#4CAF50','daily',1,0,0,NULL),(222,73,'Đi bộ 20 phút','exercise',1,NULL,'10:05:00',1,'2026-07-04 02:51:49','?','#4CAF50','daily',30,0,0,NULL),(223,73,'Ăn sáng lành mạnh','eat',1,NULL,'10:00:00',1,'2026-07-04 02:51:50','?','#4CAF50','daily',600,1,1,'2026-07-04'),(224,74,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-07-04 03:14:29','?','#4CAF50','daily',1,1,1,'2026-07-04'),(225,74,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-07-04 03:14:30','?','#4CAF50','daily',30,1,1,'2026-07-04'),(226,74,'Chạy bộ','exercise',1,NULL,'10:54:00',1,'2026-07-04 03:52:07','?','#4CAF50','daily',20,1,1,'2026-07-04'),(227,74,'Đọc sách','other',1,NULL,'13:50:00',1,'2026-07-04 03:58:11','?','#4CAF50','daily',1,1,1,'2026-07-04'),(228,74,'Ăn nhẹ','eat',1,NULL,'14:05:00',1,'2026-07-04 07:01:42','?','#4CAF50','daily',1300,1,1,'2026-07-04'),(229,75,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-07-04 07:39:37','?','#4CAF50','daily',1,1,1,'2026-07-04'),(230,75,'Ngủ','hydration',1,NULL,'16:46:00',1,'2026-07-04 07:40:16','?','#4CAF50','daily',700,0,0,NULL),(231,75,'Chạy bộ','exercise',1,NULL,'08:00:00',1,'2026-07-04 07:40:31','?','#4CAF50','daily',40,1,1,'2026-07-04'),(232,75,'Ăn xế','eat',1,NULL,'08:00:00',1,'2026-07-04 07:40:43','?','#4CAF50','daily',800,1,1,'2026-07-04'),(233,75,'Tập thể dục nhịp điệu','exercise',1,NULL,'08:00:00',1,'2026-07-04 07:40:59','?','#4CAF50','daily',10,1,1,'2026-07-04'),(234,75,'Thiền','mental',1,NULL,'08:00:00',1,'2026-07-04 07:42:51','?','#4CAF50','daily',10,1,1,'2026-07-04'),(235,75,'Chạy bộ','exercise',1,NULL,'15:38:00',1,'2026-07-04 08:20:07','?','#4CAF50','daily',10,1,1,'2026-07-04'),(236,76,'Ngủ trước 23h','sleep',1,NULL,NULL,1,'2026-07-04 09:59:37','?','#4CAF50','daily',480,1,1,'2026-07-04'),(237,76,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-07-04 09:59:38','?','#4CAF50','daily',30,1,1,'2026-07-04'),(238,76,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-07-04 09:59:39','?','#4CAF50','daily',20,1,1,'2026-07-04'),(239,76,'Uống 200 ml nước','hydration',1,NULL,'08:00:00',1,'2026-07-04 10:00:43','?','#4CAF50','daily',200,1,1,'2026-07-04'),(240,76,'Thiền 10 phút','mental',1,NULL,'08:00:00',1,'2026-07-04 10:01:11','?','#4CAF50','daily',10,1,1,'2026-07-04');
/*!40000 ALTER TABLE `habits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plants`
--

DROP TABLE IF EXISTS `plants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `plant_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'sprout',
  `level` int DEFAULT '1',
  `experience` int DEFAULT '0',
  `last_watered` date DEFAULT NULL,
  `exp` int DEFAULT '0',
  `health` int DEFAULT '100',
  `type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'basic',
  `last_updated` date DEFAULT NULL,
  `days_without_checkin` int DEFAULT '0' COMMENT 'Number of consecutive days without completing any habit',
  `last_penalty_date` date DEFAULT NULL COMMENT 'Last date when EXP penalty was applied',
  `is_wilted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `plants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plants`
--

LOCK TABLES `plants` WRITE;
/*!40000 ALTER TABLE `plants` DISABLE KEYS */;
INSERT INTO `plants` VALUES (2,7,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL,0),(4,12,'sunflower',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(13,25,'flower',1,3,'2026-05-26',0,100,'basic',NULL,0,NULL,0),(20,32,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL,0),(31,45,'sprout',1,2,'2026-06-06',0,100,'basic',NULL,0,NULL,0),(32,47,'sprout',3,15,'2026-06-10',0,100,'basic',NULL,0,NULL,0),(33,43,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL,0),(34,48,'sprout',1,0,NULL,0,100,'basic',NULL,0,NULL,0),(36,50,'sunflower',1,3,'2026-06-14',0,100,'basic',NULL,0,NULL,0),(37,51,'sprout',1,0,NULL,0,100,'basic',NULL,0,NULL,0),(38,52,'flower',1,0,NULL,0,100,'basic',NULL,0,NULL,0),(39,53,'sunflower',2,5,'2026-06-14',0,100,'basic',NULL,0,NULL,0),(40,54,'bamboo',2,6,'2026-06-14',0,100,'basic',NULL,0,NULL,0),(41,55,'sunflower',1,0,NULL,0,100,'basic',NULL,0,NULL,0),(42,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(43,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(44,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(45,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(46,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(47,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(48,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(49,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(50,12,'sprout',1,2,'2026-06-21',0,100,'basic',NULL,0,NULL,0),(51,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(52,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(53,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(54,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(55,6,'sunflower',3,15,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(56,56,'sunflower',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(57,57,'bamboo',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(58,58,'sunflower',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(59,60,'cactus',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(60,61,'bamboo',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(61,62,'sunflower',1,1,'2026-06-24',0,100,'basic',NULL,0,NULL,0),(62,63,'cactus',1,4,'2026-06-25',0,100,'basic',NULL,0,NULL,0),(63,65,'cactus',1,1,'2026-06-27',0,100,'basic',NULL,0,NULL,0),(64,66,'sunflower',1,2,'2026-06-28',0,100,'basic',NULL,0,NULL,0),(65,67,'sunflower',1,1,'2026-06-29',0,100,'basic',NULL,0,NULL,0),(66,68,'cactus',1,1,'2026-06-29',0,100,'basic',NULL,0,NULL,0),(67,69,'sunflower',1,1,'2026-06-30',0,100,'basic',NULL,0,NULL,0),(68,70,'bamboo',3,15,'2026-07-04',0,100,'basic',NULL,0,NULL,0),(69,71,'bamboo',1,1,'2026-07-04',0,100,'basic',NULL,0,NULL,0),(70,72,'flower',1,1,'2026-07-05',0,100,'basic',NULL,0,NULL,0),(71,73,'cactus',1,1,'2026-07-04',0,100,'basic',NULL,0,NULL,0),(72,74,'cactus',2,5,'2026-07-04',0,100,'basic',NULL,0,NULL,0),(73,75,'cactus',2,6,'2026-07-04',0,100,'basic',NULL,0,NULL,0),(74,76,'bamboo',2,5,'2026-07-04',0,100,'basic',NULL,0,NULL,0);
/*!40000 ALTER TABLE `plants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `streaks`
--

DROP TABLE IF EXISTS `streaks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `streaks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `current_streak` int DEFAULT '0',
  `longest_streak` int DEFAULT '0',
  `last_completed_date` date DEFAULT NULL,
  `freeze_tokens` int NOT NULL DEFAULT '0',
  `last_freeze_used_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `streaks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streaks`
--

LOCK TABLES `streaks` WRITE;
/*!40000 ALTER TABLE `streaks` DISABLE KEYS */;
INSERT INTO `streaks` VALUES (1,7,1,1,'2026-06-10',0,NULL),(2,12,1,3,'2026-06-21',0,NULL),(3,6,1,3,'2026-06-28',0,NULL),(9,25,1,1,'2026-05-26',0,NULL),(16,32,1,1,'2026-06-10',0,NULL),(25,45,1,1,'2026-06-06',0,NULL),(26,47,1,1,'2026-06-10',0,NULL),(27,43,1,1,'2026-06-10',0,NULL),(28,50,1,1,'2026-06-14',0,NULL),(29,53,1,1,'2026-06-14',0,NULL),(30,54,1,1,'2026-06-14',0,NULL),(31,56,1,1,'2026-06-24',0,NULL),(32,57,1,1,'2026-06-24',0,NULL),(33,58,1,1,'2026-06-24',0,NULL),(34,60,1,1,'2026-06-24',0,NULL),(35,61,1,1,'2026-06-24',0,NULL),(36,62,1,1,'2026-06-24',0,NULL),(37,63,1,1,'2026-06-25',0,NULL),(38,65,1,1,'2026-06-27',0,NULL),(39,66,1,1,'2026-06-28',0,NULL),(40,67,1,1,'2026-06-29',0,NULL),(41,68,1,1,'2026-06-29',0,NULL),(42,69,1,1,'2026-06-30',0,NULL),(43,70,2,2,'2026-07-04',0,NULL),(44,71,1,1,'2026-07-04',0,NULL),(45,72,1,1,'2026-07-05',0,NULL),(46,73,1,1,'2026-07-04',0,NULL),(47,74,1,1,'2026-07-04',0,NULL),(48,75,1,1,'2026-07-04',0,NULL),(49,76,1,1,'2026-07-04',0,NULL);
/*!40000 ALTER TABLE `streaks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_follows`
--

DROP TABLE IF EXISTS `user_follows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_follows` (
  `follower_id` int NOT NULL,
  `following_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follower_id`,`following_id`),
  KEY `following_id` (`following_id`),
  CONSTRAINT `user_follows_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_follows_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_follows`
--

LOCK TABLES `user_follows` WRITE;
/*!40000 ALTER TABLE `user_follows` DISABLE KEYS */;
INSERT INTO `user_follows` VALUES (6,7,'2026-05-31 05:11:45'),(6,12,'2026-06-15 10:33:27'),(12,6,'2026-07-02 04:52:46'),(12,32,'2026-06-03 11:09:45'),(12,43,'2026-07-01 09:19:03'),(32,12,'2026-06-03 10:54:15'),(70,6,'2026-07-03 09:18:15');
/*!40000 ALTER TABLE `user_follows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_hidden_notifications`
--

DROP TABLE IF EXISTS `user_hidden_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_hidden_notifications` (
  `user_id` int NOT NULL,
  `notification_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`notification_id`),
  CONSTRAINT `user_hidden_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_hidden_notifications`
--

LOCK TABLES `user_hidden_notifications` WRITE;
/*!40000 ALTER TABLE `user_hidden_notifications` DISABLE KEYS */;
INSERT INTO `user_hidden_notifications` VALUES (6,'comment_12_12','2026-06-20 07:38:04'),(6,'follow_12','2026-06-20 07:38:04'),(6,'like_12_12','2026-06-20 07:38:04'),(12,'comment_32_13','2026-06-21 08:23:16'),(12,'comment_6_13','2026-06-21 08:23:16'),(12,'comment_7_13','2026-06-21 08:23:16'),(12,'follow_32','2026-06-21 08:23:16'),(12,'follow_6','2026-06-21 08:23:16'),(12,'like_32_13','2026-06-21 08:23:16'),(12,'like_45_13','2026-06-21 08:23:16'),(12,'like_6_13','2026-06-21 08:23:16'),(12,'like_7_13','2026-06-21 08:23:16');
/*!40000 ALTER TABLE `user_hidden_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_notifications`
--

DROP TABLE IF EXISTS `user_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `emoji` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT 0xF09F9494,
  `payload` json DEFAULT NULL,
  `target_tab` int DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_created` (`user_id`,`created_at` DESC),
  CONSTRAINT `user_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_notifications`
--

LOCK TABLES `user_notifications` WRITE;
/*!40000 ALTER TABLE `user_notifications` DISABLE KEYS */;
INSERT INTO `user_notifications` VALUES (7,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:07'),(8,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:10'),(9,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:13'),(12,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:06'),(13,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:10'),(14,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:13'),(17,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:05'),(18,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:10'),(19,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:13'),(22,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:05'),(23,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:08'),(24,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:11'),(27,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:06'),(28,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:08'),(29,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:11'),(30,47,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:13'),(32,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:03'),(34,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:10'),(35,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:13'),(36,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:16'),(37,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:19'),(38,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:23'),(40,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:03'),(42,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:09'),(43,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:11'),(44,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:14'),(45,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:18'),(46,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:20'),(48,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:25'),(49,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:28'),(52,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:03'),(53,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:03'),(56,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:09'),(57,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:10'),(58,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:12'),(59,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:14'),(60,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:16'),(61,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:16'),(62,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:18'),(63,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:20'),(64,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:21'),(65,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:23'),(68,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:27'),(69,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:30'),(70,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:30'),(71,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:33'),(72,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:34'),(73,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:36'),(75,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:02'),(77,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:08'),(78,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:10'),(79,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:13'),(80,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:15'),(81,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:17'),(83,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:22'),(84,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:24'),(85,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:26'),(86,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:28'),(87,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:31'),(90,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:03'),(91,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:03'),(94,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:09'),(95,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:09'),(96,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:11'),(97,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:12'),(98,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:14'),(99,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:15'),(100,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:17'),(101,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:17'),(102,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:20'),(103,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:20'),(106,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:26'),(107,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:26'),(108,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:29'),(109,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:30'),(110,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:32'),(111,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:33'),(112,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:35'),(113,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:37'),(114,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:37'),(115,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:40'),(123,44,'post_edited','Người dùng đã chỉnh sửa bài viết bị cảnh báo','Bài viết #12 đã được người dùng chỉnh sửa sau khi bị cảnh báo. Vui lòng kiểm tra lại nội dung.','✏️','{\"post_id\": 12, \"user_id\": 6}',NULL,0,'2026-06-22 04:59:12'),(125,6,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 31, \"user_id\": 12}',NULL,1,'2026-06-22 06:41:57'),(126,32,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 31, \"user_id\": 12}',NULL,0,'2026-06-22 06:41:57'),(127,12,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"31\", \"reported_by\": 44}',NULL,1,'2026-06-25 10:19:37'),(128,12,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"31\", \"reported_by\": 44}',NULL,1,'2026-06-25 10:19:53'),(129,12,'new_post','Bài viết mới từ người bạn theo dõi','Huệ Trinh vừa đăng bài viết mới','?','{\"post_id\": 33, \"user_id\": 6}',NULL,1,'2026-06-29 13:29:22'),(139,69,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Nội dung spam hoặc lừa đảo','⚠️','{\"reason\": \"Nội dung spam hoặc lừa đảo\", \"post_id\": \"37\", \"reported_by\": 44}',NULL,1,'2026-07-01 03:08:20'),(144,6,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 38, \"user_id\": 12}',NULL,1,'2026-07-02 04:53:58'),(145,32,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 38, \"user_id\": 12}',NULL,0,'2026-07-02 04:53:58'),(146,6,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 39, \"user_id\": 12}',NULL,1,'2026-07-02 05:21:52'),(147,32,'new_post','Bài viết mới từ người bạn theo dõi','Nhật Anh vừa đăng bài viết mới','?','{\"post_id\": 39, \"user_id\": 12}',NULL,0,'2026-07-02 05:21:52'),(148,69,'warning_cleared','Đã gỡ cảnh báo bài viết','Bài viết của bạn đã được xem xét và gỡ cảnh báo. Bài viết đã hiển thị lại trên cộng đồng.','✅','{\"post_id\": \"37\"}',NULL,0,'2026-07-03 07:49:40'),(149,44,'post_edited','Người dùng đã chỉnh sửa bài viết bị cảnh báo','Bài viết #31 đã được người dùng chỉnh sửa sau khi bị cảnh báo. Vui lòng kiểm tra lại nội dung.','✏️','{\"post_id\": 31, \"user_id\": 12}',NULL,0,'2026-07-03 08:47:48'),(150,12,'warning_cleared','Bài viết đã được phê duyệt','Bài viết sau khi chỉnh sửa của bạn đã được quản trị viên phê duyệt và hiển thị lại trên cộng đồng.','✅','{\"post_id\": \"31\"}',NULL,1,'2026-07-03 08:49:43'),(151,44,'post_reported','Báo cáo bài viết mới','Nhật Anh đã báo cáo bài viết của Huệ Trinh: otherReason','?','{\"reason\": \"otherReason\", \"status\": \"warned\", \"post_id\": 12, \"description\": \"hiihiihhiiihhiih\", \"reporter_id\": 12, \"reporter_name\": \"Nhật Anh\"}',NULL,0,'2026-07-03 08:59:12'),(152,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn đã bị báo cáo và vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": 12, \"reported_by\": 44}',NULL,1,'2026-07-03 09:00:31'),(153,44,'post_edited','Người dùng đã chỉnh sửa bài viết bị cảnh báo','Bài viết #12 đã được người dùng chỉnh sửa sau khi bị cảnh báo. Vui lòng kiểm tra lại nội dung.','✏️','{\"post_id\": 12, \"user_id\": 6}',NULL,0,'2026-07-03 09:01:04'),(154,6,'warning_cleared','Bài viết đã được phê duyệt','Bài viết sau khi chỉnh sửa của bạn đã được quản trị viên phê duyệt và hiển thị lại trên cộng đồng.','✅','{\"post_id\": \"12\"}',NULL,1,'2026-07-03 09:02:52');
/*!40000 ALTER TABLE `user_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar_url` text COLLATE utf8mb4_unicode_ci,
  `role` enum('user','admin') COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `notification_email` tinyint(1) DEFAULT '1',
  `notification_push` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `gender` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_year` int DEFAULT NULL,
  `height` decimal(5,2) DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `goals` json DEFAULT NULL,
  `otp_code` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otp_expires_at` timestamp NULL DEFAULT NULL,
  `fcm_token` text COLLATE utf8mb4_unicode_ci,
  `notif_morning_enabled` tinyint(1) DEFAULT '1',
  `notif_morning_hour` int DEFAULT '8',
  `notif_morning_minute` int DEFAULT '0',
  `notif_evening_enabled` tinyint(1) DEFAULT '1',
  `notif_evening_hour` int DEFAULT '21',
  `notif_evening_minute` int DEFAULT '0',
  `language` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'vi',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'Huệ Trinh','trinhfokko@gmail.com','$2b$10$2ZkUA0XOuxidQJlzjy5I3e65tH4ceS.NH.y3bndDeimOIRg5ufyDu','/uploads/avatar-1781519564325-701026932.jpg','user',1,1,'2026-04-20 07:46:15','female',2004,157.00,47.00,'[\"sleep\"]',NULL,NULL,NULL,1,12,0,1,17,35,'vi'),(7,'Vũ Ngọc Mẫn Nhi','meomeodthvch@gmail.com','','/uploads/avatar-1780487790001-807066220.jpg','user',1,1,'2026-04-20 08:01:11','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0,'vi'),(12,'Nhật Anh','trinhmeo2k4@gmail.com','','/uploads/avatar-1780481028817-690785779.jpg','user',1,1,'2026-04-21 05:27:27','female',2006,157.00,47.00,'[\"weight\"]',NULL,NULL,NULL,1,11,40,1,18,17,'vi'),(25,'Huệ Trinh','thachthihuetrinh2004@gmail.com','',NULL,'user',1,1,'2026-05-26 05:17:40','female',2001,157.00,47.00,'[\"other:Hoc\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0,'vi'),(32,'Bình Nguyễn','binh@gmail.com','$2b$10$8HGmrLwAY7EHg3Uqe0nEieMuA.NqmHJqhZXakADYsySoqIrhZjfQy','/uploads/avatar-1780484132949-94407951.jpg','user',1,1,'2026-05-28 12:48:25','male',2001,156.00,56.00,'[\"hydration\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0,'vi'),(43,'Thanh Trà','meodthvch2004@gmail.com','','/uploads/avatar-1781087986257-727332690.jpg','user',1,1,'2026-06-03 11:46:38','female',2006,157.00,46.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(44,'Viora Application','viora.application@gmail.com','','/uploads/avatar-1781942670697-155075380.png','admin',1,1,'2026-06-05 04:49:11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(45,'Hồng Anh','honganh@gmail.com','$2b$10$3BqFk9lyQZhUmn.zwtVzaev/ZIFDJzYvHkRVu67f/amIQs6tzexh.',NULL,'user',1,1,'2026-06-06 04:45:14','female',2001,165.00,47.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(47,'Âu Gia Bảo','augiabao832@gmail.com','$2b$10$AZm1ZcqYjlbkipXTLP5aZ.SISDeevUIYjPhGppLmBw7RSlRDohgoi',NULL,'user',1,1,'2026-06-10 04:49:43','male',2007,167.00,52.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(48,'Hoa Hồng','hoahong@gmail.com','$2b$10$i9UeftFNK4z5CqiSmnLMwuubavtABPKeR1hizQJSIKL/ZNcRHj.eG',NULL,'user',1,1,'2026-06-11 04:15:55','female',2001,156.00,45.00,'[\"mental\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0,'vi'),(50,'Ngọc Anh','ngocanh@gmail.com','$2b$10$ta57mdNqjn/ULd1RTnM1weX4AiCMwoJ04z0Czz5X4ecESiR47XtJm',NULL,'user',1,1,'2026-06-14 04:24:21','female',2007,157.00,47.00,'[\"hydration\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(51,'Hữu Nhân','huunhan@gmail.com','$2b$10$BDE2zoR3/dmKNqXecn.oBOq7nD6IydXJfvFupjO3gxg3/vMsO28eC',NULL,'user',1,1,'2026-06-14 04:34:41','male',2006,167.00,56.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(52,'Anh Đào','anhdao@gmail.com','$2b$10$BagSLCUt4Crbsdnlw9YGH.JBLEDGpmgSIWAn3I63uja28sGOuHjjG',NULL,'user',1,1,'2026-06-14 04:45:24','female',2006,157.00,47.00,'[\"mental\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0,'vi'),(53,'Hướng Dương','huongduong@gmail.com','$2b$10$mBWQ85A.e3jgh.P62SUet.o.mxpmHytcfoM0OOvnzzlI9f4qMUzDu',NULL,'user',1,1,'2026-06-14 05:05:25','male',2001,170.00,60.00,'[\"weight\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0,'vi'),(54,'Bam Boo','bamboo@gmail.com','$2b$10$/fVqx5AvBCGePxO86g1rOOQl0pW9GHrd9lZFLqyoCcRGpQwiaMTcy',NULL,'user',1,1,'2026-06-14 10:16:13','other',2001,167.00,47.00,'[\"eat_healthy\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0,'vi'),(55,'Vũ Trường Nguyên','truongnguyen@gmail.com','$2b$10$mJN4Dqp7thjP3nzc.ZT91e/RXyeo8n04SOIl9CPVsTSwsmxLNcW9G',NULL,'user',1,1,'2026-06-19 08:53:13','male',2006,180.00,70.00,'[\"eat_healthy\", \"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(56,'user','user@gmail.com','$2b$10$6laB9iai0IYfUEGUjXi1hOCLq5WvUel9DrLVlAQu1jYzKrBhrOHs.',NULL,'user',1,1,'2026-06-24 07:03:48','female',2001,160.00,47.00,'[\"exercise\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(57,'user2','user2@gmail.com','$2b$10$SXZ57AnxFD9G8YCwGknlu.ql.PdLH4Owwzca1nX0Y2vD/MaSlJIey',NULL,'user',1,1,'2026-06-24 07:05:52','female',2001,180.00,69.00,'[\"sleep\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(58,'user4','user4@gmail.com','$2b$10$oBH6GKEzEqNeQlHNZfoTVehM/Ueg6DAQfwQk41tlOv8uLyrcrKSVy',NULL,'user',1,1,'2026-06-24 08:08:43','female',2001,170.00,60.00,'[\"sleep\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(59,'TestUser','testuser100@test.com','$2b$10$8mAqzU9nhp96A6.W3ZGyMu3gyilaHqrqoNwsmaQwO1K4niAzFqWlm',NULL,'user',1,1,'2026-06-24 08:15:30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(60,'user5','user5@gmail.com','$2b$10$7Bz/lkJZP3sCIWI2HHOb/e9cJXAb9j2yyuaP.62nE0nWqTgc1w6T6',NULL,'user',1,1,'2026-06-24 08:27:37','female',2006,170.00,67.00,'[\"mental\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(61,'user6u','user6@gmail.com','$2b$10$5rF6QN8C8VHiYTMuyZu5X.AWZ/PQoCnFyv.RhY9BPFBdCifjsL9vW',NULL,'user',1,1,'2026-06-24 08:33:59','female',2001,170.00,56.00,'[\"exercise\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(62,'user7u','user7@gmail.com','$2b$10$ARj/ClsrxycHdUGRE58x2.69/tiykXTtophoQiKf48Z1JYdLnTvMG',NULL,'user',1,1,'2026-06-24 08:35:04','female',2006,170.00,60.00,'[\"mental\", \"hydration\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(63,'usermeo','usermeo@gmail.com','$2b$10$HjpLPQZAR8CeCj.q78F/IuWNyYL7F5dK5nxGGBoPYz3i8LR18gNzK',NULL,'user',1,1,'2026-06-25 03:38:28','male',2001,160.00,47.00,'[\"exercise\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(64,'Mèo','meo@gmail.com','$2b$10$GnOXLX6AG7eSHDkX2FTuXeDsJ2qw4aIfQSzcoOTW/hTDEl8bHa5ni',NULL,'user',1,1,'2026-06-26 09:47:56',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(65,'mèo','meoo@gmail.com','$2b$10$Gf0Hys4O/es7wKr53FREqu4aeFRckqiktkdjLqr7P39GZFoH7dkLm',NULL,'user',1,1,'2026-06-27 05:07:14','male',2001,170.00,57.00,'[\"exercise\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(66,'Mai Lê','maile@gmail.com','$2b$10$huLnWEX6VEmvrcOIbpc2Ke.WQxDnGuRhlGajSSkpSHrbSqCre/P9C',NULL,'user',1,1,'2026-06-28 09:25:11','female',2001,150.00,57.00,'[\"mental\", \"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(67,'Ngọc Anh','ngocanhh@gmail.com','$2b$10$fcxO9JeQe1r4nCVtJl2Dbuv50GBKS.4kYATMh24p3i5Hq6n9G2.eS',NULL,'user',1,1,'2026-06-29 13:18:57','female',2004,160.00,47.00,'[\"eat_healthy\", \"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(68,'Mạnh Đình','manhdinh@gmail.comA','$2b$10$nm/6uCekWbJP7Xz2BL0mHOQkO/BUJ9WIYjo8gKsI42m1VC5MSaRnm',NULL,'user',1,1,'2026-06-29 13:29:59','male',2001,180.00,65.00,'[\"eat_healthy\", \"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(69,'Steam','steam@gmail.com','$2b$10$auLo1pC8VU0POJ1JRNxEJue2YWj2m2NdbqzsdrYVs4mAIEsBFH96m',NULL,'user',1,1,'2026-06-30 07:35:42','female',2004,170.00,67.00,'[\"eat_healthy\", \"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(70,'Hồ Lý Minh Lữ','holyminhludauden@gmail.com','$2b$10$am1FhWYQ9FKAc5cdwEF/FOPJy83I9oRe5lznQsovXgk1DQqnE7pg6','/uploads/avatar-1783069925731-328406275.jpg','user',1,1,'2026-07-03 09:06:03','male',2004,168.00,54.00,'[\"eat_healthy\", \"sleep\", \"exercise\", \"hydration\", \"weight\", \"mental\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(71,'Võ Phước Toàn','toanvo@gmail.com','$2b$10$OWJhNgryeuVBSbYN7GGNTOrUSqP1ZVoHhY5HgxswvMlDxBktPmnkK',NULL,'user',1,1,'2026-07-04 10:24:40','male',2003,170.00,55.00,'[\"sleep\", \"mental\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(72,'Kim Ngân','kimngan@gmail.com','$2b$10$vGqNCtxWlqPrgtEgR3/XjeRwdeH8GgB9MTVOT/CK9KjtCj0I1N7Sy',NULL,'user',1,1,'2026-07-05 02:34:02','female',2011,165.00,50.00,'[\"hydration\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(73,'Ngô Tuấn Anh','tuananh@gmail.com','$2b$10$uJj5dwwj329xZsu/G82JP.0aS9Hhgwz3ObkbMNk4b9Duu3mgS3cEe',NULL,'user',1,1,'2026-07-04 02:51:25','male',2001,165.00,55.00,'[\"hydration\", \"weight\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(74,'Mai Thư','maithu@gmail.com','$2b$10$eS/Z4whV7rvZKBz9XOWqOu6D7PbZDWSf4vmmqwMpwTfXnD0DySm9a',NULL,'user',1,1,'2026-07-04 03:13:55','other',2006,160.00,56.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(75,'Mạnh Đạt Nguyễn','dat@gmail.com','$2b$10$gJ/k8jzS2syUw1TOM5kpFeSHCNADmKZUqyQ9XI3DQ7ov53ivV1.1W',NULL,'user',1,1,'2026-07-04 07:39:14','male',2006,160.00,56.00,'[\"sleep\"]',NULL,NULL,NULL,1,8,0,1,21,0,'vi'),(76,'Thảo Vy','thaovy@gmail.com','$2b$10$UdpVZOfeOERGQuz23wpTvelZfPSHxLugYZVsIksFCYMvwP2SjqfPS',NULL,'user',1,1,'2026-07-04 09:46:54','female',2001,157.00,NULL,'[\"sleep\", \"exercise\"]',NULL,NULL,'eINyPfbcRw6GsB5Y7Jn9r6:APA91bHCi7-YgyXJcCsQtsVVEFta7c8rYgVy7GMxOiOp735EW0lwi3-SkFFOFSYgTrdr1_sssN8gBf0bRrHtW9YW5e0DPQMCqXwapem_5dqScqezXaI-fso',1,8,0,1,21,0,'vi');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-04 18:58:13
