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
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,6,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:17:12','2026-04-28 06:17:12'),(2,7,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:29:14','2026-04-28 06:29:14'),(3,6,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-04-30 11:14:53','2026-04-30 11:14:53'),(4,12,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(5,12,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(6,6,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-05-06 05:01:16','2026-05-06 05:01:16'),(7,12,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-05-13 04:38:14','2026-05-13 04:38:14'),(12,25,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-26 05:19:30','2026-05-26 05:19:30'),(19,32,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-28 12:48:55','2026-05-28 12:48:55'),(30,45,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-06-06 04:46:05','2026-06-06 04:46:05');
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
INSERT INTO `auto_reminder_settings` VALUES (1,1,'13:12:00','20:00:00',1,1,'2026-06-08 06:11:47');
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
INSERT INTO `community_post_likes` VALUES (6,12,'2026-06-02 05:32:39'),(6,13,'2026-06-03 10:16:04'),(7,13,'2026-06-03 11:53:37'),(12,12,'2026-06-03 10:09:40'),(12,13,'2026-06-03 10:10:17'),(12,14,'2026-06-03 11:16:27'),(32,13,'2026-06-03 10:53:51'),(45,13,'2026-06-06 04:46:40'),(45,14,'2026-06-06 04:46:53');
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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `community_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_posts`
--

