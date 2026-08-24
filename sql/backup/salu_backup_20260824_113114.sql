-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: salu
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `salu`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `salu` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `salu`;

--
-- Table structure for table `advertisements`
--

DROP TABLE IF EXISTS `advertisements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `advertisements` (
  `advertisement_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_url` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_order` int NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`advertisement_id`),
  KEY `idx_advertisements_exposure` (`active`,`start_at`,`end_at`,`display_order`),
  CONSTRAINT `chk_advertisements_period` CHECK (((`end_at` is null) or (`start_at` is null) or (`end_at` >= `start_at`)))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advertisements`
--

LOCK TABLES `advertisements` WRITE;
/*!40000 ALTER TABLE `advertisements` DISABLE KEYS */;
INSERT INTO `advertisements` VALUES (1,'하이','가보자가보자','/upload/b07a194b-9d93-4b51-9dd0-2663a90d72b6.png','https://www.naver.com',1,1,'2026-07-28 23:04:00','2026-08-01 23:04:00','2026-07-29 23:04:25','2026-07-29 23:04:25');
/*!40000 ALTER TABLE `advertisements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `user1_id` int NOT NULL,
  `user2_id` int NOT NULL,
  `salon_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_id`),
  UNIQUE KEY `uq_chats_customer_salon` (`user1_id`,`salon_id`),
  KEY `user2_id` (`user2_id`),
  KEY `fk_chats_salon` (`salon_id`),
  CONSTRAINT `chats_ibfk_1` FOREIGN KEY (`user1_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `chats_ibfk_2` FOREIGN KEY (`user2_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_chats_salon` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES (1,1,8,1,'2026-07-31 15:33:16','2026-08-21 10:50:35'),(2,2,8,1,'2026-07-31 15:36:18','2026-07-31 15:39:50'),(3,1,9,10,'2026-07-31 15:55:15','2026-07-31 15:55:15'),(4,1,9,3,'2026-08-03 14:57:37','2026-08-03 14:57:37');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment_reports`
--

DROP TABLE IF EXISTS `comment_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment_reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `comment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reason` enum('spam','illegal','abuse','privacy','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `reason_detail` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `uk_comment_user` (`comment_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `comment_reports_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `comment_reports_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_reports`
--

LOCK TABLES `comment_reports` WRITE;
/*!40000 ALTER TABLE `comment_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `comment_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `coupon_id` int NOT NULL AUTO_INCREMENT,
  `promotion_id` int DEFAULT NULL,
  `salon_id` int DEFAULT NULL,
  `service_id` int DEFAULT NULL,
  `coupon_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `coupon_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_type` enum('percent','amount') COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `max_discount` decimal(10,2) DEFAULT NULL,
  `min_order_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `issue_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `once_per_user` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`coupon_id`),
  UNIQUE KEY `coupon_code` (`coupon_code`),
  KEY `promotion_id` (`promotion_id`),
  KEY `salon_id` (`salon_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `coupons_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`),
  CONSTRAINT `coupons_ibfk_2` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`),
  CONSTRAINT `coupons_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES (1,NULL,NULL,NULL,'신규 가입 감사 쿠폰',NULL,'percent',10.00,5000.00,20000.00,'2026-08-10','2027-08-10','signup',1,0,'2026-08-10 15:31:17','2026-08-10 23:15:50'),(2,NULL,NULL,NULL,'3,000원 할인 쿠폰',NULL,'amount',3000.00,NULL,10000.00,'2026-08-10','2026-11-10','admin',0,0,'2026-08-10 15:31:17','2026-08-18 15:22:52'),(3,NULL,NULL,NULL,'신규 가입 감사 쿠폰','TEST-WELCOME','percent',10.00,5000.00,20000.00,'2026-08-10','2027-08-10','signup',1,1,'2026-08-10 18:15:47','2026-08-10 18:15:47'),(4,NULL,NULL,NULL,'3,000원 할인 쿠폰','TEST-3000','amount',3000.00,NULL,10000.00,'2026-08-10','2026-11-10','admin',0,1,'2026-08-10 18:15:47','2026-08-10 18:15:47'),(9,NULL,NULL,NULL,'정률테스트','WELCOME%%','percent',10.00,5000.00,20000.00,'2026-08-11','2027-08-11','admin',1,1,'2026-08-11 10:21:27','2026-08-11 10:21:27');
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `chat_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `message_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `sent_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `chat_id` (`chat_id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`chat_id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,1,'야이자식아',1,'2026-07-31 15:33:23'),(2,1,8,'어쩌라고',1,'2026-07-31 15:34:00'),(3,1,1,'손님한테 그게 맞아?',1,'2026-07-31 15:34:39'),(4,1,1,'?',1,'2026-07-31 15:35:11'),(5,1,8,'되냐',1,'2026-07-31 15:35:41'),(6,1,8,'나이짜',1,'2026-07-31 15:35:50'),(7,2,2,'손님받아라',1,'2026-07-31 15:36:24'),(8,2,2,'읽씹하네',1,'2026-07-31 15:36:45'),(9,2,2,'11',1,'2026-07-31 15:38:21'),(10,2,2,'문자는 안뜨네',1,'2026-07-31 15:38:52'),(11,2,8,'거짓말',0,'2026-07-31 15:39:10'),(12,2,8,'가능한',0,'2026-07-31 15:39:31'),(13,2,2,'여기는 알람이 안뜨네',1,'2026-07-31 15:39:40'),(14,2,2,'그치?',1,'2026-07-31 15:39:43'),(15,2,2,'방금떴는데',1,'2026-07-31 15:39:47'),(16,2,2,'에휴',1,'2026-07-31 15:39:50'),(17,1,1,'sdsd',1,'2026-07-31 15:55:22'),(18,1,1,'간편결제 -> 즉시결제',1,'2026-07-31 15:58:34'),(19,1,1,'현장결제 -> 점주->고객 결제요청',1,'2026-07-31 15:58:48'),(20,1,1,'예약금을 먼저 받는걸 넣을지',1,'2026-07-31 15:59:10'),(21,1,1,'dsdsd',1,'2026-07-31 17:00:37'),(22,1,8,'dididi',1,'2026-07-31 17:00:46'),(23,1,8,'dkdl',1,'2026-07-31 17:00:51'),(24,1,8,'봐라',1,'2026-07-31 17:00:54'),(25,1,1,'안되잖아?',1,'2026-07-31 17:01:15'),(26,1,1,'안인',1,'2026-07-31 17:01:24'),(27,1,1,'아니아니',1,'2026-07-31 17:01:25'),(28,1,1,'sds',1,'2026-07-31 17:09:05'),(29,1,1,'dl',1,'2026-07-31 17:09:09'),(30,1,1,'didi',1,'2026-07-31 17:09:10'),(31,1,1,'아니근데',1,'2026-07-31 17:09:17'),(32,1,1,'왜안되냐',1,'2026-07-31 17:09:19'),(33,1,1,'ㅇㄴ이',1,'2026-07-31 17:09:20'),(34,1,1,'야이',1,'2026-07-31 17:09:29'),(35,1,1,'gd',1,'2026-07-31 17:38:36'),(36,1,8,'didi',1,'2026-07-31 17:46:28'),(37,1,8,'오 된다',1,'2026-07-31 17:46:36'),(38,1,1,'di',1,'2026-07-31 17:53:36'),(39,1,1,'야',1,'2026-07-31 17:53:38'),(40,1,8,'넹 고갱님',1,'2026-07-31 17:53:46'),(41,1,1,'야야',1,'2026-07-31 18:10:27'),(42,1,8,'네네',1,'2026-07-31 18:10:33'),(43,1,1,'11',1,'2026-07-31 18:32:55'),(44,1,8,'ss',1,'2026-07-31 18:32:58'),(45,1,8,'where',1,'2026-08-19 15:04:59'),(46,1,8,'ㅑㅓㅐㅏㅐ',1,'2026-08-21 10:50:35');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `type` enum('RESERVATION','COUPON','CHAT','NOTICE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ref_id` int DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_user_unread` (`user_id`,`is_read`,`created_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,'CHAT','새 메시지가 도착했어요','이원장: ㅑㅓㅐㅏㅐ','/common/chat?chatId=1',1,1,'2026-08-21 10:50:35');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ownerrequests`
--

DROP TABLE IF EXISTS `ownerrequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ownerrequests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `salon_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `salon_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `request_type` enum('promotion','additional_salon') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'promotion',
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `requested_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `user_id` (`user_id`),
  KEY `processed_by` (`processed_by`),
  CONSTRAINT `ownerrequests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `ownerrequests_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ownerrequests`
--

LOCK TABLES `ownerrequests` WRITE;
/*!40000 ALTER TABLE `ownerrequests` DISABLE KEYS */;
INSERT INTO `ownerrequests` VALUES (1,11,'ssss','','','promotion','pending','2026-07-31 16:11:39',NULL,NULL),(2,2,'해줘','','','promotion','approved','2026-07-31 16:13:25','2026-07-31 16:13:57',11),(3,1,'','','','promotion','rejected','2026-07-31 18:33:11','2026-07-31 18:33:39',11),(4,8,'','','','additional_salon','rejected','2026-08-18 13:01:27','2026-08-18 13:05:29',11),(5,3,'','','','promotion','approved','2026-08-18 14:28:23','2026-08-18 14:28:53',11),(6,8,'','','','promotion','pending','2026-08-18 14:59:43',NULL,NULL),(7,8,'솔데스크','010','ㅏㄴㅇ','additional_salon','pending','2026-08-18 15:06:24',NULL,NULL),(8,8,'','','','additional_salon','pending','2026-08-18 15:06:27',NULL,NULL),(9,18,'홍길동헤어','01-1111-2222','ㅏ이','promotion','approved','2026-08-19 15:08:43','2026-08-19 15:09:17',11),(10,19,'홍길동2매장','01-1111-1222','','promotion','approved','2026-08-20 12:44:32','2026-08-20 12:45:04',11);
/*!40000 ALTER TABLE `ownerrequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `reservation_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` enum('pending','completed','failed','refunded') COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `original_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `coupon_discount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `point_used` int NOT NULL DEFAULT '0',
  `pg_provider` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'KAKAOPAY',
  `user_coupon_id` int DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `reservation_id` (`reservation_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_payments_user_coupon` (`user_coupon_id`),
  CONSTRAINT `fk_payments_user_coupon` FOREIGN KEY (`user_coupon_id`) REFERENCES `user_coupons` (`user_coupon_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,1,25000.00,'신용카드','completed','TXN-0001','2026-07-22 17:35:27',25000.00,0.00,0,'KAKAOPAY',NULL),(2,2,2,18000.00,'간편결제','completed','TXN-0002','2026-07-22 17:35:27',18000.00,0.00,0,'KAKAOPAY',NULL),(3,3,3,120000.00,'신용카드','failed','TXN-0003','2026-07-22 17:35:27',120000.00,0.00,0,'KAKAOPAY',NULL),(4,4,4,90000.00,'신용카드','completed','TXN-0004','2026-07-22 17:35:27',90000.00,0.00,0,'KAKAOPAY',NULL),(5,5,5,22000.00,'간편결제','completed','TXN-0005','2026-07-22 17:35:27',22000.00,0.00,0,'KAKAOPAY',NULL),(6,6,6,70000.00,'신용카드','refunded','TXN-0006','2026-07-22 17:35:27',70000.00,0.00,0,'KAKAOPAY',NULL),(7,8,1,150000.00,'간편결제','completed','TXN-0008','2026-07-22 17:35:27',150000.00,0.00,0,'KAKAOPAY',NULL),(8,9,2,23000.00,'신용카드','completed','TXN-0009','2026-07-22 17:35:27',23000.00,0.00,0,'KAKAOPAY',NULL),(9,10,3,110000.00,'간편결제','completed','TXN-0010','2026-07-22 17:35:27',110000.00,0.00,0,'KAKAOPAY',NULL),(10,12,5,24000.00,'신용카드','refunded','TXN-0012','2026-07-22 17:35:27',24000.00,0.00,0,'KAKAOPAY',NULL),(11,13,1,18000.00,'MONEY','completed','Ta705bd061000ca9e4ab','2026-08-03 18:14:28',18000.00,0.00,0,'KAKAOPAY',NULL),(12,14,1,24000.00,'MONEY','completed','Ta71761a61000ca9e671','2026-08-04 14:18:41',24000.00,0.00,0,'KAKAOPAY',NULL),(13,16,1,24000.00,NULL,'failed','Ta71b9f961000ca9e76a','2026-08-04 19:07:52',24000.00,0.00,0,'KAKAOPAY',NULL),(14,17,1,24000.00,NULL,'failed','Ta71bac326bf7fb4c03f','2026-08-04 19:11:15',24000.00,0.00,0,'KAKAOPAY',NULL),(15,18,1,24000.00,'MONEY','completed','Ta71bb5361000ca9e76b','2026-08-04 19:13:53',24000.00,0.00,0,'KAKAOPAY',NULL),(16,19,1,24000.00,'MONEY','completed','Ta72933457126faabff4','2026-08-05 10:34:57',24000.00,0.00,0,'KAKAOPAY',NULL),(17,20,1,24000.00,NULL,'failed','Ta72c25561730144818e','2026-08-05 13:55:48',24000.00,0.00,0,'KAKAOPAY',NULL),(18,21,3,24000.00,NULL,'failed','Ta72c333617301448190','2026-08-05 13:59:30',24000.00,0.00,0,'KAKAOPAY',NULL),(19,22,1,24000.00,NULL,'failed','Ta72d36557126faac0a5','2026-08-05 15:08:36',24000.00,0.00,0,'KAKAOPAY',NULL),(20,23,1,24000.00,'MONEY','completed','Ta72d39761000ca9e93e','2026-08-05 15:09:46',24000.00,0.00,0,'KAKAOPAY',NULL),(21,24,1,24000.00,NULL,'failed','Ta72d3f526bf7fb4c24c','2026-08-05 15:11:00',24000.00,0.00,0,'KAKAOPAY',NULL),(22,25,1,24000.00,NULL,'failed','Ta72da846173014481f7','2026-08-05 15:38:59',24000.00,0.00,0,'KAKAOPAY',NULL),(23,26,1,24000.00,NULL,'failed','Ta72dfad57126faac0e6','2026-08-05 16:01:00',24000.00,0.00,0,'KAKAOPAY',NULL),(24,27,1,24000.00,NULL,'failed','Ta72dfc657126faac0e7','2026-08-05 16:01:25',24000.00,0.00,0,'KAKAOPAY',NULL),(25,28,1,24000.00,NULL,'failed','Ta72dfd861000ca9e986','2026-08-05 16:01:43',24000.00,0.00,0,'KAKAOPAY',NULL),(26,29,1,24000.00,NULL,'failed','Ta72e0f826bf7fb4c291','2026-08-05 16:06:31',24000.00,0.00,0,'KAKAOPAY',NULL),(27,30,1,150000.00,NULL,'failed','Ta72e29126bf7fb4c295','2026-08-05 16:13:20',150000.00,0.00,0,'KAKAOPAY',NULL),(28,31,1,24000.00,NULL,'failed','Ta72e8f726bf7fb4c2a9','2026-08-05 16:40:38',24000.00,0.00,0,'KAKAOPAY',NULL),(29,32,1,14000.00,'MONEY','completed','Ta72f88257126faac12b','2026-08-05 17:47:15',24000.00,0.00,10000,'KAKAOPAY',NULL),(30,33,1,14000.00,'MONEY','completed','Ta72fa32617301448272','2026-08-05 17:54:30',24000.00,0.00,10000,'KAKAOPAY',NULL),(31,34,1,14000.00,NULL,'failed','Ta72fad261000ca9e9c6','2026-08-05 17:56:49',24000.00,0.00,10000,'KAKAOPAY',NULL),(32,35,1,24000.00,NULL,'failed','Ta72fb4261000ca9e9c7','2026-08-05 17:58:41',24000.00,0.00,0,'KAKAOPAY',NULL),(33,36,1,80000.00,NULL,'failed','Ta730b06617301448296','2026-08-05 19:05:57',90000.00,0.00,10000,'KAKAOPAY',NULL),(34,37,1,9000.00,NULL,'failed','Ta759d3d26bf7fb4c7ce','2026-08-07 17:54:18',18000.00,0.00,9000,'KAKAOPAY',NULL),(35,38,1,12000.00,'MONEY','refunded','Ta79904326bf7fb4cba1','2026-08-10 17:48:23',25000.00,3000.00,10000,'KAKAOPAY',2),(36,39,1,22500.00,'MONEY','completed','Ta79d87726bf7fb4cc11','2026-08-10 22:56:24',50000.00,5000.00,22500,'KAKAOPAY',1),(37,40,17,22500.00,NULL,'failed','Ta7a73e326bf7fb4ccb3','2026-08-11 09:59:13',25000.00,2500.00,0,'KAKAOPAY',9),(38,41,17,22500.00,'MONEY','completed','Ta7a740a617301448bf5','2026-08-11 10:00:07',25000.00,2500.00,0,'KAKAOPAY',9),(39,42,1,7500.00,'MONEY','completed','Ta7a819b61000ca9f338','2026-08-11 10:58:00',18000.00,3000.00,7500,'KAKAOPAY',4),(41,45,1,18000.00,'MONEY','refunded','Ta84257966d6535a502f','2026-08-18 18:27:38',18000.00,0.00,0,'KAKAOPAY',NULL),(42,46,1,28800.00,'MONEY','refunded','Ta87a032060a22ed48f9','2026-08-21 09:48:02',32000.00,3200.00,0,'KAKAOPAY',5);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_transactions`
--

DROP TABLE IF EXISTS `point_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_transactions` (
  `point_tx_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `reservation_id` int DEFAULT NULL,
  `tx_type` enum('earn','use','restore','revoke','expire','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` int NOT NULL,
  `balance_after` int NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`point_tx_id`),
  UNIQUE KEY `uq_reservation_tx` (`reservation_id`,`tx_type`),
  KEY `idx_user_created` (`user_id`,`created_at`),
  CONSTRAINT `point_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `point_transactions_ibfk_2` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_transactions`
--

LOCK TABLES `point_transactions` WRITE;
/*!40000 ALTER TABLE `point_transactions` DISABLE KEYS */;
INSERT INTO `point_transactions` VALUES (1,1,32,'use',-10000,0,'예약 결제 사용',NULL,'2026-08-05 17:46:57'),(2,1,33,'use',-10000,0,'예약 결제 사용',NULL,'2026-08-05 17:54:10'),(3,1,34,'use',-10000,0,'예약 결제 사용',NULL,'2026-08-05 17:56:49'),(4,1,34,'restore',10000,10000,'결제 취소 환급',NULL,'2026-08-05 17:56:56'),(5,1,36,'use',-10000,0,'예약 결제 사용',NULL,'2026-08-05 19:05:57'),(6,1,36,'restore',10000,10000,'결제 취소 환급',NULL,'2026-08-05 19:06:11'),(7,1,37,'use',-9000,1000,'예약 결제 사용',NULL,'2026-08-07 17:54:18'),(8,1,37,'restore',9000,10000,'결제 취소 환급',NULL,'2026-08-07 17:54:23'),(9,1,38,'use',-10000,0,'예약 결제 사용',NULL,'2026-08-10 17:48:03'),(10,1,39,'use',-22500,27500,'예약 결제 사용',NULL,'2026-08-10 22:56:06'),(11,1,42,'use',-7500,20000,'예약 결제 사용',NULL,'2026-08-11 10:57:46'),(12,1,13,'earn',1000,21000,'리뷰 작성 적립',NULL,'2026-08-11 11:51:38'),(13,1,43,'use',-9000,12000,'예약 결제 사용',NULL,'2026-08-18 17:46:23'),(14,1,43,'restore',9000,21000,'결제 취소 환급',NULL,'2026-08-18 18:11:07');
/*!40000 ALTER TABLE `point_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_likes`
--

DROP TABLE IF EXISTS `post_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_likes` (
  `like_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reaction_type` enum('like','dislike') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `uk_post_user` (`post_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`),
  CONSTRAINT `post_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_likes`
--

LOCK TABLES `post_likes` WRITE;
/*!40000 ALTER TABLE `post_likes` DISABLE KEYS */;
INSERT INTO `post_likes` VALUES (2,1,1,'like','2026-07-29 15:13:05'),(3,4,1,'dislike','2026-08-18 14:42:02');
/*!40000 ALTER TABLE `post_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_reports`
--

DROP TABLE IF EXISTS `post_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `reason` enum('spam','illegal','abuse','privacy','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `reason_detail` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `uk_post_user` (`post_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_reports_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_reports_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_reports`
--

LOCK TABLES `post_reports` WRITE;
/*!40000 ALTER TABLE `post_reports` DISABLE KEYS */;
INSERT INTO `post_reports` VALUES (1,3,14,'2026-08-02 21:02:41','other','kkll;');
/*!40000 ALTER TABLE `post_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salon_id` int DEFAULT NULL,
  `view_count` int DEFAULT '0',
  `like_count` int DEFAULT '0',
  `dislike_count` int DEFAULT '0',
  `report_count` int DEFAULT '0',
  `status` enum('visible','blinded','deleted') COLLATE utf8mb4_unicode_ci DEFAULT 'visible',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_posts_salon` (`salon_id`),
  CONSTRAINT `fk_posts_salon` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` VALUES (1,1,'e','dldddd','헤어스타일',NULL,10,19,1,0,0,'visible','2026-07-27 23:59:00','2026-08-04 15:01:24'),(3,1,'신고하봬','산고해봐','헤어스타일',NULL,10,7,0,0,1,'visible','2026-08-02 21:02:16','2026-08-18 14:42:15'),(4,1,'df','dsd','시술후기','7453a4c5-3279-46aa-bc94-ea50ce1cf4f9.png',3,8,0,1,0,'visible','2026-08-18 14:39:52','2026-08-20 15:36:51');
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotions` (
  `promotion_id` int NOT NULL AUTO_INCREMENT,
  `salon_id` int DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `discount_rate` decimal(5,2) DEFAULT NULL,
  `coupon_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`promotion_id`),
  UNIQUE KEY `coupon_code` (`coupon_code`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `promotions_ibfk_1` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `salon_id` int NOT NULL,
  `stylist_id` int DEFAULT NULL,
  `service_id` int NOT NULL,
  `reservation_time` datetime NOT NULL,
  `status` enum('pending','confirmed','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reject_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cancel_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `salon_id` (`salon_id`),
  KEY `stylist_id` (`stylist_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`),
  CONSTRAINT `reservations_ibfk_3` FOREIGN KEY (`stylist_id`) REFERENCES `stylists` (`stylist_id`),
  CONSTRAINT `reservations_ibfk_4` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES (1,1,1,1,1,'2026-07-25 14:00:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(2,2,1,2,2,'2026-07-20 11:00:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(3,3,2,3,3,'2026-07-23 15:00:00','cancelled',NULL,NULL,'2026-07-22 17:35:25','2026-08-05 16:00:55'),(4,4,3,4,5,'2026-07-18 10:00:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(5,5,4,5,6,'2026-07-26 13:00:00','confirmed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(6,6,4,6,7,'2026-07-15 16:00:00','cancelled',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(7,7,5,7,8,'2026-07-24 12:00:00','cancelled',NULL,NULL,'2026-07-22 17:35:25','2026-08-05 16:00:55'),(8,1,6,8,9,'2026-07-19 17:00:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(9,2,7,9,10,'2026-07-27 10:00:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(10,3,8,10,11,'2026-07-16 14:30:00','completed',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(11,4,9,11,12,'2026-07-28 11:30:00','cancelled',NULL,NULL,'2026-07-22 17:35:25','2026-08-05 16:00:55'),(12,5,10,12,13,'2026-07-21 09:00:00','cancelled',NULL,NULL,'2026-07-22 17:35:25','2026-07-22 17:35:25'),(13,1,1,13,2,'2026-08-05 10:30:00','confirmed',NULL,NULL,'2026-08-03 18:13:53','2026-08-03 18:14:28'),(14,1,10,12,13,'2026-08-04 15:30:00','confirmed',NULL,NULL,'2026-08-04 14:18:17','2026-08-04 14:18:41'),(15,1,10,12,13,'2026-08-05 09:30:00','cancelled',NULL,NULL,'2026-08-04 19:03:05','2026-08-05 16:00:55'),(16,1,10,12,13,'2026-08-05 10:00:00','cancelled',NULL,NULL,'2026-08-04 19:07:52','2026-08-05 16:00:55'),(17,1,10,12,13,'2026-08-05 10:30:00','cancelled',NULL,NULL,'2026-08-04 19:11:14','2026-08-05 16:00:55'),(18,1,10,12,13,'2026-08-05 11:00:00','confirmed',NULL,NULL,'2026-08-04 19:13:38','2026-08-04 19:13:53'),(19,1,10,12,13,'2026-08-13 10:30:00','confirmed',NULL,NULL,'2026-08-05 10:34:43','2026-08-05 10:34:58'),(20,1,10,12,13,'2026-08-06 10:00:00','cancelled',NULL,NULL,'2026-08-05 13:55:48','2026-08-05 16:00:55'),(21,3,10,12,13,'2026-08-06 10:30:00','cancelled',NULL,NULL,'2026-08-05 13:59:30','2026-08-05 16:00:55'),(22,1,10,12,13,'2026-08-06 10:00:00','cancelled',NULL,NULL,'2026-08-05 15:08:36','2026-08-05 16:00:55'),(23,1,10,12,13,'2026-08-06 09:30:00','confirmed',NULL,NULL,'2026-08-05 15:09:26','2026-08-05 15:09:46'),(24,1,10,12,13,'2026-08-06 11:00:00','cancelled',NULL,NULL,'2026-08-05 15:11:00','2026-08-05 16:00:55'),(25,1,10,12,13,'2026-08-06 10:30:00','cancelled',NULL,NULL,'2026-08-05 15:38:59','2026-08-05 16:00:55'),(26,1,10,12,13,'2026-08-06 10:00:00','cancelled',NULL,NULL,'2026-08-05 16:01:00','2026-08-05 16:01:11'),(27,1,10,12,13,'2026-08-06 10:00:00','cancelled',NULL,NULL,'2026-08-05 16:01:25','2026-08-05 16:13:12'),(28,1,10,12,13,'2026-08-06 09:00:00','cancelled',NULL,NULL,'2026-08-05 16:01:43','2026-08-05 16:13:12'),(29,1,10,12,13,'2026-08-06 10:30:00','cancelled',NULL,NULL,'2026-08-05 16:06:31','2026-08-05 16:09:00'),(30,1,6,8,9,'2026-08-06 11:00:00','cancelled',NULL,NULL,'2026-08-05 16:13:20','2026-08-05 16:13:24'),(31,1,10,12,13,'2026-08-06 09:00:00','cancelled',NULL,NULL,'2026-08-05 16:40:38','2026-08-05 16:40:44'),(32,1,10,12,13,'2026-08-06 09:00:00','confirmed',NULL,NULL,'2026-08-05 17:46:57','2026-08-05 17:47:15'),(33,1,10,12,13,'2026-08-12 09:00:00','confirmed',NULL,NULL,'2026-08-05 17:54:10','2026-08-05 17:54:30'),(34,1,10,12,13,'2026-08-12 17:30:00','cancelled',NULL,NULL,'2026-08-05 17:56:49','2026-08-05 17:56:56'),(35,1,10,12,13,'2026-08-12 17:30:00','cancelled',NULL,NULL,'2026-08-05 17:58:41','2026-08-05 17:58:45'),(36,1,3,4,5,'2026-08-06 17:00:00','cancelled',NULL,NULL,'2026-08-05 19:05:56','2026-08-05 19:06:11'),(37,1,1,13,2,'2026-08-12 11:00:00','cancelled',NULL,NULL,'2026-08-07 17:54:18','2026-08-07 17:54:23'),(38,1,1,13,1,'2026-08-10 18:30:00','cancelled','ll','rejected','2026-08-10 17:48:03','2026-08-10 18:03:37'),(39,1,9,11,12,'2026-08-11 10:30:00','confirmed',NULL,NULL,'2026-08-10 22:56:06','2026-08-10 22:56:24'),(40,17,1,13,1,'2026-08-11 18:30:00','cancelled',NULL,NULL,'2026-08-11 09:59:13','2026-08-11 09:59:19'),(41,17,1,13,1,'2026-08-11 18:30:00','confirmed',NULL,NULL,'2026-08-11 09:59:53','2026-08-11 10:00:07'),(42,1,1,13,2,'2026-08-11 18:00:00','confirmed',NULL,NULL,'2026-08-11 10:57:46','2026-08-11 10:58:00'),(43,1,1,13,2,'2026-08-28 10:00:00','cancelled',NULL,NULL,'2026-08-18 17:46:23','2026-08-18 18:11:07'),(44,1,1,13,2,'2026-08-28 18:30:00','cancelled',NULL,NULL,'2026-08-18 17:47:28','2026-08-18 18:11:07'),(45,1,1,13,2,'2026-08-28 10:00:00','cancelled',NULL,'user_cancelled','2026-08-18 18:27:21','2026-08-21 09:50:43'),(46,1,1,13,15,'2026-08-28 18:30:00','cancelled',NULL,'user_cancelled','2026-08-21 09:47:44','2026-08-21 09:51:55');
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `salon_id` int NOT NULL,
  `reservation_id` int NOT NULL,
  `rating` int NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `reservation_id` (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`),
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`),
  CONSTRAINT `reviews_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,1,1,1,5,'커트 실력이 정말 좋아요! 다음에도 재방문 의사 있습니다.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(2,2,1,2,4,'깔끔하고 친절했어요.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(3,4,3,4,5,'히피펌 결과물이 만족스러웠습니다.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(4,1,6,8,5,'발레아쥬 컬러가 자연스럽게 잘 나왔어요.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(5,2,7,9,4,'가격 대비 만족스러운 시술이었습니다.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(6,3,8,10,5,'셋팅펌 유지력이 좋아요, 강추합니다.',NULL,NULL,'2026-07-22 17:35:29','2026-07-22 17:35:29'),(7,1,1,13,2,'sss',NULL,NULL,'2026-08-11 11:51:38','2026-08-11 11:51:38');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salon_operating_hours`
--

DROP TABLE IF EXISTS `salon_operating_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salon_operating_hours` (
  `hour_id` int NOT NULL AUTO_INCREMENT,
  `salon_id` int NOT NULL,
  `day_of_week` enum('월','화','수','목','금','토','일') COLLATE utf8mb4_unicode_ci NOT NULL,
  `open_time` time NOT NULL,
  `close_time` time NOT NULL,
  PRIMARY KEY (`hour_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `salon_operating_hours_ibfk_1` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salon_operating_hours`
--

LOCK TABLES `salon_operating_hours` WRITE;
/*!40000 ALTER TABLE `salon_operating_hours` DISABLE KEYS */;
INSERT INTO `salon_operating_hours` VALUES (1,1,'월','10:00:00','20:00:00'),(2,2,'월','11:00:00','21:00:00'),(3,3,'월','10:00:00','19:00:00'),(4,4,'월','09:30:00','20:30:00'),(5,5,'월','10:00:00','20:00:00'),(6,6,'월','11:00:00','22:00:00'),(7,7,'월','09:00:00','19:00:00'),(8,8,'월','10:00:00','21:00:00'),(9,9,'월','10:30:00','20:30:00'),(10,10,'월','09:00:00','18:00:00'),(11,10,'화','09:00:00','18:00:00'),(12,9,'화','10:30:00','20:30:00'),(13,8,'화','10:00:00','21:00:00'),(14,7,'화','09:00:00','19:00:00'),(15,6,'화','11:00:00','22:00:00'),(16,5,'화','10:00:00','20:00:00'),(17,4,'화','09:30:00','20:30:00'),(18,3,'화','10:00:00','19:00:00'),(19,2,'화','11:00:00','21:00:00'),(20,1,'화','10:00:00','20:00:00'),(21,10,'수','09:00:00','18:00:00'),(22,9,'수','10:30:00','20:30:00'),(23,8,'수','10:00:00','21:00:00'),(24,7,'수','09:00:00','19:00:00'),(25,6,'수','11:00:00','22:00:00'),(26,5,'수','10:00:00','20:00:00'),(27,4,'수','09:30:00','20:30:00'),(28,3,'수','10:00:00','19:00:00'),(29,2,'수','11:00:00','21:00:00'),(30,1,'수','10:00:00','20:00:00'),(31,10,'목','09:00:00','18:00:00'),(32,9,'목','10:30:00','20:30:00'),(33,8,'목','10:00:00','21:00:00'),(34,7,'목','09:00:00','19:00:00'),(35,6,'목','11:00:00','22:00:00'),(36,5,'목','10:00:00','20:00:00'),(37,4,'목','09:30:00','20:30:00'),(38,3,'목','10:00:00','19:00:00'),(39,2,'목','11:00:00','21:00:00'),(40,1,'목','10:00:00','20:00:00'),(41,10,'금','09:00:00','18:00:00'),(42,9,'금','10:30:00','20:30:00'),(43,8,'금','10:00:00','21:00:00'),(44,7,'금','09:00:00','19:00:00'),(45,6,'금','11:00:00','22:00:00'),(46,5,'금','10:00:00','20:00:00'),(47,4,'금','09:30:00','20:30:00'),(48,3,'금','10:00:00','19:00:00'),(49,2,'금','11:00:00','21:00:00'),(50,1,'금','10:00:00','20:00:00'),(51,10,'토','09:00:00','18:00:00'),(52,9,'토','10:30:00','20:30:00'),(53,8,'토','10:00:00','21:00:00'),(54,7,'토','09:00:00','19:00:00'),(55,6,'토','11:00:00','22:00:00'),(56,5,'토','10:00:00','20:00:00'),(57,4,'토','09:30:00','20:30:00'),(58,3,'토','10:00:00','19:00:00'),(59,2,'토','11:00:00','21:00:00'),(60,1,'토','10:00:00','20:00:00'),(61,11,'월','10:00:00','20:00:00'),(62,11,'화','10:00:00','20:00:00'),(63,11,'수','10:00:00','20:00:00'),(64,11,'목','10:00:00','20:00:00'),(65,11,'금','10:00:00','20:00:00'),(66,11,'토','10:00:00','20:00:00'),(75,12,'월','10:00:00','20:00:00'),(76,12,'화','10:00:00','20:00:00'),(77,12,'수','10:00:00','20:00:00'),(78,12,'목','10:00:00','20:00:00'),(79,12,'금','10:00:00','20:00:00'),(80,12,'토','10:00:00','20:00:00'),(88,13,'월','10:00:00','20:00:00'),(89,13,'화','10:00:00','20:00:00'),(90,13,'수','10:00:00','20:00:00'),(91,13,'목','10:00:00','20:00:00'),(92,13,'금','10:00:00','20:00:00'),(93,13,'토','10:00:00','20:00:00');
/*!40000 ALTER TABLE `salon_operating_hours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salonnotices`
--

DROP TABLE IF EXISTS `salonnotices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salonnotices` (
  `notice_id` int NOT NULL AUTO_INCREMENT,
  `salon_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notice_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `salonnotices_ibfk_1` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salonnotices`
--

LOCK TABLES `salonnotices` WRITE;
/*!40000 ALTER TABLE `salonnotices` DISABLE KEYS */;
INSERT INTO `salonnotices` VALUES (1,1,'라움헤어 할인행사','적립금 추가20%할인','/upload/255cf00a-d9a6-4859-89dc-49b2524738eb.png','2026-08-07 18:57:44'),(2,2,'j','kk',NULL,'2026-08-18 15:03:14'),(3,12,'첫 영업 기념 삭발 무료','ㅇㅇ',NULL,'2026-08-19 15:11:15');
/*!40000 ALTER TABLE `salonnotices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salons`
--

DROP TABLE IF EXISTS `salons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salons` (
  `salon_id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `salon_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `average_rating` decimal(2,1) DEFAULT '0.0',
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `closed_at` datetime DEFAULT NULL,
  `activation_status` enum('preparing','active') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  PRIMARY KEY (`salon_id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `salons_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salons`
--

LOCK TABLES `salons` WRITE;
/*!40000 ALTER TABLE `salons` DISABLE KEYS */;
INSERT INTO `salons` VALUES (1,8,'라움헤어','서울 강남구 테헤란로 101','02-511-1001','트렌디한 커트와 컬러 전문 살롱',3.7,NULL,'2026-07-22 17:35:15','2026-08-19 15:03:27',NULL,'active',37.4986232,127.0280657),(2,8,'소울커트','서울 마포구 홍대동 45-6','02-511-1002','홍대 감성의 캐주얼 헤어샵',4.2,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.5563000,126.9236000),(3,9,'블랑쉬헤어','서울 서초구 반포동 78-9','02-511-1003','웨딩/투톤 컬러 전문',4.7,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.5045000,126.9959000),(4,9,'그레이스살롱','인천 남동구 구월동 12-3','032-511-1004','가족 단골 손님이 많은 동네 미용실',4.3,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.4478000,126.7017000),(5,10,'헤어스튜디오 온','인천 연수구 송도동 34-5','032-511-1005','남성 전문 클리닉 헤어샵',4.4,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.3894000,126.6390000),(6,10,'살롱드밀','서울 성동구 성수동 56-7','02-511-1006','연예인 단골로 유명한 프리미엄 살롱',4.8,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.5446000,127.0559000),(7,11,'위드헤어','인천 부평구 부평동 89-1','032-511-1007','합리적인 가격의 실속형 헤어샵',4.0,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.4934000,126.7220000),(8,11,'컬러플레이 헤어','서울 마포구 연남동 23-4','02-511-1008','탈염/컬러 특화 살롱',4.6,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.5626000,126.9255000),(9,8,'에디트헤어','서울 용산구 이태원동 67-8','02-511-1009','남녀 커트 및 펌 전문',4.1,NULL,'2026-07-22 17:35:15','2026-07-28 15:15:53',NULL,'active',37.5345000,126.9946000),(10,9,'뮤즈헤어살롱','인천 미추홀구 주안동 90-1','032-511-1010','20년 경력 원장님이 직접 시술',4.9,NULL,'2026-07-22 17:35:15','2026-07-31 16:09:51',NULL,'active',37.4638000,126.6810000),(11,3,'','','',NULL,0.0,NULL,'2026-08-18 14:28:53','2026-08-18 15:16:11','2026-08-18 15:16:11','active',NULL,NULL),(12,18,'홍길동헤어','경기 포천시 호국로 1007','01-1111-2222','하이',0.0,NULL,'2026-08-19 15:09:17','2026-08-19 15:12:05',NULL,'active',37.8738102,127.1575541),(13,19,'홍길동2매장','경기 포천시 호국로 1007','01-1111-1222','',0.0,NULL,'2026-08-20 12:45:04','2026-08-20 12:47:24',NULL,'active',37.8738102,127.1575541);
/*!40000 ALTER TABLE `salons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `salon_id` int NOT NULL,
  `service_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_minutes` int DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `concern` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `services_ibfk_1` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,1,'여성컷',NULL,25000.00,40,'디자이너 커트 (샴푸 포함)',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(2,1,'남성컷',NULL,18000.00,30,'남성 스타일 커트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(3,2,'볼륨매직',NULL,120000.00,150,'자연스러운 볼륨 매직 스트레이트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(4,2,'뿌리염색',NULL,60000.00,90,'새치 커버 뿌리염색',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(5,3,'히피펌',NULL,90000.00,120,'내추럴 웨이브 히피펌',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(6,4,'여성컷',NULL,22000.00,40,'디자이너 커트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(7,4,'클리닉트리트먼트',NULL,70000.00,60,'손상모 집중 케어',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(8,5,'남성컷',NULL,20000.00,30,'남성 클리닉 커트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(9,6,'발레아쥬',NULL,150000.00,180,'자연스러운 그라데이션 염색',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(10,7,'여성컷',NULL,23000.00,40,'디자이너 커트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(11,8,'셋팅펌',NULL,110000.00,150,'내추럴 셋팅펌',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(12,9,'남성컷',NULL,50000.00,30,'남성 스타일 커트',NULL,'2026-07-22 17:35:18','2026-08-10 22:53:50'),(13,10,'여성컷',NULL,24000.00,40,'디자이너 커트',NULL,'2026-07-22 17:35:18','2026-07-22 17:35:18'),(14,12,'삭발',NULL,10000.00,20,'1122',NULL,'2026-08-19 15:10:59','2026-08-19 15:10:59'),(15,1,'레이어드컷','컷',32000.00,50,'얼굴형에 맞춘 층 커트','무거운 머리, 볼륨 부족, 답답한 인상','2026-08-20 11:59:44','2026-08-20 11:59:44'),(16,1,'애쉬브라운 염색','염색',85000.00,120,'탈색 없이 넣는 애쉬 계열 염색','노란기 제거, 차분한 톤, 자연스러운 갈색','2026-08-20 11:59:44','2026-08-20 11:59:44'),(17,1,'헤어글로스','클리닉',45000.00,40,'윤기 코팅 트리트먼트','푸석함, 윤기 없음, 부스스한 모발','2026-08-20 11:59:44','2026-08-20 11:59:44'),(18,1,'앞머리펌','펌',35000.00,40,'자연스러운 앞머리 컬','뜨는 앞머리, 밋밋한 인상','2026-08-20 11:59:44','2026-08-20 11:59:44'),(19,2,'허쉬컷','컷',28000.00,50,'가벼운 layered 허쉬컷','무거운 머리, 답답한 인상, 볼륨 부족','2026-08-20 11:59:44','2026-08-20 11:59:44'),(20,2,'투블럭컷','컷',21000.00,35,'남성 투블럭 스타일','짧고 깔끔한 스타일, 옆머리 뜸','2026-08-20 11:59:44','2026-08-20 11:59:44'),(21,2,'흑채펌','펌',78000.00,110,'자연스러운 남성 다운펌','뜨는 머리, 곱슬머리, 정리 안 되는 옆머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(22,2,'베이직 트리트먼트','클리닉',35000.00,40,'기본 영양 케어','푸석함, 갈라짐, 손상모','2026-08-20 11:59:44','2026-08-20 11:59:44'),(23,3,'웨딩 업스타일','세트',130000.00,90,'예식 당일 업스타일','특별한 날 스타일링, 웨딩','2026-08-20 11:59:44','2026-08-20 11:59:44'),(24,3,'투톤 컬러','염색',180000.00,240,'탈색 후 두 가지 톤 배색','개성 있는 컬러, 분위기 전환','2026-08-20 11:59:44','2026-08-20 11:59:44'),(25,3,'디지털펌','펌',140000.00,180,'열기구 웨이브 펌','힘없는 모발, 볼륨 부족, 웨이브 연출','2026-08-20 11:59:44','2026-08-20 11:59:44'),(26,3,'단백질 클리닉','클리닉',95000.00,80,'탈색모 집중 복구','탈색 손상, 끊어짐, 심한 손상모','2026-08-20 11:59:44','2026-08-20 11:59:44'),(27,4,'커트+드라이','세트',32000.00,60,'커트와 드라이를 함께','일상 손질 편한 커트, 스타일링','2026-08-20 11:59:44','2026-08-20 11:59:44'),(28,4,'새치커버 염색','염색',55000.00,80,'자연 갈색 새치 커버','새치 커버, 흰머리, 자연스러운 톤','2026-08-20 11:59:44','2026-08-20 11:59:44'),(29,4,'볼륨매직','펌',115000.00,150,'뿌리 볼륨 매직','곱슬머리, 부스스한 모발, 매끈한 볼륨','2026-08-20 11:59:44','2026-08-20 11:59:44'),(30,4,'두피 스케일링','클리닉',40000.00,40,'두피 각질 제거와 진정','두피 가려움, 기름진 두피, 냄새','2026-08-20 11:59:44','2026-08-20 11:59:44'),(31,5,'남성 다운펌','펌',45000.00,60,'뜨는 옆머리 정리','뜨는 머리, 정리 안 되는 옆머리, 곱슬머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(32,5,'두피 클리닉','클리닉',60000.00,60,'두피 집중 관리 프로그램','두피 가려움, 비듬, 기름진 두피','2026-08-20 11:59:44','2026-08-20 11:59:44'),(33,5,'남성 커버 염색','염색',45000.00,60,'남성용 새치 커버','새치 커버, 흰머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(34,5,'스포츠컷','컷',16000.00,25,'짧고 관리 쉬운 커트','짧고 깔끔한 스타일, 관리 편한 머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(35,6,'프리미엄 헤드스파','클리닉',160000.00,90,'두피 마사지 포함 스파','두피 피로, 스트레스, 기름진 두피','2026-08-20 11:59:44','2026-08-20 11:59:44'),(36,6,'디자이너 컷','컷',90000.00,60,'원장 디자이너 커트','얼굴형 커버, 이미지 변신','2026-08-20 11:59:44','2026-08-20 11:59:44'),(37,6,'럭셔리 클리닉','클리닉',220000.00,120,'고농축 단백질 복구','심한 손상모, 끊어짐, 갈라짐','2026-08-20 11:59:44','2026-08-20 11:59:44'),(38,7,'남성컷','컷',15000.00,25,'실속형 남성 커트','짧고 깔끔한 스타일, 관리 편한 머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(39,7,'기본펌','펌',55000.00,90,'가격 부담 없는 기본 펌','볼륨 부족, 힘없는 모발','2026-08-20 11:59:44','2026-08-20 11:59:44'),(40,7,'뿌리염색','염색',38000.00,60,'뿌리만 채우는 염색','새치 커버, 뿌리 자란 머리','2026-08-20 11:59:44','2026-08-20 11:59:44'),(41,8,'블리치 2회','염색',160000.00,210,'밝은 톤을 위한 2회 탈색','밝은 컬러, 톤 업, 개성 있는 컬러','2026-08-20 11:59:44','2026-08-20 11:59:44'),(42,8,'핑크 컬러','염색',130000.00,180,'탈색 후 핑크 컬러','개성 있는 컬러, 분위기 전환','2026-08-20 11:59:44','2026-08-20 11:59:44'),(43,8,'탈색모 클리닉','클리닉',80000.00,70,'탈색 직후 복구 케어','탈색 손상, 심한 손상모, 끊어짐','2026-08-20 11:59:44','2026-08-20 11:59:44'),(44,8,'컬러 커트','컷',30000.00,45,'컬러에 맞춘 커트','이미지 변신, 얼굴형 커버','2026-08-20 11:59:44','2026-08-20 11:59:44'),(45,9,'여성컷','컷',24000.00,40,'디자이너 커트','일상 손질 편한 커트, 얼굴형 커버','2026-08-20 11:59:44','2026-08-20 11:59:44'),(46,9,'히피펌','펌',88000.00,120,'내추럴 웨이브 히피펌','밋밋한 머리, 웨이브 연출, 볼륨 부족','2026-08-20 11:59:44','2026-08-20 11:59:44'),(47,9,'보브펌','펌',95000.00,130,'단발 웨이브 펌','단발 스타일, 웨이브 연출','2026-08-20 11:59:44','2026-08-20 11:59:44'),(48,9,'영양 클리닉','클리닉',50000.00,50,'펌·염색 후 영양 보충','손상모, 푸석함, 갈라짐','2026-08-20 11:59:44','2026-08-20 11:59:44'),(49,10,'원장 커트','컷',38000.00,50,'원장 직접 시술 커트','얼굴형 커버, 이미지 변신','2026-08-20 11:59:44','2026-08-20 11:59:44'),(50,10,'셋팅펌','펌',105000.00,150,'내추럴 셋팅펌','볼륨 부족, 힘없는 모발, 자연스러운 웨이브','2026-08-20 11:59:44','2026-08-20 11:59:44'),(51,10,'발레아쥬','염색',145000.00,180,'자연스러운 그라데이션 염색','칙칙한 톤, 그라데이션 염색, 분위기 전환','2026-08-20 11:59:44','2026-08-20 11:59:44'),(52,10,'손상모 집중케어','클리닉',72000.00,70,'손상 단계별 맞춤 케어','손상모, 갈라짐, 푸석함 완화','2026-08-20 11:59:44','2026-08-20 11:59:44'),(78,13,'ㄴㅇ','컷',3700.00,325,'33',NULL,'2026-08-20 12:46:23','2026-08-20 12:46:23');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stylist_schedules`
--

DROP TABLE IF EXISTS `stylist_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stylist_schedules` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `stylist_id` int NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`schedule_id`),
  KEY `stylist_id` (`stylist_id`),
  CONSTRAINT `stylist_schedules_ibfk_1` FOREIGN KEY (`stylist_id`) REFERENCES `stylists` (`stylist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stylist_schedules`
--

LOCK TABLES `stylist_schedules` WRITE;
/*!40000 ALTER TABLE `stylist_schedules` DISABLE KEYS */;
INSERT INTO `stylist_schedules` VALUES (1,2,'2026-08-07','10:00:00','19:00:00',1),(2,13,'2026-08-03','10:00:00','19:00:00',1),(3,13,'2026-08-04','10:00:00','19:00:00',1),(4,13,'2026-08-05','10:00:00','19:00:00',1),(5,13,'2026-08-06','10:00:00','19:00:00',1),(6,13,'2026-08-07','10:00:00','19:00:00',1),(7,13,'2026-08-08','10:00:00','19:00:00',1),(8,13,'2026-08-09','10:00:00','19:00:00',1),(9,13,'2026-08-10','10:00:00','19:00:00',1),(10,13,'2026-08-11','10:00:00','19:00:00',1),(11,13,'2026-08-12','10:00:00','19:00:00',1),(12,13,'2026-08-13','10:00:00','19:00:00',1),(13,13,'2026-08-14','10:00:00','19:00:00',1),(14,13,'2026-08-15','10:00:00','19:00:00',1),(15,13,'2026-08-16','10:00:00','19:00:00',1),(16,13,'2026-08-17','10:00:00','19:00:00',1),(17,13,'2026-08-18','10:00:00','19:00:00',1),(18,13,'2026-08-19','10:00:00','19:00:00',1),(19,13,'2026-08-20','10:00:00','19:00:00',1),(20,13,'2026-08-21','10:00:00','19:00:00',1),(21,13,'2026-08-22','10:00:00','19:00:00',1),(22,13,'2026-08-23','10:00:00','19:00:00',1),(23,13,'2026-08-24','10:00:00','19:00:00',1),(24,13,'2026-08-25','10:00:00','19:00:00',1),(25,13,'2026-08-26','10:00:00','19:00:00',1),(26,13,'2026-08-27','10:00:00','19:00:00',1),(27,13,'2026-08-28','10:00:00','19:00:00',1),(28,1,'2026-08-04','10:00:00','19:00:00',1),(29,1,'2026-08-05','10:00:00','19:00:00',1),(30,1,'2026-08-06','10:00:00','19:00:00',1),(31,1,'2026-08-07','10:00:00','19:00:00',1),(32,11,'2026-08-10','10:00:00','19:00:00',1),(33,11,'2026-08-11','10:00:00','19:00:00',1),(34,11,'2026-08-12','10:00:00','19:00:00',1),(35,11,'2026-08-13','10:00:00','19:00:00',1),(36,11,'2026-08-14','10:00:00','19:00:00',1),(37,11,'2026-08-15','10:00:00','19:00:00',1),(38,11,'2026-08-16','10:00:00','19:00:00',1),(39,11,'2026-08-17','10:00:00','19:00:00',1),(40,11,'2026-08-18','10:00:00','19:00:00',1),(41,11,'2026-08-19','10:00:00','19:00:00',1),(42,11,'2026-08-20','10:00:00','19:00:00',1),(43,11,'2026-08-21','10:00:00','19:00:00',1),(44,11,'2026-08-22','10:00:00','19:00:00',1),(45,11,'2026-08-23','10:00:00','19:00:00',1),(46,11,'2026-08-24','10:00:00','19:00:00',1),(47,11,'2026-08-25','10:00:00','19:00:00',1),(48,11,'2026-08-26','10:00:00','19:00:00',1),(49,11,'2026-08-27','10:00:00','19:00:00',1),(50,11,'2026-08-28','10:00:00','19:00:00',1),(51,11,'2026-08-29','10:00:00','19:00:00',1),(52,11,'2026-08-30','10:00:00','19:00:00',1),(53,11,'2026-08-31','10:00:00','19:00:00',1),(54,1,'2026-08-18','10:00:00','19:00:00',1),(55,1,'2026-08-19','10:00:00','19:00:00',1),(56,1,'2026-08-20','10:00:00','19:00:00',1),(57,1,'2026-08-21','10:00:00','19:00:00',1),(58,1,'2026-08-22','10:00:00','19:00:00',1),(59,1,'2026-08-23','10:00:00','19:00:00',1),(60,1,'2026-08-24','10:00:00','19:00:00',1),(61,1,'2026-08-25','10:00:00','19:00:00',1),(62,1,'2026-08-26','10:00:00','19:00:00',1),(63,1,'2026-08-27','10:00:00','19:00:00',1),(64,1,'2026-08-28','10:00:00','19:00:00',1),(65,1,'2026-08-29','10:00:00','19:00:00',1),(66,1,'2026-08-30','10:00:00','19:00:00',1),(67,1,'2026-08-31','10:00:00','19:00:00',1),(68,2,'2026-08-18','10:00:00','19:00:00',1),(69,2,'2026-08-19','10:00:00','19:00:00',1),(70,2,'2026-08-20','10:00:00','19:00:00',1),(71,2,'2026-08-21','10:00:00','19:00:00',1),(72,2,'2026-08-22','10:00:00','19:00:00',1),(73,2,'2026-08-23','10:00:00','19:00:00',1),(74,2,'2026-08-24','10:00:00','19:00:00',1),(75,2,'2026-08-25','10:00:00','19:00:00',1),(76,2,'2026-08-26','10:00:00','19:00:00',1),(77,2,'2026-08-27','10:00:00','19:00:00',1),(78,2,'2026-08-28','10:00:00','19:00:00',1),(79,2,'2026-08-29','10:00:00','19:00:00',1),(80,2,'2026-08-30','10:00:00','19:00:00',1),(81,2,'2026-08-31','10:00:00','19:00:00',1),(82,3,'2026-08-18','10:00:00','19:00:00',1),(83,3,'2026-08-19','10:00:00','19:00:00',1),(84,3,'2026-08-20','10:00:00','19:00:00',1),(85,3,'2026-08-21','10:00:00','19:00:00',1),(86,3,'2026-08-22','10:00:00','19:00:00',1),(87,3,'2026-08-23','10:00:00','19:00:00',1),(88,3,'2026-08-24','10:00:00','19:00:00',1),(89,3,'2026-08-25','10:00:00','19:00:00',1),(90,3,'2026-08-26','10:00:00','19:00:00',1),(91,3,'2026-08-27','10:00:00','19:00:00',1),(92,3,'2026-08-28','10:00:00','19:00:00',1),(93,3,'2026-08-29','10:00:00','19:00:00',1),(94,3,'2026-08-30','10:00:00','19:00:00',1),(95,3,'2026-08-31','10:00:00','19:00:00',1),(96,16,'2026-08-24','00:00:00','23:59:00',0),(97,16,'2026-08-31','00:00:00','23:59:00',0),(98,16,'2026-09-07','00:00:00','23:59:00',0),(99,16,'2026-09-14','00:00:00','23:59:00',0),(100,16,'2026-09-21','00:00:00','23:59:00',0),(101,16,'2026-09-28','00:00:00','23:59:00',0),(102,16,'2026-10-05','00:00:00','23:59:00',0),(103,16,'2026-10-12','00:00:00','23:59:00',0),(104,16,'2026-10-19','00:00:00','23:59:00',0),(105,16,'2026-10-26','00:00:00','23:59:00',0),(106,16,'2026-11-02','00:00:00','23:59:00',0),(107,16,'2026-11-09','00:00:00','23:59:00',0);
/*!40000 ALTER TABLE `stylist_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stylists`
--

DROP TABLE IF EXISTS `stylists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stylists` (
  `stylist_id` int NOT NULL AUTO_INCREMENT,
  `salon_id` int NOT NULL,
  `stylist_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stylist_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `stylists_ibfk_1` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stylists`
--

LOCK TABLES `stylists` WRITE;
/*!40000 ALTER TABLE `stylists` DISABLE KEYS */;
INSERT INTO `stylists` VALUES (1,1,'김지은','010-3000-0001','커트 전문 디자이너 경력 8년',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(2,1,'박민수','010-3000-0002','남성 커트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(3,2,'이하늘','010-3000-0003','매직/스트레이트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(4,3,'최유정','010-3000-0004','펌 전문 디자이너',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(5,4,'정다은','010-3000-0005','커트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(6,4,'오세훈','010-3000-0006','트리트먼트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(7,5,'강태양','010-3000-0007','남성 클리닉 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(8,6,'윤소희','010-3000-0008','컬러 전문 원장',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(9,7,'한지민','010-3000-0009','커트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(10,8,'서준혁','010-3000-0010','펌 전문 디자이너',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(11,9,'임수아','010-3000-0011','남성/여성 커트 전문',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(12,10,'배도현','010-3000-0012','20년 경력 원장',NULL,'2026-07-22 17:35:21','2026-07-22 17:35:21'),(13,1,'김수겸','010-1111-2222','월요일 휴무','/upload/cb92d8a3-a0fc-4586-b68d-161a3c58c2ba.png','2026-08-03 15:30:01','2026-08-03 15:30:01'),(14,2,'dsd','sdsdsd','sdsd',NULL,'2026-08-18 15:04:47','2026-08-18 15:04:47'),(15,2,'ll','','asasa',NULL,'2026-08-18 15:05:35','2026-08-18 15:05:35'),(16,13,'sdd','011-1111-2222','매주 월요일 휴무',NULL,'2026-08-20 12:46:47','2026-08-20 12:46:47');
/*!40000 ALTER TABLE `stylists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_coupons`
--

DROP TABLE IF EXISTS `user_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_coupons` (
  `user_coupon_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `coupon_id` int NOT NULL,
  `status` enum('available','reserved','used','expired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `reservation_id` int DEFAULT NULL,
  `issued_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_coupon_id`),
  KEY `coupon_id` (`coupon_id`),
  KEY `reservation_id` (`reservation_id`),
  KEY `idx_user_status` (`user_id`,`status`),
  CONSTRAINT `user_coupons_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_coupons_ibfk_2` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`),
  CONSTRAINT `user_coupons_ibfk_3` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_coupons`
--

LOCK TABLES `user_coupons` WRITE;
/*!40000 ALTER TABLE `user_coupons` DISABLE KEYS */;
INSERT INTO `user_coupons` VALUES (1,1,1,'used',39,'2026-08-10 15:32:53','2027-08-10 23:59:59','2026-08-10 22:56:24'),(2,1,2,'used',38,'2026-08-10 15:32:53','2026-11-10 23:59:59','2026-08-10 17:48:23'),(4,1,4,'used',42,'2026-08-10 22:49:28','2026-11-10 23:59:59','2026-08-11 10:58:00'),(5,1,3,'available',NULL,'2026-08-10 22:49:28','2027-08-10 23:59:59',NULL),(8,16,3,'available',NULL,'2026-08-10 23:11:09','2027-08-10 23:59:59',NULL),(9,17,3,'used',41,'2026-08-11 09:50:07','2027-08-10 23:59:59','2026-08-11 10:00:07'),(10,1,9,'available',NULL,'2026-08-11 10:21:38','2027-08-11 23:59:59',NULL),(11,18,3,'available',NULL,'2026-08-19 15:08:20','2027-08-10 23:59:59',NULL),(12,19,3,'available',NULL,'2026-08-20 12:44:05','2027-08-10 23:59:59',NULL);
/*!40000 ALTER TABLE `user_coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sanctions`
--

DROP TABLE IF EXISTS `user_sanctions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sanctions` (
  `sanction_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int DEFAULT NULL,
  `post_title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment_id` int DEFAULT NULL,
  `comment_content` text COLLATE utf8mb4_unicode_ci,
  `admin_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sanction_type` enum('suspend_3d','suspend_7d','permanent') COLLATE utf8mb4_unicode_ci NOT NULL,
  `suspended_until` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sanction_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_sanctions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sanctions`
--

LOCK TABLES `user_sanctions` WRITE;
/*!40000 ALTER TABLE `user_sanctions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sanctions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_type` enum('customer','owner','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` enum('local','google','naver') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local',
  `provider_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `status` enum('active','suspended','banned') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `notifications_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `suspended_until` datetime DEFAULT NULL,
  `point_balance` int NOT NULL DEFAULT '0',
  `last_reply_check_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_users_provider_id` (`provider`,`provider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'test1@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test1','010-2000-0001',NULL,'customer','local',NULL,'2026-07-22 17:35:12','2026-08-21 10:48:49',NULL,'active',1,NULL,21000,NULL),(2,'test2@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test2','010-2000-0002',NULL,'owner','local',NULL,'2026-07-22 17:35:12','2026-07-31 16:13:57',NULL,'active',1,NULL,0,NULL),(3,'test3@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test3','010-2000-0003',NULL,'owner','local',NULL,'2026-07-22 17:35:12','2026-08-18 14:28:53',NULL,'active',1,NULL,0,NULL),(4,'test4@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test4','010-2000-0004',NULL,'customer','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(5,'test5@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test5','010-2000-0001',NULL,'customer','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(6,'test6@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','test6','010-2000-0002',NULL,'customer','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(7,'test7@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','tsst7','010-2000-0003',NULL,'customer','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(8,'owner1@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','이원장','010-2000-0001',NULL,'owner','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(9,'owner2@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','박원장','010-2000-0002',NULL,'owner','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(10,'owner3@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','최원장','010-2000-0003',NULL,'owner','local',NULL,'2026-07-22 17:35:12','2026-07-22 17:42:28',NULL,'active',1,NULL,0,NULL),(11,'owner4@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','정원장','010-2000-0004',NULL,'admin','local',NULL,'2026-07-22 17:35:12','2026-07-31 16:12:32',NULL,'active',1,NULL,0,NULL),(12,'sin@test.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','신신신',NULL,NULL,'admin','local',NULL,'2026-07-22 17:40:52','2026-07-29 16:06:42',NULL,'active',1,NULL,0,NULL),(13,'sss@sss.com','$2a$10$ZmxjwfsRQR8Q2h5SxE6y5.JjBzfDoD.LwOh49TCUR6QiK0RFN06oO','김수겸',NULL,NULL,'customer','local',NULL,'2026-07-27 14:31:27','2026-07-27 14:31:27',NULL,'active',1,NULL,0,NULL),(14,'tttt1@salu.com','$2a$10$ScUkV0w3I6zhSb1Y8QPKp.q7j.zz5Xb9qelENTpvgVAkA7d5LB7w.','홍길동',NULL,NULL,'customer','local',NULL,'2026-08-02 20:12:57','2026-08-02 20:12:57',NULL,'active',1,NULL,0,NULL),(15,'tttt@salu.com','$2a$10$O.ltBPxHn47AQ8bN/9y1rOyeiGu251unj1jKRpcU/x.N4XexHBCve','홍길동',NULL,NULL,'customer','local',NULL,'2026-08-10 18:13:04','2026-08-10 18:13:04',NULL,'active',1,NULL,0,NULL),(16,'hong22@salu.com','$2a$10$OVVqxxhGnSi1s3TFTEthFO5vfwCQAbHwskoCucPVu.we5nuNhv7j2','홍길동22',NULL,NULL,'customer','local',NULL,'2026-08-10 23:11:09','2026-08-10 23:11:09',NULL,'active',1,NULL,0,NULL),(17,'hong11@salu.com','$2a$10$naX6GxTV1q59es.8DquLXOF7gdV9.O63qe3EFXdgDqqaHkYXAkMJa','홍길동11',NULL,NULL,'customer','local',NULL,'2026-08-11 09:50:07','2026-08-11 09:50:07',NULL,'active',1,NULL,0,NULL),(18,'hong@salu.com','$2a$10$NljbT05uNvMSAiT98Ev8uewE1HNDP0YkNIbbpGYdaTn8xxcR.dJM.','홍길동',NULL,NULL,'owner','local',NULL,'2026-08-19 15:08:20','2026-08-19 15:09:17',NULL,'active',1,NULL,0,NULL),(19,'hong2@salu.com','$2a$10$.HhpHsE/ZaMTEh5hNEmX8uOe6i9yhSN7.4EJuOQoaaiJphBQlJ1yy','홍길동2',NULL,NULL,'owner','local',NULL,'2026-08-20 12:44:05','2026-08-20 12:45:04',NULL,'active',1,NULL,0,NULL),(20,'kyumi1701@gmail.com',NULL,'김수겸',NULL,NULL,'customer','google','102014246782510931149','2026-08-20 15:11:40','2026-08-20 15:11:40',NULL,'active',1,NULL,0,NULL),(21,'kyumi1003@naver.com',NULL,'김수겸',NULL,NULL,'customer','naver','2xwv_M80w_b82bKnOhwJfqJSGGrDUKXK8J9zXgBxXxQ','2026-08-20 15:24:37','2026-08-20 15:24:37',NULL,'active',1,NULL,0,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlists` (
  `wishlist_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `salon_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`wishlist_id`),
  UNIQUE KEY `user_id` (`user_id`,`salon_id`),
  KEY `salon_id` (`salon_id`),
  CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`salon_id`) REFERENCES `salons` (`salon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlists`
--

LOCK TABLES `wishlists` WRITE;
/*!40000 ALTER TABLE `wishlists` DISABLE KEYS */;
INSERT INTO `wishlists` VALUES (5,1,10,'2026-08-10 13:05:50'),(6,1,6,'2026-08-18 13:00:36');
/*!40000 ALTER TABLE `wishlists` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-24 11:31:14
