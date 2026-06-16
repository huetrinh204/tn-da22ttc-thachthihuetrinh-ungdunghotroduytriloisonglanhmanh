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
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,6,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:17:12','2026-04-28 06:17:12'),(2,7,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:29:14','2026-04-28 06:29:14'),(3,6,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-04-30 11:14:53','2026-04-30 11:14:53'),(4,12,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(5,12,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(6,6,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-05-06 05:01:16','2026-05-06 05:01:16'),(7,12,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-05-13 04:38:14','2026-05-13 04:38:14'),(12,25,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-26 05:19:30','2026-05-26 05:19:30'),(19,32,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-28 12:48:55','2026-05-28 12:48:55'),(30,45,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-06 04:46:05','2026-06-06 04:46:05'),(31,47,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-10 04:50:30','2026-06-10 04:50:30'),(32,12,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 05:39:33','2026-06-10 05:39:33'),(33,43,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-10 06:12:19','2026-06-10 06:12:19'),(34,7,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 10:06:18','2026-06-10 10:06:18'),(35,43,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 10:10:10','2026-06-10 10:10:10'),(36,43,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 10:10:41','2026-06-10 10:10:41'),(37,32,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:24:49','2026-06-10 11:24:49'),(38,32,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 11:24:49','2026-06-10 11:24:49'),(39,47,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:39:07','2026-06-10 11:39:07'),(40,47,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-06-10 11:40:58','2026-06-10 11:40:58'),(41,6,'checkin_50','Nửa trăm','Hoàn thành 50 check-ins','?','2026-06-10 11:58:47','2026-06-10 11:58:47'),(42,6,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-06-10 11:59:42','2026-06-10 11:59:42'),(43,50,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 04:24:59','2026-06-14 04:24:59'),(44,53,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 09:52:57','2026-06-14 09:52:57'),(45,54,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-14 10:17:19','2026-06-14 10:17:19');
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
INSERT INTO `auto_reminder_settings` VALUES (1,1,'11:52:00','18:00:00',1,1,'2026-06-16 07:51:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_comments`
--

LOCK TABLES `community_comments` WRITE;
/*!40000 ALTER TABLE `community_comments` DISABLE KEYS */;
INSERT INTO `community_comments` VALUES (3,12,12,'Tui nè, bạn ở đâu?','2026-06-03 10:09:54'),(4,13,6,'Câu nói hay lắm','2026-06-03 10:16:27'),(5,13,32,'Sâu sắc!','2026-06-03 10:54:39'),(6,14,12,'???','2026-06-03 11:16:38'),(7,13,7,'Ý nghĩa lắm nha người đẹp ?','2026-06-03 11:57:20');
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
INSERT INTO `community_post_likes` VALUES (6,12,'2026-06-02 05:32:39'),(6,13,'2026-06-15 09:14:35'),(7,13,'2026-06-03 11:53:37'),(12,12,'2026-06-03 10:09:40'),(12,13,'2026-06-03 10:10:17'),(12,14,'2026-06-03 11:16:27'),(32,13,'2026-06-03 10:53:51'),(45,13,'2026-06-06 04:46:40'),(45,14,'2026-06-06 04:46:53');
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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `community_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_posts`
--

LOCK TABLES `community_posts` WRITE;
/*!40000 ALTER TABLE `community_posts` DISABLE KEYS */;
INSERT INTO `community_posts` VALUES (12,6,'Tìm bạn chạy bộ mỗi sáng cùng mình hehe','http://10.0.2.2:3000/uploads/1780378232788-178490186.jpg',NULL,NULL,2,'2026-06-02 05:30:33','normal'),(13,12,'Hơi thở chính là cây cầu kết nối sự sống và ý thức của con người. Khi gặp phải những chuyện buồn trong cuộc sống, hãy hít một hơi thật sâu, thở ra và cho qua mọi thứ','http://10.0.2.2:3000/uploads/1780481276384-741277433.jpg',NULL,NULL,3,'2026-06-03 10:07:57','normal'),(14,32,'?','http://10.0.2.2:3000/uploads/1780484789156-731392882.jpg',NULL,NULL,1,'2026-06-03 11:06:30','normal'),(15,43,'Mình muốn tăng cân thì cần tập những bài tập và tùy chọn khẩu phần ăn như thế nào ạ? \nMọi người share tip mình biết với\n#tangcanlanhmanh',NULL,'[\"#tangcanlanhmanh\"]',NULL,1,'2026-06-10 10:41:41','normal'),(27,6,'? Bước đầu tiên\nHoàn thành check-in đầu tiên','http://10.0.2.2:3000/uploads/1781599176618-631895994.png','[\"#thanhTich\", \"#achievement\"]',NULL,2,'2026-06-16 08:39:38','achievement');
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
) ENGINE=InnoDB AUTO_INCREMENT=209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habit_logs`
--

LOCK TABLES `habit_logs` WRITE;
/*!40000 ALTER TABLE `habit_logs` DISABLE KEYS */;
INSERT INTO `habit_logs` VALUES (6,2,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(7,1,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(8,3,7,'2026-04-20',0,0,'2026-04-20 09:29:15',NULL,NULL,NULL),(15,4,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(16,5,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(18,7,12,'2026-04-21',0,0,'2026-04-21 05:31:52',NULL,NULL,NULL),(19,6,12,'2026-04-21',0,0,'2026-04-21 05:31:53',NULL,NULL,NULL),(20,8,12,'2026-04-21',0,0,'2026-04-21 05:39:24',NULL,NULL,NULL),(21,9,6,'2026-04-25',0,0,'2026-04-25 06:29:43',NULL,NULL,NULL),(37,9,6,'2026-04-28',0,0,'2026-04-28 06:20:39',NULL,NULL,NULL),(38,12,6,'2026-04-28',0,0,'2026-04-28 06:20:40',NULL,NULL,NULL),(39,13,6,'2026-04-28',0,0,'2026-04-28 06:20:41',NULL,NULL,NULL),(40,3,7,'2026-04-28',0,0,'2026-04-28 06:29:14',NULL,NULL,NULL),(41,2,7,'2026-04-28',0,0,'2026-04-28 06:29:19',NULL,NULL,NULL),(42,1,7,'2026-04-28',0,0,'2026-04-28 06:30:01',NULL,NULL,NULL),(43,13,6,'2026-04-29',0,0,'2026-04-29 09:27:32',NULL,NULL,NULL),(44,12,6,'2026-04-29',0,0,'2026-04-29 09:28:25',NULL,NULL,NULL),(45,9,6,'2026-04-29',0,0,'2026-04-29 09:28:49',NULL,NULL,NULL),(46,12,6,'2026-04-30',0,0,'2026-04-30 11:14:53',NULL,NULL,NULL),(47,9,6,'2026-04-30',0,0,'2026-04-30 11:15:09',NULL,NULL,NULL),(48,3,7,'2026-04-30',0,0,'2026-04-30 11:16:41',NULL,NULL,NULL),(49,8,12,'2026-04-30',0,0,'2026-04-30 11:35:42',NULL,NULL,NULL),(50,7,12,'2026-04-30',0,0,'2026-04-30 11:35:48',NULL,NULL,NULL),(51,12,6,'2026-05-02',0,0,'2026-05-02 10:53:16',NULL,NULL,NULL),(52,9,6,'2026-05-02',0,0,'2026-05-02 11:45:13',NULL,NULL,NULL),(53,12,6,'2026-05-04',0,0,'2026-05-04 05:56:25',NULL,NULL,NULL),(54,9,6,'2026-05-04',0,0,'2026-05-04 05:56:36',NULL,NULL,NULL),(55,12,6,'2026-05-06',0,0,'2026-05-06 04:47:38',NULL,NULL,NULL),(56,9,6,'2026-05-06',0,0,'2026-05-06 04:47:44',NULL,NULL,NULL),(57,16,6,'2026-05-06',0,0,'2026-05-06 05:01:16',NULL,20.00,'ml'),(58,16,6,'2026-05-07',0,0,'2026-05-07 04:18:38',NULL,NULL,'ml'),(59,17,6,'2026-05-07',0,0,'2026-05-07 04:20:13',NULL,0.50,'km'),(60,19,6,'2026-05-07',0,0,'2026-05-07 05:01:00',NULL,400.00,'km'),(61,20,6,'2026-05-07',0,0,'2026-05-07 05:09:48',NULL,300.00,'cal'),(62,20,6,'2026-05-10',0,0,'2026-05-10 04:22:57',NULL,50.00,'cal'),(63,16,6,'2026-05-10',0,0,'2026-05-10 04:32:13',NULL,200.00,'ml'),(64,19,6,'2026-05-10',0,0,'2026-05-10 05:22:18',NULL,200.00,'m'),(65,3,7,'2026-05-10',0,0,'2026-05-10 06:19:46',NULL,NULL,NULL),(66,20,6,'2026-05-11',0,0,'2026-05-11 05:36:43',NULL,20.00,'cal'),(67,16,6,'2026-05-11',0,0,'2026-05-11 05:37:00',NULL,200.00,'ml'),(68,19,6,'2026-05-11',0,0,'2026-05-11 05:42:31',NULL,350.00,'m'),(69,8,12,'2026-05-11',0,0,'2026-05-11 05:44:56',NULL,NULL,NULL),(70,7,12,'2026-05-11',0,0,'2026-05-11 05:44:58',NULL,NULL,NULL),(71,5,12,'2026-05-11',0,0,'2026-05-11 05:45:00',NULL,NULL,NULL),(72,4,12,'2026-05-12',0,0,'2026-05-12 04:49:52',NULL,NULL,NULL),(73,21,12,'2026-05-12',0,0,'2026-05-12 04:50:49',NULL,500.00,'m'),(74,22,12,'2026-05-12',0,0,'2026-05-12 05:01:49',NULL,100.00,'cal'),(75,22,12,'2026-05-13',0,0,'2026-05-13 04:38:14',NULL,150.00,'cal'),(76,21,12,'2026-05-13',0,0,'2026-05-13 04:41:30',NULL,500.00,'m'),(77,20,6,'2026-05-13',0,0,'2026-05-13 05:24:02',NULL,120.00,'cal'),(78,19,6,'2026-05-13',0,0,'2026-05-13 05:24:36',NULL,200.00,'m'),(79,16,6,'2026-05-13',0,0,'2026-05-13 05:26:20',NULL,100.00,'ml'),(80,3,7,'2026-05-13',0,0,'2026-05-13 05:28:37',NULL,NULL,NULL),(81,2,7,'2026-05-13',0,0,'2026-05-13 05:31:50',NULL,100.00,'cal'),(82,1,7,'2026-05-13',0,0,'2026-05-13 05:33:43',NULL,NULL,NULL),(83,23,12,'2026-05-13',0,0,'2026-05-13 05:40:49',NULL,100.00,'ml'),(84,24,12,'2026-05-13',0,0,'2026-05-13 05:41:54',NULL,1.00,'giờ'),(85,19,6,'2026-05-14',0,0,'2026-05-14 05:00:25',NULL,150.00,'m'),(87,20,6,'2026-05-21',0,0,'2026-05-21 05:59:45',NULL,150.00,'cal'),(88,19,6,'2026-05-21',0,0,'2026-05-21 06:08:56',NULL,120.00,'m'),(89,16,6,'2026-05-21',0,0,'2026-05-21 07:55:08',NULL,NULL,'ml'),(96,37,25,'2026-05-26',0,0,'2026-05-26 05:19:30',NULL,NULL,NULL),(106,47,32,'2026-05-28',0,0,'2026-05-28 12:48:55',NULL,50.00,'ml'),(130,47,32,'2026-05-30',0,0,'2026-05-30 04:40:06',NULL,50.00,'ml'),(131,26,6,'2026-05-30',0,0,'2026-05-30 06:10:08',NULL,50.00,'cal'),(132,20,6,'2026-05-30',0,0,'2026-05-30 06:10:13',NULL,20.00,'cal'),(133,19,6,'2026-05-30',0,0,'2026-05-30 06:10:17',NULL,20.00,'m'),(134,16,6,'2026-05-30',0,0,'2026-05-30 06:10:33',NULL,240.00,'ml'),(135,26,6,'2026-05-31',0,0,'2026-05-31 06:30:58',NULL,NULL,'cal'),(136,20,6,'2026-05-31',0,0,'2026-05-31 06:31:08',NULL,NULL,'cal'),(137,26,6,'2026-06-02',0,0,'2026-06-02 05:33:37',NULL,67.00,'cal'),(138,20,6,'2026-06-03',0,0,'2026-06-03 09:55:12',NULL,56.00,'cal'),(139,21,12,'2026-06-03',0,0,'2026-06-03 10:08:33',NULL,50.00,'m'),(140,19,6,'2026-06-03',0,0,'2026-06-03 10:51:20',NULL,50.00,'m'),(141,16,6,'2026-06-03',0,0,'2026-06-03 10:51:34',NULL,158.00,'ml'),(142,47,32,'2026-06-03',0,0,'2026-06-03 11:05:54',NULL,100.00,'ml'),(143,24,12,'2026-06-03',0,0,'2026-06-03 11:37:14',NULL,2.00,'giờ'),(144,24,12,'2026-06-04',0,0,'2026-06-04 07:56:39',NULL,NULL,'giờ'),(145,23,12,'2026-06-04',0,0,'2026-06-04 07:56:44',NULL,NULL,'ml'),(146,22,12,'2026-06-04',0,0,'2026-06-04 07:56:46',NULL,NULL,'cal'),(147,20,6,'2026-06-05',0,0,'2026-06-05 05:57:05',NULL,NULL,'cal'),(148,19,6,'2026-06-05',0,0,'2026-06-05 05:57:08',NULL,NULL,'m'),(149,75,45,'2026-06-06',0,0,'2026-06-06 04:46:05',NULL,90.00,'cal'),(150,20,6,'2026-06-08',0,0,'2026-06-08 04:49:57',NULL,45.00,'cal'),(151,19,6,'2026-06-08',0,0,'2026-06-08 04:50:37',NULL,100.00,'m'),(152,77,47,'2026-06-10',0,0,'2026-06-10 04:50:30',NULL,500.00,'m'),(153,24,12,'2026-06-10',0,0,'2026-06-10 05:39:33',NULL,1.00,'giờ'),(154,79,43,'2026-06-10',0,0,'2026-06-10 06:12:19',NULL,120.00,'m'),(155,78,43,'2026-06-10',0,0,'2026-06-10 06:14:35',NULL,80.00,'m'),(156,80,7,'2026-06-10',0,0,'2026-06-10 10:06:18',NULL,200.00,'m'),(157,81,43,'2026-06-10',0,0,'2026-06-10 10:08:31',NULL,400.00,'ml'),(158,82,43,'2026-06-10',0,0,'2026-06-10 10:09:32',NULL,120.00,'cal'),(159,83,43,'2026-06-10',0,0,'2026-06-10 10:10:10',NULL,8.00,'giờ'),(160,84,43,'2026-06-10',0,0,'2026-06-10 10:10:41',NULL,NULL,NULL),(161,86,43,'2026-06-10',0,0,'2026-06-10 10:37:18',NULL,NULL,NULL),(162,87,43,'2026-06-10',0,0,'2026-06-10 10:37:51',NULL,NULL,NULL),(163,23,12,'2026-06-10',0,0,'2026-06-10 10:43:59',NULL,200.00,'ml'),(164,22,12,'2026-06-10',0,0,'2026-06-10 10:44:04',NULL,120.00,'cal'),(165,21,12,'2026-06-10',0,0,'2026-06-10 10:44:10',NULL,100.00,'m'),(166,88,12,'2026-06-10',0,0,'2026-06-10 11:02:22',NULL,NULL,NULL),(167,89,12,'2026-06-10',0,0,'2026-06-10 11:03:40',NULL,NULL,NULL),(168,73,32,'2026-06-10',0,0,'2026-06-10 11:08:38',NULL,70.00,'m'),(169,47,32,'2026-06-10',0,0,'2026-06-10 11:09:02',NULL,200.00,'ml'),(170,90,32,'2026-06-10',0,0,'2026-06-10 11:14:41',NULL,NULL,NULL),(171,91,32,'2026-06-10',0,0,'2026-06-10 11:24:13',NULL,NULL,NULL),(172,92,32,'2026-06-10',0,0,'2026-06-10 11:24:49',NULL,NULL,'m'),(173,76,47,'2026-06-10',0,0,'2026-06-10 11:37:50',NULL,200.00,'m'),(174,93,47,'2026-06-10',0,0,'2026-06-10 11:39:07',NULL,7.00,'giờ'),(175,94,47,'2026-06-10',0,0,'2026-06-10 11:39:16',NULL,600.00,'ml'),(176,95,47,'2026-06-10',0,0,'2026-06-10 11:39:19',NULL,NULL,NULL),(177,96,47,'2026-06-10',0,0,'2026-06-10 11:40:58',NULL,120.00,'cal'),(178,16,6,'2026-06-10',0,0,'2026-06-10 11:58:39',NULL,150.00,'ml'),(179,19,6,'2026-06-10',0,0,'2026-06-10 11:58:43',NULL,200.00,'m'),(180,20,6,'2026-06-10',0,0,'2026-06-10 11:58:47',NULL,120.00,'cal'),(181,97,6,'2026-06-10',0,0,'2026-06-10 11:59:20',NULL,NULL,NULL),(182,98,6,'2026-06-10',0,0,'2026-06-10 11:59:42',NULL,NULL,NULL),(183,99,6,'2026-06-10',0,0,'2026-06-10 12:00:13',NULL,8.00,'giờ'),(184,100,6,'2026-06-10',0,0,'2026-06-10 12:00:33',NULL,NULL,NULL),(185,99,6,'2026-06-11',0,0,'2026-06-11 04:12:46',NULL,1.00,'giờ'),(186,97,6,'2026-06-11',0,0,'2026-06-11 04:12:57',NULL,NULL,NULL),(187,20,6,'2026-06-11',0,0,'2026-06-11 04:14:59',NULL,120.00,'cal'),(188,104,50,'2026-06-14',0,0,'2026-06-14 04:24:59',NULL,150.00,'ml'),(189,109,53,'2026-06-14',0,0,'2026-06-14 09:52:57',NULL,123.00,'cal'),(190,108,53,'2026-06-14',0,0,'2026-06-14 09:53:07',NULL,400.00,'m'),(191,111,54,'2026-06-14',0,0,'2026-06-14 10:17:19',NULL,120.00,'cal'),(192,110,54,'2026-06-14',0,0,'2026-06-14 10:17:35',NULL,120.00,'cal'),(193,113,54,'2026-06-14',0,0,'2026-06-14 11:46:01',NULL,142.00,'ml'),(194,114,54,'2026-06-14',0,0,'2026-06-14 12:10:36',NULL,200.00,'ml'),(195,116,54,'2026-06-14',0,0,'2026-06-14 12:17:07',NULL,100.00,'ml'),(196,117,54,'2026-06-14',0,0,'2026-06-14 12:26:15',NULL,100.00,'ml'),(197,118,54,'2026-06-14',0,0,'2026-06-14 12:37:59',NULL,100.00,'ml'),(198,119,54,'2026-06-14',0,0,'2026-06-14 12:39:09',NULL,500.00,'ml'),(199,97,6,'2026-06-15',0,1,'2026-06-15 03:36:01',NULL,1.00,NULL),(200,120,6,'2026-06-15',0,1,'2026-06-15 03:37:05',NULL,800.00,'ml'),(201,121,6,'2026-06-15',0,0,'2026-06-15 03:38:59',NULL,500.00,'ml'),(202,122,6,'2026-06-15',0,1,'2026-06-15 03:40:28',NULL,1.00,NULL),(203,123,6,'2026-06-15',0,0,'2026-06-15 03:56:35',NULL,200.00,'ml'),(204,124,6,'2026-06-15',0,0,'2026-06-15 03:57:14',NULL,20.00,'ml'),(205,125,6,'2026-06-15',0,1,'2026-06-15 03:59:46',NULL,300.00,'ml'),(206,126,6,'2026-06-15',0,1,'2026-06-15 05:25:54',NULL,20.00,NULL),(207,133,6,'2026-06-16',0,0,'2026-06-16 05:26:14',NULL,300.00,'ml'),(208,134,6,'2026-06-16',0,1,'2026-06-16 05:30:21',NULL,10.00,'giờ');
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
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habits`
--

