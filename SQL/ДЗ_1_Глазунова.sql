/*
К вам обратились представители it-отдела полиции города Верхняя Пышма (Свердловской области).
В регионе повышенный уровень организованной преступности, и в рамках модернизации было решено хранить информацию о преступных группировках в электроннном виде, в базе PostgreSQL.

После 10 бессонных ночей, и 20 пересогласований, аналитики и архитектор составили вот такую схему:

Задание 1. Создайте таблицы со следующими полями.
Используйти первичные и внешние ключи с подходящими условиями.
Для id используйте целочисленный тип int, для строк - тип varchar(30), для дат - тип date.

district - районы
    district_id - id района
    district_name - название района

    Ограничения:
        Все названия районов должны быть не пустым и уникальным
        Нельзя удалить район, в котором есть улицы*/

create table district
(
   district_id integer,
   district_name varchar(30) unique not null,
   
   constraint district_pk primary key (district_id)
);

/*
street - улицы
    street_id - id улицы
    street_name - название улицы
    district_id - id района, в к которому относится улица

    Ограничения:
        Каждая улица должна иметь не пустое имя и относиться к какому-нибудь району

*/

create table street
(
   street_id integer,
   street_name varchar(30) not null,
   district_id integer not null,
   
   constraint street_pk primary key (street_id),
   constraint street_district_fk foreign key (district_id) references district (district_id) on delete restrict
);

/*
gang - преступная группировка
    gang_id - id группировки
    gang_name - название группировки

    Ограничения:
        Название группировки должно быть не пустым и уникальным
        При удалении банды, у всех приступников, состоящих в этой банде, gang_id должен стать равным NULL
*/

create table gang
(
   gang_id integer,
   gang_name varchar(30) not null,
   
   constraint gang_pk primary key (gang_id),
   constraint unique_gang_name unique(gang_name)
);

/*
gang_street_relation - связи (many-to-many) меджу бандами, и улицами, которые они контролируют
    gang_id - id группировки
    street_id - id улицы

    Ограничения:
        Все пары значений не должны повторяться и быть не пустыми (составной первичный ключ)
        При удалении банды или улицы, должны удаляться соответствующие записи
*/

create table gang_street_relation
(
   gang_id integer,
   street_id integer,

   constraint gang_street_pk primary key (gang_id, street_id),
   constraint gang_fk foreign key (gang_id) references gang (gang_id) on delete cascade,
   constraint street_fk foreign key (street_id) references street (street_id) on delete cascade
);

/*
criminal - преступник
    criminal_id - id преступника
    last_name - фамилия
    first_name - имя
    middle_name - отчество
    birth_date - дата рождения
    death_date - дата смерти
    gang_id - id банды, в которой он состоит

    Ограничения:
        Фамилия и имя должны быть не пустыми
        Фамилия, имя и отчество должны начинаться с больших букв (если не пустые)
        Дата рождения должна быть не пустой
*/

create table criminal
(
   criminal_id integer,
   last_name varchar(30) not null ,
   first_name varchar(30) not null,
   middle_name varchar(30),
   birth_date date not null,
   death_date date,
   gang_id integer,
   
   constraint criminal_pk primary key (criminal_id),
   constraint criminal_gang_fk foreign key (gang_id) references gang (gang_id) on delete set null,
   constraint check_last_name check (substring(last_name, 1, 1) ~* '^[А-Я]+$'),
   constraint check_first_name check (substring(first_name, 1, 1) ~* '^[А-Я]+$'),
   constraint check_middle_name check (substring(middle_name, 1, 1) ~* '^[А-Я]+$' or middle_name is null)
);
/*
Заказчик прислал вам письмо со списком районов, улиц, и банд.

Задание 2: Внесите в созданные таблицы следующе данные:

Районы и улицы:
1 - Ленинский
    1 - Проспект Ленина
    2 - Улица Ленина
    3 - 3й Ленинский проезд
    4 - 8й Ленинский тупик
2 - Кировский
    5 - Хажайная
    6 - Набережная
    7 - Астраханская
    8 - Московская
    9 - Мирный переулок
3 - Заводской
    10 - Проспект 50 лет октября
    11 - Электроугли
    12 - Улица академика Яблочкова
4 - Солнечный
    13 - Новоузенская
    14 - Улица имени Салтыкова-Щедрина
    15 - 99й автобусный тупик
    16 - Проспект 50 лет октября

Банды, и id улиц, которые они держат:
1 - Анонимные алкоголики
    1, 2, 4, 5
2 - Неуловимые мстители
    3, 7
3 - Дикобразы
    6, 10, 12
4 - Анонимные хакеры
    8, 9
5 - Панки
    15
*/

