-- Q1: Who is the senior most emplyee based on job title?

SELECT * FROM EMPLOYEE 
ORDER BY LEVELS DESC
LIMIT 1


-- Q2: Which countries have the most Invoices?

SELECT COUNT(*) AS C, BILLING_COUNTRY 
FROM INVOICE GROUP BY BILLING_COUNTRY 
ORDER BY C DESC


-- Q3: What are top 3 values of total invoice

select total from invoice 
ORDER BY total desc limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as InvoiceTotal 
from invoice 
group by billing_city 
order by InvoiceTotal desc limit 1


/* Q5: Who is the best customer? The customer who has spent the most money 
will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total from customer as c
inner join invoice as i on c.customer_id  = i.customer_id
group by c.customer_id
order by total desc limit 1


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email, first_name, last_name 
from customer as c
join invoice on c.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
)
order by email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(artist.artist_id) AS number_of_songs
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first. */

select name, milliseconds as song_length 
from track
where milliseconds > (select avg(milliseconds) from track)
order by song_length desc;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, 
artist name and total spent */

with best_selling_artists as (
	select artist.artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*quantity) as total_sales
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by 1
	order by 3 desc
	limit 1
)

select c.customer_id, c.first_name, c.last_name, b.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice as i
join customer as c on i.customer_id = c.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join album as a on t.album_id = a.album_id
join best_selling_artists as b on a.artist_id = b.artist_id
group by 1, 2,3, 4
order by 5 desc


/* Q10: We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns 
each country along with the top Genre. For countries where the maximum number of purchases 
is shared return all Genres. */

with popular_genre as (
	select count(il.quantity) AS purchases, c.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country 
					  ORDER BY COUNT(il.quantity) DESC) AS RowNo
	from invoice_line il
	join invoice i on il.invoice_id = i.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by 2, 3, 4
	order by 2, 1 desc
)
select * FROM popular_genre WHERE RowNo <= 1


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


/* Thank You :) */