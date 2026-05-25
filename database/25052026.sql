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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,6,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:17:12','2026-04-28 06:17:12'),(2,7,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:29:14','2026-04-28 06:29:14'),(3,6,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-04-30 11:14:53','2026-04-30 11:14:53'),(4,12,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(5,12,'habits_5','Đa nhiệm','Tạo 5 thói quen','?','2026-04-30 11:35:42','2026-04-30 11:35:42'),(6,6,'plant_level_3','Cây non','Cây đạt cấp độ 3','?','2026-05-06 05:01:16','2026-05-06 05:01:16'),(7,12,'streak_3','3 ngày liên tiếp','Duy trì streak 3 ngày','?','2026-05-13 04:38:14','2026-05-13 04:38:14'),(8,18,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-14 07:10:36','2026-05-14 07:10:36'),(10,21,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-25 05:33:41','2026-05-25 05:33:41'),(11,24,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-05-25 05:58:54','2026-05-25 05:58:54');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
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
INSERT INTO `community_comment_likes` VALUES (6,1,'2026-05-21 07:33:41');
/*!40000 ALTER TABLE `community_comment_likes` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_comments`
--

LOCK TABLES `community_comments` WRITE;
/*!40000 ALTER TABLE `community_comments` DISABLE KEYS */;
INSERT INTO `community_comments` VALUES (1,1,7,'hi','2026-05-21 06:07:10');
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
INSERT INTO `community_post_likes` VALUES (6,1,'2026-05-21 06:08:04'),(6,3,'2026-05-21 06:08:03'),(7,1,'2026-05-21 06:06:31'),(24,4,'2026-05-25 06:01:25');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_posts`
--

LOCK TABLES `community_posts` WRITE;
/*!40000 ALTER TABLE `community_posts` DISABLE KEYS */;
INSERT INTO `community_posts` VALUES (1,6,'hi',NULL,NULL,NULL,1,'2026-05-21 06:04:21'),(2,6,'wow',NULL,NULL,NULL,1,'2026-05-21 06:05:47'),(3,7,'chay 1km nao',NULL,NULL,NULL,1,'2026-05-21 06:06:50'),(4,6,'hi mn',NULL,NULL,NULL,1,'2026-05-21 07:33:23');
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
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habit_logs`
--

