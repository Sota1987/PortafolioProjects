/*

Cleaning Data in SQL Queries

*/


Select OwnerAddress, ParcelID, ISNULL(OwnerAddress, ParcelID)
From [Data Cleaning].[dbo].[NashvilleHousing]


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(date, SaleDate)
From [Data Cleaning].[dbo].[NashvilleHousing]


UPDATE [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(date, SaleDate)

--OR
Select SaleDate, cast(SaleDate as date)
From [Data Cleaning].[dbo].[NashvilleHousing]

UPDATE [Data Cleaning].[dbo].[NashvilleHousing]
SET SaleDate = cast(SaleDate as date)

--OR AGGREGATE A COLUMN
ALTER TABLE [Data Cleaning].[dbo].[NashvilleHousing]
ADD SaleDateConverted date

UPDATE [Data Cleaning].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM [Data Cleaning].[dbo].[NashvilleHousing]



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning]..NashvilleHousing a JOIN [Data Cleaning]..NashvilleHousing b ON 
a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning]..NashvilleHousing a JOIN [Data Cleaning]..NashvilleHousing b ON 
a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
From [Data Cleaning]..NashvilleHousing

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City
From [Data Cleaning]..NashvilleHousing

ALTER TABLE [Data Cleaning]..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE [Data Cleaning]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Data Cleaning]..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE [Data Cleaning]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitCity
FROM [Data Cleaning]..NashvilleHousing

--another way to do that
SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS 'Address',
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS 'City',
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS 'State'
FROM [Data Cleaning]..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant)
FROM [Data Cleaning]..NashvilleHousing

SELECT 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END AS Test
FROM [Data Cleaning]..NashvilleHousing

UPDATE [Data Cleaning]..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Data Cleaning]..NashvilleHousing
GROUP By SoldAsVacant
ORDER By 2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, COUNT(*)
FROM [Data Cleaning]..NashvilleHousing
GROUP By ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
HAVING COUNT(*) > 1


WITH rownum_CTE AS (
	SELECT *, ROW_NUMBER() OVER 
		(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) as rownum
	FROM [Data Cleaning]..NashvilleHousing
)
DELETE FROM rownum_CTE
WHERE rownum > 1

WITH rownum_CTE AS (
	SELECT *, ROW_NUMBER() OVER 
		(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) as rownum
	FROM [Data Cleaning]..NashvilleHousing
)
SELECT *
FROM rownum_CTE
WHERE rownum > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE [Data Cleaning]..NashvilleHousing
DROP COLUMN TaxDistrict, SaleDateConverted, PropertySplitCity






-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