LOCK TABLES `habits` WRITE;
/*!40000 ALTER TABLE `habits` DISABLE KEYS */;
INSERT INTO `habits` VALUES (1,7,'aa','other',1,NULL,NULL,0,'2026-04-20 09:24:10','⭐','#4CAF50','daily',1,1,1,'2026-05-13'),(2,7,'b','eat',1,NULL,NULL,0,'2026-04-20 09:24:33','?','#4CAF50','daily',1,1,1,'2026-05-13'),(3,7,'c','other',1,NULL,NULL,0,'2026-04-20 09:29:10','?','#4CAF50','daily',1,1,1,'2026-05-13'),(4,12,'testphone','other',1,NULL,NULL,0,'2026-04-21 05:27:55','⭐','#4CAF50','daily',1,1,1,'2026-05-12'),(5,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:28:09','?','#4CAF50','daily',1,1,1,'2026-05-11'),(6,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:31:39','⭐','#4CAF50','daily',1,0,0,NULL),(7,12,'ok','other',1,NULL,NULL,0,'2026-04-21 05:31:45','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(8,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:37:23','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(9,6,'demo','other',1,NULL,NULL,0,'2026-04-25 06:29:41','⭐','#4CAF50','daily',1,0,0,NULL),(12,6,'test','other',1,NULL,NULL,0,'2026-04-28 05:44:12','⭐','#4CAF50','daily',1,0,0,NULL),(13,6,'an','eat',1,NULL,NULL,0,'2026-04-28 06:12:43','⭐','#4CAF50','daily',1,0,0,NULL),(16,6,'Uống 500ml nước','hydration',1,NULL,NULL,0,'2026-05-06 05:01:00','?','#4CAF50','daily',1,1,1,'2026-06-10'),(17,6,'Chạy 500m','exercise',1,NULL,NULL,0,'2026-05-07 04:19:35','?','#4CAF50','daily',1,1,1,'2026-05-07'),(18,6,'Chạy 500m','other',1,NULL,NULL,0,'2026-05-07 05:00:15','?','#4CAF50','daily',1,0,0,NULL),(19,6,'Chạy 500m','exercise',1,NULL,NULL,0,'2026-05-07 05:00:43','?','#4CAF50','daily',1,1,1,'2026-06-10'),(20,6,'Ăn 500 calories','eat',1,NULL,NULL,0,'2026-05-07 05:09:33','?','#4CAF50','daily',1,2,2,'2026-06-11'),(21,12,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-05-12 04:50:35','?','#4CAF50','daily',1,1,1,'2026-06-10'),(22,12,'Ăn healthy','eat',1,NULL,NULL,1,'2026-05-12 05:01:36','?','#4CAF50','daily',1,1,1,'2026-06-10'),(23,12,'Uống nước','hydration',1,NULL,NULL,1,'2026-05-13 05:40:31','?','#4CAF50','daily',1,1,1,'2026-06-10'),(24,12,'Ngủ trưa','sleep',1,NULL,NULL,1,'2026-05-13 05:41:45','?','#4CAF50','daily',1,1,1,'2026-06-10'),(26,6,'Ăn','eat',1,NULL,NULL,0,'2026-05-21 07:55:58','?','#4CAF50','daily',1,1,1,'2026-06-02'),(37,25,'Học tập 1 giờ','other',1,NULL,NULL,1,'2026-05-26 05:19:15','✏️','#4CAF50','daily',1,1,1,'2026-05-26'),(47,32,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-05-28 12:48:45','?','#4CAF50','daily',1,1,1,'2026-06-10'),(73,32,'Chạy 500m','exercise',1,NULL,NULL,1,'2026-05-30 04:40:18','?','#4CAF50','daily',1,1,1,'2026-06-10'),(74,45,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-06 04:45:48','?','#4CAF50','daily',1,0,0,NULL),(75,45,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-06 04:45:49','?','#4CAF50','daily',1,1,1,'2026-06-06'),(76,47,'Vận động 30 phút','exercise',1,NULL,NULL,0,'2026-06-10 04:50:13','?','#4CAF50','daily',1,1,1,'2026-06-10'),(77,47,'Đi bộ 20 phút','exercise',1,NULL,NULL,0,'2026-06-10 04:50:14','?','#4CAF50','daily',1,1,1,'2026-06-10'),(78,43,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-10 06:12:09','?','#4CAF50','daily',1,1,1,'2026-06-10'),(79,43,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-10 06:12:10','?','#4CAF50','daily',1,1,1,'2026-06-10'),(80,7,'Chạy 200m','exercise',1,NULL,NULL,1,'2026-06-10 10:05:47','?','#4CAF50','daily',1,1,1,'2026-06-10'),(81,43,'Uống 2l nước','hydration',1,NULL,NULL,1,'2026-06-10 10:08:23','?','#4CAF50','daily',1,1,1,'2026-06-10'),(82,43,'Ăn 2 đĩa rau','eat',1,NULL,NULL,1,'2026-06-10 10:09:16','?','#4CAF50','daily',1,1,1,'2026-06-10'),(83,43,'Ngủ đủ 8 tiếng','sleep',1,NULL,NULL,1,'2026-06-10 10:10:04','?','#4CAF50','daily',1,1,1,'2026-06-10'),(84,43,'Thiền 20 phút','mental',1,NULL,NULL,1,'2026-06-10 10:10:36','?','#4CAF50','daily',1,1,1,'2026-06-10'),(85,43,'Đọc sách 20 phút','other',1,NULL,NULL,0,'2026-06-10 10:36:52','?','#4CAF50','daily',1,0,0,NULL),(86,43,'Đọc sách 20 phút','other',1,NULL,NULL,0,'2026-06-10 10:37:12','?','#4CAF50','daily',1,1,1,'2026-06-10'),(87,43,'Đọc sách 10 phút','other',1,NULL,NULL,1,'2026-06-10 10:37:48','?','#4CAF50','daily',1,1,1,'2026-06-10'),(88,12,'hehe','other',1,NULL,NULL,1,'2026-06-10 11:02:16','?','#4CAF50','daily',1,1,1,'2026-06-10'),(89,12,'ci ly','other',1,NULL,NULL,0,'2026-06-10 11:03:37','?','#4CAF50','daily',1,1,1,'2026-06-10'),(90,32,'Đọc sách 20 phút','other',1,NULL,NULL,1,'2026-06-10 11:14:30','?','#4CAF50','daily',1,1,1,'2026-06-10'),(91,32,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-10 11:24:06','?','#4CAF50','daily',1,1,1,'2026-06-10'),(92,32,'Tập gym','exercise',1,NULL,NULL,1,'2026-06-10 11:24:37','?','#4CAF50','daily',1,1,1,'2026-06-10'),(93,47,'Ngủ đủ giấc','sleep',1,NULL,NULL,0,'2026-06-10 11:38:30','?','#4CAF50','daily',1,1,1,'2026-06-10'),(94,47,'Uống đủ nước','hydration',1,NULL,NULL,0,'2026-06-10 11:38:43','?','#4CAF50','daily',1,1,1,'2026-06-10'),(95,47,'Thiền 20 phút','mental',1,NULL,NULL,0,'2026-06-10 11:39:03','?','#4CAF50','daily',1,1,1,'2026-06-10'),(96,47,'Ăn rau','eat',1,NULL,NULL,0,'2026-06-10 11:40:51','?','#4CAF50','daily',1,1,1,'2026-06-10'),(97,6,'Đọc sách 20 phút','other',1,NULL,NULL,1,'2026-06-10 11:59:12','?','#4CAF50','daily',1,1,1,'2026-06-15'),(98,6,'Tập gym','other',1,NULL,NULL,0,'2026-06-10 11:59:38','?','#4CAF50','daily',1,1,1,'2026-06-10'),(99,6,'Ngủ đủ giấc','sleep',1,NULL,NULL,1,'2026-06-10 12:00:06','?','#4CAF50','daily',1,2,2,'2026-06-11'),(100,6,'Làm bài tập','other',1,NULL,NULL,0,'2026-06-10 12:00:30','?','#4CAF50','daily',1,1,1,'2026-06-10'),(101,48,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-11 04:19:05','?','#4CAF50','daily',1,0,0,NULL),(102,49,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-13 08:37:02','?','#4CAF50','daily',1,0,0,NULL),(103,49,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-13 08:37:03','?','#4CAF50','daily',1,0,0,NULL),(104,50,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-06-14 04:24:49','?','#4CAF50','daily',1,1,1,'2026-06-14'),(105,51,'Vận động 30 phút','exercise',1,NULL,NULL,1,'2026-06-14 04:35:06','?','#4CAF50','daily',1,0,0,NULL),(106,51,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-14 04:35:08','?','#4CAF50','daily',1,0,0,NULL),(107,52,'Thiền 10 phút','mental',1,NULL,NULL,1,'2026-06-14 04:45:45','?','#4CAF50','daily',1,0,0,NULL),(108,53,'Đi bộ 20 phút','exercise',1,NULL,NULL,1,'2026-06-14 05:05:49','?','#4CAF50','daily',1,1,1,'2026-06-14'),(109,53,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-14 05:05:50','?','#4CAF50','daily',1,1,1,'2026-06-14'),(110,54,'Ăn sáng lành mạnh','eat',1,NULL,NULL,0,'2026-06-14 10:16:54','?','#4CAF50','daily',1,1,1,'2026-06-14'),(111,54,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,0,'2026-06-14 10:16:55','?','#4CAF50','daily',1,1,1,'2026-06-14'),(112,54,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-14 11:40:01','?','#4CAF50','daily',1,0,0,NULL),(113,54,'Uống 1 ly nước','hydration',1,NULL,NULL,0,'2026-06-14 11:41:16','?','#4CAF50','daily',1,1,1,'2026-06-14'),(114,54,'Uống nước','hydration',1,NULL,NULL,0,'2026-06-14 12:10:29','?','#4CAF50','daily',700,1,1,'2026-06-14'),(115,54,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-06-14 12:16:17','?','#4CAF50','daily',10,0,0,NULL),(116,54,'Uống nước hàng ngày','hydration',1,NULL,NULL,0,'2026-06-14 12:17:00','?','#4CAF50','daily',600,1,1,'2026-06-14'),(117,54,'Uống nước mỗi buổi sáng','hydration',1,NULL,NULL,0,'2026-06-14 12:26:10','?','#4CAF50','daily',400,1,1,'2026-06-14'),(118,54,'Uống nước buổi sáng','hydration',1,NULL,NULL,1,'2026-06-14 12:37:53','?','#4CAF50','daily',400,1,1,'2026-06-14'),(119,54,'Uống nước buổi chiều','hydration',1,NULL,NULL,1,'2026-06-14 12:39:04','?','#4CAF50','daily',2000,1,1,'2026-06-14'),(120,6,'Uống nước buổi sáng','hydration',1,NULL,NULL,1,'2026-06-15 03:36:56','?','#4CAF50','daily',600,1,1,'2026-06-15'),(121,6,'Uống nước buổi trưa','hydration',1,NULL,NULL,1,'2026-06-15 03:38:52','?','#4CAF50','daily',600,0,0,NULL),(122,6,'Xem thời sự','other',1,NULL,NULL,1,'2026-06-15 03:40:19','?','#4CAF50','daily',1,1,1,'2026-06-15'),(123,6,'Uống nước đi','hydration',1,NULL,NULL,0,'2026-06-15 03:41:16','?','#4CAF50','daily',2000,0,0,NULL),(124,6,'Uống nước','hydration',1,NULL,'10:57:00',0,'2026-06-15 03:57:01','?','#4CAF50','daily',400,0,0,NULL),(125,6,'Uống 200 ml nước','hydration',1,NULL,'10:59:00',0,'2026-06-15 03:58:23','?','#4CAF50','daily',200,1,1,'2026-06-15'),(126,6,'Thiền 20 phút','mental',1,NULL,'11:08:00',0,'2026-06-15 04:08:01','?','#4CAF50','daily',20,1,1,'2026-06-15'),(127,6,'Chạy bộ 15 phút','exercise',1,NULL,'11:10:00',0,'2026-06-15 04:09:53','?','#4CAF50','daily',15,0,0,NULL),(128,6,'Test uống nước','hydration',1,NULL,'11:32:00',0,'2026-06-15 04:31:48','?','#4CAF50','daily',2000,0,0,NULL),(129,6,'test','hydration',1,NULL,'11:34:00',0,'2026-06-15 04:33:16','?','#4CAF50','daily',2000,0,0,NULL),(130,6,'test 11h35','hydration',1,NULL,'11:35:00',0,'2026-06-15 04:34:18','?','#4CAF50','daily',300,0,0,NULL),(131,6,'test 11h41','hydration',1,NULL,'11:41:00',0,'2026-06-15 04:39:45','?','#4CAF50','daily',2000,0,0,NULL),(132,6,'test 11h53','eat',1,NULL,'11:53:00',0,'2026-06-15 04:52:47','?','#4CAF50','daily',300,0,0,NULL),(133,6,'Test uống nước 12h26','hydration',1,NULL,'12:26:00',1,'2026-06-16 05:25:12','?','#4CAF50','daily',400,0,0,NULL),(134,6,'test ngủ trưa 10 phút','sleep',1,NULL,'12:30:00',1,'2026-06-16 05:29:13','?','#4CAF50','daily',10,1,1,'2026-06-16');
/*!40000 ALTER TABLE `habits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `habit_id` int DEFAULT NULL,
  `type` enum('email','push','widget') COLLATE utf8mb4_unicode_ci DEFAULT 'push',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `scheduled_time` datetime DEFAULT NULL,
  `is_sent` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `habit_id` (`habit_id`),
  KEY `idx_notifications_user` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`habit_id`) REFERENCES `habits` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `plants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plants`
--

LOCK TABLES `plants` WRITE;
/*!40000 ALTER TABLE `plants` DISABLE KEYS */;
INSERT INTO `plants` VALUES (2,7,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL),(3,6,'cactus',2,6,'2026-06-16',0,100,'basic',NULL,0,NULL),(4,12,'sunflower',3,15,'2026-06-10',0,100,'basic',NULL,0,NULL),(13,25,'flower',1,3,'2026-05-26',0,100,'basic',NULL,0,NULL),(20,32,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL),(31,45,'sprout',1,2,'2026-06-06',0,100,'basic',NULL,0,NULL),(32,47,'sprout',3,15,'2026-06-10',0,100,'basic',NULL,0,NULL),(33,43,'sprout',3,17,'2026-06-10',0,100,'basic',NULL,0,NULL),(34,48,'sprout',1,0,NULL,0,100,'basic',NULL,0,NULL),(35,49,'cactus',1,0,NULL,0,100,'basic',NULL,0,NULL),(36,50,'sunflower',1,3,'2026-06-14',0,100,'basic',NULL,0,NULL),(37,51,'sprout',1,0,NULL,0,100,'basic',NULL,0,NULL),(38,52,'flower',1,0,NULL,0,100,'basic',NULL,0,NULL),(39,53,'sunflower',2,5,'2026-06-14',0,100,'basic',NULL,0,NULL),(40,54,'bamboo',2,6,'2026-06-14',0,100,'basic',NULL,0,NULL);
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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `streaks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streaks`
--

LOCK TABLES `streaks` WRITE;
/*!40000 ALTER TABLE `streaks` DISABLE KEYS */;
INSERT INTO `streaks` VALUES (1,7,1,1,'2026-06-10'),(2,12,1,3,'2026-06-10'),(3,6,2,3,'2026-06-16'),(9,25,1,1,'2026-05-26'),(16,32,1,1,'2026-06-10'),(25,45,1,1,'2026-06-06'),(26,47,1,1,'2026-06-10'),(27,43,1,1,'2026-06-10'),(28,50,1,1,'2026-06-14'),(29,53,1,1,'2026-06-14'),(30,54,1,1,'2026-06-14');
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
INSERT INTO `user_follows` VALUES (6,7,'2026-05-31 05:11:45'),(6,12,'2026-06-15 10:33:27'),(12,6,'2026-06-03 10:09:24'),(12,32,'2026-06-03 11:09:45'),(32,12,'2026-06-03 10:54:15');
/*!40000 ALTER TABLE `user_follows` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_notifications`
--

LOCK TABLES `user_notifications` WRITE;
/*!40000 ALTER TABLE `user_notifications` DISABLE KEYS */;
INSERT INTO `user_notifications` VALUES (1,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,0,'2026-06-06 05:34:31'),(2,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,1,'2026-06-06 05:39:01'),(3,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,1,'2026-06-08 04:44:03'),(4,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Không phù hợp với tiêu chuẩn cộng đồng','⚠️','{\"reason\": \"Không phù hợp với tiêu chuẩn cộng đồng\", \"post_id\": \"12\"}',NULL,1,'2026-06-08 05:01:24'),(5,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,1,'2026-06-08 06:00:00'),(6,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:03'),(7,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:07'),(8,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:10'),(9,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:13'),(10,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,1,'2026-06-08 06:05:00'),(11,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:03'),(12,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:06'),(13,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:10'),(14,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:13'),(15,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,1,'2026-06-08 06:12:00'),(16,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:02'),(17,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:05'),(18,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:10'),(19,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:13'),(20,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,1,'2026-06-10 04:45:00'),(21,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:03'),(22,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:05'),(23,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:08'),(24,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-10 04:45:11'),(25,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:00'),(26,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:03'),(27,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:06'),(28,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:08'),(29,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:11'),(30,47,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-10 04:52:13'),(31,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:00'),(32,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:03'),(33,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:06'),(34,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:10'),(35,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:13'),(36,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:16'),(37,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:19'),(38,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-11 04:52:23'),(39,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:00'),(40,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:03'),(41,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:06'),(42,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:09'),(43,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:11'),(44,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:14'),(45,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:18'),(46,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:20'),(47,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:23'),(48,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:25'),(49,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 04:52:28'),(50,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:00'),(51,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:00'),(52,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:03'),(53,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:03'),(54,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:06'),(55,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:07'),(56,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:09'),(57,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:10'),(58,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:12'),(59,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:14'),(60,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:16'),(61,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:16'),(62,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:18'),(63,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:20'),(64,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:21'),(65,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:23'),(66,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:24'),(67,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:27'),(68,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:27'),(69,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:30'),(70,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:30'),(71,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:33'),(72,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','⏰ Đừng quên hoàn thành thói quen hôm nay nhé! Mỗi ngày một chút, thành công sẽ đến! ?','?',NULL,NULL,0,'2026-06-14 13:00:34'),(73,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','Dzo thực hiện thói quen liền cho tui ?','?',NULL,NULL,0,'2026-06-14 13:00:36'),(74,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:00'),(75,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:02'),(76,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:06'),(77,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:08'),(78,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:10'),(79,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:13'),(80,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:15'),(81,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:17'),(82,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:20'),(83,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:22'),(84,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:24'),(85,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:26'),(86,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:28'),(87,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-15 04:52:31'),(88,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:00'),(89,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:00'),(90,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:03'),(91,7,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:03'),(92,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:06'),(93,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:06'),(94,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:09'),(95,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:09'),(96,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:11'),(97,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:12'),(98,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:14'),(99,43,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:15'),(100,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:17'),(101,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:17'),(102,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:20'),(103,48,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:20'),(104,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:23'),(105,49,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:23'),(106,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:26'),(107,50,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:26'),(108,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:29'),(109,51,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:30'),(110,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:32'),(111,52,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:33'),(112,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:35'),(113,53,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:37'),(114,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:37'),(115,54,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Giữ vững chuỗi ngày của bạn! Hoàn thành thói quen ngay hôm nay! ?','?',NULL,NULL,0,'2026-06-15 11:00:40');
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'Huệ Trinh','trinhfokko@gmail.com','$2b$10$vZBWx/jBkOpFB5A.7txl5.hvARrMKLpx8gAnNPamtOloO.blxuHq.','/uploads/avatar-1781519564325-701026932.jpg','user',1,1,'2026-04-20 07:46:15','female',2004,157.00,47.00,'[\"sleep\"]',NULL,NULL,'eINyPfbcRw6GsB5Y7Jn9r6:APA91bHCi7-YgyXJcCsQtsVVEFta7c8rYgVy7GMxOiOp735EW0lwi3-SkFFOFSYgTrdr1_sssN8gBf0bRrHtW9YW5e0DPQMCqXwapem_5dqScqezXaI-fso',1,12,0,1,17,35),(7,'Vũ Ngọc Mẫn Nhi','meomeodthvch@gmail.com','','/uploads/avatar-1780487790001-807066220.jpg','user',1,1,'2026-04-20 08:01:11','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0),(12,'Nhật Anh','trinhmeo2k4@gmail.com','','/uploads/avatar-1780481028817-690785779.jpg','user',1,1,'2026-04-21 05:27:27','female',2006,157.00,47.00,'[\"weight\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,11,40,1,18,17),(25,'Huệ Trinh','thachthihuetrinh2004@gmail.com','',NULL,'user',1,1,'2026-05-26 05:17:40','female',2001,157.00,47.00,'[\"other:Hoc\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(32,'Bình Nguyễn','binh@gmail.com','$2b$10$8HGmrLwAY7EHg3Uqe0nEieMuA.NqmHJqhZXakADYsySoqIrhZjfQy','/uploads/avatar-1780484132949-94407951.jpg','user',1,1,'2026-05-28 12:48:25','male',2001,156.00,56.00,'[\"hydration\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0),(43,'Thanh Trà','meodthvch2004@gmail.com','','/uploads/avatar-1781087986257-727332690.jpg','user',1,1,'2026-06-03 11:46:38','female',2006,157.00,46.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0),(44,'Viora Application','viora.application@gmail.com','',NULL,'admin',1,1,'2026-06-05 04:49:11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'eINyPfbcRw6GsB5Y7Jn9r6:APA91bHCi7-YgyXJcCsQtsVVEFta7c8rYgVy7GMxOiOp735EW0lwi3-SkFFOFSYgTrdr1_sssN8gBf0bRrHtW9YW5e0DPQMCqXwapem_5dqScqezXaI-fso',1,8,0,1,21,0),(45,'Hồng Anh','honganh@gmail.com','$2b$10$3BqFk9lyQZhUmn.zwtVzaev/ZIFDJzYvHkRVu67f/amIQs6tzexh.',NULL,'user',1,1,'2026-06-06 04:45:14','female',2001,165.00,47.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0),(47,'Âu Gia Bảo','augiabao832@gmail.com','$2b$10$AZm1ZcqYjlbkipXTLP5aZ.SISDeevUIYjPhGppLmBw7RSlRDohgoi',NULL,'user',1,1,'2026-06-10 04:49:43','male',2007,167.00,52.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0),(48,'Hoa Hồng','hoahong@gmail.com','$2b$10$i9UeftFNK4z5CqiSmnLMwuubavtABPKeR1hizQJSIKL/ZNcRHj.eG',NULL,'user',1,1,'2026-06-11 04:15:55','female',2001,156.00,45.00,'[\"mental\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0),(49,'demo','demo@gmail.com','$2b$10$MuHbbBaiLvOjNU2j6P32TemkbW38Cfj0kdpd2v8IObUqa.cMdhh3i',NULL,'user',1,1,'2026-06-13 08:30:01','male',2007,157.00,47.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0),(50,'Ngọc Anh','ngocanh@gmail.com','$2b$10$ta57mdNqjn/ULd1RTnM1weX4AiCMwoJ04z0Czz5X4ecESiR47XtJm',NULL,'user',1,1,'2026-06-14 04:24:21','female',2007,157.00,47.00,'[\"hydration\"]',NULL,NULL,NULL,1,8,0,1,21,0),(51,'Hữu Nhân','huunhan@gmail.com','$2b$10$BDE2zoR3/dmKNqXecn.oBOq7nD6IydXJfvFupjO3gxg3/vMsO28eC',NULL,'user',1,1,'2026-06-14 04:34:41','male',2006,167.00,56.00,'[\"exercise\"]',NULL,NULL,NULL,1,8,0,1,21,0),(52,'Anh Đào','anhdao@gmail.com','$2b$10$BagSLCUt4Crbsdnlw9YGH.JBLEDGpmgSIWAn3I63uja28sGOuHjjG',NULL,'user',1,1,'2026-06-14 04:45:24','female',2006,157.00,47.00,'[\"mental\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0),(53,'Hướng Dương','huongduong@gmail.com','$2b$10$mBWQ85A.e3jgh.P62SUet.o.mxpmHytcfoM0OOvnzzlI9f4qMUzDu',NULL,'user',1,1,'2026-06-14 05:05:25','male',2001,170.00,60.00,'[\"weight\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0),(54,'Bam Boo','bamboo@gmail.com','$2b$10$/fVqx5AvBCGePxO86g1rOOQl0pW9GHrd9lZFLqyoCcRGpQwiaMTcy',NULL,'user',1,1,'2026-06-14 10:16:13','other',2001,167.00,47.00,'[\"eat_healthy\"]',NULL,NULL,'e-1gHTMAQYqkwNVM1niySX:APA91bF7VrwDkVSsJx_VfVNKVdsKIdaIGKDDZ2LFH3lSzR0A1uKKrhJ0EZ08K6ZQDJZl1A0FVN3nf8n7_ZITWrOokQMJZ43W2MJ-Gi6Ge6FTGvDeo5LUrzI',1,8,0,1,21,0);
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

-- Dump completed on 2026-06-16 15:41:48
