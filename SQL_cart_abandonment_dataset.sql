GRANT FILE ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;

CREATE DATABASE shopsphere;
USE shopsphere;

CREATE TABLE customers (
Customer_ID VARCHAR(20),
Gender VARCHAR(20),
Age INT,
Marital_Status VARCHAR(20),
City VARCHAR(100),
State VARCHAR(100),
Income_Bracket VARCHAR(20),
Annual_Income DOUBLE,
Occupation VARCHAR(100),
Customer_Segment VARCHAR(50),
Signup_Date DATE,
Loyalty_Tier VARCHAR(20),
Preferred_Channel VARCHAR(50),
App_User_Flag INT,
Credit_Score INT,
Household_Size INT,
Tenure_Months INT,
Last_Login_Days_Ago INT
);

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/mysql_files/Customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from customers;

CREATE TABLE website_activity (
    Session_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Visit_Date DATE,
    Device_Type VARCHAR(30),
    Traffic_Source VARCHAR(50),
    Pages_Viewed INT,
    Session_Duration DECIMAL(10,2),
    Added_To_Cart TINYINT,
    Purchased TINYINT,
    Purchase_After_Cart TINYINT
);

LOAD DATA LOCAL INFILE 'C:/mysql_files/Website_Activity.csv'
INTO TABLE website_activity
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from website_activity;

CREATE TABLE customer_department_targets (
    Customer_ID VARCHAR(20),
    Age INT,
    Loyalty_Tier VARCHAR(20),
    Credit_Score INT,
    Tenure_Months INT,
    Last_Login_Days_Ago INT,
    Total_Orders INT,
    Total_Revenue DECIMAL(15,2),
    Avg_Order_Value DECIMAL(15,2),
    Total_Quantity INT,
    Recency_Days INT,
    Total_Tickets INT,
    Avg_Satisfaction DECIMAL(5,2),
    Escalation_Rate DECIMAL(5,3),
    Campaigns_Received INT,
    Campaign_Open_Rate DECIMAL(5,3),
    Campaign_Click_Rate DECIMAL(5,3),
    Campaign_Response_Rate DECIMAL(5,3),
    Total_Sessions INT,
    Avg_Pages_Viewed DECIMAL(10,2),
    Cart_Rate DECIMAL(5,3),
    Web_Purchase_Rate DECIMAL(5,3),
    Churn_Flag TINYINT,
    Future_VIP_Flag TINYINT,
    Customer_Lifetime_Value DECIMAL(15,2)
);

LOAD DATA LOCAL INFILE 'C:/mysql_files/Customer_Department_Targets.csv'
INTO TABLE customer_department_targets
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from customer_department_targets;

CREATE TABLE marketing_campaigns (
    Campaign_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Campaign_Type VARCHAR(50),
    Send_Date DATE,
    Opened TINYINT,
    Clicked TINYINT,
    Purchased TINYINT,
    Campaign_Cost DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'C:/mysql_files/Marketing_Campaigns.csv'
INTO TABLE marketing_campaigns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from marketing_campaigns
limit 10;

CREATE TABLE orders (
    Order_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Store_ID VARCHAR(20),
    Order_Date DATE,
    Quantity INT,
    Unit_Price DECIMAL(15,2),
    Discount DECIMAL(5,2),
    Final_Amount DECIMAL(15,2),
    Payment_Method VARCHAR(30),
    Delivery_Mode VARCHAR(30),
    Order_Status VARCHAR(30)
);

LOAD DATA LOCAL INFILE 'C:/mysql_files/Orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from orders
limit 10;

show tables;

ALTER TABLE customers
ADD PRIMARY KEY (Customer_ID);

ALTER TABLE website_activity
ADD PRIMARY KEY (Session_ID);

ALTER TABLE orders
ADD PRIMARY KEY (Order_ID);

ALTER TABLE marketing_campaigns
ADD PRIMARY KEY (Campaign_ID);

SELECT COUNT(DISTINCT Customer_ID)
FROM customers;

SELECT COUNT(DISTINCT Customer_ID)
FROM website_activity;

# Data Quality check 

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM website_activity;

SELECT COUNT(*) FROM orders;

# Checeking if null value present in customer_id column of website _activity table
SELECT
COUNT(*) total_rows,
SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) missing_age,
SUM(CASE WHEN Income_Bracket IS NULL THEN 1 ELSE 0 END) missing_income,
SUM(CASE WHEN Occupation IS NULL THEN 1 ELSE 0 END) missing_occupation,
SUM(CASE WHEN Loyalty_Tier IS NULL THEN 1 ELSE 0 END) missing_loyalty
FROM customers;

