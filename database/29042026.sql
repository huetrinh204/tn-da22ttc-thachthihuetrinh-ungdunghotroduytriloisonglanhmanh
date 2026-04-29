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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,6,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:17:12','2026-04-28 06:17:12'),(2,7,'first_checkin','Bước đầu tiên','Hoàn thành check-in đầu tiên','?','2026-04-28 06:29:14','2026-04-28 06:29:14');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `habit_id` (`habit_id`,`log_date`),
  UNIQUE KEY `unique_log` (`habit_id`,`log_date`),
  KEY `idx_logs_habit` (`habit_id`),
  CONSTRAINT `habit_logs_ibfk_1` FOREIGN KEY (`habit_id`) REFERENCES `habits` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habit_logs`
--

LOCK TABLES `habit_logs` WRITE;
/*!40000 ALTER TABLE `habit_logs` DISABLE KEYS */;
INSERT INTO `habit_logs` VALUES (6,2,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL),(7,1,7,'2026-04-20',0,0,'2026-04-20 09:28:57',NULL),(8,3,7,'2026-04-20',0,0,'2026-04-20 09:29:15',NULL),(15,4,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL),(16,5,12,'2026-04-21',0,0,'2026-04-21 05:31:50',NULL),(18,7,12,'2026-04-21',0,0,'2026-04-21 05:31:52',NULL),(19,6,12,'2026-04-21',0,0,'2026-04-21 05:31:53',NULL),(20,8,12,'2026-04-21',0,0,'2026-04-21 05:39:24',NULL),(21,9,6,'2026-04-25',0,0,'2026-04-25 06:29:43',NULL),(23,10,15,'2026-04-28',0,0,'2026-04-28 04:35:18',NULL),(24,11,15,'2026-04-28',0,0,'2026-04-28 04:36:20',NULL),(37,9,6,'2026-04-28',0,0,'2026-04-28 06:20:39',NULL),(38,12,6,'2026-04-28',0,0,'2026-04-28 06:20:40',NULL),(39,13,6,'2026-04-28',0,0,'2026-04-28 06:20:41',NULL),(40,3,7,'2026-04-28',0,0,'2026-04-28 06:29:14',NULL),(41,2,7,'2026-04-28',0,0,'2026-04-28 06:29:19',NULL),(42,1,7,'2026-04-28',0,0,'2026-04-28 06:30:01',NULL),(43,13,6,'2026-04-29',0,0,'2026-04-29 09:27:32',NULL),(44,12,6,'2026-04-29',0,0,'2026-04-29 09:28:25',NULL),(45,9,6,'2026-04-29',0,0,'2026-04-29 09:28:49',NULL);
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
  PRIMARY KEY (`id`),
  KEY `idx_habits_user` (`user_id`),
  CONSTRAINT `habits_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `habits`
--

