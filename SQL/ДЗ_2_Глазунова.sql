--1. Напишите запрос, возвращающий системную дату. Назовите колонку 'Date'.

select current_date as Date;

--2. Напишите запрос, возвращающий ID сотрудника, его имя и фамилию, текущую зарплату и зарплату, увеличенную на 15.5% (в виде целого числа). Назовите новую колонку 'New Salary'.

select employee_id, first_name, last_name, salary, round(salary * 1.155, 0) as new_salary
from employees;

--3. Напишите запрос, возвращающий ID сотрудника, его имя и фамилию, текущую зарплату и зарплату, увеличенную на 15.5% (в виде целлого числа) и разность между текущей зарплатой и зарплатой после увеличения. Назовите новые колонку 'New Salary' и 'Increase'.

select employee_id, first_name, last_name, salary, round(salary * 1.155, 0) as new_salary, round(salary * 1.155, 0) - salary as increase
from employees;

--4. Напишите запрос, возвращающий фамилию сотрудника (первая буква должна быть большой, остальные - маленькими) и количество букв в фамилии для сотрудников, фамилии которых начинаются с 'J', 'A' или 'M'. Назовите колонки 'Name' и 'Length'. Отсортируйте результат по возрастанию длины фамилии. 

select
	upper(substring(last_name, 1, 1)) || lower(substring(last_name, 2, length(last_name))) as Name,
	length(last_name) as Length
from
	employees
where
	last_name like 'J%'
	or last_name like 'A%'
	or last_name like 'M%'
order by
	length(last_name);

--5. Напишите запрос, возвращающий фамилию сотрудника (первая буква должна быть большой, остальные - маленькими) и количество букв в фамилии для сотрудников, фамилии которых начинаются с буквы, которую вводит пользователь. Назовите колонки 'Name' и 'Length'. Отсортируйте результат по возрастанию длины фамилии. Напишите запрос таким образом, чтобы его результат не зависел от регистра символов, в котором вводится буква.

-- Примечание: функция ввода с клавиатуры работает только в Oracle DB, аналога для PostgreSQL не нашла, сделала через Oracle с изменением DDL

select
	upper(substr(last_name, 1, 1)) || lower(substr(last_name, 2, length(last_name))) as Name,
	length(last_name) as Length
from employees
where last_name like upper('&letter%')
order by
	length(last_name);

--6. Напишите запрос, возвращающий для всех сотрудников фамилию и количесво месяцев, в течение которого этот сотрудник работает в компании (округлите результат до ближайшего целого числа). Назовите колонку 'MONTH_WORKED'. Отсортируйте записи по возрастанию количества месяцев.

--PostgreSQL
select last_name,
round((extract(epoch from current_date) - extract(epoch from hire_date)) / (3600*24*(1.0*365/12)), 0) as month_worked
from employees
order by month_worked, last_name;

--Oracle
select last_name,
months_between(current_date,hire_date) as month_worked
from employees
order by month_worked, last_name;

--7. Напишите запрос возвращающий фамилию сотрудника и его зарплату. отформатируйте колонку с зарплатой так, чтобы её длина составляла 15 символов, а недостающие символы заполнялись символом '$' слева от суммы запрлаты (например 24000 -> $$$$$$$$$$24000).

select last_name, lpad(salary::varchar, 15, '$') 
from employees;

--8. Напишите запрос, отображащий первые 8 символов фамилии пользователя и отображающий его зарплату в виде строки символов '*', где каждый символ соответствует 100$. Отсортируйте результат по убыванию зарплаты. Назовите полученную колонку 'EMLOYEES_AND_THEIR_SALARIES'

select substring(last_name, 0, 8) || repeat('*', (salary/100)::integer) as EMLOYEES_AND_THEIR_SALARIES
from employees 
order by salary desc;

--9. Напишите запрос, возвращающий фамилии и количество недель работы сотрудников отдела с ID - 90. Назовите полученную колонку 'TENSURE' и преобразуйте её значение в целое, отбросив вещественную часть. Отсортируйте результат по убыванию 'TENSURE'.

select last_name,
trunc((extract(epoch from current_date) - extract(epoch from hire_date)) / (3600*24*7), 0) as tensure
from employees
where department_id = 90
order by tensure desc;

--10. Напишите запрос, возвращающий строку следующего вида для каждого сотрудника: "<фамилия> зарабатывает <зарплата> каждый месяц, но хочет получать <зарплата * 3>". Назовите колонку 'Dream Salaries'

select last_name || ' зарабатывает ' || salary::varchar || ' каждый месяц, но хочет получать '|| (salary*3)::varchar as dream_salaries
from employees;

--11. Напишите запрос, возвращающий фамилию, дату устройства на работу и дату пересмотра зарплаты для каждого сотрудника. Дата пересмотра зарплаты - первый понедельник после 6 месяцев работы в компании. Назовите колонку 'REVIEW'. Отформатируйте значение этой колонки так, чтобы дата выводилась в виде строки "Monday, the Thirty-First of July, 2000"

with q as
(select last_name, hire_date,
case
	when date_part('dow', hire_date + interval '6 month') = 1 then hire_date + interval '6 month'
	else interval '1 week' + date_trunc('week', hire_date + interval '6 month')
end as review
from employees)

select last_name, hire_date,
'Monday, the ' || date_part('day', review) || ' of ' || 
('{January, February, March, April, May, June, July, August, September, October, November, December}'::text[])[date_part('month',review)] || 
', ' || date_part('year', review) as review
from q;

