--1. Напишите запрос, возвращающий job_id и количество сотрудников этой профессии.

select job_id, count(employee_id)
from employees
group by job_id
order by job_id;

--2. Найдите количество сотрудников, являющихся менеджерами.

select job_id, count(employee_id)
from employees
natural join jobs
where job_title like '%Manager%'
group by job_id;

--3. Найдите разность между наибольшей и наименьшей зарплатой.

select max(salary) - min(salary) as diff
from employees;

--4. напишите запрос, возвращающий id менеджера и наименьшую зарплату его сотрудника.

select manager_id, min(salary)
from employees
group by manager_id;

--5. Напишите запрос, возвращающий id тех отделов в которых нет сотрудников с должностью ST_CLERK. Используйте операторы для работы с множествами.

select department_id
from departments

except

select department_id
from employees
where job_id <> 'ST_CLERK';

--6. Выведите id и название стран, в которых нет ни одного отдела. Используйте операторы для работы с множествами.

select country_id, country_name 
from countries
where country_id not in (select distinct(country_id)
						 from locations
						 where location_id in (select location_id
						 					   from locations
						 					   
						 					   intersect
						 					   
						 					   select location_id
						 					   from departments));

--7. Выведите список job_id и department_id для отделов 10, 50, 20. Сохраните порядок отделов как указано в условии задачи. Используйте операторы для работы с множествами.

with q as 
(select 1 as id, job_id, department_id
from employees
where department_id = 10
	  
union
	  
select 2 as id, job_id, department_id
from employees
where department_id = 50
	  
union all
	  
select 3 as id, job_id, department_id
from employees
where department_id = 20)

select job_id, department_id
from q;

--8. Выведите employee_id и job_id сотрудников, которые ранее имели ту же должность, как и сейчас.

select employee_id, job_id
from employees

intersect

select employee_id, job_id
from job_history;

--9. Выведите фамилии, id отдела и название отдела для всех сотрудников, не привязанных ни к одному отделу, а также список отделов, к которым не привязан ни один сотрудник. Используйте операторы для работы с множествами.

select employee_id, department_id
from employees
where department_id is NULL

union

select null::numeric as employee_id, department_id 
from departments

except

select null::numeric as employee_id, department_id
from employees;
