-- Data Cleaning  
Use portfolio_project_db;

Select *
from layoffs;

Select count(*)
from layoffs;

-- 1. Removing Duplicates. 
-- 2. Standardizing the data.  
-- 3. Null Values or Blank Values.
-- 4. Removing Unused column.


-- Creating a staging table to make all the changes and keep the raw data intact.
Create Table layoffs_staging
Like layoffs; 

Insert layoffs_staging
Select * 
from layoffs;


Select count(*)
from layoffs_staging;


-- finding the duplicate records 

Select * 
from layoffs_staging;


-- CTE to find out all the duplicate records from the table 
With duplicate_cte as 
(
Select *,
ROW_NUMBER() 
OVER(
Partition By company, location , industry , total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) as row_num
from layoffs_staging
)

Select *
from duplicate_cte
where row_num>1; 


Select *
from layoffs_staging
where company like 'Casper';



-- Delete all the duplicate records 
-- With duplicate_cte as 
-- (
-- Select *,
-- ROW_NUMBER() 
-- OVER(
-- Partition By company, location , industry , total_laid_off, percentage_laid_off, 'date',
-- stage, country, funds_raised_millions) as row_num
-- from layoffs_staging
-- )
-- Delete 
-- from duplicate_cte
-- where row_num>1; 
 
-- this above delete query is throwing an error
-- Reason : IN MySQL , CTE is read-only, we can't delete/update directly from a CTE.


-- Steps to delete the duplicate records by keeping 1 record in our dataset.

-- 1. Create another staging table
Drop table if exists layoffs_staging2;  
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULl,
   row_num  int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
from layoffs_staging2;

Insert into layoffs_staging2
Select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date',
stage, country, funds_raised_millions) as row_num
from layoffs_staging; 

Select * from layoffs_staging2;

-- this layoffs_staging2 table has a row_num column in it so now we can directly 
-- apply filter into our layoffs_staging2 table from the row_num column.

-- now filter the layoffs_staging2 table where row_num is more than 1
Select *
from layoffs_staging2
where row_num>1;   

   
-- Delete all the duplicate records   
Delete
from layoffs_staging2
where row_num>1;   
   
   
Select *
from layoffs_staging2;   



-- Standardizing Data 

Select company, trim(company)
from layoffs_staging2;

-- updating the company column
update layoffs_staging2
set company = trim(company);

-- industry column
select distinct industry
from layoffs_staging2
order by 1; 


-- crypto, crypto currency and cryptoCurrency all are same 
Select * 
from layoffs_staging2
where industry like 'Crypto%'; 


-- update all the industry to Crypto  
Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


-- location column
Select distinct location 
from layoffs_staging2
order by 1; 


-- country column
Select distinct country
from layoffs_staging2
order by 1; 

-- in country column we have two united states written in different forms ,
-- so lets standardize it.
Select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;  


update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';



-- date columns 
-- in our table the date column is of text time 
-- if we wanted to perform any time intelligence function in EDA then it will be a problem
-- so lets change the date column to m-d-y format

Select `date`,
str_to_date(`date`, '%m/%d/%Y') as new_date
from layoffs_staging2; 


-- update the date column in layoffs_staging2 table 
Update layoffs_staging2
set `date`= str_to_date(`date`, '%m/%d/%Y');

Select `date` from 
layoffs_staging2;


-- Change the data-type of date column from text to date.
Alter table layoffs_staging2
modify column `date` Date; 

-- alter command always needs to be done in staging table not in the original raw dataset.



-- working with null and blank values. 

Select *
from layoffs_staging2;


Select distinct industry
from layoffs_staging2;


Select *
from layoffs_staging2
where industry is Null
or industry = '';

-- lets try to find out the industry where the company is 'Airbnb'
Select *
from layoffs_staging2
where company = 'Airbnb'; 

-- now lets find out all the blank or null industries having same company and location by using self join

Select t1.industry , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where t1.industry is null or t1.industry =''
And t2.industry is not null; 

-- now update all the blank values to null
update layoffs_staging2
set industry = Null 
where industry ='';


Select t1.industry , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where t1.industry is null
And t2.industry is not null; 


-- now popluate all the null industry values from t2 where the location and comapny is same between t1 and t2.
Update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
And t2.industry is not null; 


Select * 
from layoffs_staging2
where industry is null;

Select *
from layoffs_staging2
where company = 'Airbnb';



-- still we have a blank industry for company = 'Bally%', its because there is ony one record for the company.

-- lets search for the data where tota_laid_off and precentage_laid_off both are null.
Select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; 

 
-- if the total_laid_off and percentage_laid_off both are null that means those companies donot laid off so will delete these records
Delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; 

Select *
from layoffs_staging2;


-- drop column row_num from the table
Alter table layoffs_staging2
drop column row_num; 





  

















