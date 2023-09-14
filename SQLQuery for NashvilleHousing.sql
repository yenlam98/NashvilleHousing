/****** View Top 100  ******/
SELECT TOP 100 *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  order by SaleDate

  --Work with date, create new date column

  alter table NashvilleHousing
  add SaleDateConverted date

  update NashvilleHousing
  set SaleDateConverted = convert (date,SaleDate)

  SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  order by ParcelID

  --Work with PropertyAddress
  SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  where PropertyAddress is null

  SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  order by ParcelID --Test if each ParcelID will have 1 address => right

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
 from [PortfolioProject].[dbo].[NashvilleHousing] as a
 join [PortfolioProject].[dbo].[NashvilleHousing] as b
 on a.ParcelID=b.ParcelID
 where a.PropertyAddress is null

 update a
 set PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject].[dbo].[NashvilleHousing] as a
 join [PortfolioProject].[dbo].[NashvilleHousing] as b
 on a.ParcelID=b.ParcelID
 where a.PropertyAddress is null --update all null value but still remain 2 of them whose Address is all null

 update NashvilleHousing
 set PropertyAddress = 'IDLEWILD DR, MADISON'
 where ParcelID = '052 01 0 296.00' --update 1 null value with value from OwnerAddress, but another is still null

 delete from NashvilleHousing
 where ParcelID = '108 07 0A 026.00' and PropertyAddress is null --delete the remaining null

 --Break out Address into Address, City, State
 --For PropertyAddress
 select PropertyAddress, substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address, substring(PropertyAddress,charindex(',',PropertyAddress) +1,len(PropertyAddress)) as State
 from [PortfolioProject].[dbo].[NashvilleHousing]

 alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add Address nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set Address = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

  alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add City nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set City = substring(PropertyAddress,charindex(',',PropertyAddress) + 1,len(PropertyAddress))

 --For OwnerAddress
  select parsename(replace(OwnerAddress,',','.'),1),parsename(replace(OwnerAddress,',','.'),2),parsename(replace(OwnerAddress,',','.'),3)
 from [PortfolioProject].[dbo].[NashvilleHousing]

  alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add OwnerAddressSplit nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set OwnerAddressSplit = parsename(replace(OwnerAddress,',','.'),3)

  alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add OwnerCity nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set OwnerCity = parsename(replace(OwnerAddress,',','.'),2)

 alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add OwnerState nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set OwnerState = parsename(replace(OwnerAddress,',','.'),32)

 --Change Y and N to Yes and No in SoldAsVacant

 select distinct  SoldAsVacantUpdate, count (SoldAsVacantUpdate)
 from [PortfolioProject].[dbo].[NashvilleHousing]
 group by SoldAsVacantUpdate
 order by 2

 select SoldAsVacant, count (SoldAsVacant),
 case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end as result
 from [PortfolioProject].[dbo].[NashvilleHousing]
 group by result

 alter table [PortfolioProject].[dbo].[NashvilleHousing]
 add SoldAsVacantUpdate nvarchar(200)

 update [PortfolioProject].[dbo].[NashvilleHousing]
 set SoldAsVacantUpdate = case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end

 --Remove duplicates
 --Create table in case we need to delete rows
create table NashvilleHousing_v2 ([UniqueID ] float
      ,[ParcelID] nvarchar(255)
      ,[LandUse] nvarchar(255)
      ,[PropertyAddress] nvarchar(255)
      ,[SaleDate] datetime
      ,[SalePrice] float
      ,[LegalReference] nvarchar(255)
      ,[SoldAsVacant] nvarchar(255)
      ,[OwnerName] nvarchar(255)
      ,[OwnerAddress] nvarchar(255)
      ,[Acreage] float
      ,[TaxDistrict] nvarchar(255)
      ,[LandValue] float
      ,[BuildingValue] float
      ,[TotalValue] float
      ,[YearBuilt] float
      ,[Bedrooms] float
      ,[FullBath] float
      ,[HalfBath] float
      ,[SaleDateConverted] date
      ,[PropertyAddressSplit] nvarchar(200)
      ,[PropertyCity] nvarchar(200)
      ,[OwnerAddressSplit] nvarchar(200)
      ,[OwnerCity] nvarchar(200)
      ,[OwnerState] nvarchar(200)
      ,[SoldAsVacantUpdate] nvarchar(200))
Insert into NashvilleHousing_v2
select * from [PortfolioProject].[dbo].[NashvilleHousing]

select * from NashvilleHousing_v2
--find duplicate by count num rows but it seems like all rows are unique
select *,
row_number() over (partition by UniqueID, ParcelID, SaleDate, SalePrice, LegalReference order by ParcelID) as num_rows
from NashvilleHousing_v2

select distinct row_number() over (partition by UniqueID, ParcelID, SaleDate, SalePrice, LegalReference order by ParcelID) as num_rows
from NashvilleHousing_v2
--another way to find duplicate
select *,
concat(UniqueID, ParcelID, SaleDate, SalePrice, LegalReference) as concat
from NashvilleHousing_v2 --56476 rows

select distinct
concat(UniqueID, ParcelID, SaleDate, SalePrice, LegalReference) as concat
from NashvilleHousing_v2


--delete unused columns
alter table NashvilleHousing_v2
drop column /*PropertyAddress, OwnerAddress, TaxDistrict,SaleDate,*/ SoldAsVacant

select * from  NashvilleHousing_v2