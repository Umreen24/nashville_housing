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

-- Update empty columns with address

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

-- Removing comma from address

SELECT 
SUBSTRING(property_address, 1, POSITION(',' in property_address) -1) AS address
, SUBSTRING(property_address, POSITION(',' in property_address) + 1, LENGTH(property_address)) AS address
FROM nashville_housing;

-- Create two new columns to separate property address and city

ALTER TABLE nashville_housing
Add property_split_address text;

UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address, 1, POSITION(',' in property_address) -1);

ALTER TABLE nashville_housing
Add property_split_city text;

UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address, POSITION(',' in property_address) + 1, LENGTH(property_address));


--SELECT *
--FROM nashville_housing;

---------------------------

-- Split owner address

SELECT owner_address
FROM nashville_housing;

-- Using SPLIT_PART to split 
-- SQL Server equivalent is PARSENAME

SELECT 
SPLIT_PART(owner_address, ',', 1),
SPLIT_PART(owner_address, ',', 2),
SPLIT_PART(owner_address, ',', 3)
FROM nashville_housing;

-- Add split owner address columns to table and populate 

ALTER TABLE nashville_housing
Add owner_split_address text;

UPDATE nashville_housing
SET owner_split_address = SPLIT_PART(owner_address, ',', 1);

ALTER TABLE nashville_housing
Add owner_split_city text;

UPDATE nashville_housing
SET owner_split_city = SPLIT_PART(owner_address, ',', 2);

ALTER TABLE nashville_housing
Add owner_split_state text;

UPDATE nashville_housing
SET owner_split_state = SPLIT_PART(owner_address, ',', 3);

---------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" column 

-- Checking number of Yes and No in whole table 
-- Going to change Y and N to Yes and No as they have the highest count 

SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT sold_as_vacant,
CASE 
	WHEN sold_as_vacant = 'Y' THEN 'Yes'
	WHEN sold_as_vacant = 'N' THEN 'No'
	ELSE sold_as_vacant
	END
FROM nashville_housing;

UPDATE nashville_housing
SET sold_as_vacant = CASE 
	WHEN sold_as_vacant = 'Y' THEN 'Yes'
	WHEN sold_as_vacant = 'N' THEN 'No'
	ELSE sold_as_vacant
	END;
	
---------------------------

-- Remove duplicates

WITH cte_rownum AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference
	ORDER BY unique_id ) row_num
FROM nashville_housing
)
DELETE
FROM nashville_housing
WHERE parcel_id IN (SELECT parcel_id FROM cte_rownum WHERE row_num > 1);

-- Using select to check for duplicates after deletion
-- Replace DELETE query with SELECT query below
--SELECT *
--FROM cte_rownum
--WHERE row_num > 1
--ORDER BY property_address; 

---------------------------

-- Delete unused columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN property_address;

ALTER TABLE nashville_housing
DROP COLUMN owner_address;

ALTER TABLE nashville_housing
DROP COLUMN tax_district;