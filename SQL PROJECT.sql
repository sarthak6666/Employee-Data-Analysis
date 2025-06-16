create database employee;

use employee;

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

select * from JobDepartment;

CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from SalaryBonus;

CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
	REFERENCES JobDepartment(Job_ID)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

select * from Employee;

CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

select * from Qualification;

CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Leaves;

CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from Payroll;
-------------------------------------------------------------------------------------------------------------------------------
-- Analysis Questions

-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
-- Which departments have the highest number of employees?
-- What is the average salary per department?
-- Who are the top 5 highest-paid employees?
-- What is the total salary expenditure across the company?

-- 1
select count(distinct concat(firstname,' ', lastname)) as Count from Employee; 

-- 2
select  jobdept ,count(Employee.emp_ID) as Count from JobDepartment
inner join Employee on JobDepartment.Job_ID = Employee.Job_ID 
group by jobdept
order by count(Employee.emp_ID) desc limit 1;

-- 3
select  jobdept ,avg(Payroll.total_amount) as avg from JobDepartment
inner join Payroll on JobDepartment.Job_ID = Payroll.Job_ID 
group by jobdept;

-- 4
select E.firstname, E.lastname, P.total_amount
from Payroll P
join Employee E on P.emp_ID = E.emp_ID
order by P.total_amount desc
limit 5;

-- 5 
SELECT 
    SUM(total_amount) AS total_salary_expenditure
FROM Payroll;

-----------------------------------------------------------------------------------------------------------------------------

-- 2. Job and Department Analysis
-- How many different job roles exist in each department? 
-- What is the average salary range per department? 
-- Which job roles offer the highest salary? 
-- Which departments have the highest total salary allocation?

-- 1
select jobdept,count(distinct name) as total_job_roles
from JobDepartment
group by jobdept;

-- 2
select JobDepartment.jobdept, avg(SalaryBonus.amount) as AvgBase_salary
from JobDepartment
join SalaryBonus on JobDepartment.Job_ID = SalaryBonus.Job_ID
group by  JobDepartment.jobdept;

-- 3
select 
JobDepartment.name as JobRole,
SalaryBonus.amount as Basesalary
from JobDepartment
join SalaryBonus on JobDepartment.Job_ID = SalaryBonus.Job_ID
order by SalaryBonus.amount desc
limit 5;

-- 4 
select
JobDepartment.jobdept,
sum(Payroll.total_amount) as TotalSalaryAllocation
from Payroll
join JobDepartment on Payroll.job_ID = JobDepartment.Job_ID
group by JobDepartment.jobdept
order by TotalSalaryAllocation desc;

---------------------------------------------------------------------------------------------------------------------------------

-- 3. QUALIFICATION AND SKILLS ANALYSIS 
-- How many employees have at least one qualification listed? 
-- Which positions require the most qualifications? 
-- Which employees have the highest number of qualifications?

-- 1
select
    count(distinct Qualification.Emp_ID) as Employees_with_qualifications
from Qualification;

-- 2
select 
    Qualification.Position, 
    count(*) as number_of_qualifications
from Qualification
group by Qualification.Position
order by number_of_qualifications DESC
limit 5;

-- 3
select 
    Employee.emp_ID, 
    Employee.firstname, 
    Employee.lastname, 
    COUNT(Qualification.QualID) as Total_qualifications
from Employee
join Qualification on Employee.emp_ID = Qualification.Emp_ID
group by Employee.emp_ID, Employee.firstname, Employee.lastname
order by total_qualifications desc
limit 5;
select * from Employee;
select * from Qualification;

---------------------------------------------------------------------------------------------------------------------------
-- 4. LEAVE AND ABSENCE PATTERNS 
-- Which year had the most employees taking leaves?  
-- What is the average number of leave days taken by its employees per department? 
-- Which employees have taken the most leaves? 
-- What is the total number of leave days taken company-wide?
-- How do leave days correlate with payroll amounts?

-- 1
select  Year(Leaves.date) as leaveYear,
count(distinct Leaves.emp_ID) as EmployeesonLeave
from Leaves
group by Year(Leaves.date)
order by EmployeesonLeave desc
limit 1;

-- 2
select JobDepartment.jobdept, avg(leave_counts.leave_days) as avg_leave_days_per_employee
from (select Leaves.emp_ID, count(*) as leave_days from Leaves group by Leaves.emp_ID) as leave_counts
join Employee on leave_counts.emp_ID = Employee.emp_ID
join JobDepartment on Employee.Job_ID = JobDepartment.Job_ID
group by JobDepartment.jobdept;

-- 3
select Employee.emp_ID,Employee.firstname,Employee.lastname,
count(Leaves.leave_ID) as TotalLeaveDays
from employee
join Leaves on Employee.emp_ID = Leaves.emp_ID
group by Employee.emp_ID,Employee.firstname,Employee.lastname
order by TotalLeaveDays desc
limit 5;

-- 4
select count(*) as TotalLeaveDays
from Leaves;

-- 5
select 
    Employee.emp_ID, 
    Employee.firstname, 
    Employee.lastname, 
    count(Leaves.leave_ID) as total_leave_days, 
    SUM(Payroll.total_amount) as total_payroll
from Employee
left join Leaves ON Employee.emp_ID = Leaves.emp_ID
left join Payroll ON Employee.emp_ID = Payroll.emp_ID
group by Employee.emp_ID, Employee.firstname, Employee.lastname
order by total_leave_days desc;

-------------------------------------------------------------------------------------------------------------------------------

-- 5. PAYROLL AND COMPENSATION ANALYSIS 

-- What is the total monthly payroll processed?  
-- What is the average bonus given per department? 
-- Which department receives the highest total bonuses? 
-- What is the average value of total_amount after considering leave deductions?

-- 1
select 
date_format(Payroll.date,'%Y-%m') as PayrollMonth,
sum(Payroll.total_amount) as Totalmontlypayroll
from Payroll
group by date_format(Payroll.date,'%Y-%m')
order by PayrollMonth;

-- 2
select
    JobDepartment.jobdept, 
    avg(SalaryBonus.bonus) as Avgbonus
from JobDepartment
join SalaryBonus on JobDepartment.Job_ID = SalaryBonus.Job_ID
group by JobDepartment.jobdept;

-- 3
select JobDepartment.jobdept, 
sum(SalaryBonus.bonus) as totalbonus
from JobDepartment
join SalaryBonus on JobDepartment.Job_ID = SalaryBonus.Job_ID
group by JobDepartment.jobdept
order by totalbonus DESC
LIMIT 1;

-- 4
select 
    avg(Payroll.total_amount)
from Payroll;

--------------------------------------------------------------------------------------------------------------------------

-- 6. EMPLOYEE PERFORMANCE AND GROWTH 
-- Which year had the highest number of employee promotions?

select year(Qualification.Date_In) as promotion_year, 
count(*) as total_promotions
from Qualification
group by year (Qualification.Date_In)
order by total_promotions desc
limit 1;