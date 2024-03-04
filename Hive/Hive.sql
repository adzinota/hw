-- Настройка параметров для динамического партиционирования
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;

--drop table student10.task;
--drop database student10;

-- Создание базы данных и выбор этой базы
create database if not exists student10;
use student10;

-- Создание таблицы с заданной структурой
create table task(id bigint, col1 string, col2 string, col3 string)
partitioned by(p int)
stored as parquet;

-- Структура созданной таблицы
describe task;

-- Вставка сгенерированных данных в таблицу
insert into task partition (p)
select * from
(with gnrt as 
	(select 
		concat(
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end) as col1,
		concat(
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end) as col2,
		concat(
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end,
			case when rand() >= 0.5 then chr(97 + floor(rand() * 25) ) else chr(48 + floor(rand() * 9)) end) as col3,
		id
	from (select posexplode(split(space(9999), ' ')) as (id, d)) t)
select id, col1, col2, col3, ntile(10) over() as p from gnrt) as tab;

-- Просмотр партиций
show partitions task;

-- Просмотр первых десяти строк
select *
from task
limit 10;

-- Просмотр того, что id и количество строк совпадают с заданием
select min(id) as min_id, max(id) as max_id, count(*) as row_count
from task;

-- Просмотр того, что id и количество строк по партициям совпадают с заданием
select p as part, min(id) as min_id, max(id) as max_id, count(*) as row_count
from task
group by p;

/*
Задание 1
Для каждой патриции выведите минимальное, максимальное значение id и общее количество строк для случаев, когда:
*/

-- все три текстовых поля заполнены буквами
select p as part, min(id) as min_id, max(id) as max_id, count(*) as row_count
from task
where concat(col1, col2, col3) rlike '^[a-z]+$'
group by p;

-- просмотр этих полей
select *
from task
where concat(col1, col2, col3) rlike '^[a-z]+$'
order by id;

-- все три текстовых поля заполнены цифрами
select p as part, min(id) as min_id, max(id) as max_id, count(*) as row_count
from task
where concat (col1, col2, col3) rlike '^[0-9]+$'
group by p;

-- просмотр этих полей
select *
from task
where concat (col1, col2, col3) rlike '^[0-9]+$'
order by id;

/*
Задание 2
Удалите из таблицы поле col2, при этом данные по остальным полям в таблице должны быть сохранены.
Подсказка: напрямую поле из таблицы удалить не получится, нужен ряд последовательных действий.
*/

-- Создадим новую таблицу с той же структурой
create table temp(id bigint, col1 string, col3 string) partitioned by(p int) stored as parquet;

describe temp;

-- Скопируем в нее нужные столбцы из исходной
insert into temp
select id, col1, col3, p
from task;

-- Посмотрим таблицы
show tables;

select * from task limit 10;

select * from temp limit 10;

-- Удалим исходную таблицу и переименуем новую
drop table task;

alter table temp rename to task;

describe task;

show tables;