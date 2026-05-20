-- MySQL dump 10.13  Distrib 9.6.0, for macos26.3 (arm64)
--
-- Host: localhost    Database: pos_mysql_app
-- ------------------------------------------------------
-- Server version	9.6.0

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
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text,
  `customer_type` varchar(50) NOT NULL DEFAULT 'walk-in',
  `credit_limit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'John Snoq','','','','wholesale',1000.00,0.00,'','2026-04-12 21:08:22'),(2,'ABC Store','','','','wholesale',10000.00,0.00,'','2026-04-12 21:20:19');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sale_id` int NOT NULL,
  `customer_id` int NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `paid_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` varchar(50) NOT NULL DEFAULT 'unpaid',
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sale_id` (`sale_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,49,1,100.00,100.00,'paid','2026-04-14','2026-04-12 21:09:30'),(2,50,1,150.00,150.00,'paid','2026-04-16','2026-04-12 21:13:26'),(3,51,1,50.00,50.00,'paid','2026-04-14','2026-04-12 21:15:19'),(4,52,2,5095.00,5095.00,'paid',NULL,'2026-04-12 21:24:03'),(5,55,1,155.00,155.00,'paid',NULL,'2026-04-12 22:38:57');
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `invoice_id` int DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL DEFAULT 'cash',
  `received_by` int DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `invoice_id` (`invoice_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,1,10.00,'cash',1,'Initial payment for sale #49','2026-04-12 21:09:30'),(2,1,2,50.00,'cash',1,'Initial payment for sale #50','2026-04-12 21:13:26'),(3,1,3,50.00,'cash',1,'','2026-04-12 21:17:33'),(4,1,2,100.00,'card',1,'second payment','2026-04-12 21:18:54'),(5,2,4,2000.00,'cash',1,'Initial payment for sale #52','2026-04-12 21:24:03'),(6,2,4,2000.00,'cash',1,'','2026-04-17 09:55:31'),(7,2,4,500.00,'cash',1,'','2026-04-17 10:06:05'),(8,2,4,595.00,'cash',1,'final payment','2026-04-18 05:28:43'),(9,1,NULL,245.00,'cash',1,'final payment','2026-04-18 05:29:39');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `po_items`
--

DROP TABLE IF EXISTS `po_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `po_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `po_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity_ordered` int NOT NULL,
  `quantity_received` int NOT NULL DEFAULT '0',
  `unit_cost` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `po_id` (`po_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `po_items_ibfk_1` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `po_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `po_items`
--

LOCK TABLES `po_items` WRITE;
/*!40000 ALTER TABLE `po_items` DISABLE KEYS */;
INSERT INTO `po_items` VALUES (1,1,20,1,1,40.00,'2026-04-11 23:32:24'),(2,1,10,10,10,40.00,'2026-04-11 23:32:24'),(3,2,14,1000,1000,42.00,'2026-04-11 23:41:34'),(4,3,20,50,20,41.00,'2026-04-12 01:02:36'),(5,4,34,30,30,96000.00,'2026-04-12 01:18:20');
/*!40000 ALTER TABLE `po_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_audit_log`
--

DROP TABLE IF EXISTS `product_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_audit_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `old_value` longtext,
  `new_value` longtext,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `product_audit_log_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `product_audit_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_audit_log`
--

LOCK TABLES `product_audit_log` WRITE;
/*!40000 ALTER TABLE `product_audit_log` DISABLE KEYS */;
INSERT INTO `product_audit_log` VALUES (1,10,1,'admin','duplicate','source','5','10','2026-04-10 23:36:52'),(2,10,1,'admin','edit','name','Black Jackets (Copy)','Red Jackets','2026-04-10 23:37:12'),(3,10,1,'admin','edit','sku','JAC-001','JAC-002','2026-04-10 23:37:12'),(4,1,1,'admin','edit','price','54.0','55.0','2026-04-10 23:39:37'),(5,2,1,'admin','edit','cost_price','0.0','25.0','2026-04-11 22:46:13'),(6,34,1,'admin','edit','price','135000.0','138000.0','2026-04-12 01:25:55');
/*!40000 ALTER TABLE `product_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `cost_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `price` decimal(12,2) NOT NULL,
  `stock_quantity` int NOT NULL DEFAULT '0',
  `sku` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `low_stock_threshold` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Blue T-Shirt','Shirts',0.00,55.00,985,'TS-BLU-M','T-Shirt Blues M Size','2026-03-28 05:25:15',NULL),(2,'Blue T-Shirt','Shirts',25.00,50.00,993,'TS-BLU-L','T-Shirt Blue L Size','2026-03-28 05:26:06',NULL),(3,'White T-Shirt','Shirts',0.00,50.00,81,'TS-WH-S','T-Shirt White S size','2026-03-28 05:27:41',NULL),(4,'Test Blue Jeans','Pants',15.00,39.99,39,'TEST-JEANS-001','Test product for E2E testing','2026-03-28 05:58:06',NULL),(5,'Black Jackets','Jackets',40.00,50.00,923,'JT-BL-M','Jacket black M size','2026-03-28 06:28:34',NULL),(7,'Sock','Other',15.00,30.00,81,'SOCK','Socks','2026-03-28 23:31:06',NULL),(8,'Hat','Hats',40.00,60.00,998,'Hats','','2026-03-28 23:36:01',NULL),(9,'TEST-STUFF','Accessories',1000.00,1030.00,94,'TS','','2026-04-10 22:48:10',5),(10,'Red Jackets','Jackets',40.00,50.00,49,'JAC-002','Jacket black M size','2026-04-10 23:36:52',NULL),(11,'Black Jackets1','Jackets',40.00,50.00,987,'JT-BL-M1','Jacket black M size','2026-04-11 20:36:34',NULL),(12,'Blue T-Shirt1','Shirts',0.00,55.00,1001,'TS-BLU-M1','T-Shirt Blues M Size','2026-04-11 20:36:34',NULL),(13,'Blue T-Shirt1','Shirts',0.00,50.00,994,'TS-BLU-L1','T-Shirt Blue L Size','2026-04-11 20:36:34',NULL),(14,'Hat1','Hats',41.00,60.00,2000,'Hats1','','2026-04-11 20:36:34',NULL),(15,'Red Jackets1','Jackets',40.00,50.00,39,'JAC-0021','Jacket black M size','2026-04-11 20:36:34',NULL),(16,'Sock1','Other',15.00,30.00,81,'SOCK1','Socks','2026-04-11 20:36:34',NULL),(17,'TEST-STUFF1','Accessories',1000.00,1030.00,94,'TS1','','2026-04-11 20:36:34',5),(18,'Test Blue Jeans1','Pants',15.00,39.99,39,'TEST1-JEANS-001','Test product for E2E testing','2026-04-11 20:36:34',NULL),(19,'White T-Shirt1','Shirts',0.00,50.00,81,'TS-WH-S1','T-Shirt White S size','2026-04-11 20:36:34',NULL),(20,'Black Jackets2','Jackets',40.95,50.00,0,'JT-BL-M2','Jacket black M size','2026-04-11 20:40:31',NULL),(21,'Blue T-Shirt2','Shirts',0.00,55.00,3,'TS-BLU-M2','T-Shirt Blues M Size','2026-04-11 20:40:31',NULL),(22,'Blue T-Shirt2','Shirts',0.00,50.00,0,'TS-BLU-L2','T-Shirt Blue L Size','2026-04-11 20:40:31',NULL),(23,'Hat2','Hats',40.00,60.00,0,'Hats2','','2026-04-11 20:40:31',NULL),(24,'Red Jackets2','Jackets',40.00,50.00,39,'JAC-0022','Jacket black M size','2026-04-11 20:40:31',NULL),(25,'Sock2','Other',25.00,30.00,82,'SOCK2','Socks','2026-04-11 20:40:31',NULL),(26,'TEST-STUFF2','Accessories',2000.00,2030.00,94,'TS2','','2026-04-11 20:40:31',5),(27,'Test Blue Jeans2','Pants',25.00,39.99,39,'TEST2-JEANS-002','Test product for E2E testing','2026-04-11 20:40:31',NULL),(28,'White T-Shirt2','Shirts',0.00,50.00,82,'TS-WH-S2','T-Shirt White S size','2026-04-11 20:40:31',NULL),(29,'Hand Chain','Suviniour',5.00,10.00,100,'SR-HC','','2026-04-11 20:52:11',5),(30,'TEST123','Suviniour',20.00,28.00,10,'TS123','incoming stock1','2026-04-11 23:59:28',5),(31,'Tes15','Suviniour',200.00,300.00,10,'tes15','incoming stock','2026-04-12 00:11:30',5),(32,'Done2','Suviniour',10.00,30.00,100,'Don','','2026-04-12 00:52:03',5),(33,'Don3','Suviniour',10.00,40.00,20,'Don3','','2026-04-12 00:55:57',5),(34,'RICE - MTK','Basic needs',95600.00,138000.00,46,'RMTK','incoming stock ','2026-04-12 01:12:34',5),(35,'fasdfa','Shirts',12.00,2.00,12,'SHI-001','','2026-04-17 09:03:48',NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `total_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `notes` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `received_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,1,'received',440.00,'',1,'2026-04-11 23:32:24','2026-04-11 23:37:36'),(2,1,'received',42000.00,'',1,'2026-04-11 23:41:34','2026-04-11 23:42:12'),(3,1,'partial',2050.00,'',1,'2026-04-12 01:02:36',NULL),(4,2,'received',2880000.00,'',1,'2026-04-12 01:18:20','2026-04-12 01:19:00');
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_returns`
--

DROP TABLE IF EXISTS `sale_returns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_returns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sale_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `items_json` longtext NOT NULL,
  `refund_amount` decimal(12,2) NOT NULL,
  `reason` text,
  `return_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sale_id` (`sale_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `sale_returns_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  CONSTRAINT `sale_returns_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_returns`
--

LOCK TABLES `sale_returns` WRITE;
/*!40000 ALTER TABLE `sale_returns` DISABLE KEYS */;
INSERT INTO `sale_returns` VALUES (1,33,1,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"price\": 1030, \"quantity\": 2}, {\"product_id\": 7, \"name\": \"Sock\", \"price\": 30, \"quantity\": 1}, {\"product_id\": 8, \"name\": \"Hat\", \"price\": 60, \"quantity\": 1}]',2150.00,'','2026-04-10 22:52:57'),(2,39,1,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 6}]',324.00,'','2026-04-17 10:26:35');
/*!40000 ALTER TABLE `sale_returns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT '',
  `total_amount` decimal(12,2) NOT NULL,
  `total_cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `payment_method` varchar(50) DEFAULT 'cash',
  `cash_tendered` decimal(12,2) DEFAULT '0.00',
  `items_json` longtext NOT NULL,
  `sale_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,NULL,NULL,'',108.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 2, \"max_stock\": 50}]','2026-03-28 05:33:53'),(3,3,NULL,'',500.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"price\": 50, \"quantity\": 10, \"max_stock\": 100}]','2026-03-28 06:26:29'),(4,3,NULL,'',250.00,200.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"price\": 50, \"quantity\": 5, \"max_stock\": 10}]','2026-03-28 06:28:59'),(5,3,NULL,'',162.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 3, \"max_stock\": 48}]','2026-03-28 06:45:41'),(6,4,NULL,'',250.00,200.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 5, \"max_stock\": 5}]','2026-03-28 22:16:48'),(7,1,NULL,'',199.95,75.00,0.00,'cash',0.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 5, \"max_stock\": 73}]','2026-03-28 22:19:41'),(8,1,NULL,'',216.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 4, \"max_stock\": 45}]','2026-03-28 22:29:50'),(9,1,NULL,'',154.00,40.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"max_stock\": 24}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"max_stock\": 41}, {\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"max_stock\": 40}]','2026-03-28 22:30:15'),(10,1,NULL,'',192.00,120.00,66.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 3, \"discount\": 12, \"discount_type\": \"fixed\", \"max_stock\": 23}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 2, \"discount\": 50, \"discount_type\": \"percent\", \"max_stock\": 40}]','2026-03-28 22:48:53'),(11,3,NULL,'',40.50,40.00,9.50,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 19, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-03-28 23:04:06'),(12,3,NULL,'',43.50,40.00,6.50,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 13, \"discount_type\": \"percent\", \"max_stock\": 19}]','2026-03-28 23:05:23'),(13,3,NULL,'',50.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 39}]','2026-03-28 23:05:46'),(14,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 18}]','2026-03-28 23:07:44'),(15,1,NULL,'',180.00,110.00,0.00,'cash',0.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}]','2026-03-28 23:36:27'),(16,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 16}]','2026-03-28 23:51:29'),(17,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 14}]','2026-03-29 00:04:24'),(18,1,NULL,'',58.80,30.00,1.20,'cash',0.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 2, \"discount_type\": \"percent\", \"max_stock\": 98}]','2026-03-29 20:27:38'),(19,1,NULL,'',6654.00,4200.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 38}, {\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 8, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 38}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 95, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 98}, {\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 10, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 12}]','2026-03-29 20:58:13'),(20,1,NULL,'',1350.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 27, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 30}]','2026-03-29 21:30:40'),(21,1,NULL,'',90.00,80.00,10.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 10, \"discount_type\": \"percent\", \"max_stock\": 2}]','2026-04-02 06:00:37'),(22,1,NULL,'',84.00,15.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 37}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 96}]','2026-04-10 22:15:48'),(23,1,NULL,'',44.00,0.00,10.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 10, \"discount_type\": \"fixed\", \"max_stock\": 36}]','2026-04-10 22:20:07'),(24,1,NULL,'',738.00,55.00,0.00,'cash',1000.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 12, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 35}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 95}]','2026-04-10 22:28:10'),(25,1,NULL,'',144.99,60.00,144.99,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 94}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 68}]','2026-04-10 22:29:47'),(26,1,NULL,'',229.98,30.00,0.00,'cash',300.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 68}]','2026-04-10 22:30:13'),(27,1,NULL,'',150.00,0.00,0.00,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}]','2026-04-10 22:30:46'),(28,1,NULL,'',50.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 90}]','2026-04-10 22:31:57'),(29,1,NULL,'',50.00,0.00,0.00,'cash',200.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 90}]','2026-04-10 22:32:04'),(30,1,NULL,'',54.00,0.00,0.00,'cash',100.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 23}]','2026-04-10 22:32:28'),(31,1,NULL,'',1100.80,360.00,19.00,'cash',1500.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 20, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 64}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 4, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 88}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 4, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 92}]','2026-04-10 22:34:28'),(32,1,NULL,'',101.99,30.00,18.00,'cash',110.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 92}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 64}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 88}]','2026-04-10 22:35:22'),(33,1,NULL,'',3260.00,3110.00,10.00,'cash',3500.00,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 10, \"discount_type\": \"fixed\", \"max_stock\": 87}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 2}]','2026-04-10 22:49:26'),(34,1,NULL,'',54.00,0.00,0.00,'card',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 22}]','2026-04-10 22:50:07'),(35,1,NULL,'',3373.97,3075.00,0.00,'transfer',0.00,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 97}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 43}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 85}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 83}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 21}]','2026-04-10 22:50:54'),(36,1,NULL,'',1263.99,1070.00,0.00,'cash',0.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 40}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 82}, {\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 96}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 84}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-04-10 22:59:15'),(37,1,NULL,'',30.00,15.00,0.00,'cash',100.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 83}]','2026-04-10 23:00:00'),(38,1,NULL,'Smith',1060.00,1015.00,0.00,'cash',1060.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 82}, {\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 95}]','2026-04-10 23:08:57'),(39,1,NULL,'Smith',540.00,0.00,0.00,'cash',1000.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 10, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 19}]','2026-04-10 23:10:14'),(40,1,NULL,'Smith',270.00,0.00,0.00,'cash',500.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 5, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 9}]','2026-04-10 23:10:37'),(41,1,NULL,'',55.00,0.00,0.00,'cash',100.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 6}]','2026-04-11 00:01:03'),(42,3,NULL,'',110.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 5}]','2026-04-11 00:20:55'),(43,1,NULL,'',50.00,40.00,0.00,'cash',0.00,'[{\"product_id\": 10, \"name\": \"Red Jackets\", \"sku\": \"JAC-002\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 40}]','2026-04-11 00:43:07'),(44,1,NULL,'',410.00,320.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 6, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}]','2026-04-12 00:28:33'),(45,1,NULL,'',265000.00,191200.00,5000.00,'cash',265000.00,'[{\"product_id\": 34, \"name\": \"RICE - MTK\", \"sku\": \"RMTK\", \"price\": 135000, \"cost_price\": 95000, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-04-12 01:21:37'),(46,1,NULL,'',270000.00,191200.00,6000.00,'cash',270000.00,'[{\"product_id\": 34, \"name\": \"RICE - MTK\", \"sku\": \"RMTK\", \"price\": 138000, \"cost_price\": 95600, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 48}]','2026-04-12 01:37:46'),(47,1,NULL,'',100.00,80.00,0.00,'cash',500.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 999}]','2026-04-12 01:43:34'),(48,1,NULL,'',160.00,120.00,0.00,'cash',160.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 999}]','2026-04-12 08:52:08'),(49,1,1,'John Snoq',100.00,80.00,0.00,'partial',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 997}]','2026-04-12 21:09:30'),(50,1,1,'John Snoq',150.00,120.00,0.00,'partial',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 995}]','2026-04-12 21:13:26'),(51,1,1,'John Snoq',50.00,40.00,0.00,'credit',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 992}]','2026-04-12 21:15:19'),(52,1,2,'ABC Store',5095.00,3259.95,0.00,'partial',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 60, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 992}, {\"product_id\": 20, \"name\": \"Black Jackets2\", \"sku\": \"JT-BL-M2\", \"price\": 50, \"cost_price\": 40.95, \"quantity\": 21, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 21}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 19, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1003}]','2026-04-12 21:24:03'),(53,1,NULL,'',315.00,120.00,0.00,'cash',315.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 932}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 991}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 984}, {\"product_id\": 12, \"name\": \"Blue T-Shirt1\", \"sku\": \"TS-BLU-M1\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1003}]','2026-04-12 22:04:17'),(54,1,NULL,'Sam',105.00,40.00,0.00,'cash',105.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 982}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 989}]','2026-04-12 22:06:15'),(55,3,1,'John Snoq',155.00,80.00,0.00,'credit',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 931}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 988}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 981}]','2026-04-12 22:38:57'),(56,1,NULL,'',250.00,240.00,50.00,'cash',250.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 6, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 930}]','2026-04-18 05:33:41'),(57,1,NULL,'',200.00,65.00,10.00,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 25, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 994}, {\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 924}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 986}, {\"product_id\": 12, \"name\": \"Blue T-Shirt1\", \"sku\": \"TS-BLU-M1\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1002}]','2026-04-18 05:34:08');
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` longtext NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=672 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (81,'smtp_password','unhymrfsdnyiarqo','2026-04-18 05:17:33'),(105,'smtp_server','smtp.gmail.com','2026-04-18 05:18:11'),(106,'smtp_port','587','2026-04-18 05:18:11'),(107,'smtp_username','kumarar.cumdy@gmail.com','2026-04-18 05:18:11'),(108,'alert_email','kumarar.cumdy2017@gmail.com','2026-04-18 05:18:11'),(109,'low_stock_threshold','6','2026-04-18 05:18:11'),(112,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-17 08:44:36'),(113,'session_timeout','300','2026-04-18 05:17:54'),(120,'currency_symbol','฿','2026-04-18 05:18:03'),(121,'shop_name','Monster','2026-04-18 05:18:31'),(122,'shop_icon','🏪','2026-04-18 05:18:31');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_history`
--

DROP TABLE IF EXISTS `stock_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `quantity_change` int NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `note` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `stock_history_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_history`
--

LOCK TABLES `stock_history` WRITE;
/*!40000 ALTER TABLE `stock_history` DISABLE KEYS */;
INSERT INTO `stock_history` VALUES (1,1,50,'initial','Initial stock','2026-03-28 05:25:15'),(2,2,40,'initial','Initial stock','2026-03-28 05:26:06'),(3,3,100,'initial','Initial stock','2026-03-28 05:27:41'),(4,1,-2,'sale','Sale transaction','2026-03-28 05:33:53'),(5,4,50,'initial','Initial stock','2026-03-28 05:58:06'),(6,4,25,'import','E2E test stock import','2026-03-28 05:58:06'),(7,4,-2,'sale','Sale by test_sales','2026-03-28 05:58:06'),(8,3,-10,'sale','Sale by john','2026-03-28 06:26:29'),(9,5,10,'initial','Initial stock','2026-03-28 06:28:34'),(10,5,-5,'sale','Sale by john','2026-03-28 06:28:59'),(11,1,-3,'sale','Sale by john','2026-03-28 06:45:41'),(12,5,-5,'sale','Sale by jo jo','2026-03-28 22:16:48'),(13,4,-5,'sale','Sale by admin','2026-03-28 22:19:41'),(14,5,24,'import','added stock on 20260329','2026-03-28 22:21:39'),(15,1,-4,'sale','Sale by admin','2026-03-28 22:29:50'),(16,5,-1,'sale','Sale by admin','2026-03-28 22:30:15'),(17,1,-1,'sale','Sale by admin','2026-03-28 22:30:15'),(18,2,-1,'sale','Sale by admin','2026-03-28 22:30:15'),(19,5,-3,'sale','Sale by admin','2026-03-28 22:48:53'),(20,1,-2,'sale','Sale by admin','2026-03-28 22:48:53'),(21,5,-1,'sale','Sale by john','2026-03-28 23:04:06'),(22,5,-1,'sale','Sale by john','2026-03-28 23:05:23'),(23,2,-1,'sale','Sale by john','2026-03-28 23:05:46'),(24,5,-2,'sale','Sale by admin','2026-03-28 23:07:44'),(26,7,100,'initial','Initial stock','2026-03-28 23:31:06'),(27,8,100,'initial','Initial stock','2026-03-28 23:36:01'),(28,7,-2,'sale','Sale by admin','2026-03-28 23:36:27'),(29,8,-2,'sale','Sale by admin','2026-03-28 23:36:27'),(30,5,-2,'sale','Sale by admin','2026-03-28 23:51:29'),(31,5,-2,'sale','Sale by admin','2026-03-29 00:04:24'),(32,7,-2,'sale','Sale by admin','2026-03-29 20:27:38'),(33,1,-1,'sale','Sale by admin','2026-03-29 20:58:13'),(34,2,-8,'sale','Sale by admin','2026-03-29 20:58:13'),(35,8,-95,'sale','Sale by admin','2026-03-29 20:58:13'),(36,5,-10,'sale','Sale by admin','2026-03-29 20:58:13'),(37,2,-27,'sale','Sale by admin','2026-03-29 21:30:40'),(38,5,-2,'sale','Sale by admin','2026-04-02 06:00:37'),(39,1,-1,'sale','Sale by admin','2026-04-10 22:15:48'),(40,7,-1,'sale','Sale by admin','2026-04-10 22:15:48'),(41,1,-1,'sale','Sale by admin','2026-04-10 22:20:07'),(42,1,-12,'sale','Sale by admin','2026-04-10 22:28:10'),(43,8,-1,'sale','Sale by admin','2026-04-10 22:28:10'),(44,7,-1,'sale','Sale by admin','2026-04-10 22:28:10'),(45,2,-3,'sale','Sale by admin','2026-04-10 22:29:47'),(46,7,-2,'sale','Sale by admin','2026-04-10 22:29:47'),(47,4,-2,'sale','Sale by admin','2026-04-10 22:29:47'),(48,2,-3,'sale','Sale by admin','2026-04-10 22:30:13'),(49,4,-2,'sale','Sale by admin','2026-04-10 22:30:13'),(50,2,-3,'sale','Sale by admin','2026-04-10 22:30:46'),(51,3,-1,'sale','Sale by admin','2026-04-10 22:31:57'),(52,3,-1,'sale','Sale by admin','2026-04-10 22:32:04'),(53,1,-1,'sale','Sale by admin','2026-04-10 22:32:28'),(54,4,-20,'sale','Sale by admin','2026-04-10 22:34:28'),(55,3,-4,'sale','Sale by admin','2026-04-10 22:34:28'),(56,7,-4,'sale','Sale by admin','2026-04-10 22:34:28'),(57,7,-1,'sale','Sale by admin','2026-04-10 22:35:22'),(58,4,-1,'sale','Sale by admin','2026-04-10 22:35:22'),(59,3,-1,'sale','Sale by admin','2026-04-10 22:35:22'),(60,9,100,'initial','Initial stock','2026-04-10 22:48:10'),(61,9,-3,'sale','Sale by admin','2026-04-10 22:49:26'),(62,7,-2,'sale','Sale by admin','2026-04-10 22:49:26'),(63,8,-2,'sale','Sale by admin','2026-04-10 22:49:26'),(64,1,-1,'sale','Sale by admin','2026-04-10 22:50:07'),(65,9,-3,'sale','Sale by admin','2026-04-10 22:50:54'),(66,4,-3,'sale','Sale by admin','2026-04-10 22:50:54'),(67,7,-2,'sale','Sale by admin','2026-04-10 22:50:54'),(68,3,-1,'sale','Sale by admin','2026-04-10 22:50:54'),(69,1,-1,'sale','Sale by admin','2026-04-10 22:50:54'),(70,9,2,'return','Refund for sale #33 by admin','2026-04-10 22:52:57'),(71,7,1,'return','Refund for sale #33 by admin','2026-04-10 22:52:57'),(72,8,1,'return','Refund for sale #33 by admin','2026-04-10 22:52:57'),(73,4,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(74,3,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(75,9,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(76,7,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(77,8,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(78,1,-1,'sale','Sale by admin','2026-04-10 22:59:15'),(79,7,-1,'sale','Sale by admin','2026-04-10 23:00:00'),(80,7,-1,'sale','Sale by admin','2026-04-10 23:08:57'),(81,9,-1,'sale','Sale by admin','2026-04-10 23:08:57'),(82,1,-10,'sale','Sale by admin','2026-04-10 23:10:14'),(83,1,-5,'sale','Sale by admin','2026-04-10 23:10:37'),(84,10,40,'import','','2026-04-10 23:37:34'),(85,1,2,'import','','2026-04-10 23:38:59'),(86,1,-1,'sale','Sale by admin','2026-04-11 00:01:03'),(87,1,-2,'sale','Sale by john','2026-04-11 00:20:55'),(88,10,-1,'sale','Sale by admin','2026-04-11 00:43:07'),(89,5,1000,'import','incoming instock','2026-04-11 20:38:57'),(90,11,1000,'import','incoming instock','2026-04-11 20:38:57'),(91,1,1000,'import','incoming instock','2026-04-11 20:38:57'),(92,2,1000,'import','incoming instock','2026-04-11 20:38:57'),(93,12,1000,'import','incoming instock','2026-04-11 20:38:57'),(94,13,1000,'import','incoming instock','2026-04-11 20:38:57'),(95,8,1000,'import','incoming instock','2026-04-11 20:38:57'),(96,14,1000,'import','incoming instock','2026-04-11 20:38:57'),(97,29,100,'initial','Initial stock','2026-04-11 20:52:11'),(98,20,1,'purchase','PO #1 received by admin','2026-04-11 23:37:36'),(99,10,10,'purchase','PO #1 received by admin','2026-04-11 23:37:36'),(100,14,1000,'purchase','PO #2 received by admin','2026-04-11 23:42:12'),(101,30,10,'initial','Initial stock','2026-04-11 23:59:28'),(102,31,10,'initial','Initial stock | Cost: 200.00','2026-04-12 00:11:30'),(103,5,-6,'sale','Sale by admin','2026-04-12 00:28:33'),(104,11,-1,'sale','Sale by admin','2026-04-12 00:28:33'),(105,8,-1,'sale','Sale by admin','2026-04-12 00:28:33'),(106,32,100,'initial','Initial stock | Cost: 10.00','2026-04-12 00:52:03'),(107,33,20,'initial','Initial stock | Cost: 10.00','2026-04-12 00:55:57'),(108,20,20,'purchase','PO #3 received by admin | Cost: 40.00 → 40.95 (PO unit cost: 41.00)','2026-04-12 01:02:58'),(109,34,20,'initial','Initial stock | Cost: 95000.00','2026-04-12 01:12:34'),(110,34,30,'purchase','PO #4 received by admin | Cost: 95000.00 → 95600.00 (PO unit cost: 96000.00)','2026-04-12 01:19:00'),(111,34,-2,'sale','Sale by admin','2026-04-12 01:21:37'),(112,34,-2,'sale','Sale by admin','2026-04-12 01:37:46'),(113,11,-2,'sale','Sale by admin','2026-04-12 01:43:34'),(114,5,-2,'sale','Sale by admin','2026-04-12 08:52:08'),(115,8,-1,'sale','Sale by admin','2026-04-12 08:52:08'),(116,11,-2,'sale','Sale by admin','2026-04-12 21:09:30'),(117,11,-3,'sale','Sale by admin','2026-04-12 21:13:26'),(118,11,-1,'sale','Sale by admin','2026-04-12 21:15:19'),(119,5,-60,'sale','Sale by admin','2026-04-12 21:24:03'),(120,20,-21,'sale','Sale by admin','2026-04-12 21:24:03'),(121,1,-19,'sale','Sale by admin','2026-04-12 21:24:03'),(122,5,-1,'sale','Sale by admin','2026-04-12 22:04:17'),(123,11,-2,'sale','Sale by admin','2026-04-12 22:04:17'),(124,1,-2,'sale','Sale by admin','2026-04-12 22:04:17'),(125,12,-1,'sale','Sale by admin','2026-04-12 22:04:17'),(126,1,-1,'sale','Sale by admin','2026-04-12 22:06:15'),(127,11,-1,'sale','Sale by admin','2026-04-12 22:06:15'),(128,5,-1,'sale','Sale by john','2026-04-12 22:38:57'),(129,11,-1,'sale','Sale by john','2026-04-12 22:38:57'),(130,1,-1,'sale','Sale by john','2026-04-12 22:38:57'),(131,35,12,'initial','Initial stock | Cost: 12.00','2026-04-17 09:03:48'),(132,1,6,'return','Refund for sale #39 by admin','2026-04-17 10:26:35'),(133,5,-6,'sale','Sale by admin','2026-04-18 05:33:41'),(134,2,-1,'sale','Sale by admin','2026-04-18 05:34:08'),(135,5,-1,'sale','Sale by admin','2026-04-18 05:34:08'),(136,1,-1,'sale','Sale by admin','2026-04-18 05:34:08'),(137,12,-1,'sale','Sale by admin','2026-04-18 05:34:08');
/*!40000 ALTER TABLE `stock_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `contact_person` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` text,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'MoMo','Jame','jame@gmail.com','+66941104272','Bangkok','Souvinior Shop','2026-04-11 23:30:28'),(2,'Myat Tin Kyi','U Ba','','','','','2026-04-12 01:09:09');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','admin','Administrator','2026-03-28 05:36:50'),(3,'john','b4b597c714a8f49103da4dab0266af0ee0ae4f8575250a84855c3d76941cd422','user','john','2026-03-28 06:01:44'),(4,'jo jo','0776180dc120b60d4f3e065d47ee3eb22c74585fe39dd66774850583b5c87ee9','user','jojo','2026-03-28 06:48:01');
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

-- Dump completed on 2026-04-18 14:37:24
