-- Порядок предложения запроса
SELECT - указывает, какие поля таблицы необходимо вывести в результирующую таблицу, OVER () - оконная функция 
FROM - указывает из какой таблицы будет выборка полей
JOIN - объединяем данные из нескольких связанных таблиц запросами: inner join, left join, right join, full outer join, cross join
[UNION|INTERSECT|EXCEPT] - объединение строк(убирает дубли), пересечение строк(оставляет только присутствующие в результатах обоих запросов), 
-- исключение строк(из строк первого запроса исключаются строки второго запроса)
WHERE(для строк) - фильтрует таблицу по значениям полей. Операторы сравнения: =,>,<,>=,<=,<> or !=. 
-- Доп.операторы условий: AND,OR,[NOT]IN,[NOT]BETWEEN,[NOT]LIKE, IS [NOT]NULL.  
GROUP BY - агрегирует(групирует) данные по какому либо полю 
HAVING(для групп) - фильтрация данных после агрегации, при использовании GROUP BY
WINDOW w AS () - именнованая оконная функция или псевдоним окна, нужна если мы пишем несколько оконных функций в одном запросе
ORDER BY - сортирует результирующую таблицу [ASC | DESC] [NULLS FIRST | NULLS LAST]
LIMIT - позволяет извлечь определенное кол-во строк. Используем OFFSSET для получения верхних/нижних N строк

-- агрегатные функции вытаскивают значения в новое поле
SELECT country, count(registration_date), MAX(registration_date), MIN(registration_date), AVG(id)
FROM `chint-297212.test_dataset1.e1_users - users`
GROUP BY 1 /*создает уникальные комбинации, которые указаны в запросе и группируют данные по полям, 
которые мы указали в запросе(GROUP BY нарезает данные на группы, и значения из этих групп приезжают в агрегатные функции, 
в новое поле, если функцию не указываем, тогда работает как DISTINCT)*/

-- У всех полей которые есть в результатирующей таблице можно посчитать кол-во строк или применить другие функции индивидуально для поля
-- v1 выводим все поля и видим что у всех одинаковое кол-во строк
SELECT count(user_id), count(orders_id), count(order_date), count(order_sum)

-- v2 Но если добавим модификатор DISTINCT то получаем только уникальные значения по каждому полю, 
-- точно такой же результат получим если будем использовать запрос GROUP BY без DISTINCT
SELECT count(DISTINCT user_id), count(DISTINCT orders_id), count(DISTINCT order_date), count(DISTINCT order_sum)

-- v3 Добавляем параметр даты и наши значения нарезаются на группы: дата + count(value) т.е получаем значение на каждую дату
SELECT order_date, count(user_id), count(DISTINCT user_id)
FROM `chint-297212.test_dataset1.e1_orders - orders`
WHERE order_date = '2015-04-10'
GROUP BY 1

-- Можно заказать группировку, но не брать поля в селект
SELECT user_id, count(*) AS count
FROM `chint-297212.test_dataset1.e1_orders - orders`
GROUP BY user_id, order_sum -- сгруппировали по двум полям, в селекте вывели одно поле 
HAVING count >= 7
ORDER BY count DESC

Primary Key -- первичный ключ - это поле значение которого уникально для каждой строки
Foreign Key  -- внешний ключ - это поле в котором содержится первичный ключ другой таблицы
-- ключи устанавливают связи между таблицами "один к одному", "один ко многим", "многие ко многим"

-- Присоединение
INNER JOIN -- внутреннее соединение 
SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25` -- основная таблица 
JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24`
ON c24.user_id = c25.id -- так же, можем джойнить по множественым условиям, если такие условия в табл существуют  
WHERE c24.orders_id <=745
ORDER BY c24.orders_id
-- берется ключ из основной таблицы и джонится с ключом из доп.таблицы, в результатирующую таблицу попадают только совпадения, строки с null не джонятся. 
-- если обе таблицы имеют одно и то же имя поля, мы можем использовать USING синтаксис: JOIN `table_name` USING(columns), 
-- тем самым исключаем написание строки с ON t1.columns=t2.columns
-- при внутреннем джоине, можем выполнить запись без JOIN, перечислив таблицы во FROM и указать ключи в WHERE 
FROM `chint-297212.test_dataset1.e1_users - users` `c25`, `chint-297212.test_dataset1.e1_orders - orders` `c24`
WHERE c24.user_id = c25.id

LEFT OUTER JOIN -- внешнее соединение(можно сравнить с функ-ей ВПР экселя);
SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25` -- основная таблица 
LEFT JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24` -- доп.таблица 
ON c24.user_id = c25.id
-- берется ключ из левой таблицы и джонится с ключом из правой таблицы, но если ключ в правой таблице не нашелся, строка все равно добавляется в результат, 
-- а значения полей правой таблицы равны null. Строки со значением которые есть только в правой таблице, а в левой их нет, не джонятся.  