LOCK TABLES `habits` WRITE;
/*!40000 ALTER TABLE `habits` DISABLE KEYS */;
INSERT INTO `habits` VALUES (1,7,'aa','other',1,NULL,NULL,1,'2026-04-20 09:24:10','⭐','#4CAF50','daily',1),(2,7,'b','eat',1,NULL,NULL,1,'2026-04-20 09:24:33','?','#4CAF50','daily',1),(3,7,'c','other',1,NULL,NULL,1,'2026-04-20 09:29:10','?','#4CAF50','daily',1),(4,12,'testphone','other',1,NULL,NULL,1,'2026-04-21 05:27:55','⭐','#4CAF50','daily',1),(5,12,'test','other',1,NULL,NULL,1,'2026-04-21 05:28:09','?','#4CAF50','daily',1),(6,12,'test','other',1,NULL,NULL,1,'2026-04-21 05:31:39','⭐','#4CAF50','daily',1),(7,12,'ok','other',1,NULL,NULL,1,'2026-04-21 05:31:45','⭐','#4CAF50','daily',1),(8,12,'test','other',1,NULL,NULL,1,'2026-04-21 05:37:23','⭐','#4CAF50','daily',1),(9,6,'demo','other',1,NULL,NULL,1,'2026-04-25 06:29:41','⭐','#4CAF50','daily',1),(10,15,'Chạy bộ','exercise',1,NULL,NULL,1,'2026-04-28 04:35:16','?','#4CAF50','daily',1),(11,15,'Uống 2l nước','hydration',1,NULL,NULL,1,'2026-04-28 04:36:16','?','#4CAF50','daily',1),(12,6,'test','other',1,NULL,NULL,1,'2026-04-28 05:44:12','⭐','#4CAF50','daily',1),(13,6,'an','eat',1,NULL,NULL,0,'2026-04-28 06:12:43','⭐','#4CAF50','daily',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plants`
--

LOCK TABLES `plants` WRITE;
/*!40000 ALTER TABLE `plants` DISABLE KEYS */;
INSERT INTO `plants` VALUES (2,7,'sprout',1,6,'2026-04-28',0,100,'basic',NULL),(3,6,'cactus',1,7,'2026-04-29',0,100,'basic',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `streaks`
--

LOCK TABLES `streaks` WRITE;
/*!40000 ALTER TABLE `streaks` DISABLE KEYS */;
INSERT INTO `streaks` VALUES (1,7,1,1,'2026-04-28'),(2,12,1,1,'2026-04-21'),(3,6,2,2,'2026-04-29'),(4,15,1,1,'2026-04-28');
/*!40000 ALTER TABLE `streaks` ENABLE KEYS */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Test User','test@gmail.com','123456',NULL,'user',1,1,'2026-04-17 03:59:58',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'Trinh','trinh@gmail.com','123456',NULL,'user',1,1,'2026-04-17 05:14:38',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'testpostman','testpostman@gmail.com','$2b$10$SMgcdMWOHOs7AuWfTR5/0ucJVkRD6LrfdnItDvscdQGjhmL18I94O',NULL,'user',1,1,'2026-04-17 05:24:07',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,'testlogin','testlogin@gmail.com','$2b$10$804Utew7BvJ8nhmAUVUnGufoFQF9kVa3mSdbh1F./7Ut915xtDqpu',NULL,'user',1,1,'2026-04-17 05:52:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,'Huệ Trinh','trinhfokko@gmail.com','',NULL,'user',1,1,'2026-04-20 07:46:15','female',2004,157.00,47.00,'[\"sleep\"]',NULL,NULL),(7,'Meo Meo','meomeodthvch@gmail.com','',NULL,'user',1,1,'2026-04-20 08:01:11','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL),(8,'testdk','testdk@gmail.com','$2b$10$UW5OHcJ9F91hfl2p9jdGcuHr.G2MIbjDs3DiodSNp2wdhClIOU.gy',NULL,'user',1,1,'2026-04-20 08:22:25',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,'test','test@gmail.','$2b$10$2v/e7uLLkmA1UvdO3.lLsebWJfyRgD5h2595PDHk3WF.w61Q88m8.',NULL,'user',1,1,'2026-04-20 08:39:51',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(10,'test','testne@gmail.com','$2b$10$zwvNW8lz9CEyAPSyOCSoyuepXBffHStfkFlTFr1KyAoENh3r/Ak4a',NULL,'user',1,1,'2026-04-20 08:45:10','other',2019,157.00,56.00,'[\"eat_healthy\"]',NULL,NULL),(11,'demo','demo@gmail.com','$2b$10$WthRKl06zz4OMoT1UAKqIeL9wLcE1luJ3UHTZovLQ0k7Kh2GNftzO',NULL,'user',1,1,'2026-04-20 08:59:20','female',2004,157.00,47.00,'[\"hydration\", \"other:Tang can\"]',NULL,NULL),(12,'Meo Meo','trinhmeo2k4@gmail.com','',NULL,'user',1,1,'2026-04-21 05:27:27',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(13,'Phone','phone@gmail.com','$2b$10$anU//d12p32CaVPkikrubOTRjckUscudfTw5dvBfn6E4wgj3lP9t2',NULL,'user',1,1,'2026-04-21 05:32:19','other',1979,157.00,45.00,'[\"other:tăng cân\"]',NULL,NULL),(14,'Meo','meo@gmail.com','$2b$10$s8m4WuG2Fcj017cAU9sWKu0p4IyaTi.hzGn6QTYM7Iq6B/JunByAC',NULL,'user',1,1,'2026-04-26 05:08:21','female',2011,157.00,45.00,'[\"eat_healthy\"]',NULL,NULL),(15,'trinh','trinhh@gmail.com','$2b$10$hnvs3cOULFUQFzCTrIdl2ebu6oYYt3ItwZaCJF2XhwDUt/keABT2S',NULL,'user',1,1,'2026-04-28 04:34:13','female',2006,157.00,47.00,'[\"eat_healthy\", \"weight\"]',NULL,NULL),(16,'demo','demoo@gmail.com','$2b$10$1LMMrYNlAd5Kfdp87JtRFOvk6IUB6mF81Wuzi52FLMyt2pZPkrJBS',NULL,'user',1,1,'2026-04-28 04:37:16',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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

-- Dump completed on 2026-04-29 18:03:18
