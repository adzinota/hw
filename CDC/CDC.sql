-- Создание схемы и таблиц

create schema cdc;

create table cdc.source (
	id int,
	attr1 int,
	attr2 int,
	gregor_dt date
);

insert into cdc.source values
(1,	11,	111, '01.01.2023'),
(2,	22,	222, '01.01.2023'),
(3,	33,	333, '01.01.2023'),
(5,	55,	555, '01.01.2023'),
(6,	66,	666, '01.01.2023'),
(1,	11,	111, '01.02.2023'),
(2,	22,	222, '01.02.2023'),
(3,	33,	333, '01.02.2023'),
(4,	44,	444, '01.02.2023'),
(5,	55,	5555, '01.02.2023'),
(1,	11,	111, '01.08.2023'),
(2,	222,222, '01.08.2023'),
(3,	33,	333, '01.08.2023'),
(5,	55,	5555, '01.08.2023');

create table cdc.target (
	id int,
	attr1 int,
	attr2 int,
	start_dt date,
	end_dt date,
	ctl_action char(1),
	ctl_datechange date
);

/*
Задача 1.1:	Написать прототип реализующий заполнение Target из Source по примеру
В источнике данные хранятся в срезном виде, а в целевой таблице в интервальном
Суть задачи в том, чтобы перенести интервальное хранение в срезное
Предполагается, что прототип запускается каждый день в инкрементальном режиме и переносит данные только за дату запуска
*/

create or replace procedure cdc.etl(in launch_date date)
language plpgsql
as $procedure$
begin
	-- ctl_action=U (Update)
    update cdc.target
    set
        end_dt = launch_date - interval '1 day',
        ctl_action = 'U',
        ctl_datechange = launch_date
    where
        id in (select id from cdc.source where gregor_dt = launch_date)
        and end_dt = '9999-12-31'
        and launch_date > start_dt
        and exists (select 1
					from cdc.source as s
					where
						s.gregor_dt = launch_date
                		and s.id = cdc.target.id
                		and (s.attr1 <> cdc.target.attr1 or s.attr2 <> cdc.target.attr2));

    -- ctl_action=D (Delete)
    update cdc.target
    set
        end_dt = launch_date - interval '1 day',
        ctl_action = 'D',
        ctl_datechange = launch_date
    where
        id not in (select id from cdc.source where gregor_dt = launch_date)
        and end_dt = '9999-12-31'
        and launch_date > start_dt
        and not exists (select 1
						from cdc.source as s
						where
							s.gregor_dt = launch_date
							and s.id = cdc.target.id);

    -- ctl_action=I (Insert)
    insert into cdc.target
    select
        s.id,
        s.attr1,
        s.attr2,
        launch_date as start_dt,
        '9999-12-31' as end_dt,
        'I' as ctl_action,
        launch_date as ctl_datechange
    from
        cdc.source as s
    where
        s.gregor_dt = launch_date
        and not exists (select 1
        				from cdc.target as t
        				where
        					t.id = s.id
        					and t.end_dt = '9999-12-31');
end $procedure$;

-- Запуск процедуры

call cdc.etl('2023-01-01');

call cdc.etl('2023-02-01');

call cdc.etl('2023-08-01');

-- Вывод результата

select *
from cdc.target as t
order by id, start_dt

/*
Задача 1.2:	Написать прототип, забирающий из Target актуальную (последнюю) запись по каждому уникальному значению ID
При этом не использовать select * from target where end_dt='9999-12-31'
*/

with q as
	(select *, row_number() over (partition by id order by end_dt desc) as r_num
	from cdc.target)
select id, attr1, attr2, start_dt, end_dt, ctl_action, ctl_datechange
from q
where r_num = 1;