RIGHT OUTER JOIN -- внешнее соединение(можно сравнить с функ-ей ВПР экселя);
SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25` -- основная таблица 
RIGHT JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24` -- доп.таблица 
ON c24.user_id = c25.id
-- берется ключ из правой таблицы и джонится с ключом из левой таблицы, но если ключ в левой таблице не нашелся, строка все равно добавляется в результат, 
-- а значения полей левой таблицы равны null. Строки со значением которые есть только в левой таблице, а в правой их нет, не джонятся. 

FULL JOIN -- полное внешнее соединение двух таблиц
SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25` -- основная таблица 
FULL JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24` -- доп.таблица 
ON c24.user_id = c25.id
-- полное внешнее соединение объединяет результаты как левого, так и правого соединения.
-- если строки в объединенной таблице не совпадают, полное внешнее соединение устанавливает значения NULL для каждого поля таблицы, 
-- в котором нет совпадающей строки.

CROSS JOIN -- перекрестное соединение 
-- Декартово произведние - это когда строки умножаются друг на друга. Если в таблице есть более 1 уникального ключа их строки будут перемножаться 
-- и в результатирующую таблицу попадут не корректные стат данные. Поэтому если в таблице есть дубликаты нужно это учитывать. 
-- Проверить можем: после LEFT JOIN кол-во строк не изменилось; суммы у числовых полей не изменились.
SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25` -- основная таблица 
CROSS JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24` -- доп.таблица
-- запись: 
FROM 'table-1', 'table-2' -- эквивалентна предыдущей с CROSS JOIN
-- запись: 
INNER JOIN 'table-2' ON true -- условие всегда оценивается как истинное, для имитации перекрестного соединения: 

Self-Join -- это когда на одну и ту же таблицу можно легко ссылаться несколько раз, используя разные псевдонимы, 
-- очень полезны для запроса иерархических данных или для сравнения строк в одной таблице.
SELECT c25.email, c25d.email, 'ok' AS name -- так же можно очень просто прокидывать какие то свои значения, в данном случае это константа. 
FROM `chint-297212.test_dataset1.e1_users - users` `c25`
JOIN `chint-297212.test_dataset1.e1_users - users` `c25d`
ON c25.email != c25d.email


-- Применяю подзапрос: джоним сначала таблицы, потом применяем агрегатную функцию для подсчета строк. 
-- так же, с помощью подзапросов можно реализовать множественные джоины.
-- Подзапросы можно использовать более 1 раза, например можно джонить две таблицы, которые были получены из подзапросов. Смотреть урок 9 там подробно. 
SELECT user_id, count(*)
FROM
(SELECT c25.email, c24.user_id, c24.order_date, c24.orders_id
FROM `chint-297212.test_dataset1.e1_users - users` `c25`
LEFT JOIN `chint-297212.test_dataset1.e1_orders - orders` `c24`
ON c24.user_id = c25.id
ORDER BY c24.orders_id)
GROUP BY user_id

-- IF условие: поиск значения - поле user_id = 8774, тогда присвоить 11, иначе NULL
SELECT IF(user_id = 8774, 11, NULL), IF (orders_id= 3402, 21, 8888), IF (order_date = '2014-09-21', '2014','09-21'), order_sum
FROM `chint-297212.test_dataset1.e1_orders - orders`

SELECT * -- DISTINCT user_id
FROM `chint-297212.test_dataset1.e1_orders - orders`
-- WHERE user_id	IS NULL -- проверяем на присутствие значения null в строке; IS NOT NULL исключает пустые значения в строке
WHERE (user_id = 8704 AND order_date = '2014-09-21' ) OR (orders_id = 12123 AND order_date = '2015-09-24' ) -- фильтр со скобками, 
-- можем строить множество микро-фильтров, где в один фильтр входят свои уникальные условия. 
ORDER BY order_sum DESC -- ASC по возрастанию(default), DESC - по убыванию; добавляя несколько полей через запятую, мы делаем множественную сортировку 

-- Конкатенация строк 
SELECT user_id || " - " ||order_date AS strings
-- CONCAT(user_id, ' - ', order_date)
FROM `chint-297212.test_dataset1.e1_orders - orders`*/

-- Арифметика. Операции выполняются по строкам(по горизонтали) 
SELECT user_id, orders_id, order_date, order_sum, user_id + order_sum AS set1
FROM `chint-297212.test_dataset1.e1_orders - orders`

