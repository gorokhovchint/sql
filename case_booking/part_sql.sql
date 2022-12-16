-- создаем таблицы с данными пользователей
DROP TABLE IF EXISTS users;
CREATE TABLE users(
   ID_USER INTEGER NOT NULL,
   NAME_ADD VARCHAR(255) NOT NULL,
   PHONE VARCHAR(255) NOT NULL,
   DATE_ADD DATE NOT NULL,
   PRIMARY KEY (ID_USER)
);
INSERT into users (ID_USER, NAME_ADD, PHONE, DATE_ADD) values (1463540, 'Mariet', '9044321230', '2021-05-01'), 
(1463541, 'Iwona', '9044321231', '2021-05-01'),
(1463542, 'Anand', '9044321232', '2021-05-01'),
(1463543, 'Augustus', '9044321233', '2021-05-01'),
(1463544, 'Koko', '9044321234', '2021-05-01'),
(1463545, 'Marylynn', '9044321235', '2021-05-01'),
(1463546, 'Natala', '9044321236', '2021-05-01'),
(1463547, 'Tora', '9044321237', '2022-05-01'),
(1463548, 'Brax', '9044321238', '2022-05-01'),
(1463549, 'Sande', '9044321239', '2022-05-01'),
(1463550, 'Hilliary', '9044321240', '2022-05-01'),
(1463551, 'Raelyn', '9044321241', '2022-05-01'),
(1463552, 'Chip', '9044321242', '2022-05-01'),
(1463553, 'Grietje', '9044321243', '2022-05-01'),
(1463554, 'Tsuyoshi', '9044321244', '2022-05-01')

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
   ID_ORDER INTEGER NOT NULL,
   ID_OBJECT INTEGER NOT NULL,
   ID_USER INTEGER NOT NULL,
   PRICE NUMERIC(21,16) NOT NULL,
   DATE_ADD DATE NOT NULL,
   PRIMARY KEY (ID_ORDER)
);
INSERT into orders (ID_ORDER, ID_OBJECT, ID_USER, PRICE, DATE_ADD) values (7810, 570800, 1463540, 10550, '2022-06-11'),
(7811, 570801, 1463541, 10579, '2022-06-11'),
(7812, 570802, 1463542, 7550, '2022-06-12'),
(7813, 570803, 1463543, 2554, '2022-06-13'),
(7814, 570804, 1463544, 13550, '2022-07-02'),
(7815, 570805, 1463545, 7555, '2022-07-02'),
(7816, 570806, 1463546, 12556, '2022-07-04'),
(7817, 570807, 1463547, 18553, '2022-07-05'),
(7818, 570808, 1463548, 7552, '2022-07-10'),
(7819, 570809, 1463549, 11902, '2022-07-12'),
(7820, 570810, 1463550, 5052, '2022-07-15'),
(7821, 570811, 1463551, 8952, '2022-07-15'),
(7822, 570812, 1463552, 1352, '2022-07-15'),
(7823, 570813, 1463553, 7852, '2022-07-21'),
(7824, 570814, 1463554, 12652, '2022-07-21')

DROP TABLE IF EXISTS objects;
CREATE TABLE objects (
   ID_OBJECT INTEGER NOT NULL,
   CITY VARCHAR(255) NOT NULL,
   TYPE_ADD VARCHAR(255) NOT NULL,
   NAME_ADD VARCHAR(255) NOT NULL,
   OWNER_ID INTEGER NOT NULL,
   DATE_ADD DATE NOT NULL,
   PRIMARY KEY (ID_OBJECT)
);
INSERT into objects (ID_OBJECT, CITY, TYPE_ADD, NAME_ADD, OWNER_ID, DATE_ADD) values (570800, 'Москва', 'Квартира', 'Mariet', 10, '2022-06-11'),
(570801, 'Воронеж', 'Квартира', 'Iwona', 11, '2022-06-11'),
(570802, 'Самара', 'Квартира', 'Anand', 12, '2022-06-12'),
(570803, 'Москва', 'Квартира', 'Augustus', 13, '2022-06-13'),
(570804, 'Воронеж', 'Квартира', 'Koko', 14, '2022-07-02'),
(570805, 'Самара', 'Квартира', 'Marylynn', 15, '2022-07-02'),
(570806, 'Москва', 'Квартира', 'Natala', 16, '2022-07-04'),
(570807, 'Воронеж', 'Квартира', 'Tora', 17, '2022-07-05'),
(570808, 'Самара', 'Квартира', 'Brax', 18, '2022-07-10'),
(570809, 'Москва', 'Квартира', 'Sande', 19, '2022-07-12'),
(570810, 'Воронеж', 'Квартира', 'Hilliary', 20, '2022-07-15'),
(570811, 'Самара', 'Квартира', 'Raelyn', 21, '2022-07-15'),
(570812, 'Москва', 'Квартира', 'Chip', 22, '2022-07-15'),
(570813, 'Воронеж', 'Квартира', 'Grietje', 23, '2022-07-21'),
(570814, 'Самара', 'Квартира', 'Tsuyoshi', 24, '2022-07-21')

-- Пишем запрос
CREATE EXTENSION IF NOT EXISTS tablefunc
with sales_summary as (select *
from crosstab('select o2.city as city, cast(EXTRACT(YEAR FROM t1.date_reg) as VARCHAR) as date_reg, ROUND(AVG(t1.price)) as price 
from
(select u.id_user, u.date_add as date_reg, o.id_order, o.price, o.id_object  
from users u
join orders o
on o.id_user = u.id_user) as t1
join objects o2 
on o2.id_object = t1.id_object
group by 1, 2
order by city ASC, date_reg ASC', 'SELECT DISTINCT cast(EXTRACT(YEAR FROM date_add) as VARCHAR) as year FROM users order by year ASC')
AS 
sales_years(city varchar, y2021 NUMERIC, y2022 NUMERIC))

select sales_summary.*, cast(ROUND(((y2021-y2022)/y2021*100) * -1) as varchar) || '%' as per 
from sales_summary