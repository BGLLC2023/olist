CREATE DATABASE olist;
USE olist;
-- olist_customers_dataset 
CREATE TABLE customers(
	customer_id VARCHAR(255) UNIQUE PRIMARY KEY,
    custumer_unique_id VARCHAR(255),  -- sic: matches source column name
    customer_zip_code_prefix INT,
    customer_city VARCHAR(255),
    customer_state VARCHAR(255)
);
select * from customers limit 5;
-- orders 
CREATE TABLE orders(
	order_id VARCHAR(255) PRIMARY KEY NOT NULL,
    customer_id VARCHAR(255),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,  -- fixed typo
    -- constraint customers 1:m orders
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
select * from orders limit 5;
-- products 
CREATE TABLE products(
	product_id VARCHAR(255) PRIMARY KEY,
    product_category VARCHAR(255),
    product_name_lenght SMALLINT,          -- sic on column name; type fixed (character count, not text)
    product_description_lenght SMALLINT,   -- sic on column name; type fixed
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT, 
    product_width_cm INT
);
ALTER TABLE products
ADD COLUMN category_id INT;
SET SQL_SAFE_UPDATES = 0;
UPDATE products
SET category_id = NULL;
UPDATE products p
SET category_id = (
    SELECT category_id  
    FROM category c 
    WHERE c.product_category_name = p.product_category
);
SELECT * FROM products limit 5;
ALTER TABLE products
ADD CONSTRAINT fk_category
FOREIGN KEY (category_id) REFERENCES category(category_id);
ALTER TABLE products
DROP COLUMN product_category;
SET SQL_SAFE_UPDATES = 1;
-- sellers
select category_id from category limit 5;
CREATE TABLE sellers(
	seller_id VARCHAR(255) PRIMARY KEY,
    seller_zip_code INT,
    seller_city VARCHAR(255),
    seller_state VARCHAR(2)
);
-- order items 
CREATE TABLE orderitems(
	order_id VARCHAR(255),
    order_item_id INT,
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),           
    freight_value DECIMAL(10,2),   
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
-- order payments
CREATE TABLE order_payments(
	order_id VARCHAR(255),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),  
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- order reviews
CREATE TABLE order_reviews(
	review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score INT, 
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(255),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE category(
	category_id INT UNIQUE AUTO_INCREMENT PRIMARY KEY,
	product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);


