-- 1. Employee Details: employee number, last name, first name, sex, and salary
SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary
FROM Employees AS e
JOIN Salaries AS s USING (emp_no);

-- 2. First name, last name, and hire date for employees hired in 1986
SELECT first_name, last_name, hire_date
FROM Employees
WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31';

-- 3. Manager Details: dept number, dept name, manager employee number, last name, first name
SELECT dm.dept_no, d.dept_name, dm.emp_no, e.last_name, e.first_name
FROM Department_Managers AS dm
JOIN Departments AS d USING (dept_no)
JOIN Employees AS e USING (emp_no);

-- Create view to be used in queries 4, 6, 7
CREATE VIEW emp_and_dept AS
	SELECT de.emp_no, e.last_name, e.first_name, d.dept_name
	FROM Department_Employees AS de
	JOIN Departments AS d USING (dept_no)
	JOIN Employees AS e USING (emp_no);

-- 4. Employee Departments: employee number, last name, first name, and department name
SELECT *
FROM emp_and_dept;

-- 5. Hercules B: first name, last name, sex
SELECT first_name, last_name, sex
FROM Employees
WHERE first_name = 'Hercules' AND last_name LIKE 'B%';

-- 6. Sales Department: employee number, last name, first name, dept name
SELECT *
FROM emp_and_dept
WHERE dept_name = 'Sales';

-- 7. Sales & Development Departments: employee number, last name, first name, dept name
SELECT *
FROM emp_and_dept
WHERE dept_name = 'Sales' OR dept_name = 'Development';

-- 8. Last name frequency
SELECT last_name, COUNT(last_name) AS last_name_count
FROM Employees
GROUP BY last_name
ORDER BY last_name_count DESC;