CREATE SCHEMA IF NOT EXISTS dm;

CREATE TABLE dm.dim_date (
    date_key     SERIAL PRIMARY KEY,
    full_date    DATE       UNIQUE,
    day          SMALLINT,
    month        SMALLINT,
    quarter      SMALLINT,
    year         SMALLINT,
    day_of_week  SMALLINT,
    is_weekend   BOOLEAN
);

CREATE TABLE dm.dim_pet_type (
    pet_type_key SERIAL PRIMARY KEY,
    pet_type     TEXT       UNIQUE
);

CREATE TABLE dm.dim_pet_category (
    pet_cat_key  SERIAL PRIMARY KEY,
    pet_category TEXT       UNIQUE
);

CREATE TABLE dm.dim_pet_breed (
    pet_breed_key SERIAL PRIMARY KEY,
    pet_breed     TEXT       UNIQUE
);

CREATE TABLE dm.dim_pet (
    pet_key       SERIAL PRIMARY KEY,
    pet_type_key  INTEGER REFERENCES dm.dim_pet_type,
    pet_cat_key   INTEGER REFERENCES dm.dim_pet_category,
    pet_breed_key INTEGER REFERENCES dm.dim_pet_breed,
    pet_name      TEXT,
    UNIQUE (pet_type_key, pet_cat_key, pet_breed_key, pet_name)
);

CREATE TABLE dm.dim_customer (
    customer_key    SERIAL PRIMARY KEY,
    customer_id     INTEGER    UNIQUE,
    first_name      TEXT,
    last_name       TEXT,
    age             SMALLINT,
    email           TEXT,
    country         TEXT,
    postal_code     TEXT,
    pet_key         INTEGER    REFERENCES dm.dim_pet
);

CREATE TABLE dm.dim_seller (
    seller_key      SERIAL PRIMARY KEY,
    seller_id       INTEGER    UNIQUE,
    first_name      TEXT,
    last_name       TEXT,
    email           TEXT,
    country         TEXT,
    postal_code     TEXT
);

CREATE TABLE dm.dim_store (
    store_key     SERIAL PRIMARY KEY,
    name          TEXT,
    location      TEXT,
    city          TEXT,
    state         TEXT,
    country       TEXT,
    phone         TEXT,
    email         TEXT,
    UNIQUE (name, location)
);

CREATE TABLE dm.dim_supplier (
    supplier_key  SERIAL PRIMARY KEY,
    name          TEXT,
    contact       TEXT,
    email         TEXT,
    phone         TEXT,
    address       TEXT,
    city          TEXT,
    country       TEXT,
    UNIQUE (name, email)
);

CREATE TABLE dm.dim_product_category (
    prod_cat_key    SERIAL PRIMARY KEY,
    product_category TEXT       UNIQUE
);

CREATE TABLE dm.dim_product_color (
    color_key     SERIAL PRIMARY KEY,
    product_color TEXT       UNIQUE
);

CREATE TABLE dm.dim_product_brand (
    brand_key     SERIAL PRIMARY KEY,
    product_brand TEXT       UNIQUE
);

CREATE TABLE dm.dim_product_material (
    material_key    SERIAL PRIMARY KEY,
    product_material TEXT      UNIQUE
);

CREATE TABLE dm.dim_product_size (
    size_key      SERIAL PRIMARY KEY,
    product_size  TEXT       UNIQUE
);

CREATE TABLE dm.dim_product (
    product_key      SERIAL PRIMARY KEY,
    product_id       INTEGER    UNIQUE,
    name             TEXT,
    prod_cat_key     INTEGER    REFERENCES dm.dim_product_category,
    color_key        INTEGER    REFERENCES dm.dim_product_color,
    brand_key        INTEGER    REFERENCES dm.dim_product_brand,
    material_key     INTEGER    REFERENCES dm.dim_product_material,
    size_key         INTEGER    REFERENCES dm.dim_product_size,
    weight           NUMERIC(6,2),
    description      TEXT,
    rating           NUMERIC(3,1),
    reviews          INTEGER,
    release_date     DATE,
    expiry_date      DATE,
    supplier_key     INTEGER    REFERENCES dm.dim_supplier
);

CREATE TABLE dm.fact_sales (
    sale_key         SERIAL PRIMARY KEY,
    date_key         INTEGER REFERENCES dm.dim_date,
    customer_key     INTEGER REFERENCES dm.dim_customer,
    seller_key       INTEGER REFERENCES dm.dim_seller,
    store_key        INTEGER REFERENCES dm.dim_store,
    supplier_key     INTEGER REFERENCES dm.dim_supplier,
    pet_key          INTEGER REFERENCES dm.dim_pet,
    product_key      INTEGER REFERENCES dm.dim_product,
    sale_quantity    INTEGER,
    sale_total_price NUMERIC(12,2)
);
