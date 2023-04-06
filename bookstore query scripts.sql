		--JOIN--
SELECT *  from client c 
join city c2 on c2.city_id = c.client_id 			-- связь клиента и города
right join buy b on b.buy_id = c.client_id  		-- связь клинта и заказа
full  join buy_step bs on bs.buy_id = b.buy_id 		-- связь заказа и детали заказа
left join step s on s.step_id = bs.step_id 			-- связь деталей заказа и этапов обработки
left join buy_book bb on bb.buy_id = b.buy_id 		-- связь заказа и магазина
left  join book b2 on b2.book_id = bb.book_id 		-- связь магазина и книги
join author a on a.author_id = b2.author_id 		-- связь автора и книги
join genre g on g.genre_id = b2.genre_id 			-- связь жанра и книги 																		


		--  Удаление таблиц    
		
DROP TABLE IF EXISTS stepik.НАЗВАНИЕ ТАБЛИЦЫ CASCADE;


		--  Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.

select b.buy_id, b2.title, b2.price, bb.amount  from buy b 
right join client c on c.client_id = b.client_id 
left join buy_book bb on bb.buy_id = b.buy_id 
left join book b2 on b2.book_id = bb.book_id

where c.name_client  = 'Баранов Павел'
order by b.buy_id, b2.title;

		/*Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).  
		Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.*/


SELECT name_author, title, count(bb.amount)  FROM author a
JOIN book b2 ON b2.author_id = a.author_id 
LEFT JOIN buy_book bb ON bb.book_id = b2.book_id 
GROUP BY title,name_author
 ORDER BY  name_author asc, title asc; 


		/*Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. 
		Указать количество заказов в каждый город, этот столбец назвать Количество. 
		Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов. */


SELECT name_city ,count(b.buy_id)AS Количество  FROM city c2
JOIN client c ON c.city_id =c2.city_id 
JOIN buy b ON b.client_id = c.client_id 
GROUP BY name_city 
ORDER BY name_city ;
					 

		/*Вывести номера всех оплаченных заказов и даты, когда они были оплачены.*/

SELECT bs.buy_id, bs.date_step_end FROM buy_step bs 
JOIN step s ON s.step_id = bs.step_id 
WHERE s.name_step ='Оплата' AND bs.date_step_end  IS NOT NULL;
		
		/*Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены), 
		 в отсортированном по номеру заказа виде. Последний столбец назвать Стоимость.*/

SELECT  bb.buy_id, c.name_client, sum(bb.amount*b2.price) AS Стоимость FROM buy_book bb 
JOIN book b2 ON b2.book_id = bb.book_id 
JOIN buy b ON b.buy_id = bb.buy_id 
JOIN client c ON c.client_id  = b.client_id
GROUP BY bb.buy_id, c.name_client
ORDER BY buy_id asc;

		/*Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. 
		 Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.*/

SELECT bs.buy_id, s.name_step  FROM buy_step bs 
JOIN step s ON s.step_id = bs.step_id 
WHERE date_step_beg IS NOT NULL AND date_step_end IS NULL
ORDER BY buy_id;


		/*В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап Транспортировка). 
		 Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город.
		 А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. 
		 В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.*/

SELECT b.buy_id, 
abs (DATE_PART('day', bs.date_step_end)-DATE_PART('day', bs.date_step_beg))-1 as Количество_дней,
CASE 
	WHEN DATE_PART('day', bs.date_step_beg)-DATE_PART('day', bs.date_step_end)-1>c2.days_delivery
	THEN  DATE_PART('day', bs.date_step_beg)-DATE_PART('day', bs.date_step_end) -1 - c2.days_delivery
	ELSE 0
END AS Опоздание
  
FROM city c2
JOIN client c ON c.city_id = c2.city_id 
JOIN buy b ON b.client_id = c.client_id 
JOIN buy_step bs ON bs.buy_id = b.buy_id 
JOIN step s ON s.step_id = bs.step_id 
WHERE s.step_id = 3 AND bs.date_step_end  IS NOT NULL 
ORDER BY b.buy_id;



		/*Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. В решении используйте фамилию автора, а не его id.*/

SELECT c.name_client FROM client c 
JOIN buy b ON b.client_id = c.client_id 
JOIN buy_book bb ON bb.buy_id = b.buy_id 
JOIN book b2 ON b2.book_id = bb.book_id 
JOIN author a ON a.author_id = b2.author_id 
WHERE a.name_author = 'Достоевский Ф.М.'
GROUP BY c.name_client
ORDER BY c.name_client;


		/*Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. Последний столбец назвать Количество.*/

SELECT g.name_genre, sum(bb.amount) AS Количество FROM genre g 
JOIN book b2 ON b2.genre_id = g.genre_id 
JOIN buy_book bb ON bb.book_id = b2.book_id 
GROUP BY g.name_genre
HAVING sum(bb.amount) =
		(SELECT max(sum_amount) AS max_sum_amont FROM 
			(SELECT g.genre_id, sum(bb.amount) AS sum_amount FROM buy_book bb  
			JOIN book b ON b.book_id = bb.book_id 
			JOIN genre g ON g.genre_id = b.genre_id 
			GROUP BY g.genre_id
		) query_in

		);

		/*Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. 
		 Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде.
		 Название столбцов: Год, Месяц, Сумма.*/