LOCK TABLES `community_posts` WRITE;
/*!40000 ALTER TABLE `community_posts` DISABLE KEYS */;
INSERT INTO `community_posts` VALUES (12,6,'Tìm bạn chạy bộ mỗi sáng cùng mình hehe','http://10.0.2.2:3000/uploads/1780378232788-178490186.jpg',NULL,NULL,2,'2026-06-02 05:30:33'),(13,12,'Hơi thở chính là cây cầu kết nối sự sống và ý thức của con người. Khi gặp phải những chuyện buồn trong cuộc sống, hãy hít một hơi thật sâu, thở ra và cho qua mọi thứ','http://10.0.2.2:3000/uploads/1780481276384-741277433.jpg',NULL,NULL,3,'2026-06-03 10:07:57'),(14,32,'?','http://10.0.2.2:3000/uploads/1780484789156-731392882.jpg',NULL,NULL,1,'2026-06-03 11:06:30');
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
) ENGINE=InnoDB AUTO_INCREMENT=152 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habit_logs`
--

LOCK TABLES `habit_logs` WRITE;
/*!40000 ALTER TABLE `habit_logs` DISABLE KEYS */;
INSERT INTO `habit_logs` VALUES (6,2,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(7,1,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(8,3,7,'2026-04-20',0,0,'2026-04-20 09:29:15',NULL,NULL,NULL),(15,4,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(16,5,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(18,7,12,'2026-04-21',0,0,'2026-04-21 05:31:52',NULL,NULL,NULL),(19,6,12,'2026-04-21',0,0,'2026-04-21 05:31:53',NULL,NULL,NULL),(20,8,12,'2026-04-21',0,0,'2026-04-21 05:39:24',NULL,NULL,NULL),(21,9,6,'2026-04-25',0,0,'2026-04-25 06:29:43',NULL,NULL,NULL),(37,9,6,'2026-04-28',0,0,'2026-04-28 06:20:39',NULL,NULL,NULL),(38,12,6,'2026-04-28',0,0,'2026-04-28 06:20:40',NULL,NULL,NULL),(39,13,6,'2026-04-28',0,0,'2026-04-28 06:20:41',NULL,NULL,NULL),(40,3,7,'2026-04-28',0,0,'2026-04-28 06:29:14',NULL,NULL,NULL),(41,2,7,'2026-04-28',0,0,'2026-04-28 06:29:19',NULL,NULL,NULL),(42,1,7,'2026-04-28',0,0,'2026-04-28 06:30:01',NULL,NULL,NULL),(43,13,6,'2026-04-29',0,0,'2026-04-29 09:27:32',NULL,NULL,NULL),(44,12,6,'2026-04-29',0,0,'2026-04-29 09:28:25',NULL,NULL,NULL),(45,9,6,'2026-04-29',0,0,'2026-04-29 09:28:49',NULL,NULL,NULL),(46,12,6,'2026-04-30',0,0,'2026-04-30 11:14:53',NULL,NULL,NULL),(47,9,6,'2026-04-30',0,0,'2026-04-30 11:15:09',NULL,NULL,NULL),(48,3,7,'2026-04-30',0,0,'2026-04-30 11:16:41',NULL,NULL,NULL),(49,8,12,'2026-04-30',0,0,'2026-04-30 11:35:42',NULL,NULL,NULL),(50,7,12,'2026-04-30',0,0,'2026-04-30 11:35:48',NULL,NULL,NULL),(51,12,6,'2026-05-02',0,0,'2026-05-02 10:53:16',NULL,NULL,NULL),(52,9,6,'2026-05-02',0,0,'2026-05-02 11:45:13',NULL,NULL,NULL),(53,12,6,'2026-05-04',0,0,'2026-05-04 05:56:25',NULL,NULL,NULL),(54,9,6,'2026-05-04',0,0,'2026-05-04 05:56:36',NULL,NULL,NULL),(55,12,6,'2026-05-06',0,0,'2026-05-06 04:47:38',NULL,NULL,NULL),(56,9,6,'2026-05-06',0,0,'2026-05-06 04:47:44',NULL,NULL,NULL),(57,16,6,'2026-05-06',0,0,'2026-05-06 05:01:16',NULL,20.00,'ml'),(58,16,6,'2026-05-07',0,0,'2026-05-07 04:18:38',NULL,NULL,'ml'),(59,17,6,'2026-05-07',0,0,'2026-05-07 04:20:13',NULL,0.50,'km'),(60,19,6,'2026-05-07',0,0,'2026-05-07 05:01:00',NULL,400.00,'km'),(61,20,6,'2026-05-07',0,0,'2026-05-07 05:09:48',NULL,300.00,'cal'),(62,20,6,'2026-05-10',0,0,'2026-05-10 04:22:57',NULL,50.00,'cal'),(63,16,6,'2026-05-10',0,0,'2026-05-10 04:32:13',NULL,200.00,'ml'),(64,19,6,'2026-05-10',0,0,'2026-05-10 05:22:18',NULL,200.00,'m'),(65,3,7,'2026-05-10',0,0,'2026-05-10 06:19:46',NULL,NULL,NULL),(66,20,6,'2026-05-11',0,0,'2026-05-11 05:36:43',NULL,20.00,'cal'),(67,16,6,'2026-05-11',0,0,'2026-05-11 05:37:00',NULL,200.00,'ml'),(68,19,6,'2026-05-11',0,0,'2026-05-11 05:42:31',NULL,350.00,'m'),(69,8,12,'2026-05-11',0,0,'2026-05-11 05:44:56',NULL,NULL,NULL),(70,7,12,'2026-05-11',0,0,'2026-05-11 05:44:58',NULL,NULL,NULL),(71,5,12,'2026-05-11',0,0,'2026-05-11 05:45:00',NULL,NULL,NULL),(72,4,12,'2026-05-12',0,0,'2026-05-12 04:49:52',NULL,NULL,NULL),(73,21,12,'2026-05-12',0,0,'2026-05-12 04:50:49',NULL,500.00,'m'),(74,22,12,'2026-05-12',0,0,'2026-05-12 05:01:49',NULL,100.00,'cal'),(75,22,12,'2026-05-13',0,0,'2026-05-13 04:38:14',NULL,150.00,'cal'),(76,21,12,'2026-05-13',0,0,'2026-05-13 04:41:30',NULL,500.00,'m'),(77,20,6,'2026-05-13',0,0,'2026-05-13 05:24:02',NULL,120.00,'cal'),(78,19,6,'2026-05-13',0,0,'2026-05-13 05:24:36',NULL,200.00,'m'),(79,16,6,'2026-05-13',0,0,'2026-05-13 05:26:20',NULL,100.00,'ml'),(80,3,7,'2026-05-13',0,0,'2026-05-13 05:28:37',NULL,NULL,NULL),(81,2,7,'2026-05-13',0,0,'2026-05-13 05:31:50',NULL,100.00,'cal'),(82,1,7,'2026-05-13',0,0,'2026-05-13 05:33:43',NULL,NULL,NULL),(83,23,12,'2026-05-13',0,0,'2026-05-13 05:40:49',NULL,100.00,'ml'),(84,24,12,'2026-05-13',0,0,'2026-05-13 05:41:54',NULL,1.00,'giờ'),(85,19,6,'2026-05-14',0,0,'2026-05-14 05:00:25',NULL,150.00,'m'),(87,20,6,'2026-05-21',0,0,'2026-05-21 05:59:45',NULL,150.00,'cal'),(88,19,6,'2026-05-21',0,0,'2026-05-21 06:08:56',NULL,120.00,'m'),(89,16,6,'2026-05-21',0,0,'2026-05-21 07:55:08',NULL,NULL,'ml'),(96,37,25,'2026-05-26',0,0,'2026-05-26 05:19:30',NULL,NULL,NULL),(106,47,32,'2026-05-28',0,0,'2026-05-28 12:48:55',NULL,50.00,'ml'),(130,47,32,'2026-05-30',0,0,'2026-05-30 04:40:06',NULL,50.00,'ml'),(131,26,6,'2026-05-30',0,0,'2026-05-30 06:10:08',NULL,50.00,'cal'),(132,20,6,'2026-05-30',0,0,'2026-05-30 06:10:13',NULL,20.00,'cal'),(133,19,6,'2026-05-30',0,0,'2026-05-30 06:10:17',NULL,20.00,'m'),(134,16,6,'2026-05-30',0,0,'2026-05-30 06:10:33',NULL,240.00,'ml'),(135,26,6,'2026-05-31',0,0,'2026-05-31 06:30:58',NULL,NULL,'cal'),(136,20,6,'2026-05-31',0,0,'2026-05-31 06:31:08',NULL,NULL,'cal'),(137,26,6,'2026-06-02',0,0,'2026-06-02 05:33:37',NULL,67.00,'cal'),(138,20,6,'2026-06-03',0,0,'2026-06-03 09:55:12',NULL,56.00,'cal'),(139,21,12,'2026-06-03',0,0,'2026-06-03 10:08:33',NULL,50.00,'m'),(140,19,6,'2026-06-03',0,0,'2026-06-03 10:51:20',NULL,50.00,'m'),(141,16,6,'2026-06-03',0,0,'2026-06-03 10:51:34',NULL,158.00,'ml'),(142,47,32,'2026-06-03',0,0,'2026-06-03 11:05:54',NULL,100.00,'ml'),(143,24,12,'2026-06-03',0,0,'2026-06-03 11:37:14',NULL,2.00,'giờ'),(144,24,12,'2026-06-04',0,0,'2026-06-04 07:56:39',NULL,NULL,'giờ'),(145,23,12,'2026-06-04',0,0,'2026-06-04 07:56:44',NULL,NULL,'ml'),(146,22,12,'2026-06-04',0,0,'2026-06-04 07:56:46',NULL,NULL,'cal'),(147,20,6,'2026-06-05',0,0,'2026-06-05 05:57:05',NULL,NULL,'cal'),(148,19,6,'2026-06-05',0,0,'2026-06-05 05:57:08',NULL,NULL,'m'),(149,75,45,'2026-06-06',0,0,'2026-06-06 04:46:05',NULL,90.00,'cal'),(150,20,6,'2026-06-08',0,0,'2026-06-08 04:49:57',NULL,45.00,'cal'),(151,19,6,'2026-06-08',0,0,'2026-06-08 04:50:37',NULL,100.00,'m');
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
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habits`
--

