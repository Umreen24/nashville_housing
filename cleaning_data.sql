-- Cleaning data in SQL

SELECT *
FROM nashville_housing;

---------------------------

-- Standardize date format

SELECT CAST(sale_date AS date)
FROM nashville_housing;

---------------------------

-- Populate property address data

SELECT *
FROM nashville_housing
--WHERE property_address IS NULL;
ORDER BY parcel_id;


-- Need to do a self join 

SELECT nh_a.parcel_id, nh_a.property_address, nh_b.parcel_id, nh_b.property_address
FROM nashville_housing nh_a
JOIN nashville_housing nh_b
	ON nh_a.parcel_id = nh_b.parcel_id
	AND nh_a.unique_id <> nh_b.unique_id;

UPDATE nashville_housing
SET property_address = COALESCE(NULLIF(nashville_housing.property_address, ''), nh_b.property_address)
FROM nashville_housing AS nh_b
WHERE nashville_housing.parcel_id = nh_b.parcel_id AND nashville_housing.unique_id <> nh_b.unique_id AND nashville_housing.property_address IS NULL;

---------------------------

-- Break out address into individual columns (address, city, state)

SELECT property_address
FROM nashville_housing;
--WHERE property_address IS NULL;
--ORDER BY parcel_id;

SELECT 
SUBSTRING(property_address, 1, POSITION(',' in property_address) -1) AS address
, SUBSTRING(property_address, POSITION(',' in property_address) + 1, LENGTH(property_address)) AS address
FROM nashville_housing;