SELECT DATE_PART('year', bs.date_step_end ) AS Год, DATE_PART('month', bs.date_step_end)AS Месяц, sum(b2.price*bb.amount)   FROM buy_step bs 
JOIN buy b ON b.buy_id = bs.buy_id 
JOIN buy_book bb ON bb.buy_id = b.buy_id 
JOIN book b2 ON b2.book_id = bb.book_id 
WHERE date_step_end IS NOT NULL AND step_id = 1
GROUP BY Год, Месяц 
UNION 
SELECT DATE_PART('year', ba.date_payment) AS Год, DATE_PART('month', ba.date_payment)AS Месяц, sum(ba.price*ba.amount) FROM buy_archive ba  
GROUP BY Год, Месяц
ORDER BY Месяц ASC, Год ASC;




		/*Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 2020 и 2019 год . 
		 Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.*/

SELECT title, sum(Количество) AS Количество, sum(Сумма) AS Сумма
FROM 

(SELECT b2.title , sum(bb.amount) AS Количество, sum(bb.amount*b2.price) AS Сумма FROM book b2
JOIN buy_book bb ON bb.book_id = b2.book_id 
JOIN buy b ON b.buy_id = bb.buy_id 
JOIN buy_step bs ON bs.buy_id = b. buy_id
WHERE bs.date_step_end IS NOT NULL AND bs.step_id = 1
GROUP BY b2.title

UNION 

SELECT b2.title ,sum(ba.amount) AS Количество, sum(ba.amount*ba.price) AS Сумма FROM buy_archive ba  
JOIN book b2 ON b2.book_id = ba.book_id 
GROUP BY b2.title
) 
book

GROUP BY title
ORDER BY sum(Сумма) DESC


		/*Посчитать количество потраченных каждым клиентом денег и отсортировать их в порядке убывания для оценки общей активности каждого клиента:*/


select 
    name_client, 
    sum(buy_book.amount * book.price) as "Сумма" 
from 
    buy_book 
    inner join buy using (buy_id) 
    inner join client using (client_id) 
    inner join book using (book_id) 
group by name_client
order by Сумма desc;




		/* Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.*/

INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city 
WHERE city.name_city  = 'Москва';
SELECT * FROM client;

		/*Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».*/

INSERT INTO buy (buy_description,client_id)
SELECT 'Связаться со мной по вопросу доставки',client_id
FROM client 
WHERE client.name_client = 'Попов Илья';
SELECT * FROM buy;

		/* В таблицу buy_book добавить заказ с номером 5. 
		  Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.  */

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 2 FROM book, author
WHERE name_author LIKE 'Пастернак%' AND title='Лирика';

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book_id, 1 FROM book, author
WHERE name_author LIKE 'Булгаков%' AND title='Белая гвардия';
select * from buy_book


		/*Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.*/

UPDATE book, buy_book 
SET book.amount = book.amount - buy_book.amount 
WHERE buy_book.buy_book_id = 5 AND book.book_id = buy_book.buy_book_id ;
SELECT * FROM book


		/*Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость. 		 
		 Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.*/

CREATE TABLE buy_pay AS
SELECT b.title,a.name_author  , b.price , bb.amount , b.price*bb.amount AS Стоимость FROM book b 
JOIN buy_book bb ON bb.book_id = b.book_id 
JOIN author a ON a.author_id = b.author_id 
WHERE bb.buy_id =5
ORDER BY b.title;
SELECT * FROM buy_pay


		/*Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. 
		 * Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого). 
		 * Для решения используйте ОДИН запрос. */

SELECT bb.buy_id, sum(bb.amount) as Количество, sum(b.price*bb.amount) AS Итого FROM book b 
JOIN buy_book bb ON bb.book_id = b.book_id 
JOIN author a ON a.author_id = b.author_id 
WHERE bb.buy_id =5 
 group by bb.buy_id;
select * from buy_pay

		/*В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. 
		  В столбцы date_step_beg и date_step_end всех записей занести Null.*/

INSERT INTO buy_step (buy_id,step_id, date_step_beg, date_step_end)
SELECT buy.buy_id , step.step_id, null, null  FROM buy, step
where buy_id = 5;
 SELECT * FROM buy_step
 
 		/*В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.*/
 
 
UPDATE buy_step 
SET date_step_beg = '2020-04-12'
WHERE buy_id = 5 AND step_id = 1;
SELECT * FROM buy_step

		/*Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), 
		 задав в столбце date_step_beg для этого этапа ту же дату.*/

UPDATE buy_step 
SET date_step_end = '2020-04-13'
WHERE buy_id = 5 AND step_id = 1;

UPDATE buy_step 
SET date_step_beg = '2020-04-13'
WHERE buy_id = 5 AND step_id = 2;
SELECT * FROM buy_step





























