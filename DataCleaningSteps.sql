--Standardize the date format

Select Convert(date,SaleDate) 
From NashvilleHousing

Alter Table NashvilleHousing
ADD SaleDateNew Date;

Update NashvilleHousing
Set SaleDateNew = convert(date,SaleDate)

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column SaleDate;

Select * 
From NashvilleHousing

--Populate Property Address Data

Select * 
From NashvilleHousing
Where PropertyAddress is Null

Select * 
From NashvilleHousing A
Join NashvilleHousing B
ON A.ParcelID = B.ParcelID And A.[UniqueID ] <> B.[UniqueID ]

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress 
From NashvilleHousing A
Join NashvilleHousing B
ON A.ParcelID = B.ParcelID And A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is Null

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing A
Join NashvilleHousing B
ON A.ParcelID = B.ParcelID And A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is Null

Update A
Set A.PropertyAddress = B.PropertyAddress
From NashvilleHousing A
Join NashvilleHousing B
ON A.ParcelID = B.ParcelID And A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is Null

--Address into individual columns (Address/City/State)

Select * 
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1) +1, len(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
ADD PropertyStreet nvarchar(255);

Update NashvilleHousing
Set PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1) -1)

Alter Table NashvilleHousing
ADD PropertyCity nvarchar(255);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1) +1, len(PropertyAddress))

--Owner Address into individual columns

Select Parsename(replace(OwnerAddress, ',','.'),3) as OwnerStreet,
Parsename(replace(OwnerAddress, ',','.'),2) as OwnerCity,
Parsename(replace(OwnerAddress, ',','.'),1) as OwnerState
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerStreet nvarchar(255)

Update NashvilleHousing
Set OwnerStreet = Parsename(replace(OwnerAddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerCity nvarchar(255)

Update NashvilleHousing
Set OwnerCity = Parsename(replace(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerState nvarchar(255)

Update NashvilleHousing
Set OwnerState = Parsename(replace(OwnerAddress, ',','.'),1)


--Change SoldAsVacant to Yes and No from Y and N

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =
Case When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
End

Select *
From NashvilleHousing

--Remove Duplicates

With DuplicatesCTE AS (
Select *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateNew, LegalReference ORDER BY UniqueId) as row_num 
From Cleaning.dbo.NashvilleHousing)

Delete 
From DuplicatesCTE
Where row_num > 1

Select * 
From NashvilleHousing

--Remove unneccessary columns

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop column PropertyAddress, OwnerAddress
