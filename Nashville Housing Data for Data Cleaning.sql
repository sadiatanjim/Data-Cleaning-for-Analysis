/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Data_Cleaning..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Data_Cleaning..NashvilleHousing

UPDATE Data_Cleaning..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)   --NOT Working

-- If it doesn't Update properly

SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM Data_Cleaning..NashvilleHousing

ALTER TABLE Data_Cleaning..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Data_Cleaning..NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)   

--If want to drop column of a table

ALTER TABLE Data_Cleaning..NashvilleHousing 
DROP COLUMN SaleDateConverted;

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM Data_Cleaning..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, 
  --ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning..NashvilleHousing a
JOIN Data_Cleaning..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Data_Cleaning..NashvilleHousing a
JOIN Data_Cleaning..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Data_Cleaning..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM Data_Cleaning..NashvilleHousing


ALTER TABLE Data_Cleaning..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Data_Cleaning..NashvilleHousing 
SET  PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE Data_Cleaning..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Data_Cleaning..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Data_Cleaning..NashvilleHousing

--Alternative way of breaking out/ split in case of OwnerAddress 

Select OwnerAddress
From Data_Cleaning..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Data_Cleaning..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From Data_Cleaning..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From Data_Cleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From Data_Cleaning..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Data_Cleaning.dbo.NashvilleHousing
--order by ParcelID
)

--DELETE 
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From Data_Cleaning..NashvilleHousing

ALTER TABLE Data_Cleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE Data_Cleaning..NashvilleHousing
DROP COLUMN SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Extra work to try

--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE Data_Cleaning

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE Data_Cleaning;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE Data_Cleaning;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
