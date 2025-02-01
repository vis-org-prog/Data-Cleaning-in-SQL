select * from layoffs;

-- Remove duplicates
-- Standardize the data
-- null values or blank values
-- remove any columns that are unnecessary

create table layoff_staging like layoffs;

insert layoff_staging select * from layoffs;

select * from layoff_staging;

#the reason we are having a copy of the raw data is because we can use it as a reference first,
-- but cannot work directly on the raw data during the cleaning stage.

select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`) as row_num from layoff_staging;

with duplicate_cte as (
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) 
as row_num from layoff_staging
)
select * from duplicate_cte where row_num>1;

select * from layoff_staging where company = 'Casper';

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoff_staging2;

insert into layoff_staging2 select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) 
as row_num from layoff_staging;

delete from layoff_staging2 where row_num>1;

select * from layoff_staging2 where row_num>1;

-- standardizing data --
update layoff_staging2 set company = trim(company); -- remove spaces

select company from layoff_staging2;

select * from layoff_staging2 where industry = 'Crypto';
select distinct industry from layoff_staging2 order by 1;

select * from layoff_staging2 where industry like 'Crypto%';

update layoff_staging2 set industry = 'Crypto' where industry like 'Crypto%';

select distinct location from layoff_staging2 order by 1;

select distinct country from layoff_staging2 order by 1;

update layoff_staging2  set country = 'United States' where country = 'United States.';
-- update layoff_staging2  set country = trim(trailing  '.' from country) where country like 'United States%';-- this should be an alternative to the above code

select `date`, str_to_date(`date`, '%m/%d/%Y') from layoff_staging2;

update layoff_staging2 set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoff_staging2 modify column `date` date;

select * from layoff_staging2;

-- null values or blank values

select * from layoff_staging2 where total_laid_off is null and percentage_laid_off is null;

select * from layoff_staging2 where industry is null or industry ='';

update layoff_staging2 set industry = null where industry = '';

select * from layoff_staging2 where company = 'airbnb';

-- now we will populate the blank with the same industry for each and every company

select * from layoff_staging2 as t1 
join layoff_staging2 as t2 on t1.company = t2.company where (t1.industry is null or t1.industry = '') and t2.industry is not null;

select t1.industry, t2.industry from layoff_staging2 as t1 
join layoff_staging2 as t2 on t1.company = t2.company where (t1.industry is null or t1.industry = '') and t2.industry is not null;

update layoff_staging2 t1 join layoff_staging2 t2 on t1.company = t2. company set t1.industry = t2.industry where t1.industry is null 
and t2.industry is not null;

delete from layoff_staging2 where total_laid_off is null and percentage_laid_off is null;

-- drop column from the table--

alter table layoff_staging2 drop row_num;
select * from layoff_staging2;