LOCK TABLES `habits` WRITE;
/*!40000 ALTER TABLE `habits` DISABLE KEYS */;
INSERT INTO `habits` VALUES (1,7,'aa','other',1,NULL,NULL,0,'2026-04-20 09:24:10','⭐','#4CAF50','daily',1,1,1,'2026-05-13'),(2,7,'b','eat',1,NULL,NULL,0,'2026-04-20 09:24:33','?','#4CAF50','daily',1,1,1,'2026-05-13'),(3,7,'c','other',1,NULL,NULL,0,'2026-04-20 09:29:10','?','#4CAF50','daily',1,1,1,'2026-05-13'),(4,12,'testphone','other',1,NULL,NULL,0,'2026-04-21 05:27:55','⭐','#4CAF50','daily',1,1,1,'2026-05-12'),(5,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:28:09','?','#4CAF50','daily',1,1,1,'2026-05-11'),(6,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:31:39','⭐','#4CAF50','daily',1,0,0,NULL),(7,12,'ok','other',1,NULL,NULL,0,'2026-04-21 05:31:45','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(8,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:37:23','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(9,6,'demo','other',1,NULL,NULL,0,'2026-04-25 06:29:41','⭐','#4CAF50','daily',1,0,0,NULL),(12,6,'test','other',1,NULL,NULL,0,'2026-04-28 05:44:12','⭐','#4CAF50','daily',1,0,0,NULL),(13,6,'an','eat',1,NULL,NULL,0,'2026-04-28 06:12:43','⭐','#4CAF50','daily',1,0,0,NULL),(16,6,'Uống 500ml nước','hydration',1,NULL,NULL,1,'2026-05-06 05:01:00','?','#4CAF50','daily',1,1,1,'2026-06-03'),(17,6,'Chạy 500m','exercise',1,NULL,NULL,0,'2026-05-07 04:19:35','?','#4CAF50','daily',1,1,1,'2026-05-07'),(18,6,'Chạy 500m','other',1,NULL,NULL,0,'2026-05-07 05:00:15','?','#4CAF50','daily',1,0,0,NULL),(19,6,'Chạy 500m','exercise',1,NULL,NULL,1,'2026-05-07 05:00:43','?','#4CAF50','daily',1,1,1,'2026-06-08'),(20,6,'Ăn 500 calories','eat',1,NULL,NULL,1,'2026-05-07 05:09:33','?','#4CAF50','daily',1,1,1,'2026-06-08'),(21,12,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-05-12 04:50:35','?','#4CAF50','daily',1,1,1,'2026-06-03'),(22,12,'Ăn healthy','eat',1,NULL,NULL,1,'2026-05-12 05:01:36','?','#4CAF50','daily',1,1,1,'2026-06-04'),(23,12,'Uống nước','hydration',1,NULL,NULL,1,'2026-05-13 05:40:31','?','#4CAF50','daily',1,1,1,'2026-06-04'),(24,12,'Ngủ trưa','sleep',1,NULL,NULL,1,'2026-05-13 05:41:45','?','#4CAF50','daily',1,2,2,'2026-06-04'),(26,6,'Ăn','eat',1,NULL,NULL,0,'2026-05-21 07:55:58','?','#4CAF50','daily',1,1,1,'2026-06-02'),(37,25,'Học tập 1 giờ','other',1,NULL,NULL,1,'2026-05-26 05:19:15','✏️','#4CAF50','daily',1,1,1,'2026-05-26'),(47,32,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-05-28 12:48:45','?','#4CAF50','daily',1,1,1,'2026-06-03'),(73,32,'Chạy 500m','exercise',1,NULL,NULL,1,'2026-05-30 04:40:18','?','#4CAF50','daily',1,0,0,NULL),(74,45,'Ăn sáng lành mạnh','eat',1,NULL,NULL,1,'2026-06-06 04:45:48','?','#4CAF50','daily',1,0,0,NULL),(75,45,'Ăn đủ rau & trái cây','eat',1,NULL,NULL,1,'2026-06-06 04:45:49','?','#4CAF50','daily',1,1,1,'2026-06-06');
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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `plants_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plants`
--

LOCK TABLES `plants` WRITE;
/*!40000 ALTER TABLE `plants` DISABLE KEYS */;
INSERT INTO `plants` VALUES (2,7,'sprout',2,14,'2026-05-13',0,100,'basic',NULL),(3,6,'cactus',6,89,'2026-06-08',0,100,'basic',NULL),(4,12,'sunflower',2,14,'2026-06-04',0,100,'basic',NULL),(13,25,'flower',1,3,'2026-05-26',0,100,'basic',NULL),(20,32,'sprout',2,8,'2026-06-03',0,100,'basic',NULL),(31,45,'sprout',1,2,'2026-06-06',0,100,'basic',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streaks`
--

LOCK TABLES `streaks` WRITE;
/*!40000 ALTER TABLE `streaks` DISABLE KEYS */;
INSERT INTO `streaks` VALUES (1,7,1,1,'2026-05-13'),(2,12,2,3,'2026-06-04'),(3,6,1,3,'2026-06-08'),(9,25,1,1,'2026-05-26'),(16,32,1,1,'2026-06-03'),(25,45,1,1,'2026-06-06');
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
INSERT INTO `user_follows` VALUES (6,7,'2026-05-31 05:11:45'),(6,12,'2026-06-03 10:15:47'),(12,6,'2026-06-03 10:09:24'),(12,32,'2026-06-03 11:09:45'),(32,12,'2026-06-03 10:54:15');
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_notifications`
--

LOCK TABLES `user_notifications` WRITE;
/*!40000 ALTER TABLE `user_notifications` DISABLE KEYS */;
INSERT INTO `user_notifications` VALUES (1,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,0,'2026-06-06 05:34:31'),(2,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,0,'2026-06-06 05:39:01'),(3,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Thông tin sai sự thật','⚠️','{\"reason\": \"Thông tin sai sự thật\", \"post_id\": \"12\"}',NULL,0,'2026-06-08 04:44:03'),(4,6,'warning','Cảnh báo vi phạm nội dung','Bài viết của bạn vi phạm quy định cộng đồng: Không phù hợp với tiêu chuẩn cộng đồng','⚠️','{\"reason\": \"Không phù hợp với tiêu chuẩn cộng đồng\", \"post_id\": \"12\"}',NULL,1,'2026-06-08 05:01:24'),(5,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,1,'2026-06-08 06:00:00'),(6,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:03'),(7,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:07'),(8,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:10'),(9,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Cây của bạn đang đợi bạn đấy! Hãy hoàn thành thói quen để cây phát triển tốt nhé! ?','?',NULL,NULL,0,'2026-06-08 06:00:13'),(10,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,1,'2026-06-08 06:05:00'),(11,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:03'),(12,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:06'),(13,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:10'),(14,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','? Thành công là tổng của những nỗ lực nhỏ lặp đi lặp lại mỗi ngày. Bạn đã hoàn thành chưa? ?','?',NULL,NULL,0,'2026-06-08 06:05:13'),(15,6,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:00'),(16,12,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:02'),(17,25,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:05'),(18,32,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:10'),(19,45,'reminder','⏰ Nhắc nhở hoàn thành thói quen','✨ Hành trình ngàn dặm bắt đầu từ bước chân đầu tiên. Hãy hoàn thành thói quen của bạn! ?','?',NULL,NULL,0,'2026-06-08 06:12:13');
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
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'Huệ Trinh','trinhfokko@gmail.com','$2b$10$vZBWx/jBkOpFB5A.7txl5.hvARrMKLpx8gAnNPamtOloO.blxuHq.','/uploads/avatar-1780209034497-231256774.jpg','user',1,1,'2026-04-20 07:46:15','female',2004,157.00,47.00,'[\"sleep\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,14,52,1,18,17),(7,'Vũ Ngọc Mẫn Nhi','meomeodthvch@gmail.com','','/uploads/avatar-1780487790001-807066220.jpg','user',1,1,'2026-04-20 08:01:11','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(12,'Nhật Anh','trinhmeo2k4@gmail.com','','/uploads/avatar-1780481028817-690785779.jpg','user',1,1,'2026-04-21 05:27:27','female',2006,157.00,47.00,'[\"weight\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,11,40,1,18,17),(25,'Huệ Trinh','thachthihuetrinh2004@gmail.com','',NULL,'user',1,1,'2026-05-26 05:17:40','female',2001,157.00,47.00,'[\"other:Hoc\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(32,'Bình Nguyễn','binh@gmail.com','$2b$10$8HGmrLwAY7EHg3Uqe0nEieMuA.NqmHJqhZXakADYsySoqIrhZjfQy','/uploads/avatar-1780484132949-94407951.jpg','user',1,1,'2026-05-28 12:48:25','male',2001,156.00,56.00,'[\"hydration\"]',NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0),(43,'meo meo','meodthvch2004@gmail.com','',NULL,'user',1,1,'2026-06-03 11:46:38',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(44,'Viora Application','viora.application@gmail.com','',NULL,'admin',1,1,'2026-06-05 04:49:11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'eGz8-aiBRnag008TozA5Nn:APA91bEshtKd7_4piwh47QKJTjFfsiCq1c8_zcJa6tY6iP5_jkqpDVY6_A4mbT3qL1ETGq1w7r3yUtZMh8zFIhQCdljN85R6HCl85k_3eHOyqcixkQoeusk',1,8,0,1,21,0),(45,'Hồng Anh','honganh@gmail.com','$2b$10$3BqFk9lyQZhUmn.zwtVzaev/ZIFDJzYvHkRVu67f/amIQs6tzexh.',NULL,'user',1,1,'2026-06-06 04:45:14','female',2001,165.00,47.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0);
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

-- Dump completed on 2026-06-08 13:13:36