SELECT
SUM(CASE WHEN Pages_Viewed IS NULL THEN 1 ELSE 0 END) missing_pages,
SUM(CASE WHEN Session_Duration IS NULL THEN 1 ELSE 0 END) missing_duration,
SUM(CASE WHEN Device_Type IS NULL THEN 1 ELSE 0 END) missing_device
FROM website_activity;


# checking if duplicate customer_id present in customers table
SELECT
Customer_ID,
COUNT(*) duplicate_count
FROM customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

SELECT
COUNT(*) total_duplicate_records
FROM
(
SELECT Customer_ID
FROM customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1
) x;

SELECT
Session_ID,
COUNT(*)
FROM website_activity
GROUP BY Session_ID
HAVING COUNT(*) > 1;

# Checking Categorical Labels

SELECT DISTINCT Gender
FROM customers;

SELECT DISTINCT Loyalty_Tier
FROM customers;

SELECT DISTINCT Device_Type
FROM website_activity;

SELECT DISTINCT Traffic_Source
FROM website_activity;

# Data anomalies
# checking if future customer signup date is present
SELECT *
FROM customers
WHERE Signup_Date > CURDATE();

# Is there website visit date from future
SELECT *
FROM website_activity
WHERE Visit_Date > CURDATE();

#Checking if there is future order date
SELECT *
FROM orders
WHERE Order_Date > CURDATE();

# Negative tenure month
SELECT *
FROM customers
WHERE Tenure_Months < 0;

# Last login negative
SELECT *
FROM customers
WHERE Last_Login_Days_Ago < 0;

# Outlier detction
# Income outlier by min max method
SELECT
MIN(Annual_Income),
MAX(Annual_Income),
AVG(Annual_Income)
FROM customers;

SELECT *
FROM customers
ORDER BY Annual_Income DESC
LIMIT 20;

# The highest income ($34.16 million) is 33 times larger than your average income ($1.02 million), 
# and even the 20th highest income ($14.36 million) is 14 times larger than the average.
# So there is outlier's present

# Searching for outliers in Quantity
SELECT
MIN(Quantity),
MAX(Quantity),
AVG(Quantity)
FROM orders;

SELECT *
FROM orders
ORDER BY Quantity DESC
LIMIT 20;

# These values are highly unusual because the average order quantity is only about 3 items, 
# but someone suddenly bought 51 items in a single order. This is over 16 times larger than the average.

# Sales outlier detection
SELECT
MIN(Final_Amount),
MAX(Final_Amount),
AVG(Final_Amount)
FROM orders;

SELECT *
FROM orders
ORDER BY Final_Amount DESC
LIMIT 20;

# Distribution Analysis

SELECT 
    CASE 
        WHEN Annual_Income < 500000 THEN 'Low'
        WHEN Annual_Income < 1500000 THEN 'Medium'
        WHEN Annual_Income < 5000000 THEN 'High'
        ELSE 'Very High'
    END AS Income_Group,
    COUNT(*) AS Customers
FROM customers
GROUP BY Income_Group
ORDER BY CASE Income_Group
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
        WHEN 'Very High' THEN 4
    END;

# I adjusted the thresholds so that the $1.02 million dataset average sits naturally in the "Medium" bucket, 
# while isolating your multi-million dollar outlier values into the "Very High" bucket.

# Order Value distribution
SELECT 
    CASE 
        WHEN Final_Amount < 1000 THEN '0-1K'
        WHEN Final_Amount < 5000 THEN '1K-5K'
        WHEN Final_Amount < 10000 THEN '5K-10K'
        WHEN Final_Amount < 25000 THEN '10K-25K'
        WHEN Final_Amount < 50000 THEN '25K-50K'
        ELSE '50K+'
    END AS Value_Band,
    COUNT(*) AS Order_Count
FROM orders
GROUP BY Value_Band
ORDER BY 
    CASE Value_Band
        WHEN '0-1K'   THEN 1
        WHEN '1K-5K'  THEN 2
        WHEN '5K-10K' THEN 3
        WHEN '10K-25K' THEN 4
        WHEN '25K-50K' THEN 5
        ELSE 6
    END;