--12. Напишите запрос, возвращающий фамилию сотрудника и размер комиссии. Если сотрудник не получает комиссию - выведите 'No Comission'. Назовите полуеченную колонку COMM.

select last_name, salary,
case
	when commission_pct is null then 'No Comission'
	else (salary*commission_pct)::integer::varchar
end as comm
from employees;

--13. Напишите запрос, возвращающий адреса всех департаментов. Запрос должен возвращать ID локации, адрес (улицу), город, штат и страну. Используйте NATURAL JOIN.

select distinct(location_id), street_address, city, state_province, country_name 
from departments
natural join locations
natural join countries
order by location_id;

--14. Напишите запрос, возвращающий фамилию, ID отдела и наименование отдела для каждого сотрудника;

select last_name, department_id, department_name 
from employees
natural join departments
order by last_name;

--15. Напишите запрос, возвращающий фамилию, JOB_ID, ID отдела и название отдела для всех сотрудников из Торонто.
select last_name, job_id, department_id, department_name 
from employees
natural join departments
natural join locations
where city='Toronto';

--16. Напишите запрос, возвращающий фамилию, ID сотрудника, фамилию менеджера и ID менеджера для каждого сотрудника. Назовите колонки 'Employee', 'Emp#', 'Manager', 'Mgr#'.
select e.last_name as Employee, e.employee_id as Emp_N, m.last_name as Manager, e.manager_id as Mgr_N
from employees as e
join employees as m on e.manager_id = m.employee_id
order by e.employee_id;

--17. Напишите запрос, возвращающий фамилию, ID сотрудника, фамилию менеджера и ID менеджера для каждого сотрудника (для сотрудников, у которых нет менеджера, в этих колонках должен быть NULL). Назовите колонки 'Employee', 'Emp#', 'Manager', 'Mgr#'.

select e.last_name as Employee, e.employee_id as Emp_N, m.last_name as Manager, e.manager_id as Mgr_N
from employees as e 
left join employees as m on e.manager_id = m.employee_id
order by e.employee_id;

--18. Напишите запрос, возвращающий ID отдела, фамилию сотрудника и фамилии всех сотрудников, работающих в том же отделе. Назовите колонки 'DEPARTMENT', 'EMPLOYEE' и 'COLLEAGUE'.

select e1.department_id as department, e1.last_name as employee, e2.last_name as colleague
from employees as e1, employees as e2
where e1.employee_id != e2.employee_id and e1.department_id = e2.department_id;

--19. Напишите запрос, возвращающий фамилию и дату найма всех сотрудников, нанятых после David.

--Людей с такой фамилией нет, возьмем того Дэвида, которого наняли последним

select last_name, hire_date
from employees
where hire_date > (select hire_date
				   from employees
				   where first_name = 'David'
				   order by hire_date desc
				   limit 1)
order by hire_date;

--20. Напишите запрос, возвращающий фамилию сотрудника, дату найма сотрудника, фамилию менеджера и дату найма менеджера для всех сотрудников, нанятых раньше, чем их менеджеры.

select e.last_name as employee, e.hire_date employee_hire_date, 
m.last_name as manager, m.hire_date as manager_hire_date
from employees as e
join employees as m on e.manager_id = m.employee_id
where e.hire_date < m.hire_date 
order by e.hire_date;

--22. Напишите запрос, возвращающий ID сотрудника, фамилию и зарплату всех сотрудников, получающих зарплату больше средней по компании. Отсортируйте результат по возрастанию зарплаты. Используйте подзапрос.

select employee_id, last_name, salary
from employees
where salary > (select avg(salary) from employees)
order by salary;

--23. Напишите запрос, возвращающий ID сотрудника и фамилию всех сотрудников, работающих в одном отделе с работником, в чьей фамилии есть буква 'u'. Используйте подзапрос.

select employee_id, last_name
from employees
where department_id in (select distinct(department_id)
						from employees
						where last_name like '%u%')
and employee_id not in (select employee_id
						from employees
						where last_name like '%u%')
order by employee_id;

--24. Напишите запрос, возвращающий фамилию, ID отдела и JOB_ID всех сотрудников, отдел которых расположен в локации с ID 1700. Используйте подзапрос.

select last_name, department_id, job_id
from employees
where department_id in (select department_id
						from departments
						where location_id = 1700);

--25. Напишите запрос, возвращающий фамилии и зарплаты всех сотрудников, которые подчиняются сотруднику King. Используйте подзапрос.

select last_name, salary
from employees
where manager_id in (select employee_id
from employees
where last_name = 'King');

--26. Напишите запрос возвращающий ID отдела, фамилии и JOB_ID для всех сотрудников Executive department.

select department_id, last_name, job_id
from employees
where department_id in (select department_id
						from departments
						where department_name = 'Executive');

--27. Напишите запрос, возвращающий фамилии всех сотрудников, получающих больше, чем любой сотрудник отдела с ID 6.

select last_name
from employees
where salary > (select max(salary)
				from employees
				where department_id = 60);

--28. Напишите запрос, возвращающий ID, фамилии и зарплаты всех сотрудников, работающих в одном отделе с работником, в чьей фамилии есть буква 'u' и получающих больше средней зарплаты в компании. Используйте подзапрос.

select employee_id, last_name
from employees
where department_id in (select distinct(department_id)
						from employees
						where last_name like '%u%')
and employee_id not in (select employee_id
						from employees
						where last_name like '%u%')
and salary > (select avg(salary)
			  from employees)
order by salary;