-- Cleaning data project

SELECT *
FROM PortfolioProject.dbo.nashvillehousing

-- Standardize Date Format

SELECT Saledate, CONVERT(Date,saledate)
FROM nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(Date,saledate)

ALTER TABLE NashvilleHousing
ADD sale_date_converted DATE

UPDATE NashvilleHousing
SET sale_date_converted = CONVERT(DATE, SaleDate)

SELECT sale_date_converted
FROM NashvilleHousing


-- Populate Property Address data

SELECT *
FROM NashvilleHousing
WHERE propertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address information into individual columns

SELECT propertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address nvarchar(255)

UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD property_split_city nvarchar(255)


UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress)) 

SELECT *
FROM NashvilleHousing



Select OwnerAddress
FROM NashvilleHousing

SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
  FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD owner_address_split nvarchar(255)

UPDATE NashvilleHousing
SET owner_address_split = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD owner_city nvarchar(255)


UPDATE NashvilleHousing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD owner_state nvarchar(50)

UPDATE NashvilleHousing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)as count
FROM NashvilleHousing
GROUP By SoldAsVacant
Order by count


SELECT SoldasVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS Sold_Vacant
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
	

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueId
					) row_num

FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE Row_num > 1




-- Delete unused columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate