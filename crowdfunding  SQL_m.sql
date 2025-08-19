use crowdfunding;

###################################### Show EPOCH TIME to Real Dates #####################################################   

Select
    date(FROM_UNIXTIME(created_at)) AS created_date,
    date(FROM_UNIXTIME(deadline)) AS deadline_date,
    date(FROM_UNIXTIME(launched_at)) AS launched_date,
    date(FROM_UNIXTIME(state_changed_at)) AS state_changed_date
From projects;

###################################### Calendar Table #####################################################   

select * from calendar_table;

########################################## Convert the Goal amount into USD #################################################  

Select  ProjectID, (goal * static_usd_rate) as goal_usd
From projects;

########################################### Total Number of Projects based on outcome ################################################### 
 
 select state, count(*) as Total_Project from projects
 group by state 
 order by Total_Project desc;
 
 ########################################### Total Number of Projects based on Locations ################################################### 

select l.country, count(*) as total_project 
from projects p join location_table l on p.location_id = l.id
group by l.country
order by total_project desc; 

########################################### Total Number of Projects based on category ################################################### 

select c.name, count(*) as total_project
from projects p join category_table c on p.category_id = c.category_id
group by c.name
order by total_project desc;

########################################### Total Number of Projects created by year, month and Quarter ##################################### 

SELECT
    YEAR(FROM_UNIXTIME(created_at)) AS project_year,
    MONTH(FROM_UNIXTIME(created_at)) AS project_month,
    QUARTER(FROM_UNIXTIME(created_at)) AS project_quarter,
    COUNT(*) AS total_projects
FROM
    projects
GROUP BY
    project_year,
    project_month,
    project_quarter
ORDER BY
    project_year,
    project_month;

###########################################  SUCCESSFUL PROJECT BASED ON AMOUNT RAISED ################################################### 

Select concat('$ ',round(SUM(usd_pledged)/10000000,2),' B') as Total_Amount_Raised
From projects
WHERE state = 'successful';
    
###########################################  SUCCESSFUL PROJECT BASED ON NUMBER OF BACKERS ################################################### 

Select concat(round(SUM(backers_count)/1000000,2),' M') as Total_Number_Backers
From projects
WHERE state = 'successful';

###########################################  SUCCESSFUL PROJECT BASED ON AVERAGE NUMBER OF DAYS ################################################# 
           
Select Round(AVG(DATEDIFF(FROM_UNIXTIME(state_changed_at), FROM_UNIXTIME(launched_at)))) as Avg_days_successful_projects
From projects
WHERE state = 'successful'
      and launched_at IS NOT NULL
      and  state_changed_at IS NOT NULL;
      
 ########################################  Top Successful Projects By No. of Backers ##########################################################   
 
 SELECT 
    name,
  round(backers_count/1000) as Backers_count_in_thousand
FROM 
    projects
WHERE 
    state = 'successful'
ORDER BY 
    Backers_count_in_thousand DESC
LIMIT 10;

########################################  Top Successful Projects By Amount Raised ##########################################################     

SELECT 
    name,
    round(usd_pledged/1000000,2) as amount_raised_in_million
FROM 
    projects
WHERE 
    state = 'successful'
ORDER BY 
    amount_raised_in_million DESC
LIMIT 10;

############################################## Percentage of Overall Successful Projects  ###################################################### 

SELECT
concat(ROUND(SUM(state = 'successful') / COUNT(*) * 100,2),' %') AS  sucessful_project
FROM projects;

############################################## Percentage of Successful Projects by Category ###################################################### 

SELECT category_table.name,
  concat(ROUND(SUM(state = 'successful') / COUNT(*) * 100,2),' %') AS sucessful_project
FROM projects
inner join category_table
using (category_id)
group by category_table.name
order by sucessful_project desc;

############################################## Percentage of Successful Projects by year, month ###################################################### 

SELECT
    YEAR(FROM_UNIXTIME(created_at)) AS project_year,
    MONTH(FROM_UNIXTIME(created_at)) AS project_month,
    QUARTER(FROM_UNIXTIME(created_at)) AS project_quarter,
    concat(ROUND(
        COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(*),
        2
    ),' %') AS success_percentage
FROM
    projects
GROUP BY
    project_year, project_month, project_quarter
ORDER BY
    project_year, project_month;


############################################## Percentage of Successful projects by Goal Range ###################################################### 

SELECT 
  CASE 
    WHEN goal <= 1000 THEN '0-1K'
    WHEN goal <= 5000 THEN '1K-5K'
    WHEN goal <= 10000 THEN '5K-10K'
    ELSE '10K+'
  END AS goal_range,
 concat( round(COUNT(CASE WHEN state = 'successful' THEN 1 END) / COUNT(*) * 100,2) ,' %')AS success_project
FROM projects
Group by goal_range
order by success_project desc;


      

