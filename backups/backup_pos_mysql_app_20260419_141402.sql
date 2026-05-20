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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'John Snow','','','','wholesale',1000.00,0.00,'','2026-04-12 21:08:22',1),(2,'ABC Store','','','','wholesale',10000.00,0.00,'','2026-04-12 21:20:19',1),(3,'Shine','8437204','shine@gmail.com','','wholesale',1000.00,500.00,'','2026-04-19 05:11:03',2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sale_id` (`sale_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (1,49,1,100.00,100.00,'paid','2026-04-14','2026-04-12 21:09:30',1),(2,50,1,150.00,150.00,'paid','2026-04-16','2026-04-12 21:13:26',1),(3,51,1,50.00,50.00,'paid','2026-04-14','2026-04-12 21:15:19',1),(4,52,2,5095.00,5095.00,'paid',NULL,'2026-04-12 21:24:03',1),(5,55,1,155.00,155.00,'paid',NULL,'2026-04-12 22:38:57',1),(6,62,3,529.20,29.20,'partial',NULL,'2026-04-19 05:11:44',2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `invoice_id` (`invoice_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,1,10.00,'cash',1,'Initial payment for sale #49','2026-04-12 21:09:30',1),(2,1,2,50.00,'cash',1,'Initial payment for sale #50','2026-04-12 21:13:26',1),(3,1,3,50.00,'cash',1,'','2026-04-12 21:17:33',1),(4,1,2,100.00,'card',1,'second payment','2026-04-12 21:18:54',1),(5,2,4,2000.00,'cash',1,'Initial payment for sale #52','2026-04-12 21:24:03',1),(6,2,4,2000.00,'cash',1,'','2026-04-17 09:55:31',1),(7,2,4,500.00,'cash',1,'','2026-04-17 10:06:05',1),(8,2,4,595.00,'cash',1,'final payment','2026-04-18 05:28:43',1),(9,1,NULL,245.00,'cash',1,'final payment','2026-04-18 05:29:39',1),(10,3,6,29.20,'cash',8,'Initial payment for sale #62','2026-04-19 05:11:44',2);
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `po_items`
--

LOCK TABLES `po_items` WRITE;
/*!40000 ALTER TABLE `po_items` DISABLE KEYS */;
INSERT INTO `po_items` VALUES (1,1,20,1,1,40.00,'2026-04-11 23:32:24'),(2,1,10,10,10,40.00,'2026-04-11 23:32:24'),(3,2,14,1000,1000,42.00,'2026-04-11 23:41:34'),(4,3,20,50,50,41.00,'2026-04-12 01:02:36'),(5,4,34,30,30,96000.00,'2026-04-12 01:18:20'),(6,5,37,3,0,30.00,'2026-04-19 05:10:30');
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
  `shop_id` int DEFAULT NULL,
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
INSERT INTO `product_audit_log` VALUES (1,10,1,'admin','duplicate','source','5','10','2026-04-10 23:36:52',1),(2,10,1,'admin','edit','name','Black Jackets (Copy)','Red Jackets','2026-04-10 23:37:12',1),(3,10,1,'admin','edit','sku','JAC-001','JAC-002','2026-04-10 23:37:12',1),(4,1,1,'admin','edit','price','54.0','55.0','2026-04-10 23:39:37',1),(5,2,1,'admin','edit','cost_price','0.0','25.0','2026-04-11 22:46:13',1),(6,34,1,'admin','edit','price','135000.0','138000.0','2026-04-12 01:25:55',1);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_sku_shop` (`sku`,`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Blue T-Shirt','Shirts',0.00,55.00,984,'TS-BLU-M','T-Shirt Blues M Size','2026-03-28 05:25:15',NULL,1),(2,'Blue T-Shirt','Shirts',25.00,50.00,992,'TS-BLU-L','T-Shirt Blue L Size','2026-03-28 05:26:06',NULL,1),(3,'White T-Shirt','Shirts',0.00,50.00,81,'TS-WH-S','T-Shirt White S size','2026-03-28 05:27:41',NULL,1),(4,'Test Blue Jeans','Pants',15.00,39.99,39,'TEST-JEANS-001','Test product for E2E testing','2026-03-28 05:58:06',NULL,1),(5,'Black Jackets','Jackets',40.00,50.00,922,'JT-BL-M','Jacket black M size','2026-03-28 06:28:34',NULL,1),(7,'Sock','Other',15.00,30.00,81,'SOCK','Socks','2026-03-28 23:31:06',NULL,1),(8,'Hat','Hats',40.00,60.00,998,'Hats','','2026-03-28 23:36:01',NULL,1),(9,'TEST-STUFF','Accessories',1000.00,1030.00,94,'TS','','2026-04-10 22:48:10',5,1),(10,'Red Jackets','Jackets',40.00,50.00,49,'JAC-002','Jacket black M size','2026-04-10 23:36:52',NULL,1),(11,'Black Jackets1','Jackets',40.00,50.00,986,'JT-BL-M1','Jacket black M size','2026-04-11 20:36:34',NULL,1),(12,'Blue T-Shirt1','Shirts',0.00,55.00,1001,'TS-BLU-M1','T-Shirt Blues M Size','2026-04-11 20:36:34',NULL,1),(13,'Blue T-Shirt1','Shirts',0.00,50.00,994,'TS-BLU-L1','T-Shirt Blue L Size','2026-04-11 20:36:34',NULL,1),(14,'Hat1','Hats',41.00,60.00,2000,'Hats1','','2026-04-11 20:36:34',NULL,1),(15,'Red Jackets1','Jackets',40.00,50.00,39,'JAC-0021','Jacket black M size','2026-04-11 20:36:34',NULL,1),(16,'Sock1','Other',15.00,30.00,81,'SOCK1','Socks','2026-04-11 20:36:34',NULL,1),(17,'TEST-STUFF1','Accessories',1000.00,1030.00,94,'TS1','','2026-04-11 20:36:34',5,1),(18,'Test Blue Jeans1','Pants',15.00,39.99,39,'TEST1-JEANS-001','Test product for E2E testing','2026-04-11 20:36:34',NULL,1),(19,'White T-Shirt1','Shirts',0.00,50.00,81,'TS-WH-S1','T-Shirt White S size','2026-04-11 20:36:34',NULL,1),(20,'Black Jackets2','Jackets',41.00,50.00,30,'JT-BL-M2','Jacket black M size','2026-04-11 20:40:31',NULL,1),(21,'Blue T-Shirt2','Shirts',0.00,55.00,3,'TS-BLU-M2','T-Shirt Blues M Size','2026-04-11 20:40:31',NULL,1),(22,'Blue T-Shirt2','Shirts',0.00,50.00,0,'TS-BLU-L2','T-Shirt Blue L Size','2026-04-11 20:40:31',NULL,1),(23,'Hat2','Hats',40.00,60.00,0,'Hats2','','2026-04-11 20:40:31',NULL,1),(24,'Red Jackets2','Jackets',40.00,50.00,39,'JAC-0022','Jacket black M size','2026-04-11 20:40:31',NULL,1),(25,'Sock2','Other',25.00,30.00,82,'SOCK2','Socks','2026-04-11 20:40:31',NULL,1),(26,'TEST-STUFF2','Accessories',2000.00,2030.00,94,'TS2','','2026-04-11 20:40:31',5,1),(27,'Test Blue Jeans2','Pants',25.00,39.99,39,'TEST2-JEANS-002','Test product for E2E testing','2026-04-11 20:40:31',NULL,1),(28,'White T-Shirt2','Shirts',0.00,50.00,82,'TS-WH-S2','T-Shirt White S size','2026-04-11 20:40:31',NULL,1),(29,'Hand Chain','Suviniour',5.00,10.00,100,'SR-HC','','2026-04-11 20:52:11',5,1),(30,'TEST123','Suviniour',20.00,28.00,10,'TS123','incoming stock1','2026-04-11 23:59:28',5,1),(31,'Tes15','Suviniour',200.00,300.00,10,'tes15','incoming stock','2026-04-12 00:11:30',5,1),(32,'Done2','Suviniour',10.00,30.00,100,'Don','','2026-04-12 00:52:03',5,1),(33,'Don3','Suviniour',10.00,40.00,20,'Don3','','2026-04-12 00:55:57',5,1),(34,'RICE - MTK','Basic needs',95600.00,138000.00,46,'RMTK','incoming stock ','2026-04-12 01:12:34',5,1),(35,'fasdfa','Shirts',12.00,2.00,12,'SHI-001','','2026-04-17 09:03:48',NULL,1),(36,'k','Jackets',10.00,20.00,20,'k','','2026-04-18 06:08:58',NULL,1),(37,'Black Shirt','Shirts',30.00,60.00,9,'BS','','2026-04-19 04:07:31',NULL,2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,1,'received',440.00,'',1,'2026-04-11 23:32:24','2026-04-11 23:37:36',1),(2,1,'received',42000.00,'',1,'2026-04-11 23:41:34','2026-04-11 23:42:12',1),(3,1,'received',2050.00,'',1,'2026-04-12 01:02:36','2026-04-19 03:09:53',1),(4,2,'received',2880000.00,'',1,'2026-04-12 01:18:20','2026-04-12 01:19:00',1),(5,3,'ordered',90.00,'',8,'2026-04-19 05:10:30',NULL,2);
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
  `shop_id` int DEFAULT NULL,
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
INSERT INTO `sale_returns` VALUES (1,33,1,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"price\": 1030, \"quantity\": 2}, {\"product_id\": 7, \"name\": \"Sock\", \"price\": 30, \"quantity\": 1}, {\"product_id\": 8, \"name\": \"Hat\", \"price\": 60, \"quantity\": 1}]',2150.00,'','2026-04-10 22:52:57',1),(2,39,1,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 6}]',324.00,'','2026-04-17 10:26:35',1);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,NULL,NULL,'',108.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 2, \"max_stock\": 50}]','2026-03-28 05:33:53',1),(3,3,NULL,'',500.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"price\": 50, \"quantity\": 10, \"max_stock\": 100}]','2026-03-28 06:26:29',1),(4,3,NULL,'',250.00,200.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"price\": 50, \"quantity\": 5, \"max_stock\": 10}]','2026-03-28 06:28:59',1),(5,3,NULL,'',162.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"price\": 54, \"quantity\": 3, \"max_stock\": 48}]','2026-03-28 06:45:41',1),(6,4,NULL,'',250.00,200.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 5, \"max_stock\": 5}]','2026-03-28 22:16:48',1),(7,1,NULL,'',199.95,75.00,0.00,'cash',0.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 5, \"max_stock\": 73}]','2026-03-28 22:19:41',1),(8,1,NULL,'',216.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 4, \"max_stock\": 45}]','2026-03-28 22:29:50',1),(9,1,NULL,'',154.00,40.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"max_stock\": 24}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"max_stock\": 41}, {\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"max_stock\": 40}]','2026-03-28 22:30:15',1),(10,1,NULL,'',192.00,120.00,66.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 3, \"discount\": 12, \"discount_type\": \"fixed\", \"max_stock\": 23}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 2, \"discount\": 50, \"discount_type\": \"percent\", \"max_stock\": 40}]','2026-03-28 22:48:53',1),(11,3,NULL,'',40.50,40.00,9.50,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 19, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-03-28 23:04:06',1),(12,3,NULL,'',43.50,40.00,6.50,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 13, \"discount_type\": \"percent\", \"max_stock\": 19}]','2026-03-28 23:05:23',1),(13,3,NULL,'',50.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 39}]','2026-03-28 23:05:46',1),(14,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 18}]','2026-03-28 23:07:44',1),(15,1,NULL,'',180.00,110.00,0.00,'cash',0.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}]','2026-03-28 23:36:27',1),(16,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 16}]','2026-03-28 23:51:29',1),(17,1,NULL,'',100.00,80.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 14}]','2026-03-29 00:04:24',1),(18,1,NULL,'',58.80,30.00,1.20,'cash',0.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 2, \"discount_type\": \"percent\", \"max_stock\": 98}]','2026-03-29 20:27:38',1),(19,1,NULL,'',6654.00,4200.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 38}, {\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 8, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 38}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 95, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 98}, {\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 10, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 12}]','2026-03-29 20:58:13',1),(20,1,NULL,'',1350.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 27, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 30}]','2026-03-29 21:30:40',1),(21,1,NULL,'',90.00,80.00,10.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 10, \"discount_type\": \"percent\", \"max_stock\": 2}]','2026-04-02 06:00:37',1),(22,1,NULL,'',84.00,15.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 37}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 96}]','2026-04-10 22:15:48',1),(23,1,NULL,'',44.00,0.00,10.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 10, \"discount_type\": \"fixed\", \"max_stock\": 36}]','2026-04-10 22:20:07',1),(24,1,NULL,'',738.00,55.00,0.00,'cash',1000.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 12, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 35}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 95}]','2026-04-10 22:28:10',1),(25,1,NULL,'',144.99,60.00,144.99,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 94}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 68}]','2026-04-10 22:29:47',1),(26,1,NULL,'',229.98,30.00,0.00,'cash',300.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 68}]','2026-04-10 22:30:13',1),(27,1,NULL,'',150.00,0.00,0.00,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 0, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 3}]','2026-04-10 22:30:46',1),(28,1,NULL,'',50.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 90}]','2026-04-10 22:31:57',1),(29,1,NULL,'',50.00,0.00,0.00,'cash',200.00,'[{\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 90}]','2026-04-10 22:32:04',1),(30,1,NULL,'',54.00,0.00,0.00,'cash',100.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 23}]','2026-04-10 22:32:28',1),(31,1,NULL,'',1100.80,360.00,19.00,'cash',1500.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 20, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 64}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 4, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 88}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 4, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 92}]','2026-04-10 22:34:28',1),(32,1,NULL,'',101.99,30.00,18.00,'cash',110.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 92}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 64}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 88}]','2026-04-10 22:35:22',1),(33,1,NULL,'',3260.00,3110.00,10.00,'cash',3500.00,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 100}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 10, \"discount_type\": \"fixed\", \"max_stock\": 87}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 2}]','2026-04-10 22:49:26',1),(34,1,NULL,'',54.00,0.00,0.00,'card',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 22}]','2026-04-10 22:50:07',1),(35,1,NULL,'',3373.97,3075.00,0.00,'transfer',0.00,'[{\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 97}, {\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 43}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 85}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 83}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 21}]','2026-04-10 22:50:54',1),(36,1,NULL,'',1263.99,1070.00,0.00,'cash',0.00,'[{\"product_id\": 4, \"name\": \"Test Blue Jeans\", \"sku\": \"TEST-JEANS-001\", \"price\": 39.99, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 40}, {\"product_id\": 3, \"name\": \"White T-Shirt\", \"sku\": \"TS-WH-S\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 82}, {\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 96}, {\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 84}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-04-10 22:59:15',1),(37,1,NULL,'',30.00,15.00,0.00,'cash',100.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 83}]','2026-04-10 23:00:00',1),(38,1,NULL,'Smith',1060.00,1015.00,0.00,'cash',1060.00,'[{\"product_id\": 7, \"name\": \"Sock\", \"sku\": \"SOCK\", \"price\": 30, \"cost_price\": 15, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 82}, {\"product_id\": 9, \"name\": \"TEST-STUFF\", \"sku\": \"TS\", \"price\": 1030, \"cost_price\": 1000, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 95}]','2026-04-10 23:08:57',1),(39,1,NULL,'Smith',540.00,0.00,0.00,'cash',1000.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 10, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 19}]','2026-04-10 23:10:14',1),(40,1,NULL,'Smith',270.00,0.00,0.00,'cash',500.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 54, \"cost_price\": 0, \"quantity\": 5, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 9}]','2026-04-10 23:10:37',1),(41,1,NULL,'',55.00,0.00,0.00,'cash',100.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 6}]','2026-04-11 00:01:03',1),(42,3,NULL,'',110.00,0.00,0.00,'cash',0.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 5}]','2026-04-11 00:20:55',1),(43,1,NULL,'',50.00,40.00,0.00,'cash',0.00,'[{\"product_id\": 10, \"name\": \"Red Jackets\", \"sku\": \"JAC-002\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 40}]','2026-04-11 00:43:07',1),(44,1,NULL,'',410.00,320.00,0.00,'cash',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 6, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}]','2026-04-12 00:28:33',1),(45,1,NULL,'',265000.00,191200.00,5000.00,'cash',265000.00,'[{\"product_id\": 34, \"name\": \"RICE - MTK\", \"sku\": \"RMTK\", \"price\": 135000, \"cost_price\": 95000, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 20}]','2026-04-12 01:21:37',1),(46,1,NULL,'',270000.00,191200.00,6000.00,'cash',270000.00,'[{\"product_id\": 34, \"name\": \"RICE - MTK\", \"sku\": \"RMTK\", \"price\": 138000, \"cost_price\": 95600, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 48}]','2026-04-12 01:37:46',1),(47,1,NULL,'',100.00,80.00,0.00,'cash',500.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 999}]','2026-04-12 01:43:34',1),(48,1,NULL,'',160.00,120.00,0.00,'cash',160.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"percent\", \"max_stock\": 1000}, {\"product_id\": 8, \"name\": \"Hat\", \"sku\": \"Hats\", \"price\": 60, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 999}]','2026-04-12 08:52:08',1),(49,1,1,'John Snoq',100.00,80.00,0.00,'partial',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 997}]','2026-04-12 21:09:30',1),(50,1,1,'John Snoq',150.00,120.00,0.00,'partial',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 3, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 995}]','2026-04-12 21:13:26',1),(51,1,1,'John Snoq',50.00,40.00,0.00,'credit',0.00,'[{\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 992}]','2026-04-12 21:15:19',1),(52,1,2,'ABC Store',5095.00,3259.95,0.00,'partial',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 60, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 992}, {\"product_id\": 20, \"name\": \"Black Jackets2\", \"sku\": \"JT-BL-M2\", \"price\": 50, \"cost_price\": 40.95, \"quantity\": 21, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 21}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 19, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1003}]','2026-04-12 21:24:03',1),(53,1,NULL,'',315.00,120.00,0.00,'cash',315.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 932}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 991}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 2, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 984}, {\"product_id\": 12, \"name\": \"Blue T-Shirt1\", \"sku\": \"TS-BLU-M1\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1003}]','2026-04-12 22:04:17',1),(54,1,NULL,'Sam',105.00,40.00,0.00,'cash',105.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 982}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 989}]','2026-04-12 22:06:15',1),(55,3,1,'John Snoq',155.00,80.00,0.00,'credit',0.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 931}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 988}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 981}]','2026-04-12 22:38:57',1),(56,1,NULL,'',250.00,240.00,50.00,'cash',250.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 6, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 930}]','2026-04-18 05:33:41',1),(57,1,NULL,'',200.00,65.00,10.00,'cash',200.00,'[{\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 25, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 994}, {\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 924}, {\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 986}, {\"product_id\": 12, \"name\": \"Blue T-Shirt1\", \"sku\": \"TS-BLU-M1\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1002}]','2026-04-18 05:34:08',1),(58,7,NULL,'',100.00,80.00,0.00,'cash',100.00,'[{\"product_id\": 5, \"name\": \"Black Jackets\", \"sku\": \"JT-BL-M\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 923}, {\"product_id\": 11, \"name\": \"Black Jackets1\", \"sku\": \"JT-BL-M1\", \"price\": 50, \"cost_price\": 40, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 987}]','2026-04-19 03:58:22',1),(59,7,NULL,'',105.00,25.00,0.00,'cash',105.00,'[{\"product_id\": 1, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-M\", \"price\": 55, \"cost_price\": 0, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 985}, {\"product_id\": 2, \"name\": \"Blue T-Shirt\", \"sku\": \"TS-BLU-L\", \"price\": 50, \"cost_price\": 25, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 993}]','2026-04-19 04:05:24',1),(60,8,NULL,'',240.00,120.00,0.00,'cash',0.00,'[{\"product_id\": 37, \"name\": \"Black Shirt\", \"sku\": \"BS\", \"price\": 60, \"cost_price\": 30, \"quantity\": 4, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 30}]','2026-04-19 04:07:41',2),(61,8,NULL,'',480.00,240.00,0.00,'cash',480.00,'[{\"product_id\": 37, \"name\": \"Black Shirt\", \"sku\": \"BS\", \"price\": 60, \"cost_price\": 30, \"quantity\": 8, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 26}]','2026-04-19 05:09:01',2),(62,8,3,'Shine',529.20,270.00,10.80,'partial',0.00,'[{\"product_id\": 37, \"name\": \"Black Shirt\", \"sku\": \"BS\", \"price\": 60, \"cost_price\": 30, \"quantity\": 9, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 18}]','2026-04-19 05:11:44',2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_key_shop` (`key`,`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2675 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (81,'smtp_password','unhymrfsdnyiarqo','2026-04-18 05:17:33',NULL),(105,'smtp_server','smtp.gmail.com','2026-04-18 05:18:11',NULL),(106,'smtp_port','587','2026-04-18 05:18:11',NULL),(107,'smtp_username','kumarar.cumdy@gmail.com','2026-04-18 05:18:11',NULL),(108,'alert_email','kumarar.cumdy2017@gmail.com','2026-04-18 05:18:11',NULL),(109,'low_stock_threshold','6','2026-04-18 05:18:11',NULL),(112,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-17 08:44:36',NULL),(113,'session_timeout','1800','2026-04-18 05:56:15',NULL),(120,'currency_symbol','฿','2026-04-18 05:18:03',NULL),(121,'shop_name','Monster','2026-04-18 05:18:31',NULL),(122,'shop_icon','🏪','2026-04-18 05:18:31',NULL),(2059,'session_timeout','1800','2026-04-19 04:48:33',NULL),(2060,'smtp_server','','2026-04-19 04:48:33',NULL),(2061,'smtp_port','587','2026-04-19 04:48:33',NULL),(2062,'smtp_username','','2026-04-19 04:48:33',NULL),(2063,'smtp_password','','2026-04-19 04:48:33',NULL),(2064,'alert_email','','2026-04-19 04:48:33',NULL),(2065,'low_stock_threshold','5','2026-04-19 04:48:33',NULL),(2066,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:48:33',NULL),(2067,'session_timeout','1800','2026-04-19 04:48:34',NULL),(2068,'smtp_server','','2026-04-19 04:48:34',NULL),(2069,'smtp_port','587','2026-04-19 04:48:34',NULL),(2070,'smtp_username','','2026-04-19 04:48:34',NULL),(2071,'smtp_password','','2026-04-19 04:48:34',NULL),(2072,'alert_email','','2026-04-19 04:48:34',NULL),(2073,'low_stock_threshold','5','2026-04-19 04:48:34',NULL),(2074,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:48:34',NULL),(2075,'session_timeout','1800','2026-04-19 04:48:42',NULL),(2076,'smtp_server','','2026-04-19 04:48:42',NULL),(2077,'smtp_port','587','2026-04-19 04:48:42',NULL),(2078,'smtp_username','','2026-04-19 04:48:42',NULL),(2079,'smtp_password','','2026-04-19 04:48:42',NULL),(2080,'alert_email','','2026-04-19 04:48:42',NULL),(2081,'low_stock_threshold','5','2026-04-19 04:48:42',NULL),(2082,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:48:42',NULL),(2083,'smtp_server','','2026-04-19 04:48:42',1),(2084,'smtp_port','587','2026-04-19 04:48:42',1),(2085,'smtp_username','','2026-04-19 04:48:42',1),(2086,'smtp_password','','2026-04-19 04:48:42',1),(2087,'alert_email','','2026-04-19 04:48:42',1),(2088,'low_stock_threshold','5','2026-04-19 04:48:42',1),(2089,'smtp_server','','2026-04-19 04:48:42',2),(2090,'smtp_port','587','2026-04-19 04:48:42',2),(2091,'smtp_username','','2026-04-19 04:48:42',2),(2092,'smtp_password','','2026-04-19 04:48:42',2),(2093,'alert_email','','2026-04-19 04:48:42',2),(2094,'low_stock_threshold','5','2026-04-19 04:48:42',2),(2095,'session_timeout','1800','2026-04-19 04:48:44',NULL),(2096,'smtp_server','','2026-04-19 04:48:44',NULL),(2097,'smtp_port','587','2026-04-19 04:48:44',NULL),(2098,'smtp_username','','2026-04-19 04:48:44',NULL),(2099,'smtp_password','','2026-04-19 04:48:44',NULL),(2100,'alert_email','','2026-04-19 04:48:44',NULL),(2101,'low_stock_threshold','5','2026-04-19 04:48:44',NULL),(2102,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:48:44',NULL),(2115,'session_timeout','1800','2026-04-19 04:48:58',NULL),(2116,'smtp_server','','2026-04-19 04:48:58',NULL),(2117,'smtp_port','587','2026-04-19 04:48:58',NULL),(2118,'smtp_username','','2026-04-19 04:48:58',NULL),(2119,'smtp_password','','2026-04-19 04:48:58',NULL),(2120,'alert_email','','2026-04-19 04:48:58',NULL),(2121,'low_stock_threshold','5','2026-04-19 04:48:58',NULL),(2122,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:48:58',NULL),(2135,'session_timeout','1800','2026-04-19 04:49:11',NULL),(2136,'smtp_server','','2026-04-19 04:49:11',NULL),(2137,'smtp_port','587','2026-04-19 04:49:11',NULL),(2138,'smtp_username','','2026-04-19 04:49:11',NULL),(2139,'smtp_password','','2026-04-19 04:49:11',NULL),(2140,'alert_email','','2026-04-19 04:49:11',NULL),(2141,'low_stock_threshold','5','2026-04-19 04:49:11',NULL),(2142,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:49:11',NULL),(2155,'session_timeout','1800','2026-04-19 04:49:15',NULL),(2156,'smtp_server','','2026-04-19 04:49:15',NULL),(2157,'smtp_port','587','2026-04-19 04:49:15',NULL),(2158,'smtp_username','','2026-04-19 04:49:15',NULL),(2159,'smtp_password','','2026-04-19 04:49:15',NULL),(2160,'alert_email','','2026-04-19 04:49:15',NULL),(2161,'low_stock_threshold','5','2026-04-19 04:49:15',NULL),(2162,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:49:15',NULL),(2175,'session_timeout','1800','2026-04-19 04:49:20',NULL),(2176,'smtp_server','','2026-04-19 04:49:20',NULL),(2177,'smtp_port','587','2026-04-19 04:49:20',NULL),(2178,'smtp_username','','2026-04-19 04:49:20',NULL),(2179,'smtp_password','','2026-04-19 04:49:20',NULL),(2180,'alert_email','','2026-04-19 04:49:20',NULL),(2181,'low_stock_threshold','5','2026-04-19 04:49:20',NULL),(2182,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:49:20',NULL),(2195,'session_timeout','1800','2026-04-19 04:49:47',NULL),(2196,'smtp_server','','2026-04-19 04:49:47',NULL),(2197,'smtp_port','587','2026-04-19 04:49:47',NULL),(2198,'smtp_username','','2026-04-19 04:49:47',NULL),(2199,'smtp_password','','2026-04-19 04:49:47',NULL),(2200,'alert_email','','2026-04-19 04:49:47',NULL),(2201,'low_stock_threshold','5','2026-04-19 04:49:47',NULL),(2202,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:49:47',NULL),(2215,'session_timeout','1800','2026-04-19 04:49:48',NULL),(2216,'smtp_server','','2026-04-19 04:49:48',NULL),(2217,'smtp_port','587','2026-04-19 04:49:48',NULL),(2218,'smtp_username','','2026-04-19 04:49:48',NULL),(2219,'smtp_password','','2026-04-19 04:49:48',NULL),(2220,'alert_email','','2026-04-19 04:49:48',NULL),(2221,'low_stock_threshold','5','2026-04-19 04:49:48',NULL),(2222,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:49:48',NULL),(2235,'session_timeout','1800','2026-04-19 04:50:26',NULL),(2236,'smtp_server','','2026-04-19 04:50:26',NULL),(2237,'smtp_port','587','2026-04-19 04:50:26',NULL),(2238,'smtp_username','','2026-04-19 04:50:26',NULL),(2239,'smtp_password','','2026-04-19 04:50:26',NULL),(2240,'alert_email','','2026-04-19 04:50:26',NULL),(2241,'low_stock_threshold','5','2026-04-19 04:50:26',NULL),(2242,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:50:26',NULL),(2255,'session_timeout','1800','2026-04-19 04:50:28',NULL),(2256,'smtp_server','','2026-04-19 04:50:28',NULL),(2257,'smtp_port','587','2026-04-19 04:50:28',NULL),(2258,'smtp_username','','2026-04-19 04:50:28',NULL),(2259,'smtp_password','','2026-04-19 04:50:28',NULL),(2260,'alert_email','','2026-04-19 04:50:28',NULL),(2261,'low_stock_threshold','5','2026-04-19 04:50:28',NULL),(2262,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:50:28',NULL),(2275,'session_timeout','1800','2026-04-19 04:50:59',NULL),(2276,'smtp_server','','2026-04-19 04:50:59',NULL),(2277,'smtp_port','587','2026-04-19 04:50:59',NULL),(2278,'smtp_username','','2026-04-19 04:50:59',NULL),(2279,'smtp_password','','2026-04-19 04:50:59',NULL),(2280,'alert_email','','2026-04-19 04:50:59',NULL),(2281,'low_stock_threshold','5','2026-04-19 04:50:59',NULL),(2282,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:50:59',NULL),(2295,'session_timeout','1800','2026-04-19 04:51:02',NULL),(2296,'smtp_server','','2026-04-19 04:51:02',NULL),(2297,'smtp_port','587','2026-04-19 04:51:02',NULL),(2298,'smtp_username','','2026-04-19 04:51:02',NULL),(2299,'smtp_password','','2026-04-19 04:51:02',NULL),(2300,'alert_email','','2026-04-19 04:51:02',NULL),(2301,'low_stock_threshold','5','2026-04-19 04:51:02',NULL),(2302,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:02',NULL),(2315,'session_timeout','1800','2026-04-19 04:51:12',NULL),(2316,'smtp_server','','2026-04-19 04:51:12',NULL),(2317,'smtp_port','587','2026-04-19 04:51:12',NULL),(2318,'smtp_username','','2026-04-19 04:51:12',NULL),(2319,'smtp_password','','2026-04-19 04:51:12',NULL),(2320,'alert_email','','2026-04-19 04:51:12',NULL),(2321,'low_stock_threshold','5','2026-04-19 04:51:12',NULL),(2322,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:12',NULL),(2335,'session_timeout','1800','2026-04-19 04:51:15',NULL),(2336,'smtp_server','','2026-04-19 04:51:15',NULL),(2337,'smtp_port','587','2026-04-19 04:51:15',NULL),(2338,'smtp_username','','2026-04-19 04:51:15',NULL),(2339,'smtp_password','','2026-04-19 04:51:15',NULL),(2340,'alert_email','','2026-04-19 04:51:15',NULL),(2341,'low_stock_threshold','5','2026-04-19 04:51:15',NULL),(2342,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:15',NULL),(2355,'session_timeout','1800','2026-04-19 04:51:17',NULL),(2356,'smtp_server','','2026-04-19 04:51:17',NULL),(2357,'smtp_port','587','2026-04-19 04:51:17',NULL),(2358,'smtp_username','','2026-04-19 04:51:17',NULL),(2359,'smtp_password','','2026-04-19 04:51:17',NULL),(2360,'alert_email','','2026-04-19 04:51:17',NULL),(2361,'low_stock_threshold','5','2026-04-19 04:51:17',NULL),(2362,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:17',NULL),(2375,'session_timeout','1800','2026-04-19 04:51:21',NULL),(2376,'smtp_server','','2026-04-19 04:51:21',NULL),(2377,'smtp_port','587','2026-04-19 04:51:21',NULL),(2378,'smtp_username','','2026-04-19 04:51:21',NULL),(2379,'smtp_password','','2026-04-19 04:51:21',NULL),(2380,'alert_email','','2026-04-19 04:51:21',NULL),(2381,'low_stock_threshold','5','2026-04-19 04:51:21',NULL),(2382,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:21',NULL),(2395,'session_timeout','1800','2026-04-19 04:51:23',NULL),(2396,'smtp_server','','2026-04-19 04:51:23',NULL),(2397,'smtp_port','587','2026-04-19 04:51:23',NULL),(2398,'smtp_username','','2026-04-19 04:51:23',NULL),(2399,'smtp_password','','2026-04-19 04:51:23',NULL),(2400,'alert_email','','2026-04-19 04:51:23',NULL),(2401,'low_stock_threshold','5','2026-04-19 04:51:23',NULL),(2402,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:23',NULL),(2415,'session_timeout','1800','2026-04-19 04:51:35',NULL),(2416,'smtp_server','','2026-04-19 04:51:35',NULL),(2417,'smtp_port','587','2026-04-19 04:51:35',NULL),(2418,'smtp_username','','2026-04-19 04:51:35',NULL),(2419,'smtp_password','','2026-04-19 04:51:35',NULL),(2420,'alert_email','','2026-04-19 04:51:35',NULL),(2421,'low_stock_threshold','5','2026-04-19 04:51:35',NULL),(2422,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:35',NULL),(2435,'session_timeout','1800','2026-04-19 04:51:37',NULL),(2436,'smtp_server','','2026-04-19 04:51:37',NULL),(2437,'smtp_port','587','2026-04-19 04:51:37',NULL),(2438,'smtp_username','','2026-04-19 04:51:37',NULL),(2439,'smtp_password','','2026-04-19 04:51:37',NULL),(2440,'alert_email','','2026-04-19 04:51:37',NULL),(2441,'low_stock_threshold','5','2026-04-19 04:51:37',NULL),(2442,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:37',NULL),(2455,'session_timeout','1800','2026-04-19 04:51:52',NULL),(2456,'smtp_server','','2026-04-19 04:51:52',NULL),(2457,'smtp_port','587','2026-04-19 04:51:52',NULL),(2458,'smtp_username','','2026-04-19 04:51:52',NULL),(2459,'smtp_password','','2026-04-19 04:51:52',NULL),(2460,'alert_email','','2026-04-19 04:51:52',NULL),(2461,'low_stock_threshold','5','2026-04-19 04:51:52',NULL),(2462,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:52',NULL),(2475,'session_timeout','1800','2026-04-19 04:51:54',NULL),(2476,'smtp_server','','2026-04-19 04:51:54',NULL),(2477,'smtp_port','587','2026-04-19 04:51:54',NULL),(2478,'smtp_username','','2026-04-19 04:51:54',NULL),(2479,'smtp_password','','2026-04-19 04:51:54',NULL),(2480,'alert_email','','2026-04-19 04:51:54',NULL),(2481,'low_stock_threshold','5','2026-04-19 04:51:54',NULL),(2482,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:51:54',NULL),(2495,'session_timeout','1800','2026-04-19 04:56:58',NULL),(2496,'smtp_server','','2026-04-19 04:56:58',NULL),(2497,'smtp_port','587','2026-04-19 04:56:58',NULL),(2498,'smtp_username','','2026-04-19 04:56:58',NULL),(2499,'smtp_password','','2026-04-19 04:56:58',NULL),(2500,'alert_email','','2026-04-19 04:56:58',NULL),(2501,'low_stock_threshold','5','2026-04-19 04:56:58',NULL),(2502,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:56:58',NULL),(2515,'session_timeout','1800','2026-04-19 04:56:58',NULL),(2516,'smtp_server','','2026-04-19 04:56:58',NULL),(2517,'smtp_port','587','2026-04-19 04:56:58',NULL),(2518,'smtp_username','','2026-04-19 04:56:58',NULL),(2519,'smtp_password','','2026-04-19 04:56:58',NULL),(2520,'alert_email','','2026-04-19 04:56:58',NULL),(2521,'low_stock_threshold','5','2026-04-19 04:56:58',NULL),(2522,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:56:58',NULL),(2535,'session_timeout','1800','2026-04-19 04:56:59',NULL),(2536,'smtp_server','','2026-04-19 04:56:59',NULL),(2537,'smtp_port','587','2026-04-19 04:56:59',NULL),(2538,'smtp_username','','2026-04-19 04:56:59',NULL),(2539,'smtp_password','','2026-04-19 04:56:59',NULL),(2540,'alert_email','','2026-04-19 04:56:59',NULL),(2541,'low_stock_threshold','5','2026-04-19 04:56:59',NULL),(2542,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:56:59',NULL),(2555,'session_timeout','1800','2026-04-19 04:58:38',NULL),(2556,'smtp_server','','2026-04-19 04:58:38',NULL),(2557,'smtp_port','587','2026-04-19 04:58:38',NULL),(2558,'smtp_username','','2026-04-19 04:58:38',NULL),(2559,'smtp_password','','2026-04-19 04:58:38',NULL),(2560,'alert_email','','2026-04-19 04:58:38',NULL),(2561,'low_stock_threshold','5','2026-04-19 04:58:38',NULL),(2562,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 04:58:38',NULL),(2575,'session_timeout','1800','2026-04-19 05:02:49',NULL),(2576,'smtp_server','','2026-04-19 05:02:49',NULL),(2577,'smtp_port','587','2026-04-19 05:02:49',NULL),(2578,'smtp_username','','2026-04-19 05:02:49',NULL),(2579,'smtp_password','','2026-04-19 05:02:49',NULL),(2580,'alert_email','','2026-04-19 05:02:49',NULL),(2581,'low_stock_threshold','5','2026-04-19 05:02:49',NULL),(2582,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 05:02:49',NULL),(2595,'session_timeout','1800','2026-04-19 05:02:50',NULL),(2596,'smtp_server','','2026-04-19 05:02:50',NULL),(2597,'smtp_port','587','2026-04-19 05:02:50',NULL),(2598,'smtp_username','','2026-04-19 05:02:50',NULL),(2599,'smtp_password','','2026-04-19 05:02:50',NULL),(2600,'alert_email','','2026-04-19 05:02:50',NULL),(2601,'low_stock_threshold','5','2026-04-19 05:02:50',NULL),(2602,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 05:02:50',NULL),(2615,'session_timeout','1800','2026-04-19 05:03:48',NULL),(2616,'smtp_server','','2026-04-19 05:03:48',NULL),(2617,'smtp_port','587','2026-04-19 05:03:48',NULL),(2618,'smtp_username','','2026-04-19 05:03:48',NULL),(2619,'smtp_password','','2026-04-19 05:03:48',NULL),(2620,'alert_email','','2026-04-19 05:03:48',NULL),(2621,'low_stock_threshold','5','2026-04-19 05:03:48',NULL),(2622,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 05:03:48',NULL),(2635,'session_timeout','1800','2026-04-19 05:03:48',NULL),(2636,'smtp_server','','2026-04-19 05:03:48',NULL),(2637,'smtp_port','587','2026-04-19 05:03:48',NULL),(2638,'smtp_username','','2026-04-19 05:03:48',NULL),(2639,'smtp_password','','2026-04-19 05:03:48',NULL),(2640,'alert_email','','2026-04-19 05:03:48',NULL),(2641,'low_stock_threshold','5','2026-04-19 05:03:48',NULL),(2642,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 05:03:48',NULL),(2655,'session_timeout','1800','2026-04-19 05:03:48',NULL),(2656,'smtp_server','','2026-04-19 05:03:48',NULL),(2657,'smtp_port','587','2026-04-19 05:03:48',NULL),(2658,'smtp_username','','2026-04-19 05:03:48',NULL),(2659,'smtp_password','','2026-04-19 05:03:48',NULL),(2660,'alert_email','','2026-04-19 05:03:48',NULL),(2661,'low_stock_threshold','5','2026-04-19 05:03:48',NULL),(2662,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]','2026-04-19 05:03:48',NULL);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shops`
--

DROP TABLE IF EXISTS `shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text,
  `phone` varchar(50) DEFAULT NULL,
  `icon` varchar(50) DEFAULT 0xF09F9B92,
  `currency_symbol` varchar(10) DEFAULT '$',
  `low_stock_threshold` int DEFAULT '5',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (1,'Monster',NULL,NULL,'🏪','฿',6,'2026-04-19 03:31:42'),(2,'no.1','','','👗','฿',5,'2026-04-19 03:57:09');
/*!40000 ALTER TABLE `shops` ENABLE KEYS */;
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `stock_history_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_history`
--

LOCK TABLES `stock_history` WRITE;
/*!40000 ALTER TABLE `stock_history` DISABLE KEYS */;
INSERT INTO `stock_history` VALUES (1,1,50,'initial','Initial stock','2026-03-28 05:25:15',1),(2,2,40,'initial','Initial stock','2026-03-28 05:26:06',1),(3,3,100,'initial','Initial stock','2026-03-28 05:27:41',1),(4,1,-2,'sale','Sale transaction','2026-03-28 05:33:53',1),(5,4,50,'initial','Initial stock','2026-03-28 05:58:06',1),(6,4,25,'import','E2E test stock import','2026-03-28 05:58:06',1),(7,4,-2,'sale','Sale by test_sales','2026-03-28 05:58:06',1),(8,3,-10,'sale','Sale by john','2026-03-28 06:26:29',1),(9,5,10,'initial','Initial stock','2026-03-28 06:28:34',1),(10,5,-5,'sale','Sale by john','2026-03-28 06:28:59',1),(11,1,-3,'sale','Sale by john','2026-03-28 06:45:41',1),(12,5,-5,'sale','Sale by jo jo','2026-03-28 22:16:48',1),(13,4,-5,'sale','Sale by admin','2026-03-28 22:19:41',1),(14,5,24,'import','added stock on 20260329','2026-03-28 22:21:39',1),(15,1,-4,'sale','Sale by admin','2026-03-28 22:29:50',1),(16,5,-1,'sale','Sale by admin','2026-03-28 22:30:15',1),(17,1,-1,'sale','Sale by admin','2026-03-28 22:30:15',1),(18,2,-1,'sale','Sale by admin','2026-03-28 22:30:15',1),(19,5,-3,'sale','Sale by admin','2026-03-28 22:48:53',1),(20,1,-2,'sale','Sale by admin','2026-03-28 22:48:53',1),(21,5,-1,'sale','Sale by john','2026-03-28 23:04:06',1),(22,5,-1,'sale','Sale by john','2026-03-28 23:05:23',1),(23,2,-1,'sale','Sale by john','2026-03-28 23:05:46',1),(24,5,-2,'sale','Sale by admin','2026-03-28 23:07:44',1),(26,7,100,'initial','Initial stock','2026-03-28 23:31:06',1),(27,8,100,'initial','Initial stock','2026-03-28 23:36:01',1),(28,7,-2,'sale','Sale by admin','2026-03-28 23:36:27',1),(29,8,-2,'sale','Sale by admin','2026-03-28 23:36:27',1),(30,5,-2,'sale','Sale by admin','2026-03-28 23:51:29',1),(31,5,-2,'sale','Sale by admin','2026-03-29 00:04:24',1),(32,7,-2,'sale','Sale by admin','2026-03-29 20:27:38',1),(33,1,-1,'sale','Sale by admin','2026-03-29 20:58:13',1),(34,2,-8,'sale','Sale by admin','2026-03-29 20:58:13',1),(35,8,-95,'sale','Sale by admin','2026-03-29 20:58:13',1),(36,5,-10,'sale','Sale by admin','2026-03-29 20:58:13',1),(37,2,-27,'sale','Sale by admin','2026-03-29 21:30:40',1),(38,5,-2,'sale','Sale by admin','2026-04-02 06:00:37',1),(39,1,-1,'sale','Sale by admin','2026-04-10 22:15:48',1),(40,7,-1,'sale','Sale by admin','2026-04-10 22:15:48',1),(41,1,-1,'sale','Sale by admin','2026-04-10 22:20:07',1),(42,1,-12,'sale','Sale by admin','2026-04-10 22:28:10',1),(43,8,-1,'sale','Sale by admin','2026-04-10 22:28:10',1),(44,7,-1,'sale','Sale by admin','2026-04-10 22:28:10',1),(45,2,-3,'sale','Sale by admin','2026-04-10 22:29:47',1),(46,7,-2,'sale','Sale by admin','2026-04-10 22:29:47',1),(47,4,-2,'sale','Sale by admin','2026-04-10 22:29:47',1),(48,2,-3,'sale','Sale by admin','2026-04-10 22:30:13',1),(49,4,-2,'sale','Sale by admin','2026-04-10 22:30:13',1),(50,2,-3,'sale','Sale by admin','2026-04-10 22:30:46',1),(51,3,-1,'sale','Sale by admin','2026-04-10 22:31:57',1),(52,3,-1,'sale','Sale by admin','2026-04-10 22:32:04',1),(53,1,-1,'sale','Sale by admin','2026-04-10 22:32:28',1),(54,4,-20,'sale','Sale by admin','2026-04-10 22:34:28',1),(55,3,-4,'sale','Sale by admin','2026-04-10 22:34:28',1),(56,7,-4,'sale','Sale by admin','2026-04-10 22:34:28',1),(57,7,-1,'sale','Sale by admin','2026-04-10 22:35:22',1),(58,4,-1,'sale','Sale by admin','2026-04-10 22:35:22',1),(59,3,-1,'sale','Sale by admin','2026-04-10 22:35:22',1),(60,9,100,'initial','Initial stock','2026-04-10 22:48:10',1),(61,9,-3,'sale','Sale by admin','2026-04-10 22:49:26',1),(62,7,-2,'sale','Sale by admin','2026-04-10 22:49:26',1),(63,8,-2,'sale','Sale by admin','2026-04-10 22:49:26',1),(64,1,-1,'sale','Sale by admin','2026-04-10 22:50:07',1),(65,9,-3,'sale','Sale by admin','2026-04-10 22:50:54',1),(66,4,-3,'sale','Sale by admin','2026-04-10 22:50:54',1),(67,7,-2,'sale','Sale by admin','2026-04-10 22:50:54',1),(68,3,-1,'sale','Sale by admin','2026-04-10 22:50:54',1),(69,1,-1,'sale','Sale by admin','2026-04-10 22:50:54',1),(70,9,2,'return','Refund for sale #33 by admin','2026-04-10 22:52:57',1),(71,7,1,'return','Refund for sale #33 by admin','2026-04-10 22:52:57',1),(72,8,1,'return','Refund for sale #33 by admin','2026-04-10 22:52:57',1),(73,4,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(74,3,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(75,9,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(76,7,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(77,8,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(78,1,-1,'sale','Sale by admin','2026-04-10 22:59:15',1),(79,7,-1,'sale','Sale by admin','2026-04-10 23:00:00',1),(80,7,-1,'sale','Sale by admin','2026-04-10 23:08:57',1),(81,9,-1,'sale','Sale by admin','2026-04-10 23:08:57',1),(82,1,-10,'sale','Sale by admin','2026-04-10 23:10:14',1),(83,1,-5,'sale','Sale by admin','2026-04-10 23:10:37',1),(84,10,40,'import','','2026-04-10 23:37:34',1),(85,1,2,'import','','2026-04-10 23:38:59',1),(86,1,-1,'sale','Sale by admin','2026-04-11 00:01:03',1),(87,1,-2,'sale','Sale by john','2026-04-11 00:20:55',1),(88,10,-1,'sale','Sale by admin','2026-04-11 00:43:07',1),(89,5,1000,'import','incoming instock','2026-04-11 20:38:57',1),(90,11,1000,'import','incoming instock','2026-04-11 20:38:57',1),(91,1,1000,'import','incoming instock','2026-04-11 20:38:57',1),(92,2,1000,'import','incoming instock','2026-04-11 20:38:57',1),(93,12,1000,'import','incoming instock','2026-04-11 20:38:57',1),(94,13,1000,'import','incoming instock','2026-04-11 20:38:57',1),(95,8,1000,'import','incoming instock','2026-04-11 20:38:57',1),(96,14,1000,'import','incoming instock','2026-04-11 20:38:57',1),(97,29,100,'initial','Initial stock','2026-04-11 20:52:11',1),(98,20,1,'purchase','PO #1 received by admin','2026-04-11 23:37:36',1),(99,10,10,'purchase','PO #1 received by admin','2026-04-11 23:37:36',1),(100,14,1000,'purchase','PO #2 received by admin','2026-04-11 23:42:12',1),(101,30,10,'initial','Initial stock','2026-04-11 23:59:28',1),(102,31,10,'initial','Initial stock | Cost: 200.00','2026-04-12 00:11:30',1),(103,5,-6,'sale','Sale by admin','2026-04-12 00:28:33',1),(104,11,-1,'sale','Sale by admin','2026-04-12 00:28:33',1),(105,8,-1,'sale','Sale by admin','2026-04-12 00:28:33',1),(106,32,100,'initial','Initial stock | Cost: 10.00','2026-04-12 00:52:03',1),(107,33,20,'initial','Initial stock | Cost: 10.00','2026-04-12 00:55:57',1),(108,20,20,'purchase','PO #3 received by admin | Cost: 40.00 → 40.95 (PO unit cost: 41.00)','2026-04-12 01:02:58',1),(109,34,20,'initial','Initial stock | Cost: 95000.00','2026-04-12 01:12:34',1),(110,34,30,'purchase','PO #4 received by admin | Cost: 95000.00 → 95600.00 (PO unit cost: 96000.00)','2026-04-12 01:19:00',1),(111,34,-2,'sale','Sale by admin','2026-04-12 01:21:37',1),(112,34,-2,'sale','Sale by admin','2026-04-12 01:37:46',1),(113,11,-2,'sale','Sale by admin','2026-04-12 01:43:34',1),(114,5,-2,'sale','Sale by admin','2026-04-12 08:52:08',1),(115,8,-1,'sale','Sale by admin','2026-04-12 08:52:08',1),(116,11,-2,'sale','Sale by admin','2026-04-12 21:09:30',1),(117,11,-3,'sale','Sale by admin','2026-04-12 21:13:26',1),(118,11,-1,'sale','Sale by admin','2026-04-12 21:15:19',1),(119,5,-60,'sale','Sale by admin','2026-04-12 21:24:03',1),(120,20,-21,'sale','Sale by admin','2026-04-12 21:24:03',1),(121,1,-19,'sale','Sale by admin','2026-04-12 21:24:03',1),(122,5,-1,'sale','Sale by admin','2026-04-12 22:04:17',1),(123,11,-2,'sale','Sale by admin','2026-04-12 22:04:17',1),(124,1,-2,'sale','Sale by admin','2026-04-12 22:04:17',1),(125,12,-1,'sale','Sale by admin','2026-04-12 22:04:17',1),(126,1,-1,'sale','Sale by admin','2026-04-12 22:06:15',1),(127,11,-1,'sale','Sale by admin','2026-04-12 22:06:15',1),(128,5,-1,'sale','Sale by john','2026-04-12 22:38:57',1),(129,11,-1,'sale','Sale by john','2026-04-12 22:38:57',1),(130,1,-1,'sale','Sale by john','2026-04-12 22:38:57',1),(131,35,12,'initial','Initial stock | Cost: 12.00','2026-04-17 09:03:48',1),(132,1,6,'return','Refund for sale #39 by admin','2026-04-17 10:26:35',1),(133,5,-6,'sale','Sale by admin','2026-04-18 05:33:41',1),(134,2,-1,'sale','Sale by admin','2026-04-18 05:34:08',1),(135,5,-1,'sale','Sale by admin','2026-04-18 05:34:08',1),(136,1,-1,'sale','Sale by admin','2026-04-18 05:34:08',1),(137,12,-1,'sale','Sale by admin','2026-04-18 05:34:08',1),(138,36,20,'initial','Initial stock | Cost: 10.00','2026-04-18 06:08:58',1),(139,20,30,'purchase','PO #3 received by sam | Cost: 40.95 → 41.00 (PO unit cost: 41.00)','2026-04-19 03:09:53',1),(140,5,-1,'sale','Sale by superadmin','2026-04-19 03:58:22',1),(141,11,-1,'sale','Sale by superadmin','2026-04-19 03:58:22',1),(142,1,-1,'sale','Sale by superadmin','2026-04-19 04:05:24',1),(143,2,-1,'sale','Sale by superadmin','2026-04-19 04:05:24',1),(144,37,30,'initial','Initial stock | Cost: 30.00','2026-04-19 04:07:31',2),(145,37,-4,'sale','Sale by sam2','2026-04-19 04:07:41',2),(146,37,-8,'sale','Sale by sam2','2026-04-19 05:09:01',2),(147,37,-9,'sale','Sale by sam2','2026-04-19 05:11:44',2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'MoMo','Jame','jame@gmail.com','+66941104272','Bangkok','Souvinior Shop','2026-04-11 23:30:28',1),(2,'Myat Tin Kyi','U Ba','','','','','2026-04-12 01:09:09',1),(3,'XYZ Store','Smith','smith@gmail.com','09573685462','','','2026-04-19 05:09:39',2);
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
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','admin','Administrator','2026-03-28 05:36:50',1),(3,'john','b4b597c714a8f49103da4dab0266af0ee0ae4f8575250a84855c3d76941cd422','user','john','2026-03-28 06:01:44',1),(4,'jo jo','0776180dc120b60d4f3e065d47ee3eb22c74585fe39dd66774850583b5c87ee9','user','jojo','2026-03-28 06:48:01',1),(5,'smith','5ae36d4eba1d11d750066652650a44f3ac07e6efce1a95a1fb61121076cfab5e','user','Smith','2026-04-18 05:58:09',1),(6,'sam','e3e9fc033c2647b79bac54f75d0965c0715c6856e662fd02da8742100e5cda22','admin','Sam','2026-04-19 03:08:43',1),(7,'superadmin','186cf774c97b60a1c106ef718d10970a6a06e06bef89553d9ae65d938a886eae','super_admin','Super Administrator','2026-04-19 03:51:25',NULL),(8,'sam2','c488961ac1396163180f25e4b22fa76202e43fa37bba6b567863c966623f1998','admin','sam2','2026-04-19 04:06:41',2),(9,'sam3','6bfeb759b33d1ef0278a27edd6e73f65e584b70342f614036583fb954a88bfd1','user','sam2','2026-04-19 04:39:46',2);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'pos_mysql_app'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19 14:14:02
