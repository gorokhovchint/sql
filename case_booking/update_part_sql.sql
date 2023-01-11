-- Это обновленый запрос! Таблицы и первый запрос были созданны в файле 'part_sql'
-- Убрал из первого селекта поля которые не используем для аналитики;
-- Исключил подзапрос который был создан для джоина с таблицей 'objects', 
-- а также использую оператор using() в который передаются поля для соединения;
-- Написание кода оформленно лаконично, что облегчает его чтение;

with sales_summary as (select o2.city as city
,extract(year from u.date_add)::varchar as date_reg
,round(avg(o.price)) as price 
from users u
join orders o using(id_user)
--on o.id_user = u.id_user
join objects o2 using(id_object)
--on o2.id_object = o.id_object
group by 1,2),

-- Изменил способ для поворота(pivot) таблицы, здесь использую CASE 
-- а также добавил новое поле 'all_years', где видим среднию стоимость покупки за все годы.

agg_sales as (select city, sum(price) as all_years
,sum(case when date_reg = '2021' then price else null end) as y2021
,sum(case when date_reg = '2022' then price else null end) as y2022
from sales_summary
group by 1)

select *, round((y2021 - y2022) / y2021 * -100) || '%' as per
from agg_sales