# This output reveals that your store primarily generates revenue from a highly lucrative premium market, 
# with nearly 46% of all orders exceeding $10,000 and a steady, healthy distribution across mid-tier and budget buyers.

#Target variable Analysis

SELECT
Purchase_After_Cart,
COUNT(*) records,
ROUND (COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) percentage
FROM website_activity
WHERE Added_To_Cart=1
GROUP BY Purchase_After_Cart;

# The output shows a major conversion bottleneck, revealing that 68.20% of users who add items to their cart leave 
# without buying anything, while only 31.80% successfully complete their purchase.

# Cart Conversion rate
SELECT
ROUND(AVG(Purchase_After_Cart)*100,2) AS conversion_rate
FROM website_activity
WHERE Added_To_Cart=1;

# This metric showing that your overall cart-to-purchase conversion rate is 31.80%.

# Device Conversion
SELECT
Device_Type,
ROUND(AVG(Purchase_After_Cart)*100,2) as Device_Conversion_Rate
FROM website_activity
WHERE Added_To_Cart=1
GROUP BY Device_Type;

# This output shows that device type has absolutely no impact on checkout behavior, 
# as the conversion rate remains remarkably flat and completely identical at roughly 31% to 32% across all platforms.

# Loyalty Tier Conversion
SELECT
c.Loyalty_Tier,
ROUND(AVG(w.Purchase_After_Cart)*100,2) as Loyalty_conversion_rate
FROM website_activity w
JOIN customers c
ON w.Customer_ID=c.Customer_ID
WHERE w.Added_To_Cart=1
GROUP BY c.Loyalty_Tier;

# This output shows that loyalty programs are a massive driver of sales, 
# with conversion rates scaling dramatically upward from Bronze (24.43%) all the way to Platinum (46.93%).

# Traffic source analysis
SELECT
Traffic_Source,
COUNT(*) Sessions,
ROUND(AVG(Purchase_After_Cart)*100,2) Conversion_Rate
FROM website_activity
WHERE Added_To_Cart=1
GROUP BY Traffic_Source
ORDER BY Conversion_Rate DESC;

# This output shows that traffic source has no meaningful impact on buyer intent, 
# as conversion rates stay completely locked near 32% across all channels, including a minor cluster of 3,228 records 
# with missing source data that convert at 31.47%.

# APP users analysis
SELECT
c.App_User_Flag,
COUNT(*) Sessions,
ROUND(AVG(w.Purchase_After_Cart)*100,2) Conversion_Rate
FROM website_activity w
JOIN customers c
ON w.Customer_ID = c.Customer_ID
WHERE w.Added_To_Cart=1
GROUP BY c.App_User_Flag;

# If customers who download and use your official mobile app are 
# more likely to buy the items in their cart compared to customers who only shop on your website.

# Customer Segment Analysis
SELECT
c.Customer_Segment,
ROUND(AVG(w.Purchase_After_Cart)*100,2) Conversion_Rate
FROM website_activity w
JOIN customers c
ON w.Customer_ID = c.Customer_ID
WHERE w.Added_To_Cart=1
GROUP BY c.Customer_Segment;

# By looking at Customer_Segment, you are checking if marketing groups 
# (like people who love deals versus people who buy premium items) behave differently at the final checkout step.

# Page Viewed Impact
SELECT
CASE
WHEN Pages_Viewed <=5 THEN 'Low'
WHEN Pages_Viewed <=10 THEN 'Medium'
ELSE 'High'
END AS Page_Group,
ROUND(AVG(Purchase_After_Cart)*100,2) Conversion_Rate
FROM website_activity
WHERE Added_To_Cart=1
GROUP BY Page_Group;

# This output shows that website engagement is an incredibly powerful driver of sales, 
# with conversion rates soaring from 24.43% for low-engagement browsers up to 42.96% for highly active users.

# Seesion during impact analysis
SELECT
    CASE
        WHEN Session_Duration < 5 THEN 'Very Low (<5 min)'
        WHEN Session_Duration < 15 THEN 'Low (5-15 min)'
        WHEN Session_Duration < 30 THEN 'Medium (15-30 min)'
        ELSE 'High (30+ min)'
    END AS Session_Group,
    COUNT(*) AS Total_Sessions,
	ROUND(AVG(Purchase_After_Cart) * 100,2) AS Conversion_Rate