LOCK TABLES `habit_logs` WRITE;
/*!40000 ALTER TABLE `habit_logs` DISABLE KEYS */;
INSERT INTO `habit_logs` VALUES (6,2,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(7,1,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL,NULL,NULL),(8,3,7,'2026-04-20',0,0,'2026-04-20 09:29:15',NULL,NULL,NULL),(15,4,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(16,5,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL,NULL,NULL),(18,7,12,'2026-04-21',0,0,'2026-04-21 05:31:52',NULL,NULL,NULL),(19,6,12,'2026-04-21',0,0,'2026-04-21 05:31:53',NULL,NULL,NULL),(20,8,12,'2026-04-21',0,0,'2026-04-21 05:39:24',NULL,NULL,NULL),(21,9,6,'2026-04-25',0,0,'2026-04-25 06:29:43',NULL,NULL,NULL),(23,10,15,'2026-04-28',0,0,'2026-04-28 04:35:18',NULL,NULL,NULL),(24,11,15,'2026-04-28',0,0,'2026-04-28 04:36:20',NULL,NULL,NULL),(37,9,6,'2026-04-28',0,0,'2026-04-28 06:20:39',NULL,NULL,NULL),(38,12,6,'2026-04-28',0,0,'2026-04-28 06:20:40',NULL,NULL,NULL),(39,13,6,'2026-04-28',0,0,'2026-04-28 06:20:41',NULL,NULL,NULL),(40,3,7,'2026-04-28',0,0,'2026-04-28 06:29:14',NULL,NULL,NULL),(41,2,7,'2026-04-28',0,0,'2026-04-28 06:29:19',NULL,NULL,NULL),(42,1,7,'2026-04-28',0,0,'2026-04-28 06:30:01',NULL,NULL,NULL),(43,13,6,'2026-04-29',0,0,'2026-04-29 09:27:32',NULL,NULL,NULL),(44,12,6,'2026-04-29',0,0,'2026-04-29 09:28:25',NULL,NULL,NULL),(45,9,6,'2026-04-29',0,0,'2026-04-29 09:28:49',NULL,NULL,NULL),(46,12,6,'2026-04-30',0,0,'2026-04-30 11:14:53',NULL,NULL,NULL),(47,9,6,'2026-04-30',0,0,'2026-04-30 11:15:09',NULL,NULL,NULL),(48,3,7,'2026-04-30',0,0,'2026-04-30 11:16:41',NULL,NULL,NULL),(49,8,12,'2026-04-30',0,0,'2026-04-30 11:35:42',NULL,NULL,NULL),(50,7,12,'2026-04-30',0,0,'2026-04-30 11:35:48',NULL,NULL,NULL),(51,12,6,'2026-05-02',0,0,'2026-05-02 10:53:16',NULL,NULL,NULL),(52,9,6,'2026-05-02',0,0,'2026-05-02 11:45:13',NULL,NULL,NULL),(53,12,6,'2026-05-04',0,0,'2026-05-04 05:56:25',NULL,NULL,NULL),(54,9,6,'2026-05-04',0,0,'2026-05-04 05:56:36',NULL,NULL,NULL),(55,12,6,'2026-05-06',0,0,'2026-05-06 04:47:38',NULL,NULL,NULL),(56,9,6,'2026-05-06',0,0,'2026-05-06 04:47:44',NULL,NULL,NULL),(57,16,6,'2026-05-06',0,0,'2026-05-06 05:01:16',NULL,20.00,'ml'),(58,16,6,'2026-05-07',0,0,'2026-05-07 04:18:38',NULL,NULL,'ml'),(59,17,6,'2026-05-07',0,0,'2026-05-07 04:20:13',NULL,0.50,'km'),(60,19,6,'2026-05-07',0,0,'2026-05-07 05:01:00',NULL,400.00,'km'),(61,20,6,'2026-05-07',0,0,'2026-05-07 05:09:48',NULL,300.00,'cal'),(62,20,6,'2026-05-10',0,0,'2026-05-10 04:22:57',NULL,50.00,'cal'),(63,16,6,'2026-05-10',0,0,'2026-05-10 04:32:13',NULL,200.00,'ml'),(64,19,6,'2026-05-10',0,0,'2026-05-10 05:22:18',NULL,200.00,'m'),(65,3,7,'2026-05-10',0,0,'2026-05-10 06:19:46',NULL,NULL,NULL),(66,20,6,'2026-05-11',0,0,'2026-05-11 05:36:43',NULL,20.00,'cal'),(67,16,6,'2026-05-11',0,0,'2026-05-11 05:37:00',NULL,200.00,'ml'),(68,19,6,'2026-05-11',0,0,'2026-05-11 05:42:31',NULL,350.00,'m'),(69,8,12,'2026-05-11',0,0,'2026-05-11 05:44:56',NULL,NULL,NULL),(70,7,12,'2026-05-11',0,0,'2026-05-11 05:44:58',NULL,NULL,NULL),(71,5,12,'2026-05-11',0,0,'2026-05-11 05:45:00',NULL,NULL,NULL),(72,4,12,'2026-05-12',0,0,'2026-05-12 04:49:52',NULL,NULL,NULL),(73,21,12,'2026-05-12',0,0,'2026-05-12 04:50:49',NULL,500.00,'m'),(74,22,12,'2026-05-12',0,0,'2026-05-12 05:01:49',NULL,100.00,'cal'),(75,22,12,'2026-05-13',0,0,'2026-05-13 04:38:14',NULL,150.00,'cal'),(76,21,12,'2026-05-13',0,0,'2026-05-13 04:41:30',NULL,500.00,'m'),(77,20,6,'2026-05-13',0,0,'2026-05-13 05:24:02',NULL,120.00,'cal'),(78,19,6,'2026-05-13',0,0,'2026-05-13 05:24:36',NULL,200.00,'m'),(79,16,6,'2026-05-13',0,0,'2026-05-13 05:26:20',NULL,100.00,'ml'),(80,3,7,'2026-05-13',0,0,'2026-05-13 05:28:37',NULL,NULL,NULL),(81,2,7,'2026-05-13',0,0,'2026-05-13 05:31:50',NULL,100.00,'cal'),(82,1,7,'2026-05-13',0,0,'2026-05-13 05:33:43',NULL,NULL,NULL),(83,23,12,'2026-05-13',0,0,'2026-05-13 05:40:49',NULL,100.00,'ml'),(84,24,12,'2026-05-13',0,0,'2026-05-13 05:41:54',NULL,1.00,'giờ'),(85,19,6,'2026-05-14',0,0,'2026-05-14 05:00:25',NULL,150.00,'m'),(86,25,18,'2026-05-14',0,0,'2026-05-14 07:10:35',NULL,150.00,'m'),(87,20,6,'2026-05-21',0,0,'2026-05-21 05:59:45',NULL,150.00,'cal'),(88,19,6,'2026-05-21',0,0,'2026-05-21 06:08:56',NULL,120.00,'m'),(89,16,6,'2026-05-21',0,0,'2026-05-21 07:55:08',NULL,NULL,'ml'),(94,30,21,'2026-05-25',0,0,'2026-05-25 05:33:41',NULL,120.00,'m'),(95,36,24,'2026-05-25',0,0,'2026-05-25 05:58:54',NULL,500.00,'ml');
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
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habits`
--

LOCK TABLES `habits` WRITE;
/*!40000 ALTER TABLE `habits` DISABLE KEYS */;
INSERT INTO `habits` VALUES (1,7,'aa','other',1,NULL,NULL,1,'2026-04-20 09:24:10','⭐','#4CAF50','daily',1,1,1,'2026-05-13'),(2,7,'b','eat',1,NULL,NULL,1,'2026-04-20 09:24:33','?','#4CAF50','daily',1,1,1,'2026-05-13'),(3,7,'c','other',1,NULL,NULL,1,'2026-04-20 09:29:10','?','#4CAF50','daily',1,1,1,'2026-05-13'),(4,12,'testphone','other',1,NULL,NULL,0,'2026-04-21 05:27:55','⭐','#4CAF50','daily',1,1,1,'2026-05-12'),(5,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:28:09','?','#4CAF50','daily',1,1,1,'2026-05-11'),(6,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:31:39','⭐','#4CAF50','daily',1,0,0,NULL),(7,12,'ok','other',1,NULL,NULL,0,'2026-04-21 05:31:45','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(8,12,'test','other',1,NULL,NULL,0,'2026-04-21 05:37:23','⭐','#4CAF50','daily',1,1,1,'2026-05-11'),(9,6,'demo','other',1,NULL,NULL,0,'2026-04-25 06:29:41','⭐','#4CAF50','daily',1,0,0,NULL),(10,15,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-04-28 04:35:16','?','#4CAF50','daily',1,0,0,NULL),(11,15,'Uống 2l nước','hydration',1,NULL,NULL,1,'2026-04-28 04:36:16','?','#4CAF50','daily',1,0,0,NULL),(12,6,'test','other',1,NULL,NULL,0,'2026-04-28 05:44:12','⭐','#4CAF50','daily',1,0,0,NULL),(13,6,'an','eat',1,NULL,NULL,0,'2026-04-28 06:12:43','⭐','#4CAF50','daily',1,0,0,NULL),(14,17,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-04-30 11:40:27','?','#4CAF50','daily',1,0,0,NULL),(15,17,'Ăn rau','eat',1,NULL,NULL,1,'2026-04-30 11:40:39','?','#4CAF50','daily',1,0,0,NULL),(16,6,'Uống 500ml nước','hydration',1,NULL,NULL,1,'2026-05-06 05:01:00','?','#4CAF50','daily',1,1,1,'2026-05-21'),(17,6,'Chạy 500m','exercise',1,NULL,NULL,0,'2026-05-07 04:19:35','?','#4CAF50','daily',1,1,1,'2026-05-07'),(18,6,'Chạy 500m','other',1,NULL,NULL,0,'2026-05-07 05:00:15','?','#4CAF50','daily',1,0,0,NULL),(19,6,'Chạy 500m','exercise',1,NULL,NULL,1,'2026-05-07 05:00:43','?','#4CAF50','daily',1,1,1,'2026-05-21'),(20,6,'Ăn 500 calories','eat',1,NULL,NULL,1,'2026-05-07 05:09:33','?','#4CAF50','daily',1,1,1,'2026-05-21'),(21,12,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-05-12 04:50:35','?','#4CAF50','daily',1,2,2,'2026-05-13'),(22,12,'Ăn healthy','eat',1,NULL,NULL,1,'2026-05-12 05:01:36','?','#4CAF50','daily',1,2,2,'2026-05-13'),(23,12,'Uống nước','hydration',1,NULL,NULL,1,'2026-05-13 05:40:31','?','#4CAF50','daily',1,1,1,'2026-05-13'),(24,12,'Ngủ trưa','sleep',1,NULL,NULL,1,'2026-05-13 05:41:45','?','#4CAF50','daily',1,1,1,'2026-05-13'),(25,18,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-05-14 07:10:27','?','#4CAF50','daily',1,1,1,'2026-05-14'),(26,6,'Ăn','eat',1,NULL,NULL,1,'2026-05-21 07:55:58','?','#4CAF50','daily',1,0,0,NULL),(30,21,'Demo','exercise',1,NULL,NULL,1,'2026-05-25 05:33:02','?','#4CAF50','daily',1,1,1,'2026-05-25'),(31,21,'mammam','eat',1,NULL,NULL,1,'2026-05-25 05:39:44','?','#4CAF50','daily',1,0,0,NULL),(36,24,'Uống đủ 2 lít nước','hydration',1,NULL,NULL,1,'2026-05-25 05:58:30','?','#4CAF50','daily',1,1,1,'2026-05-25');
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plants`
--

LOCK TABLES `plants` WRITE;
/*!40000 ALTER TABLE `plants` DISABLE KEYS */;
INSERT INTO `plants` VALUES (2,7,'sprout',2,14,'2026-05-13',0,100,'basic',NULL),(3,6,'cactus',5,65,'2026-05-21',0,100,'basic',NULL),(4,12,'sunflower',1,6,'2026-05-13',0,100,'basic',NULL),(5,17,'sunflower',1,0,NULL,0,100,'basic',NULL),(6,18,'sprout',1,3,'2026-05-14',0,100,'basic',NULL),(9,21,'sprout',1,3,'2026-05-25',0,100,'basic',NULL),(12,24,'flower',1,3,'2026-05-25',0,100,'basic',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streaks`
--

LOCK TABLES `streaks` WRITE;
/*!40000 ALTER TABLE `streaks` DISABLE KEYS */;
INSERT INTO `streaks` VALUES (1,7,1,1,'2026-05-13'),(2,12,3,3,'2026-05-13'),(3,6,1,3,'2026-05-21'),(4,15,1,1,'2026-04-28'),(5,18,1,1,'2026-05-14'),(7,21,1,1,'2026-05-25'),(8,24,1,1,'2026-05-25');
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
/*!40000 ALTER TABLE `user_follows` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Test User','test@gmail.com','123456',NULL,'user',1,1,'2026-04-17 03:59:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(2,'Trinh','trinh@gmail.com','123456',NULL,'user',1,1,'2026-04-17 05:14:38',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(4,'testpostman','testpostman@gmail.com','$2b$10$SMgcdMWOHOs7AuWfTR5/0ucJVkRD6LrfdnItDvscdQGjhmL18I94O',NULL,'user',1,1,'2026-04-17 05:24:07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(5,'testlogin','testlogin@gmail.com','$2b$10$804Utew7BvJ8nhmAUVUnGufoFQF9kVa3mSdbh1F./7Ut915xtDqpu',NULL,'user',1,1,'2026-04-17 05:52:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(6,'Huệ Trinh','trinhfokko@gmail.com','$2b$10$vZBWx/jBkOpFB5A.7txl5.hvARrMKLpx8gAnNPamtOloO.blxuHq.',NULL,'user',1,1,'2026-04-20 07:46:15','female',2004,157.00,47.00,'[\"sleep\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,14,52,1,18,17),(7,'Meo Meo','meomeodthvch@gmail.com','',NULL,'user',1,1,'2026-04-20 08:01:11','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(8,'testdk','testdk@gmail.com','$2b$10$UW5OHcJ9F91hfl2p9jdGcuHr.G2MIbjDs3DiodSNp2wdhClIOU.gy',NULL,'user',1,1,'2026-04-20 08:22:25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(9,'test','test@gmail.','$2b$10$2v/e7uLLkmA1UvdO3.lLsebWJfyRgD5h2595PDHk3WF.w61Q88m8.',NULL,'user',1,1,'2026-04-20 08:39:51',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(10,'test','testne@gmail.com','$2b$10$zwvNW8lz9CEyAPSyOCSoyuepXBffHStfkFlTFr1KyAoENh3r/Ak4a',NULL,'user',1,1,'2026-04-20 08:45:10','other',2019,157.00,56.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0),(11,'demo','demo@gmail.com','$2b$10$WthRKl06zz4OMoT1UAKqIeL9wLcE1luJ3UHTZovLQ0k7Kh2GNftzO',NULL,'user',1,1,'2026-04-20 08:59:20','female',2004,157.00,47.00,'[\"hydration\", \"other:Tang can\"]',NULL,NULL,NULL,1,8,0,1,21,0),(12,'Meo Meo','trinhmeo2k4@gmail.com','',NULL,'user',1,1,'2026-04-21 05:27:27','female',2006,157.00,47.00,'[\"weight\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,11,40,1,18,17),(13,'Phone','phone@gmail.com','$2b$10$anU//d12p32CaVPkikrubOTRjckUscudfTw5dvBfn6E4wgj3lP9t2',NULL,'user',1,1,'2026-04-21 05:32:19','other',1979,157.00,45.00,'[\"other:tăng cân\"]',NULL,NULL,NULL,1,8,0,1,21,0),(14,'Meo','meo@gmail.com','$2b$10$s8m4WuG2Fcj017cAU9sWKu0p4IyaTi.hzGn6QTYM7Iq6B/JunByAC',NULL,'user',1,1,'2026-04-26 05:08:21','female',2011,157.00,45.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0),(15,'trinh','trinhh@gmail.com','$2b$10$hnvs3cOULFUQFzCTrIdl2ebu6oYYt3ItwZaCJF2XhwDUt/keABT2S',NULL,'user',1,1,'2026-04-28 04:34:13','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL,NULL,1,8,0,1,21,0),(16,'demo','demoo@gmail.com','$2b$10$1LMMrYNlAd5Kfdp87JtRFOvk6IUB6mF81Wuzi52FLMyt2pZPkrJBS',NULL,'user',1,1,'2026-04-28 04:37:16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,8,0,1,21,0),(17,'Chuột','chuot@gmail.com','$2b$10$Vpp4lIBQskV.ISLzkfGt3.N3qpMiQ7C1425MsCXDyzAij251Bqsn6',NULL,'user',1,1,'2026-04-30 11:39:57','female',2001,170.00,65.00,'[\"eat_healthy\"]',NULL,NULL,NULL,1,8,0,1,21,0),(18,'xixinh','xinh@gmail.com','$2b$10$XFx7y99YwGlgRpzwOaiNOeweTktgf8BzaLoNXhw10FUmfaw.K0GMe',NULL,'user',1,1,'2026-05-14 07:00:42','female',2001,157.00,47.00,'[\"eat_healthy\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(21,'tree','tree@gmail.com','$2b$10$39j8e8zmYMkx0HHAKTKlCe7a/Y8SJCdZDwa2Ik34V8xIIuP3LgZcG',NULL,'user',1,1,'2026-05-25 05:01:48','female',2006,157.00,47.00,'[\"exercise\"]',NULL,NULL,'fOzWNGLUSGeb3U47j3iTlh:APA91bFvrUbXxADhfz2oGHJMqOeFYbKdmDe44uepgEC68DeHQ8uhq2CaWnhA5TP22BS26HXiMEMq8JhePccj2XcDG-9V7iFxuaF6JBzEx9PNc7ticjSuUkQ',1,8,0,1,21,0),(24,'Huệ Trinh','thachthihuetrinh2004@gmail.com','',NULL,'user',1,1,'2026-05-25 05:55:13','female',2001,157.00,45.00,'[\"hydration\"]',NULL,NULL,NULL,1,8,0,1,21,0);
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

-- Dump completed on 2026-05-25 13:03:27