-- Агрегатные функции. Агрегируют по вертикали   
SELECT order_date, count(order_sum) AS allZakaz, sum(order_sum) AS allSum, avg(order_sum) AS avg
FROM `chint-297212.test_dataset1.e1_orders - orders`
WHERE order_date <= '2013-08-28' -- сначало применяется команда WHERE к исходным данным(до агрегации) в таблице, 
-- и уже к полученной и агрегированной выборке применяется наш второй фильтр HAVING
GROUP BY 1 -- если применяем агрегатные фун-ии всегда работаем с запросом GROUP BY и добавляем все поля которые есть в SELECT кроме агрегатных функций, 
-- GROUP BY позволяет разделять данные на группы, которые можно агрегировать независимо друг от друга
-- если используем GROUP BY без агрегационной функции он будет работать как distinct выводить уникальные значения.
HAVING sum(order_sum) >= 4600 -- запрос для фильтрации строк после агрегации 
AND count(order_sum) >= 2
ORDER BY order_date

-- В операции с агрегатной фун-ей можно использовать арифметику
SELECT MIN(user_id + order_sum) AS set1
FROM `chint-297212.test_dataset1.e1_orders - orders`

-- CASE 
SELECT user_id, order_date,
CASE WHEN user_id = 8704 AND order_date > '2014-09-21'  THEN 'yes' -- в THEN указываем произвольное название поля, им же и будет значение 
ELSE 'no' END AS yes -- обязательно указываем END, ELSE не обязателный запрос(значение-произвольное) 
FROM `chint-297212.test_dataset1.e1_orders - orders`

-- CASE с агрегатными функциями
SELECT CASE WHEN user_id = 8704 AND order_date > '2014-09-21'  THEN 'yes' 
-- между WHEN и THEN можно указывать условный оператор AND, OR или WHERE после оператора FROM
ELSE 'no' END AS yes, -- обязательно ставим запятую
COUNT (*) AS count
FROM `chint-297212.test_dataset1.e1_orders - orders`
GROUP BY CASE WHEN user_id = 8704 AND order_date > '2014-09-21'  THEN 'yes'
ELSE 'no' END -- здесь удаляем алиас

-- mode
SELECT --year, month,
       CASE WHEN high IS NULL THEN 'NULL'
            ELSE 'NOT NULL' END,
            COUNT(*)
  FROM tutorial.aapl_historical_stock_price
  GROUP BY --year, month,
       CASE WHEN high IS NULL THEN 'NULL'
            ELSE 'NOT NULL' END

-- Оконные функции - нужны тогда, когда нужно получить в текущей таблице, значение соседних строк не меняя группировки. 
-- 3 query) user_id=682|shareOfRevenue=4,1 
-- смотрим на долю оплат по каждому юзеру, 
SELECT
     user_id,
     orderSum / allOrderSum * 100 AS shareOfRevenue
FROM 
(
-- 2 query) user_id=682|orderSum=3500руб|allOrderSum=9800руб 
-- пишем оконку где к первому запросу дабавляется строка с суммой всех оплат без группировки(общая) 
-- т.е применили оконную функцию и посчитали сумму всех оплат(100% поля orderSum), при этом в результатирующей таблице сохранился первый запрос.
     SELECT  
     user_id,
     orderSum,
     sum(orderSum) OVER () AS allOrderSum - вызываем оконую функцию и задаем алиас
FROM 
(
-- 1 query) user_id=682|orderSum=3500руб 
-- составляем наш первый запрос, где посчитали сумму оплату по каждому юзеру . 
     SELECT 
     user_id,
          sum(order_sum) AS orderSum
     FROM `chint-297212.test_dataset1.e1_orders - orders`
     GROUP BY 1 )
)
ORDER BY shareOfRevenue DESC

-- Оконные функции - добавляем параметры 
SELECT
     user_id, orderSum,
     orderSum / allOrderSum * 100 AS shareOfRevenue
FROM 
(
-- 2) user_id=682|orderSum=3500руб|allOrderSum=9800руб
     SELECT  
     user_id,
     orderSum as orderSum,
     sum(orderSum) OVER w_fun_sum AS allOrderSum --вызываем оконную функцию, прописываем ей имя, и дальше уже будем с ней работать в блоке FROM или после WHERE
FROM 
(
-- 1) user_id=682|orderSum=3500руб
     SELECT 
     user_id,
          sum(order_sum) AS orderSum
     FROM `chint-297212.test_dataset1.e1_orders - orders`
     GROUP BY 1)
WINDOW w_fun_sum AS (
     partition by orderSum --partition by работает так же как и GROUP BY только в рамках окна
     --ORDER BY
     --ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW - параметры рамки окна
     ))
ORDER BY orderSum desc

-- пример оконной функции с параметром PARTITION BY() в блоке SELECT 
WITH table1 AS (select user_id, order_date,
    SUM(order_sum) AS orderSum
FROM `chint-297212.test_dataset1.e1_orders - orders`
ORDER BY 1,2)