insert into district (district_id, district_name) values
(1, 'Ленинский'),
(2, 'Кировский'),
(3, 'Заводской'),
(4, 'Солнечный');

insert into street (street_id, street_name, district_id) values
(1, 'Проспект Ленина', 1),
(2, 'Улица Ленина', 1),
(3, '3й Ленинский проезд', 1),
(4, '8й Ленинский тупик', 1),
(5, 'Хажайная', 2),
(6, 'Набережная', 2),
(7, 'Астраханская', 2),
(8, 'Московская', 2),
(9, 'Мирный переулок', 2),
(10, 'Проспект 50 лет октября', 3),
(11, 'Электроугли', 3),
(12, 'Улица академика Яблочкова', 3),
(13, 'Новоузенская', 4),
(14, 'Улица имени Салтыкова-Щедрина', 4),
(15, '99й автобусный тупик', 4),
(16, 'Проспект 50 лет октября', 4);

insert into gang (gang_id, gang_name) values
(1, 'Анонимные алкоголики'),
(2, 'Неуловимые мстители'),
(3, 'Дикобразы'),
(4, 'Анонимные хакеры'),
(5, 'Панки');

insert into gang_street_relation (gang_id, street_id) values
(1, 1),
(1, 2),
(1, 4),
(1, 5),
(2, 3),
(2, 7),
(3, 6),
(3, 10),
(3, 12),
(4, 8),
(4, 9),
(5, 15);

/*
После прогона всех личных дел преступников через ABBY FineReader, заказчик прислал вам такую таблицу:
*/

create table temp_criminal (
    criminal_id int,
    surname varchar(30),
    name varchar(30),
    otchestvo varchar(30) ,
    birth_date varchar(30),
    death_date varchar(30),
    gang_id int
);

insert into temp_criminal values
(1  , 'осипова'     , 'наина'      , NULL          , '16.10.1964' , NULL       , 1),
(2  , 'кудрявцева'  , 'екатерина'  , 'сергеевна'   , '07.03.1989' , '20210607' , 4),
(3  , 'виленович'   , 'лаврентьев' , '   ипатиев'  , '08.02.1991' , '20190901' , 2),
(4  , 'харитонович' , 'андрей'     , 'андреев    ' , '05.02.1964' , '20110728' , 4),
(5  , 'романовна'   , 'таисия'     , 'ершова'      , '16.02.1960' , NULL       , 5),
(6  , '  тарасов'   , 'трофим'     , NULL          , '23.12.2018' , NULL       , 1),
(7  , '  фомичев'   , 'арсений'    , 'геннадиевич' , '14.08.1964' , NULL       , 2),
(8  , 'гертрудович' , 'мирон'      , ' тимурович  ', '18.01.2001' , NULL       , 5),
(9  , 'виноградова' , ' иванна '   , NULL          , '11.02.1976' , '20080624' , 4),
(10 , 'одинцова'    , 'виктория'   , 'антоновна'   , '18.06.1975' , NULL       , 4);

/*
Задание 3. Создайте и заполните таблицу temp_criminal, используя код выше.
Изменять данные в таблице temp_criminal запрещено.
Вставьте все записи из таблицы temp_criminal в таблицу criminal так, что бы все записи вставились без ошибок.
Для решения воспользуйтесь конструкцией insert into ... select ...
*/

-- Возможно, как-то можно сделать более простым способом
-- Пояснения - в исходных данных видно, что часть Ф и О были перепутаны местами, в case проверяется условие, что исходная Ф имеет формат отчества, при этом О должна его не иметь (для исключения фамилий на -вич), далее преобразуется под требуемый формат

insert into	criminal
select
	criminal_id,
	case 
		when (trim(surname) like '%вич' or trim(surname) like '%вна') and trim(otchestvo) not like '%вич' then
		upper(substring(trim(otchestvo), 1, 1)) || lower(substring(trim(otchestvo), 2, length(trim(otchestvo))))
	else
		upper(substring(trim(surname), 1, 1)) || lower(substring(trim(surname), 2, length(trim(surname))))
	end,
	upper(substring(trim(name), 1, 1)) || lower(substring(trim(name), 2, length(trim(name)))),
	case 
		when (trim(surname) like '%вич' or trim(surname) like '%вна') and trim(otchestvo) not like '%вич' then
		upper(substring(trim(surname), 1, 1)) || lower(substring(trim(surname), 2, length(trim(surname))))
	else
		upper(substring(trim(otchestvo), 1, 1)) || lower(substring(trim(otchestvo), 2, length(trim(otchestvo))))
	end,
	to_date(birth_date, 'DD.MM.YYYY'),
	to_date(death_date, 'YYYYMMDD'),
	gang_id
