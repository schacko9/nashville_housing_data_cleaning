/*
Nashville Housing Data Cleaning
Skills Used: Standardized Data, Populated Blank Fields, Split Fields into Seperate fields, Ensured Column Data Consistency,
             Removed Duplicates, Removed Null Rows, Deleted Columns, Renamed Columns
*/
--------------------------------------------------------------------------------------------------------------------------
Select *
From DataAnalysisProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format  (Remove the extra hours and minutes)
ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update DataAnalysisProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


Select SaleDate, SaleDateConverted
From DataAnalysisProject.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data (Find where Property Address fields are NULL)
Select *
From DataAnalysisProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataAnalysisProject.dbo.NashvilleHousing a
JOIN DataAnalysisProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataAnalysisProject.dbo.NashvilleHousing a
JOIN DataAnalysisProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Property Address and Owner Address into Individual Columns (Address, City, State)
SELECT
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From DataAnalysisProject.dbo.NashvilleHousing


ALTER TABLE  DataAnalysisProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update  DataAnalysisProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update  DataAnalysisProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select *
From DataAnalysisProject.dbo.NashvilleHousing



Select
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From DataAnalysisProject.dbo.NashvilleHousing


ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update DataAnalysisProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update DataAnalysisProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update DataAnalysisProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From DataAnalysisProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
-- Changed Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataAnalysisProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Update DataAnalysisProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataAnalysisProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
Select *
From DataAnalysisProject.dbo.NashvilleHousing


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER BY UniqueID
						) row_num
From DataAnalysisProject.dbo.NashvilleHousing
--order by ParcelID
)
-- Select *
Delete
From RowNumCTE
Where row_num > 1


Select *
From DataAnalysisProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
ALTER TABLE DataAnalysisProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From DataAnalysisProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Rename Columns
Use DataAnalysisProject;

EXEC sp_rename 'NashvilleHousing.SaleDateConverted', 'SaleDate';
EXEC sp_rename 'NashvilleHousing.PropertySplitAddress', 'PropertyAddress';
EXEC sp_rename 'NashvilleHousing.PropertySplitCity', 'PropertyCity';
EXEC sp_rename 'NashvilleHousing.OwnerSplitAddress', 'OwnerAddress';
EXEC sp_rename 'NashvilleHousing.OwnerSplitCity', 'OwnerCity';
EXEC sp_rename 'NashvilleHousing.OwnerSplitState', 'OwnerState';


Select *
From DataAnalysisProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------