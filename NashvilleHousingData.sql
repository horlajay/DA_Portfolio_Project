/*
Cleaning Data In SQL Queries
*/


select *
from NashvilleHousingData
order by ParcelID
----------------------------------------------------

--Standardize Data Format

 select SaleDateConverted, CONVERT(Date, SaleDate)
 From NashvilleHousingData


Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)







---------------------------------------------------------

--Populate Propety Address Data

select *
 From NashvilleHousingData
 --where PropertyAddress is null
 order by ParcelID


select NC.ParcelID, NC.PropertyAddress, NB.ParcelID, NB.PropertyAddress, ISNULL(NC.PropertyAddress,NB.PropertyAddress)
From NashvilleHousingData NC
Join NashvilleHousingData NB
  ON NC.ParcelID = NB.ParcelID
  AND NC.[UniqueID ] <> NB.[UniqueID ]
where NC.PropertyAddress is null

Update NC 
SET PropertyAddress = ISNULL(NC.PropertyAddress,NB.PropertyAddress)
From NashvilleHousingData NC
Join NashvilleHousingData NB
  ON NC.ParcelID = NB.ParcelID
  AND NC.[UniqueID ] <> NB.[UniqueID ]
where NC.PropertyAddress is null







---------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From NashvilleHousingData
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
	--CHARINDEX(',',PropertyAddress)
FROM NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousingData
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousingData


Select OwnerAddress
From NashvilleHousingData
order by ParcelID

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From NashvilleHousingData
Order by ParcelID 



ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress nvarchar(255);


Update NashvilleHousingData
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select * 
from NashvilleHousingData



--------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousingData
Group by SoldAsVacant
Order by 2




 Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END
From NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  END






---------------------------------------------------------------------------------------

--Remove Duplicates
WITH ROW_NUMCTE As (
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
From NashvilleHousingData
)
Select *
From ROW_NUMCTE
where row_num > 1
--order by PropertyAddress


----------------------------------------------------------------------------------------

-- Delete Unused Columns


select *
From NashvilleHousingData


ALTER TABLE NashvilleHousingData
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousingData
Drop COLUMN SaleDate