FROM website_activity
WHERE Added_To_Cart = 1
GROUP BY Session_Group
ORDER BY
CASE
    WHEN Session_Group='Very Low (<5 min)' THEN 1
    WHEN Session_Group='Low (5-15 min)' THEN 2
    WHEN Session_Group='Medium (15-30 min)' THEN 3
    ELSE 4
END;

# This output shows that the longer a customer stays on your website, the more likely they are to buy, 
# with conversion rates nearly doubling from 27.52% for quick sessions up to a massive 50.77% for long sessions.

# Revenue history impact
SELECT
CASE
    WHEN cdt.Total_Revenue < 10000 THEN 'Low Revenue'
    WHEN cdt.Total_Revenue < 50000 THEN 'Medium Revenue'
    WHEN cdt.Total_Revenue < 100000 THEN 'High Revenue'
    ELSE 'VIP Revenue'
END AS Revenue_Group,
COUNT(*) AS Sessions,
ROUND(AVG(w.Purchase_After_Cart) * 100,2) AS Conversion_Rate
FROM website_activity w
JOIN customer_department_targets cdt
ON w.Customer_ID = cdt.Customer_ID
WHERE w.Added_To_Cart = 1
GROUP BY Revenue_Group
ORDER BY
CASE
WHEN Revenue_Group='Low Revenue' THEN 1
WHEN Revenue_Group='Medium Revenue' THEN 2
WHEN Revenue_Group='High Revenue' THEN 3
ELSE 4
END;

# The output shows that a customer's total historical spending history has no influence on their current cart behavior, 
# as conversion rates remain completely flat at roughly 31% to 32% across all revenue tiers.

# Recent login analusis
SELECT
CASE
    WHEN c.Last_Login_Days_Ago <= 7 THEN 'Active (0-7 Days)'
    WHEN c.Last_Login_Days_Ago <= 30 THEN 'Recent (8-30 Days)'
    WHEN c.Last_Login_Days_Ago <= 90 THEN 'Inactive (31-90 Days)'
    ELSE 'Dormant (90+ Days)'
END AS Login_Recency,
COUNT(*) AS Sessions,
ROUND(AVG(w.Purchase_After_Cart) * 100,2) AS Conversion_Rate
FROM website_activity w
JOIN customers c
ON w.Customer_ID = c.Customer_ID
WHERE w.Added_To_Cart = 1
GROUP BY Login_Recency
ORDER BY
CASE
WHEN Login_Recency='Active (0-7 Days)' THEN 1
WHEN Login_Recency='Recent (8-30 Days)' THEN 2
WHEN Login_Recency='Inactive (31-90 Days)' THEN 3
ELSE 4
END;

# This output shows that login recency is a powerful predictor of purchase intent, 
# with conversion rates dropping significantly from 41.58% for highly active users down to just 22.24% for dormant ones.

-- Original rows
SELECT COUNT(*)
FROM website_activity
WHERE Added_To_Cart=1;

-- Rows after join
SELECT COUNT(*)
FROM website_activity w
JOIN customers c
ON w.Customer_ID=c.Customer_ID
JOIN customer_department_targets cdt
ON w.Customer_ID=cdt.Customer_ID
WHERE w.Added_To_Cart=1;

-- Customers missing in CDT
SELECT COUNT(*)
FROM website_activity w
LEFT JOIN customer_department_targets cdt
ON w.Customer_ID=cdt.Customer_ID
WHERE cdt.Customer_ID IS NULL;

# Creating new dataset

CREATE TABLE cart_abandonment_dataset AS
SELECT
w.Session_ID,
w.Customer_ID,
w.Pages_Viewed,
w.Session_Duration,
w.Device_Type,
w.Traffic_Source,
c.Age,
c.Annual_Income,
c.Loyalty_Tier,
c.App_User_Flag,
c.Tenure_Months,
cdt.Total_Orders,
cdt.Total_Revenue,
cdt.Avg_Order_Value,
cdt.Recency_Days,
cdt.Campaign_Response_Rate,
cdt.Web_Purchase_Rate,
w.Purchase_After_Cart
FROM website_activity w
JOIN customers c
ON w.Customer_ID=c.Customer_ID
JOIN customer_department_targets cdt
ON w.Customer_ID=cdt.Customer_ID
WHERE w.Added_To_Cart=1;