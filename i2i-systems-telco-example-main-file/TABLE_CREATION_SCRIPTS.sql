------------------------------------------------------------
-- TABLE CREATION SCRIPT (FINAL CLEAN VERSION)
------------------------------------------------------------

-- 1. TARIFFS TABLE (independent table first)
CREATE TABLE TARIFFS (
    tariff_id NUMBER PRIMARY KEY,
    tariff_name VARCHAR2(100),
    data_limit NUMBER,
    minute_limit NUMBER,
    sms_limit NUMBER
);

------------------------------------------------------------

-- 2. CUSTOMERS TABLE (no FK yet to avoid creation errors)
CREATE TABLE CUSTOMERS (
    customer_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    city VARCHAR2(100),
    signup_date DATE,
    tariff_id NUMBER
);

------------------------------------------------------------

-- 3. USAGE_DATA TABLE (no FK yet)
CREATE TABLE USAGE_DATA (
    customer_id NUMBER PRIMARY KEY,
    data_used NUMBER,
    minutes_used NUMBER,
    sms_used NUMBER,
    status VARCHAR2(20)
);

------------------------------------------------------------
-- 4. ADD FOREIGN KEYS (AFTER TABLES EXIST)
------------------------------------------------------------

-- Link customers to tariffs
ALTER TABLE CUSTOMERS
ADD CONSTRAINT fk_tariff
FOREIGN KEY (tariff_id)
REFERENCES TARIFFS(tariff_id);

-- Link usage data to customers
ALTER TABLE USAGE_DATA
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES CUSTOMERS(customer_id);
