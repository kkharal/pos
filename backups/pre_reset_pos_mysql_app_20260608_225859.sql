-- MySQL dump 10.13  Distrib 9.6.0, for macos26.3 (arm64)
--
-- Host: 127.0.0.1    Database: pos_mysql_app
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Rishi','+919998939095','','','walk-in',0.00,0.00,'Regular customer','2026-06-07 12:09:21',2);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expense_categories`
--

DROP TABLE IF EXISTS `expense_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `icon` varchar(50) DEFAULT 0xF09F939D,
  `description` text,
  `shop_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense_categories`
--

LOCK TABLES `expense_categories` WRITE;
/*!40000 ALTER TABLE `expense_categories` DISABLE KEYS */;
INSERT INTO `expense_categories` VALUES (1,'Employee Salary','👤','Staff wages and salaries',1,'2026-06-07 03:27:10'),(2,'Shop Rent','🏠','Monthly shop rental',1,'2026-06-07 03:27:10'),(3,'Electricity / Utilities','⚡','Electric, water, gas bills',1,'2026-06-07 03:27:10'),(4,'Transportation','🚗','Delivery and travel costs',1,'2026-06-07 03:27:10'),(5,'Maintenance & Repairs','🔧','Shop repairs and maintenance',1,'2026-06-07 03:27:10'),(6,'Packaging & Supplies','📦','Bags, boxes, wrapping',1,'2026-06-07 03:27:10'),(7,'Marketing','📣','Advertising and promotions',1,'2026-06-07 03:27:10'),(8,'Miscellaneous','📝','Other expenses',1,'2026-06-07 03:27:10'),(9,'Employee Salary','👤','Staff wages and salaries',2,'2026-06-07 03:28:10'),(10,'Shop Rent','🏠','Monthly shop rental',2,'2026-06-07 03:28:10'),(11,'Electricity / Utilities','⚡','Electric, water, gas bills',2,'2026-06-07 03:28:10'),(12,'Transportation','🚗','Delivery and travel costs',2,'2026-06-07 03:28:10'),(13,'Maintenance & Repairs','🔧','Shop repairs and maintenance',2,'2026-06-07 03:28:10'),(14,'Packaging & Supplies','📦','Bags, boxes, wrapping',2,'2026-06-07 03:28:10'),(15,'Marketing','📣','Advertising and promotions',2,'2026-06-07 03:28:10'),(16,'Miscellaneous','📝','Other expenses',2,'2026-06-07 03:28:10');
/*!40000 ALTER TABLE `expense_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `description` text,
  `expense_date` date NOT NULL,
  `payment_method` varchar(50) NOT NULL DEFAULT 'cash',
  `receipt_ref` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `shop_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `po_items`
--

LOCK TABLES `po_items` WRITE;
/*!40000 ALTER TABLE `po_items` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_audit_log`
--