from temp_criminal;

/*
Задание 4: В честь 104 летия Великой Октябрьской Революции, администрация Заводского района решила переименовать "Проспект 50 лет октября" в "Проспект 104 лет октября".
Внесите соответствующие изменения в базу, не указывая конкретный id улицы
*/

update street as s
set street_name = 'Проспект 104 лет октября'
from district as d
where s.street_name = 'Проспект 50 лет октября'
and d.district_name = 'Заводской'
and s.district_id = d.district_id;

/*
В результате сегодняшней потасовки:
1. Ликвидирована банда "Панки" (запись о банде надо удалить)
2. Трагически погибли все её участники (нужно установить им дату смерти)
3. 99й автобусный тупик Солнечного района уничтожен, на его месте теперь пустырь (запись об улице надо удалить)

Задание 5: Внесите соответствующие изменения в базу. Для получения сегодняшней даты используйте соответствующую функцию
*/

delete from gang 
where gang_name = 'Панки';

update criminal
set death_date = current_date
where gang_id is null;

delete from street as s
using district as d
where s.street_name = '99й автобусный тупик'
and d.district_name = 'Солнечный';

/*
Задание 6: напишите запрос, возвращающий ФИО (как одно поле) и дату рождения в формате 'DD MON YYYY' всех живых преступников 1964 года рождения
*/

select concat_ws(' ', last_name, first_name, middle_name) as full_name,
to_char(birth_date, 'DD MON YYYY') as birth_date
from criminal
where death_date is null
and date_part('year', birth_date) = 1964;

/*
Задание 7: К базе данных подключился злоумышленник, и хочет удалить все таблицы. Какие команды он напишет?
Все команды никогда не должны завершаться с ошибкой, даже если таблицы уже была удалена ранее.
*/

drop table if exists district cascade;

drop table if exists street cascade;

drop table if exists gang cascade;

drop table if exists gang_street_relation cascade;

drop table if exists criminal cascade;

/*
Для решения заданий в этой работе используются те же таблицы, что вы создали в первом ДЗ, а именно:
    1. district
    2. street
    3. gang
    4. gang_street_relation
    5. criminal

Задание 1.
Во время тестирования на стороне заказчика выяснилось, что требования к таблицам были составлены неккоректно.
В таблицу criminal нужно добавить:
    1. Столбец identity_document_num,  в котором будет храниться номер удостоверения личности (integer).
    2. Столбец identity_document_date, в котором будет храниться дата выдачи удостоверения личности
    3. Столбец identity_document_type, в котором будет храниться тип удостоверения личности ('Паспорт', 'Водительские права', ....)

Добавьте соответствующие столбцы в таблицу и заполните их фейковыми данными:
    1. identity_document_num  = floor(random() * 100000000)
    2. identity_document_date = current_date
    3. identity_document_type = 'Паспорт'
*/

alter table criminal
add column identity_document_num integer default floor(random() * 100000000),
add column identity_document_date date default current_date,
add column identity_document_type varchar(30) default 'Паспорт';

/*
Задание 2.
Заказчик просит добавить ограничения: все добавленные в предыдущем задании столбцы не должны содержать пустых значений,
и столбец identity_document_num не должен содержать дублей
*/

alter table criminal
alter column identity_document_num set not null,
add unique (identity_document_num),
alter column identity_document_date set not null,
alter column identity_document_type set not null;

/*
Задание 3.
Заказчик снова передумал - теперь он решил, что всех преступников мы будем идентифицировать только по паспорту, а значит информация об этом больше не нужна в таблице.
Удалите колоку identity_document_type из таблицы criminal
*/

alter table criminal
drop column identity_document_type;

/*
Задание 4.
Заказчик жалуется, что когда он ищет конкретных преступников по фамилии, или по номеру и дате выдачи паспорта, то запросы работают слишком медленно.
Создайте объекты, которые могут решить эту проблему.
*/

create index on criminal (lower(last_name));

create unique index on criminal (identity_document_num);

create index on criminal(identity_document_date);

/*
Задание 5.
Заказчик хочет получить:
    1. ФИО (буквами нижнего регистра, со знаком '_' в качестве разделителя) преступников
    2. Названия улиц, в которых они орудуют
Напишите запрос, используя INNER JOIN
*/

select concat_ws('_', last_name, first_name, middle_name) as full_name, s.street_name
from criminal as c
inner join gang as g on c.gang_id = g.gang_id 
inner join gang_street_relation as gsr on g.gang_id = gsr.gang_id
inner join street as s on gsr.street_id = s.street_id;