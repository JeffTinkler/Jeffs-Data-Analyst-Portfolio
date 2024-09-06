
select *
from HousingMarket

--Standardize Date Format


Alter table HousingMarket
Add SaleDateConverted Date;

Update HousingMarket
set SaleDateConverted = convert(date,saledate)


--Populate Property Address


select PropertyAddress
from HousingMarket
--where PropertyAddress is NULL
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from HousingMarket a
	join HousingMarket b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from HousingMarket a
	join HousingMarket b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Break Property Addresses into Individual Comlumns



Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City


from HousingMarket

Alter table HousingMarket
Add PropertysplitAddress Nvarchar(255);

Update HousingMarket
set PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter table HousingMarket
Add PropertysplitCity Nvarchar(255);

Update HousingMarket
set PropertysplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


--Break Owner Addresses into Individual Comlumns


Select OwnerAddress
From HousingMarket


Select
	PARSENAME(Replace(OwnerAddress,',','.'),3),
	PARSENAME(Replace(OwnerAddress,',','.'),2),
	PARSENAME(Replace(OwnerAddress,',','.'),1)
From HousingMarket



Alter table HousingMarket
Add OwnersplitAddress Nvarchar(255);

Update HousingMarket
set OwnersplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table HousingMarket
Add OwnerysplitCity Nvarchar(255);

Update HousingMarket
set OwnerysplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)


Alter table HousingMarket
Add OwnersplitState Nvarchar(255);

Update HousingMarket
set OwnersplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


select *
from HousingMarket


--Change Y/N to Yes/No

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From HousingMarket
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
	CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From HousingMarket


UPDATE HousingMarket
	SET SoldAsVacant = 
	CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--Remove Duplicates

With Row_numCTE AS(

Select *,
	ROW_NUMBER() Over (
		Partition by parcelid,
					propertyaddress,
					saledate,
					legalreference
Order by uniqueid
) Row_num

From HousingMarket
)


Delete
from Row_numCTE
Where Row_num > 1



-- Delete unused columns


ALTER TABLE HousingMarket
	DROP COLUMN OwnerAddress,
				TaxDistrict,
				PropertyAddress,
				SaleDate