SELECT table1.*, -- оператором * выбераем все поля в таблице
SUM(orderSum) OVER (PARTITION BY order_date) AS sum_over
FROM table1 
WHERE order_date IN ('2014-09-21', '2014-08-26', '2014-08-15')
ORDER BY sum_over -- если в оконке задали аллиас, его можно уже использовать в этом же запросе.


-- Функции SQL для очистки данных:
CONCAT() -- конкатенирует несколько полей в один
LEFT(), RIGHT() -- извлекает заданное количество символов только с краев строки, не работает с FLOAT64
LENGTH() -- проверяет длину строки
CAST(column_name AS integer) -- изменяет тип данных
SUBSTR(event_date, 1, 4) -- (string, starting character position, # of characters)
RAND() -- функция генерирует рандомное число

-- чтобы использовтаь функцию LEFT с INTEGER нужно ее перевести в STRING. 
SELECT LEFT(timestamp_string, 10) timestamp_Left
FROM
(SELECT CAST(event_timestamp AS STRING) AS timestamp_string
     FROM `chint-297212.analytics_249897993.events_20210614`,
     UNNEST(event_params) AS param)

-- изменяем символьный тип данных - STRING, на тип данных date 
SELECT event_date, CAST(SUBSTR(event_date, 1, 4) || '-' || SUBSTR(event_date, 5, 2) || '-' || RIGHT(event_date, 2)AS date) AS date
-- или функция DATE()
     FROM `chint-297212.analytics_249897993.events_20210620`,
     UNNEST(event_params) AS param
     LIMIT 100

-- работаем с типом данных(дата) и возвращаем значение строки, которое мы запросили в функции EXTRACT(), 
-- можем указывать эту функцию в WHERE при этом не вызывая ее в SELECT
SELECT dates, EXTRACT(YEAR FROM dates) AS the_year, EXTRACT(MONTH FROM dates) AS the_month, EXTRACT(DAY FROM dates) AS the_day
FROM
(SELECT event_date, CAST(SUBSTR(event_date, 1, 4) || '-' || SUBSTR(event_date, 5, 2) || '-' || RIGHT(event_date, 2)AS date) AS dates
     FROM `chint-297212.analytics_249897993.events_*`,
     UNNEST(event_params) AS param
     where _table_suffix between '20210104' and '20210110'
     LIMIT 100)

SELECT concat(event_date, ' - ', param.key) 
--LENGTH(event_name)
--LEFT(event_name, 5), param.key, 
--CONCAT(event_name, ' - ', param.key)
     FROM `chint-297212.analytics_249897993.events_20210620`,
     UNNEST(event_params) AS param
     ORDER BY event_date
     LIMIT 100

-- Коррелированный подзапрос
SELECT *
     FROM `chint-297212.test_dataset1.e1_orders - orders` `a_or`
     WHERE a_or.order_sum = (
          SELECT MAX(b_or.order_sum)
               FROM `chint-297212.test_dataset1.e1_orders - orders` `b_or`
               WHERE b_or.user_id = a_or.user_id 
               )

-- разобрать пример с WITH OFFSET AS offset - добавляет поле с индексами массива
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/arrays#flattening_arrays
select event_timestamp,event_name, param.key, offset
from `chint-297212.analytics_249897993.events_20201227`
,UNNEST(event_params) AS param
WITH OFFSET AS offset
-- видим что индексы не присваиваются параметрам(ga_session_id) в одном порядке, один и тот же параметр в событии может иметь разный индекс 
where param.key = 'ga_session_id'
AND event_name = 'page_view'
--ORDER BY offset



-- пример по расплиту строки
-- 2. в подзапросе применяем функцию UNNEST(), чтобы разложить наш массив по строкам.
select source_
from(
     -- 1. применяем функцию split() к полю который хотим расплитить, в параметр(аргумент) передаем символ по которуму будем сплитить строку 
     -- и переименовываем поле(добавляем алиас) 
     select split(source_medium, '/') AS example -- можем переименовать без команды "AS"
     from `chint-297212.vtb_test.lid_GA_december`
     )
     ,UNNEST(example) AS source_
     -- 3. пронумеровали строки массива
     WITH OFFSET AS offset
     where offset =  0

-- Преобразование элементов массива в строки таблицы
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/arrays#flattening_arrays
SELECT *
FROM UNNEST([6383086,6266800,6303160,6406894,6283440])
  AS element
WITH OFFSET AS offset
ORDER BY offset

-- regex
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/string_functions
WITH array_1 AS (SELECT *
FROM UNNEST(['cid','cide','cide5','gid','gid'])
  AS element

select element, REGEXP_CONTAINS(element, 'gid') AS is_valid
FROM array_1