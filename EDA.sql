-- Exploratory Data Analysis 

Use portfolio_project_db;

Select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;  


-- if percentage_laid_off=1 means 100% layoff
-- details of all the companied who laid off 100% in order of max to min number total_laid_off. 
Select *
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc; 


-- companies who laid off 100% order by their funds raised. 
Select * 
from layoffs_staging2
where percentage_laid_off =1
order by funds_raised_millions desc; 


-- sum of total_laid_off group by each company
Select company, sum(total_laid_off)
from layoffs_staging2 
group by company
order by 2 desc; 


-- date range of layoff , start date and end date for my dataset.
Select min(`date`) as StartDate, max(`date`) as EndDate
from layoffs_staging2; 


-- industries which laid off the most
Select industry, sum(total_laid_off)
from layoffs_staging2
group by industry 
order by 2 desc; 


-- countries and their layoff counts
Select country , sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc; 


-- year wise layoff counts
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;


-- layoffs for different stage of company
Select *
from layoffs_staging2;

Select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;



-- Progression of layoff / Rolling sum of layoff / Running total of layoff

-- for each month number of tota_laid_off     
Select * from layoffs_staging2;
 
Select substring(`date`, 1,7) as `Month-Year`, Sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by substring(`date`, 1,7)
order by `Month-Year` asc;


-- running_total
with Rolling_total as (
Select substring(`date`, 1,7) as `Month-Year`, Sum(total_laid_off) as total_laidOff
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by substring(`date`, 1,7)
order by `Month-Year` asc
)

Select `Month-Year`, total_laidOff,
Sum(total_laidOff) Over(Order by `Month-Year`) as rolling_total
from Rolling_total;


-- running total of layoffs done by each company for specific year. 
Select company , Year(`date`) , sum(total_laid_off)
from layoffs_staging2
group by company , Year(`date`) 
order by 3 desc; 



-- Rank the companies who laid off more than once in 3 years.
With Company_Rank as (
Select company , Year(`date`) as `year` , sum(total_laid_off)
from layoffs_staging2
group by company , Year(`date`) 
order by 3 desc
)
Select *,
DENSE_Rank() OVER(partition by company order by `year`) as Rnk
from Company_Rank;




-- Rank the company with max number of layoffs with respect to each year
With Company_Ranks as (
Select company , Year(`date`) as `year` , sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company , Year(`date`) )

Select *,
Dense_Rank() Over(partition by `year` order by total_laid_off desc) as Rnk
from Company_Ranks
where `year` is not null
order by Rnk asc; 




-- Top 5 companies based on the number of layoffs per year. 
 
With Company_Ranks as (
Select company , Year(`date`) as `year` , sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company , Year(`date`) 
) , 
Company_Year_Rank as (
Select *,
Dense_Rank() Over(partition by `year` order by total_laid_off desc) as Rnk
from Company_Ranks
where `year` is not null
order by Rnk asc 
)

Select *
from Company_Year_Rank
where Rnk <=5;




 