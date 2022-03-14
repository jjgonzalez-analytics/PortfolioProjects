
/*

Cleaning Data in SQL Queries

*/


SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select 
	SaleDate, 
	CONVERT(Date,SaleDate) AS SaleDateConverted
FROM
	PortfolioProjects.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing
--WHERE 
--	PropertyAddress is null
ORDER BY 
	ParcelID



SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	PortfolioProjects.dbo.NashvilleHousing a
JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	PortfolioProjects.dbo.NashvilleHousing a
JOIN 
	PortfolioProjects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT 
	PropertyAddress
FROM 
	PortfolioProjects.dbo.NashvilleHousing
--WHERE 
--	PropertyAddress is null
--ORDER BY 
--	ParcelID

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM 
	PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing



SELECT 
	OwnerAddress
FROM 
	PortfolioProjects.dbo.NashvilleHousing



SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM 
	PortfolioProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT
	(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM 
	PortfolioProjects.dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2




SELECT 
	SoldAsVacant, 
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM 
	PortfolioProjects.dbo.NashvilleHousing



UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE 
AS
(
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
ORDER BY
	UniqueID
) row_num
FROM 
	PortfolioProjects.dbo.NashvilleHousing
--ORDER BY 
--	ParcelID
)
SELECT
	*
FROM 
	RowNumCTE
WHERE 
	row_num > 1
ORDER BY 
	PropertyAddress



SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT 
	*
FROM 
	PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate