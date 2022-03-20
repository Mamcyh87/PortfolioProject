
--/*Data Cleaning in SQL Queries

select * from dbo.NashvilleHousingData
-------------------------------------------------------------------------
--/*Standardize Date format


select SaleDate, convert(date,SaleDate) from dbo.NashvilleHousingData

update NashvilleHousingData
SET SaleDate= convert(date,SaleDate)

Alter Table NashvilleHousingData
ADD SaleDateConverted Date 

update NashvilleHousingData
Set SaleDateConverted=convert(date,SaleDate)

select SaleDateConverted from dbo.NashvilleHousingData
--------------------------------------------------------------------------------
--/* Populate Property Address Data
select *
from dbo.NashvilleHousingData
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousingData a
join dbo.NashvilleHousingData b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

update a
Set propertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousingData a
join dbo.NashvilleHousingData b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null
---------------------------------------------------------------------------------------------
--/* Breaking out Address into Individual Columns(Address,City,State)

select PropertyAddress
from dbo.NashvilleHousingData
--where PropertyAddress is NULL
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as  Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))as  Address
from dbo.NashvilleHousingData


Alter Table NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

update NashvilleHousingData
Set PropertySplitAddess= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousingData
ADD PropertySplitcity Nvarchar(255);

update NashvilleHousingData
Set PropertySplitAddress=SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from dbo.NashvilleHousingData

select OwnerAddress from dbo.NashvilleHousingData

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1) 
from dbo.NashvilleHousingData


Alter Table NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

update NashvilleHousingData
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousingData
ADD OwnerSplitcity Nvarchar(255);

update NashvilleHousingData
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

update NashvilleHousingData
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1) 

select * from dbo.NashvilleHousingData

----------------------------------------------------------------------------------------------------------

--/*Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),Count(SoldAsVacant)
from dbo.NashvilleHousingData
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' Then 'Yes'
when SoldAsVacant='N' Then 'No'
Else SoldAsVacant
End
from dbo.NashvilleHousingData

update dbo.NashvilleHousingData
Set SoldAsVacant=case when SoldAsVacant='Y' Then 'Yes'
when SoldAsVacant='N' Then 'No'
Else SoldAsVacant
End
from dbo.NashvilleHousingData

---------------------------------------------------------------------------------------------

--/* Remove Duplicates

With RowNumCte AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID, PropertyAddress,
	SalePrice,SaleDate,
	LegalReference
	order by UniqueID)
	row_num
From dbo.NashvilleHousingData
--order by ParcelID
)
Select *
from RowNumCte
where row_num > 1
order by PropertyAddress


--------------------------------------------------------------------------------------------------------------

--/* Delete Unused Columns

select *
From dbo.NashvilleHousingData

Alter Table dbo.NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict,PropertyAddress

Alter Table dbo.NashvilleHousingData
Drop Column SaleDate
