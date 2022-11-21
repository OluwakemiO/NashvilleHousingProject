-- CLEANING DATA IN SQL QUERIES

SELECT*
FROM NashvilleHousing


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---STANDARDIZED DATA FORMART:

---First, lets select saledate

SELECT saledate
FROM NashvilleHousing
---And we want to remove the time at the end and convert the column to only the date.
---This is what we want, we want to convert saledate to just the date without the time stamp beside it

SELECT saledate,CONVERT(DATE,SaleDate)
FROM NashvilleHousing

---We need to create another column and call it SaledateConverted

ALTER TABLE NashvilleHousing
ADD SaledateConverted DATE;

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SaledateConverted=CONVERT(DATE,SaleDate)

SELECT SaledateConverted,CONVERT(DATE,SaleDate)
FROM NashvilleHousing

---WHEN WE RUN THE TABLE AGAIN, OUR NEW COLUMN IS ADDED TO THE END OF THE TABLE.

SELECT*
FROM NashvilleHousing


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM NashvilleHousing

---LET'S LOOK AT THE NULL VALUES

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

--LET'S LOOK AT EVERYTHING WHERE PROPERTYADDRESS IS NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

---WE NEED TO LOOK FOR AN IDENTIFIER THAT WE CAN USE TO POPULATE OUR NULL ADDRESSES.
---LOOKING THROUGH THE DATA, WE'LL SEE THAT IF WE ORDER THE DATA BY THE PARCELID AND RUN THROUGH, IN SITUATIONS WHERE THE PARCELID 
---APPEARS MORE THAN ONCE, THE PROPERTY ADDRESS REMAINS THE SAME. THIS INDICATES THAT THE PARCELID CAN BE USED 

---EXAMPLE: 015 14 0 060.00	SINGLE FAMILY	3113  MILLIKEN DR, JOELTON
---         015 14 0 060.00	SINGLE FAMILY	3113  MILLIKEN DR, JOELTON

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

---WE'RE GOING TO USE THE SELF JOIN I.E JOIN THE TABLE TO ITSELF AND USE THE UNIQUE IDENTIFIER

SELECT *
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID

---SO WE NEED TO FIND A WAY TO DISTINGUISH THE COMMON PARCEL IDS USING THE UNIQUEID WHICH IS UNIQUE TO EACH SALE DATE BECAUSE THE SALE DATES MAY BE THE SAME.

SELECT*
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]

---NOW WE NEED TO CHECK IF OUR TABLE IS CORRECT WHEN THERE IS 'NULL'

SELECT Nash1.ParcelID,NASH1.PropertyAddress,Nash2.ParcelID,Nash2.PropertyAddress
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]

SELECT Nash1.ParcelID,NASH1.PropertyAddress,Nash2.ParcelID,Nash2.PropertyAddress
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

---RUNNING ABOVE QUERY SHOWS THERE'S STILL SOMETHING WRONG WITH OUR TABLE.
---025 07 0 031.00	NULL	025 07 0 031.00	410  ROSEHILL CT, GOODLETTSVILLE
---PARCELID 025 07 0 031.00 IS NULL IN NASH1 TABLE WHILE IT REALLY DOES HAVE AN ADDRESS IN NASH2 TABLE, WHICH MEANS IT HAS NOT POPULATED PROPERLY
---WE WILL USE WHAT'S CALLED 'ISNULL' TO CORRECT THIS

SELECT Nash1.ParcelID,NASH1.PropertyAddress,Nash2.ParcelID,Nash2.PropertyAddress,ISNULL(nash1.propertyaddress,Nash2.PropertyAddress)
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL


UPDATE Nash1
SET PropertyAddress= ISNULL(nash1.propertyaddress,Nash2.PropertyAddress)
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL


---LET'S CHECK IF THERE'S STILL NULL
SELECT Nash1.ParcelID,NASH1.PropertyAddress,Nash2.ParcelID,Nash2.PropertyAddress,ISNULL(nash1.propertyaddress,Nash2.PropertyAddress)
FROM NashvilleHousing  Nash1
JOIN NashvilleHousing  Nash2
ON Nash1.ParcelID=Nash2.ParcelID
AND Nash1.[UniqueID ]<> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

---IT RETURNS AN EMPTY TABLE WHICH SHOWS THAT OUR QUERY WORKED

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing

---TO SEPARATE THE ADDRESS FROM THE STRING, WE USE:

SELECT
Substring(Propertyaddress,1,CHARINDEX(',',PropertyAddress)) AS Address
FROM NashvilleHousing

---TO REMOVE THE COMMA(WHICH IS A NUMBER) FROM THE END OF THE ADDRESS, WE USE:

SELECT
Substring(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
FROM NashvilleHousing

---NOW LET'S SEPARATE THE CITY:
SELECT
Substring(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
Substring(Propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(Propertyaddress)) AS Address
FROM NashvilleHousing

---we can't separate two values from one column without creating another column
---so we're going to create two new columns and add the values in

ALTER TABLE NashvilleHousing
ADD SplitedPropertyAddress NVARCHAR(255);

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SplitedPropertyAddress = Substring(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD SplitedCityAddress NVARCHAR(255);

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SplitedCityAddress=Substring(Propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(Propertyaddress))

---WHEN WE RUN THE TABLE AGAIN, OUR NEW COLUMNS ARE ADDED TO THE END OF THE TABLE.
SELECT*
FROM NashvilleHousing


---DOING THE ADDRESS SEPARATION USING PARSENAME INSTEAD OF SUBSTRINGS

SELECT Owneraddress 
FROM NashvilleHousing

SELECT
PARSENAME(Owneraddress,1)
FROM NashvilleHousing

---WHEN WE RUN THIS, NOTHING CHANGES BECAUSE PARSENAME IS ONLY USEFUL WITH PERIODS AND NOT COMMAS
---SO WHAT WE NEED TO DO IS TO REPLACE THE COMMAS WITH PERIODS AND THEN TRY TO DO SEPARATION AGAIN.

SELECT
PARSENAME(REPLACE(Owneraddress,',','.'),1)
FROM NashvilleHousing

---THIS WORKS AND IT HAS SEPARATED THE "TN" FROM THE ADDRESS. BUT WE WANT IT TO SEPARATE THE EVERYTHING,
--- SO WE ADD THE OTHER LINES TO THE QUERY AND RUN IT AGAIN

SELECT
PARSENAME(REPLACE(Owneraddress,',','.'),1),
PARSENAME(REPLACE(Owneraddress,',','.'),2),
PARSENAME(REPLACE(Owneraddress,',','.'),3)
FROM NashvilleHousing

---NOW WHEN WE RUN THE ABOVE QUERY, WE SEE THAT PARSENAME HAS SEPARATED ALL THE ADDRESS
---BUT IT DOES IT BACKWORD BECAUSE PARSE WORSE BACKWORDS
---TO CORRECT THIS, WE JUST NEED TO REORDER THE NUMBER FROM BUTTOM UP I.E

SELECT
PARSENAME(REPLACE(Owneraddress,',','.'),3),
PARSENAME(REPLACE(Owneraddress,',','.'),2),
PARSENAME(REPLACE(Owneraddress,',','.'),1)
FROM NashvilleHousing

---NEXT WE CREATE THE COLUMNS ON OUR TABLE

ALTER TABLE NashvilleHousing
ADD SplitedOwnerAddress NVARCHAR(255);

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SplitedOwnerAddress = PARSENAME(REPLACE(Owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD SplitedOwnerCityAddress NVARCHAR(255);

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SplitedOwnerCityAddress=PARSENAME(REPLACE(Owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD SplitedOwnerStateAddress NVARCHAR(255);

---After creating the Column, we can now update the table.

UPDATE NashvilleHousing
SET SplitedOwnerStateAddress=PARSENAME(REPLACE(Owneraddress,',','.'),1)

---NOW LET'S RUN THE TABLE AGAIN TO SEE IF OUR COLUMS WERE CREATED CORRECTLY
SELECT*
FROM NashvilleHousing

---YES! WE HAVE THE COLUMNS ATTACHED TO THE END OF THE TABLE JUST LIKE WE WANT.


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---CHANGE Y AND N INTO YES AND NO IN THE 'SOLD AS VACANT' FIELD

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

---THIS QUERY SHOWS THAT THERE ARE SOME ENTRIES WRITTEN IN FULL AND SOME SHORTENED AS Y OR N
---WE WANT TO CHANGE THIS SO THAT THE ENTRIES ARE UNIFORMED AND THE COLUMN MORE MEANINGFUL
---FIRST LET'S DO A COUNT OF THE ENTRIES

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

---YES & NO ARE MORE IN NUMBER THAN THE Y AND N. SO WE WILL REPLACE THE ONES WITH THE LEAST COUNT
---SO WE'RE GOING TO USE THE CASE STATEMENT TO DO THE REPLACEMENTS

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

---NEXT, LET'S UPDATE THE SOLDASVACANT COLUMN

UPDATE NashvilleHousing
SET SoldAsVacant=CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END

---NOW LET'S RUN THE COLUMN AGAIN

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

---UPDATED!

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---REMOVE DUPLICATES

---Now we want to remove duplicate information from our data base. If we run through, we want to remove 
---information that has the same ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
---because those would be duplicates and we want to clean them out using the PARTITION BY statement


SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID
)ROW_NUM
FROM NashvilleHousing

---This query creates another table and populates it with all the duplicate informatiom. Let's ORDER BY ParcelID

SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID
)ROW_NUM
FROM NashvilleHousing
ORDER BY ParcelID

---NOW WE PUT IT IN CTE
WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID
)ROW_NUM
FROM NashvilleHousing
---ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE ROW_NUM>1
ORDER BY PropertyAddress

---WE HAVE 104 ROWS AND WE WANT TO DELETE THEM BECAUSE THEY ARE DUPLICATES
WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID
)ROW_NUM
FROM NashvilleHousing
---ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE ROW_NUM>1
--ORDER BY PropertyAddress
---LETS GO BACK TO USE THE SELECT STATEMENT TO SEE IF THEY HAVE BEEN DELETED
WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID
)ROW_NUM
FROM NashvilleHousing
---ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE ROW_NUM>1
ORDER BY PropertyAddress

---IT RETURNS A BLANK TABLE! THIS SHOWS THAT OUR SCRIPT WORKED AND DUPLICATES HAVE BEEN DELETED.
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---DELETE UNUSED COLUMNS

---NOW WE WANT TO DELETE COLUMNS THAT ARE NOT USEFUL TO US

SELECT*
FROM NashvilleHousing


---LET'S REMOVE THE OWNERADDRESS,TAXDISTRICT,PROPERTYADDRESS AND SALEDATE COLUMNS BECAUSE WE ALREADY CREATED NEW COLUMNS FOR OWNERADDRESS,
---PROPERTYADDRESS & SALEDATE COLUMNS, AND WE DONT REALLY NEED THE TAXDISTRICT COLUMN. USING THE ALTER TABLE DRP COLUMN COMMAND 
---IN OUR QUERY AS SHOWN BELOW, WE WILL DROP THESE 3 COLUMNS.

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

---WE CHECK
SELECT*
FROM NashvilleHousing

---THOSE 4 COLUMNS ARE GONE!

