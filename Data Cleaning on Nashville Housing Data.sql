/*
Clening Data in SQL Queries
*/

Select * from PortfolioProjects.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate,Convert(Date,SaleDate) from PortfolioProjects.dbo.NashvilleHousing

Alter Table NashvilleHousing Add SalesDateConverted Date;
Update NashvilleHousing Set SalesDateConverted=Convert(Date,SaleDate)

Select SalesDateConverted,Convert(Date,SaleDate) from PortfolioProjects.dbo.NashvilleHousing

-- Populate Property Address Data

Select * from PortfolioProjects.dbo.NashvilleHousing 
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) from PortfolioProjects.dbo.NashvilleHousing a Join PortfolioProjects.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] where a.PropertyAddress is null

Update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a Join PortfolioProjects.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] where a.PropertyAddress is null

--Breaking Out Address into Individual Columns( Address,City,State)
 
 Select PropertyAddress from PortfolioProjects.dbo.NashvilleHousing 

 Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address
 from PortfolioProjects.dbo.NashvilleHousing

 Alter table NashVilleHousing add PropertySplitAddress Nvarchar(255);
 Update NashvilleHousing set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

 Alter table NashVilleHousing add PropertySplitCity Nvarchar(255);
 Update NashvilleHousing set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

 Select * from PortfolioProjects.dbo.NashvilleHousing


 Select OwnerAddress from PortfolioProjects.dbo.NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProjects.dbo.NashvilleHousing

 Alter table NashVilleHousing add OwnerSplitAddress Nvarchar(255);
 Update NashvilleHousing set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

 Alter table NashVilleHousing add OwnerSplitCity Nvarchar(255);
 Update NashvilleHousing set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

  Alter table NashVilleHousing add OwnerSplitState Nvarchar(255);
 Update NashvilleHousing set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

  Select * from PortfolioProjects.dbo.NashvilleHousing

  --Change Y and N to Yes and No in "Sold as Vacant" feild

  Select Distinct(SoldAsVacant),Count(SoldAsVacant) from PortfolioProjects.dbo.NashvilleHousing
  Group by SoldAsVacant Order by 2

  Select SoldAsVacant,
  Case when SoldAsVacant='Y' Then 'Yes'
  when SoldAsVacant='N' Then 'No'
  else SoldAsVacant 
  end
  from PortfolioProjects.dbo.NashvilleHousing

  Update NashvilleHousing
  set SoldAsVacant= Case when SoldAsVacant='Y' Then 'Yes' when SoldAsVacant='N' Then 'No'else SoldAsVacant end


  --Remove Duplicates

  With RowNumCTE AS(
  Select *,ROW_NUMBER() Over(
  Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference Order by UniqueID) row_num
  from PortfolioProjects.dbo.NashvilleHousing )
  Delete from RowNumCTE where row_num>1


-- Delete Unused Columns

 Select * from PortfolioProjects.dbo.NashvilleHousing

 Alter Table PortfolioProjects.dbo.NashvilleHousing
 Drop Column OwnerAddress,PropertyAddress,TaxDistrict

 Alter Table PortfolioProjects.dbo.NashvilleHousing
 Drop Column SaleDate