LOCK TABLES `product_audit_log` WRITE;
/*!40000 ALTER TABLE `product_audit_log` DISABLE KEYS */;
INSERT INTO `product_audit_log` VALUES (1,1,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(2,2,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(3,3,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(4,4,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(5,5,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(6,6,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(7,7,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(8,8,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(9,9,3,'kharal','group_edit','name','HS Velvet Line 2P Long Sleeve','HS Velvet Line 2Pockets Long Sleeve','2026-06-07 05:21:16',2),(10,1,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(11,2,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(12,3,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(13,4,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(14,5,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(15,6,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(16,7,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(17,8,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(18,9,3,'kharal','group_edit','name','HS Velvet Line 2Pockets Long Sleeve','Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','2026-06-07 05:37:13',2),(19,27,3,'kharal','group_edit','name','Teen Top Button-Neck Short Sleeve Shirt','Teen Top Button-Neck Short Sleeve Shirt - Line','2026-06-07 06:31:28',2),(20,28,3,'kharal','group_edit','name','Teen Top Button-Neck Short Sleeve Shirt','Teen Top Button-Neck Short Sleeve Shirt - Line','2026-06-07 06:31:28',2),(21,29,3,'kharal','group_edit','name','Teen Top Button-Neck Short Sleeve Shirt','Teen Top Button-Neck Short Sleeve Shirt - Line','2026-06-07 06:31:28',2),(22,30,3,'kharal','group_edit','name','Teen Top Button-Neck Short Sleeve Shirt','Teen Top Button-Neck Short Sleeve Shirt - Line','2026-06-07 06:31:28',2);
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
  `size` varchar(50) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `variant_group` varchar(100) DEFAULT NULL,
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_product_sku_shop` (`sku`,`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,0,'SHI-001','Hyper Star','2026-06-07 05:20:31',NULL,'M','White','hs-velvet-line-2p-lo-38f9fca0',2),(2,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,0,'SHI-002','Hyper Star','2026-06-07 05:20:31',NULL,'M','Black','hs-velvet-line-2p-lo-38f9fca0',2),(3,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,0,'SHI-003','Hyper Star','2026-06-07 05:20:31',NULL,'L','Dark Brown','hs-velvet-line-2p-lo-38f9fca0',2),(4,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,1,'SHI-004','Hyper Star','2026-06-07 05:20:31',NULL,'L','Khaki','hs-velvet-line-2p-lo-38f9fca0',2),(5,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,1,'SHI-005','Hyper Star','2026-06-07 05:20:31',NULL,'L','Maroon','hs-velvet-line-2p-lo-38f9fca0',2),(6,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,2,'SHI-006','Hyper Star','2026-06-07 05:20:31',NULL,'XL','Black','hs-velvet-line-2p-lo-38f9fca0',2),(7,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,2,'SHI-007','Hyper Star','2026-06-07 05:20:31',NULL,'XL','Dark Brown','hs-velvet-line-2p-lo-38f9fca0',2),(8,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,2,'SHI-008','Hyper Star','2026-06-07 05:20:31',NULL,'XL','Gray','hs-velvet-line-2p-lo-38f9fca0',2),(9,'Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket','Shirts',140.00,400.00,1,'SHI-009','Hyper Star','2026-06-07 05:20:31',NULL,'XL','Dark Gray','hs-velvet-line-2p-lo-38f9fca0',2),(10,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,2,'SHI-010','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'M','White','hyper-start-velvet-l-1f452c85',2),(11,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,2,'SHI-011','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'M','Black','hyper-start-velvet-l-1f452c85',2),(12,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,1,'SHI-012','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'M','Brown','hyper-start-velvet-l-1f452c85',2),(13,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,2,'SHI-013','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'M','Khaki','hyper-start-velvet-l-1f452c85',2),(14,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,3,'SHI-014','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'XL','Black','hyper-start-velvet-l-1f452c85',2),(15,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,4,'SHI-015','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'XL','Brown','hyper-start-velvet-l-1f452c85',2),(16,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,3,'SHI-016','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'XL','Gray','hyper-start-velvet-l-1f452c85',2),(17,'Hyper Start Velvet Line Long Sleeve Shirt - 1 Pocket','Shirts',130.00,350.00,3,'SHI-017','Premium long sleeve shirt from the Hyper Start Velvet Line collection featuring a classic single-pocket design. Suitable for casual and business-casual wear.','2026-06-07 05:36:23',NULL,'XL','Dark Blue','hyper-start-velvet-l-1f452c85',2),(18,'Fashion Brand Zip-Neck Polo Shirt','Shirts',120.00,300.00,3,'SHI-018','','2026-06-07 06:02:32',NULL,'XL','Brown','fashion-brand-zip-ne-a4fa6c64',2),(19,'Fashion Brand Zip-Neck Polo Shirt','Shirts',120.00,300.00,1,'SHI-019','','2026-06-07 06:02:32',NULL,'XXXL','Teal Blue-Green','fashion-brand-zip-ne-a4fa6c64',2),(20,'Fashion Brand Zip-Neck Polo Shirt','Shirts',120.00,300.00,2,'SHI-020','','2026-06-07 06:02:32',NULL,'XXXL','Brown','fashion-brand-zip-ne-a4fa6c64',2),(21,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-021','','2026-06-07 06:20:51',NULL,'M','Brown','teen-top-zip-neck-sh-c04a32a5',2),(22,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-022','','2026-06-07 06:20:51',NULL,'L','Cream','teen-top-zip-neck-sh-c04a32a5',2),(23,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-023','','2026-06-07 06:20:51',NULL,'XL','Sky Blue','teen-top-zip-neck-sh-c04a32a5',2),(24,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-024','','2026-06-07 06:20:51',NULL,'XL','Cream','teen-top-zip-neck-sh-c04a32a5',2),(25,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-025','','2026-06-07 06:20:51',NULL,'XL','Black','teen-top-zip-neck-sh-c04a32a5',2),(26,'Teen Top Zip-Neck Short Sleeve Shirt','Shirts',390.00,550.00,1,'SHI-026','','2026-06-07 06:20:51',NULL,'XL','White','teen-top-zip-neck-sh-c04a32a5',2),(27,'Teen Top Button-Neck Short Sleeve Shirt - Line','Shirts',390.00,550.00,1,'SHI-027','','2026-06-07 06:24:24',NULL,'M','White','teen-top-button-neck-1899239e',2),(28,'Teen Top Button-Neck Short Sleeve Shirt - Line','Shirts',390.00,550.00,1,'SHI-028','','2026-06-07 06:24:24',NULL,'L','White','teen-top-button-neck-1899239e',2),(29,'Teen Top Button-Neck Short Sleeve Shirt - Line','Shirts',390.00,550.00,1,'SHI-029','','2026-06-07 06:24:24',NULL,'L','Cream','teen-top-button-neck-1899239e',2),(30,'Teen Top Button-Neck Short Sleeve Shirt - Line','Shirts',390.00,550.00,1,'SHI-030','','2026-06-07 06:24:24',NULL,'XL','White','teen-top-button-neck-1899239e',2),(31,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,1,'SHI-031','','2026-06-07 06:33:54',NULL,'M','Dark Gray','teen-top-button-neck-eab93b0b',2),(32,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,1,'SHI-032','','2026-06-07 06:33:54',NULL,'M','Cream','teen-top-button-neck-eab93b0b',2),(33,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,2,'SHI-033','','2026-06-07 06:33:54',NULL,'M','Black','teen-top-button-neck-eab93b0b',2),(34,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,1,'SHI-034','','2026-06-07 06:33:54',NULL,'M','Dark Blue','teen-top-button-neck-eab93b0b',2),(35,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,2,'SHI-035','','2026-06-07 06:33:54',NULL,'L','Dark Gray','teen-top-button-neck-eab93b0b',2),(36,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,1,'SHI-036','','2026-06-07 06:33:54',NULL,'L','Cream','teen-top-button-neck-eab93b0b',2),(37,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,3,'SHI-037','','2026-06-07 06:33:54',NULL,'L','Black','teen-top-button-neck-eab93b0b',2),(38,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,2,'SHI-038','','2026-06-07 06:33:54',NULL,'XL','Black','teen-top-button-neck-eab93b0b',2),(39,'Teen Top Button-Neck Short Sleeve Shirt - Plain','Shirts',390.00,550.00,1,'SHI-039','','2026-06-07 06:33:54',NULL,'XL','White','teen-top-button-neck-eab93b0b',2);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recurring_expenses`
--

DROP TABLE IF EXISTS `recurring_expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_expenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `description` text,
  `frequency` varchar(50) NOT NULL DEFAULT 'monthly',
  `next_due_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `shop_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `recurring_expenses_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recurring_expenses`
--

LOCK TABLES `recurring_expenses` WRITE;
/*!40000 ALTER TABLE `recurring_expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `recurring_expenses` ENABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_returns`
--

LOCK TABLES `sale_returns` WRITE;
/*!40000 ALTER TABLE `sale_returns` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,3,NULL,'',320.00,140.00,80.00,'cash',320.00,'[{\"product_id\": 3, \"name\": \"Hyper Start Velvet Line Long Sleeve Shirt - 2 Pocket\", \"sku\": \"SHI-003\", \"size\": \"L\", \"color\": \"Dark Brown\", \"price\": 400, \"cost_price\": 140, \"quantity\": 1, \"discount\": 0, \"discount_type\": \"fixed\", \"max_stock\": 1}]','2026-06-07 11:47:47',2);
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
  `shop_id` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_key_shop` (`key`,`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'brand_name','POS System',NULL,'2026-06-07 03:27:10'),(2,'session_timeout','1800',NULL,'2026-06-07 03:27:10'),(3,'smtp_server','',NULL,'2026-06-07 03:27:10'),(4,'smtp_port','587',NULL,'2026-06-07 03:27:10'),(5,'smtp_username','',NULL,'2026-06-07 03:27:10'),(6,'smtp_password','',NULL,'2026-06-07 03:27:10'),(7,'alert_email','',NULL,'2026-06-07 03:27:10'),(8,'low_stock_threshold','5',NULL,'2026-06-07 03:27:10'),(9,'scheduler_times','[\"09:00\", \"12:00\", \"18:00\"]',NULL,'2026-06-07 03:27:10'),(10,'smtp_server','',1,'2026-06-07 03:27:10'),(11,'smtp_port','587',1,'2026-06-07 03:27:10'),(12,'smtp_username','',1,'2026-06-07 03:27:10'),(13,'smtp_password','',1,'2026-06-07 03:27:10'),(14,'alert_email','',1,'2026-06-07 03:27:10'),(15,'low_stock_threshold','5',1,'2026-06-07 03:27:10'),(16,'smtp_server','smtp.gmail.com',2,'2026-06-07 03:30:32'),(17,'smtp_port','587',2,'2026-06-07 03:30:32'),(18,'smtp_username','kumarar.cumdy@gmail.com',2,'2026-06-07 03:30:32'),(19,'alert_email','kumarar.cumdy@gmail.com,hansumon.kk@gmail.com',2,'2026-06-07 03:30:32'),(20,'low_stock_threshold','5',2,'2026-06-07 03:30:32'),(21,'smtp_password','unhymrfsdnyiarqo',2,'2026-06-07 03:30:32');
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
INSERT INTO `shops` VALUES (1,'Default Shop',NULL,NULL,'🛒','$',5,'2026-06-07 03:27:10'),(2,'Men\'s Wear','Shop No. 74, 1st Floor, Soi 2 Indra Square Bangkok 10400 Thailand','+66941104272','👔','฿',5,'2026-06-07 03:28:10');
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
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_history`
--

LOCK TABLES `stock_history` WRITE;
/*!40000 ALTER TABLE `stock_history` DISABLE KEYS */;
INSERT INTO `stock_history` VALUES (1,1,2,'initial','Initial stock | Variant: M White','2026-06-07 05:20:31',2),(2,2,2,'initial','Initial stock | Variant: M Black','2026-06-07 05:20:31',2),(3,3,1,'initial','Initial stock | Variant: L Dark Brown','2026-06-07 05:20:31',2),(4,4,1,'initial','Initial stock | Variant: L Khaki','2026-06-07 05:20:31',2),(5,5,1,'initial','Initial stock | Variant: L Maroon','2026-06-07 05:20:31',2),(6,6,2,'initial','Initial stock | Variant: XL Black','2026-06-07 05:20:31',2),(7,7,2,'initial','Initial stock | Variant: XL Dark Brown','2026-06-07 05:20:31',2),(8,8,2,'initial','Initial stock | Variant: XL Gray','2026-06-07 05:20:31',2),(9,9,1,'initial','Initial stock | Variant: XL Dark Gray','2026-06-07 05:20:31',2),(10,10,2,'initial','Initial stock | Variant: M White','2026-06-07 05:36:23',2),(11,11,2,'initial','Initial stock | Variant: M Black','2026-06-07 05:36:23',2),(12,12,1,'initial','Initial stock | Variant: M Brown','2026-06-07 05:36:23',2),(13,13,2,'initial','Initial stock | Variant: M Khaki','2026-06-07 05:36:23',2),(14,14,3,'initial','Initial stock | Variant: XL Black','2026-06-07 05:36:23',2),(15,15,4,'initial','Initial stock | Variant: XL Brown','2026-06-07 05:36:23',2),(16,16,3,'initial','Initial stock | Variant: XL Gray','2026-06-07 05:36:23',2),(17,17,3,'initial','Initial stock | Variant: XL Dark Blue','2026-06-07 05:36:23',2),(18,2,-2,'export','Miss-counted, needed to remove','2026-06-07 05:49:13',2),(19,1,-2,'export','Miss-counted, needed to remove','2026-06-07 05:49:24',2),(20,18,3,'initial','Initial stock | Variant: XL Brown','2026-06-07 06:02:32',2),(21,19,1,'initial','Initial stock | Variant: XXXL Teal Blue-Green','2026-06-07 06:02:32',2),(22,20,2,'initial','Initial stock | Variant: XXXL Brown','2026-06-07 06:02:32',2),(23,21,1,'initial','Initial stock | Variant: M Brown','2026-06-07 06:20:51',2),(24,22,1,'initial','Initial stock | Variant: L Cream','2026-06-07 06:20:51',2),(25,23,1,'initial','Initial stock | Variant: XL Sky Blue','2026-06-07 06:20:51',2),(26,24,1,'initial','Initial stock | Variant: XL Cream','2026-06-07 06:20:51',2),(27,25,1,'initial','Initial stock | Variant: XL Black','2026-06-07 06:20:51',2),(28,26,1,'initial','Initial stock | Variant: XL White','2026-06-07 06:20:51',2),(29,27,1,'initial','Initial stock | Variant: M White','2026-06-07 06:24:24',2),(30,28,1,'initial','Initial stock | Variant: L White','2026-06-07 06:24:24',2),(31,29,1,'initial','Initial stock | Variant: L Cream','2026-06-07 06:24:24',2),(32,30,1,'initial','Initial stock | Variant: XL White','2026-06-07 06:24:24',2),(33,31,1,'initial','Initial stock | Variant: M Dark Gray','2026-06-07 06:33:54',2),(34,32,1,'initial','Initial stock | Variant: M Cream','2026-06-07 06:33:54',2),(35,33,2,'initial','Initial stock | Variant: M Black','2026-06-07 06:33:54',2),(36,34,1,'initial','Initial stock | Variant: M Dark Blue','2026-06-07 06:33:54',2),(37,35,2,'initial','Initial stock | Variant: L Dark Gray','2026-06-07 06:33:54',2),(38,36,1,'initial','Initial stock | Variant: L Cream','2026-06-07 06:33:54',2),(39,37,3,'initial','Initial stock | Variant: L Black','2026-06-07 06:33:54',2),(40,38,2,'initial','Initial stock | Variant: XL Black','2026-06-07 06:33:54',2),(41,39,1,'initial','Initial stock | Variant: XL White','2026-06-07 06:33:54',2),(42,3,-1,'sale','Sale by kharal','2026-06-07 11:47:47',2);
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
INSERT INTO `suppliers` VALUES (1,'Burmelin','','','','','','2026-06-07 03:32:01',2),(2,'BooBay Plaza','','','','','','2026-06-07 03:32:08',2),(3,'Teentop','','','','','','2026-06-07 03:32:14',2);
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_shops`
--

DROP TABLE IF EXISTS `user_shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_shops` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `shop_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_shop` (`user_id`,`shop_id`),
  KEY `shop_id` (`shop_id`),
  CONSTRAINT `user_shops_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_shops_ibfk_2` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_shops`
--

LOCK TABLES `user_shops` WRITE;
/*!40000 ALTER TABLE `user_shops` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_shops` ENABLE KEYS */;
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
  `last_login` datetime DEFAULT NULL,
  `shop_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','e34f92a20532a873cb3184398070b4b82a8fa29cf48572c203dc5f0fa6158231','super_admin','Super Administrator','2026-06-07 03:27:10','2026-06-08 15:39:50',NULL),(2,'admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','admin','Administrator','2026-06-07 03:27:10',NULL,1),(3,'kharal','802b33a5151e8e934c234c209e9e0da13bbad675ba73505ed358df5d083f7410','admin','Kumarar Kharal','2026-06-07 03:29:21','2026-06-07 13:21:19',2),(4,'thila','c0b0934be9493bd7a6daaaf002e53c178d518f955a00c1c791e3efdc712a262b','admin','Thila Kharal','2026-06-07 03:31:18','2026-06-08 07:06:16',2);
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

-- Dump completed on 2026-06-08 22:58:59
