--- ScienceQtech Employee Performance Mapping ---

--- Create a database named employee --- 
create database employee;

--- Import data_science_team.csv proj_table.csv and emp_record_table.csv into the employee database from the given resources ---
use employee;

--- Changing the data type and defining primary key for emp_record_table --- 
alter table emp_record_table 
modify column emp_id varchar(10);

alter table emp_record_variable
modify column project_id varchar(10);

alter table emp_record_table
add primary key(emp_id);

alter table emp_record_table
add foreign key(project_id) references proj_table(project_id);

--- Changing the data type of emp id and defining primary key for proj_table --- 
alter table proj_table
modify column project_id varchar(10);

alter table proj_table
add primary key(project_id);

--- Changing the data type of emp id and defining foreign key for data_science_table --- 

alter table data_science_team
modify column emp_id varchar(10);

alter table data_science_team
add foreign key(emp_id) references emp_record_table(emp_id);

----- Fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table -----
select emp_id, first_name, last_name, gender from emp_record_table;

--- fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is --
--- less than two
--- greater than four 
--- between two and four
select emp_id, first_name, last_name, gender, dept, emp_rating from emp_record_table
where emp_rating < 2 or emp_rating > 4 or emp_rating between 2 and 4;

--- concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department ---
---  from the employee table and then give the resultant column alias as NAME ---
select concat(first_name, " ", last_name) as NAME from emp_record_table
where dept = "FINANCE";

-- list only those employees who have someone reporting to them. Also, show the number of reporters (including the President) ----
create temporary table managers
as
select distinct manager_id, count(manager_id) as Number_of_reporters from emp_record_table
group by manager_id;
 
select first_name, Number_of_reporters from managers as m
inner join emp_record_table as e
where e.emp_id = m.manager_id;

--- list down all the employees from the healthcare and finance departments using union. Take data from the employee record table ---
select * from emp_record_table where dept="Healthcare"
union 
select * from emp_record_table where dept="Finance";

--- list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept --- 
--- Also include the respective employee rating along with the max emp rating for the department --- 
create table rating
as
select dept, max(emp_rating) as Max_emp_rating from emp_record_table
group by dept;

alter table rating
rename column dept to department;

select * from rating;

select emp_id, first_name, last_name, role, dept, emp_rating, Max_emp_rating from emp_record_table
inner join rating
on emp_record_table.dept = rating.department;

--- Using Windows function ---
select emp_id, first_name, last_name, role, dept, emp_rating, max(emp_rating) over (partition by dept) as Max_emp_rating from emp_record_table
order by dept;


--- calculate the minimum and the maximum salary of the employees in each role ---
select role, max(salary) as Max_salary, min(salary) as Min_salary from emp_record_table
group by role;

--- assign ranks to each employee based on their experience ---
select first_name, exp, rank() over (order by exp desc) as Rank_Exp from emp_record_table;

--- create a view that displays employees in various countries whose salary is more than six thousand ---
create view vw_emplist
as 
select first_name, country, salary from emp_record_table 
where salary > 6000
order by country;
select * from vw_emplist;

--- nested query to find employees with experience of more than ten years ---
select first_name, last_name from (
select * from emp_record_table
where exp > 10) as B;


--- create a stored procedure to retrieve the details of the employees whose experience is more than three years ---
delimiter //
create procedure sp_emp()
begin
select * from emp_record_table
where exp > 3;
end//
delimiter ;
call sp_emp();

-- Query using stored functions in the project table to check whether the job profile assigned to each employee ---
--- in the data science team matches the organization’s set standard --- 
delimiter //
create procedure sp_DS_team()
begin  
select *,if(exp<=2,"Yes","No") as Job_Profile_Match from emp_record_table where role = "JUNIOR DATA SCIENTIST"
union 
select *,if(exp between 2 and 5,"Yes","No") as Job_Profile_Match from emp_record_table where role  = "ASSOCIATE DATA SCIENTIST"
union 
select *,if(exp between 5 and 10,"Yes","No") as Job_Profile_Match from emp_record_table where role = "SENIOR DATA SCIENTIST"
union 
select *,if(exp between 10 and 12,"Yes","No") as Job_Profile_Match from emp_record_table where role = "LEAD DATA SCIENTIST"
union 
select *,if(exp between 12 and 16,"Yes","No") as Job_Profile_Match from emp_record_table where role = "MANAGER";
end //
delimiter ;
call sp_DS_team();

-- Using Case Statement ---
select *,
	case when role = "JUNIOR DATA SCIENTIST" and exp<=2 then "Yes"
    when role  = "ASSOCIATE DATA SCIENTIST" and exp between 2 and 5 then "Yes"
    when role = "SENIOR DATA SCIENTIST" and exp between 5 and 10 then "Yes"
    when role = "LEAD DATA SCIENTIST" and exp between 10 and 12 then "Yes"
    when role = "MANAGER" and exp between 12 and 16 then "Yes"
    else "No" end as Job_Profile_Match
from emp_record_table;

--- index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’
--- in the employee table after checking the execution plan ---
alter table emp_record_table
modify column first_name varchar(100);

explain select * from emp_record_table
where first_name = "Eric";

create index ix_firstname on emp_record_table(first_name);


--- query to calculate the bonus for all the employees, ---
--- based on their ratings and salaries (Use the formula: 5% of salary * employee rating) ---
select *, ((0.05*salary)*emp_rating) as Bonus from emp_record_table;

--- query to calculate the average salary distribution based on the continent and country --
select continent, country, avg(salary) from emp_record_table
group by continent, country;







