INSERT INTO dm.dim_date(full_date, day, month, quarter, year, day_of_week, is_weekend)
SELECT DISTINCT
    sale_date,
    EXTRACT(DAY   FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(YEAR  FROM sale_date),
    EXTRACT(DOW   FROM sale_date),
    (EXTRACT(DOW FROM sale_date) IN (0,6))
FROM staging.mock_data
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO dm.dim_pet_type(pet_type)
SELECT DISTINCT customer_pet_type
FROM staging.mock_data
ON CONFLICT (pet_type) DO NOTHING;

INSERT INTO dm.dim_pet_category(pet_category)
SELECT DISTINCT pet_category
FROM staging.mock_data
ON CONFLICT (pet_category) DO NOTHING;

INSERT INTO dm.dim_pet_breed(pet_breed)
SELECT DISTINCT customer_pet_breed
FROM staging.mock_data
ON CONFLICT (pet_breed) DO NOTHING;

INSERT INTO dm.dim_pet(pet_type_key, pet_cat_key, pet_breed_key, pet_name)
SELECT DISTINCT
    pt.pet_type_key,
    pc.pet_cat_key,
    pb.pet_breed_key,
    customer_pet_name
FROM staging.mock_data m
         JOIN dm.dim_pet_type     pt ON m.customer_pet_type = pt.pet_type
         JOIN dm.dim_pet_category pc ON m.pet_category       = pc.pet_category
         JOIN dm.dim_pet_breed    pb ON m.customer_pet_breed = pb.pet_breed
ON CONFLICT (pet_type_key, pet_cat_key, pet_breed_key, pet_name) DO NOTHING;

INSERT INTO dm.dim_customer(customer_id, first_name, last_name, age, email, country, postal_code, pet_key)
SELECT DISTINCT
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    p.pet_key
FROM staging.mock_data m
         JOIN dm.dim_pet p
              ON m.customer_pet_name = p.pet_name
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dm.dim_seller(seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM staging.mock_data
ON CONFLICT (seller_id) DO NOTHING;

INSERT INTO dm.dim_store(name, location, city, state, country, phone, email)
SELECT DISTINCT
    store_name, store_location, store_city, store_state, store_country, store_phone, store_email
FROM staging.mock_data
ON CONFLICT (name, location) DO NOTHING;

INSERT INTO dm.dim_supplier(name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
FROM staging.mock_data
ON CONFLICT (name, email) DO NOTHING;

INSERT INTO dm.dim_product_category(product_category)
SELECT DISTINCT product_category
FROM staging.mock_data
ON CONFLICT (product_category) DO NOTHING;

INSERT INTO dm.dim_product_color(product_color)
SELECT DISTINCT product_color
FROM staging.mock_data
ON CONFLICT (product_color) DO NOTHING;

INSERT INTO dm.dim_product_brand(product_brand)
SELECT DISTINCT product_brand
FROM staging.mock_data
ON CONFLICT (product_brand) DO NOTHING;

INSERT INTO dm.dim_product_material(product_material)
SELECT DISTINCT product_material
FROM staging.mock_data
ON CONFLICT (product_material) DO NOTHING;

INSERT INTO dm.dim_product_size(product_size)
SELECT DISTINCT product_size
FROM staging.mock_data
ON CONFLICT (product_size) DO NOTHING;

INSERT INTO dm.dim_product(
    product_id, name, prod_cat_key, color_key, brand_key, material_key, size_key,
    weight, description, rating, reviews, release_date, expiry_date, supplier_key
)
SELECT DISTINCT
    sale_product_id,
    product_name,
    pc.prod_cat_key,
    co.color_key,
    br.brand_key,
    ma.material_key,
    sz.size_key,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    sp.supplier_key
FROM staging.mock_data m
         JOIN dm.dim_product_category pc ON m.product_category = pc.product_category
         JOIN dm.dim_product_color    co ON m.product_color    = co.product_color
         JOIN dm.dim_product_brand    br ON m.product_brand    = br.product_brand
         JOIN dm.dim_product_material ma ON m.product_material = ma.product_material
         JOIN dm.dim_product_size     sz ON m.product_size     = sz.product_size
         JOIN dm.dim_supplier         sp ON m.supplier_name     = sp.name
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dm.fact_sales(
    date_key, customer_key, seller_key, store_key, supplier_key, pet_key, product_key,
    sale_quantity, sale_total_price
)
SELECT
    d.date_key,
    c.customer_key,
    s.seller_key,
    st.store_key,
    su.supplier_key,
    p.pet_key,
    pr.product_key,
    m.sale_quantity,
    m.sale_total_price
FROM staging.mock_data m
         JOIN dm.dim_date      d ON m.sale_date        = d.full_date
         JOIN dm.dim_customer  c ON m.sale_customer_id = c.customer_id
         JOIN dm.dim_seller    s ON m.sale_seller_id   = s.seller_id
         JOIN dm.dim_store     st ON m.store_name       = st.name
         JOIN dm.dim_supplier  su ON m.supplier_name    = su.name
         JOIN dm.dim_pet       p ON m.customer_pet_name = p.pet_name
         JOIN dm.dim_product   pr ON m.sale_product_id  = pr.product_id;
