-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Nov 22, 2026 at 08:12 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `olist_ecommerce`
--

-- --------------------------------------------------------

--
-- Table structure for table `category_translation`
--

CREATE TABLE `category_translation` (
  `product_category_name` varchar(100) NOT NULL,
  `product_category_name_english` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customer_id` varchar(50) NOT NULL,
  `customer_unique_id` varchar(50) NOT NULL,
  `customer_zip_code_prefix` varchar(10) DEFAULT NULL,
  `customer_city` varchar(100) DEFAULT NULL,
  `customer_state` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customer_rfm_segments`
--

CREATE TABLE `customer_rfm_segments` (
  `customer_unique_id` varchar(50) NOT NULL,
  `recency_days` int(11) NOT NULL,
  `frequency` int(11) NOT NULL,
  `monetary` decimal(12,2) NOT NULL,
  `R_score` int(11) NOT NULL,
  `F_score` int(11) NOT NULL,
  `M_score` int(11) NOT NULL,
  `RFM_score` varchar(3) NOT NULL,
  `RFM_total` int(11) NOT NULL,
  `customer_segment` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `geolocation`
--

CREATE TABLE `geolocation` (
  `geolocation_zip_code_prefix` varchar(10) DEFAULT NULL,
  `geolocation_lat` decimal(10,7) DEFAULT NULL,
  `geolocation_lng` decimal(10,7) DEFAULT NULL,
  `geolocation_city` varchar(100) DEFAULT NULL,
  `geolocation_state` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` varchar(50) NOT NULL,
  `customer_id` varchar(50) NOT NULL,
  `order_status` varchar(30) NOT NULL,
  `order_purchase_timestamp` datetime NOT NULL,
  `order_approved_at` datetime DEFAULT NULL,
  `order_delivered_carrier_date` datetime DEFAULT NULL,
  `order_delivered_customer_date` datetime DEFAULT NULL,
  `order_estimated_delivery_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_id` varchar(50) NOT NULL,
  `order_item_id` int(11) NOT NULL,
  `product_id` varchar(50) NOT NULL,
  `seller_id` varchar(50) NOT NULL,
  `shipping_limit_date` datetime DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `freight_value` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_payments`
--

CREATE TABLE `order_payments` (
  `order_id` varchar(50) NOT NULL,
  `payment_sequential` int(11) NOT NULL,
  `payment_type` varchar(30) NOT NULL,
  `payment_installments` int(11) NOT NULL,
  `payment_value` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_reviews`
--

CREATE TABLE `order_reviews` (
  `review_id` varchar(50) NOT NULL,
  `order_id` varchar(50) NOT NULL,
  `review_score` int(11) NOT NULL,
  `review_comment_title` text DEFAULT NULL,
  `review_comment_message` text DEFAULT NULL,
  `review_creation_date` datetime DEFAULT NULL,
  `review_answer_timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` varchar(50) NOT NULL,
  `product_category_name` varchar(100) DEFAULT NULL,
  `product_name_lenght` int(11) DEFAULT NULL,
  `product_description_lenght` int(11) DEFAULT NULL,
  `product_photos_qty` int(11) DEFAULT NULL,
  `product_weight_g` decimal(10,2) DEFAULT NULL,
  `product_length_cm` decimal(10,2) DEFAULT NULL,
  `product_height_cm` decimal(10,2) DEFAULT NULL,
  `product_width_cm` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sellers`
--

CREATE TABLE `sellers` (
  `seller_id` varchar(50) NOT NULL,
  `seller_zip_code_prefix` varchar(10) DEFAULT NULL,
  `seller_city` varchar(100) DEFAULT NULL,
  `seller_state` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `category_translation`
--
ALTER TABLE `category_translation`
  ADD PRIMARY KEY (`product_category_name`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `customer_rfm_segments`
--
ALTER TABLE `customer_rfm_segments`
  ADD PRIMARY KEY (`customer_unique_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `fk_orders_customers` (`customer_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_id`,`order_item_id`),
  ADD KEY `fk_items_products` (`product_id`),
  ADD KEY `fk_items_sellers` (`seller_id`);

--
-- Indexes for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD PRIMARY KEY (`order_id`,`payment_sequential`);

--
-- Indexes for table `order_reviews`
--
ALTER TABLE `order_reviews`
  ADD PRIMARY KEY (`review_id`,`order_id`),
  ADD KEY `fk_reviews_orders` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `sellers`
--
ALTER TABLE `sellers`
  ADD PRIMARY KEY (`seller_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `fk_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `fk_items_sellers` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`seller_id`);

--
-- Constraints for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD CONSTRAINT `fk_payments_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

--
-- Constraints for table `order_reviews`
--
ALTER TABLE `order_reviews`
  ADD CONSTRAINT `fk_reviews_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
