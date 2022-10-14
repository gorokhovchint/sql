DROP TABLE IF EXISTS returns;
CREATE TABLE returns(
   Returned   VARCHAR(10) NOT NULL
  ,Order_id   VARCHAR(25) NOT NULL
);
INSERT INTO returns(Returned,Order_id) VALUES ('Yes','CA-2016-100762');
INSERT INTO returns(Returned,Order_id) VALUES ('Yes','CA-2016-100762');
INSERT INTO returns(Returned,Order_id) VALUES ('Yes','CA-2016-100762');

-- добавляем одну запись, без указания названия полей, можем указывать поля после названия таблицы в ()
-- это позволит избежать ошибки и добавлять записи в случайном порядке
INSERT INTO returns values (
'Not',
'UA-2022-1011'
)

-- обновляем записи по условиям
update returns
	set returned = 'No'
where order_id = 'UA-2022-1011'

-- удаляем записи по условиям
DELETE from returns
where returned = 'No'
