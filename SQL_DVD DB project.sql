-- 1. To count the number of films that each actor played

SELECT a.actor_id, count(film_id) AS number_of_movies
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY actor_id ASC;



-- 2. Matching the category of the film each actor played

Select a.actor_id, a.first_name, a.last_name, fa.film_id, c.name AS film_cat
FROM actor a 
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film_category fc ON fa.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
ORDER BY actor_id ASC;



-- 3. To find out movies with the lowest and highest rental count and the respective revenues exluding zero inventory

SELECT f.film_id, f.title, c.name AS cat_of_movie, count(f.film_id) AS rental_count, SUM(amount) AS total_revenue
FROM film f
JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON i.inventory_id=r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
JOIN film_category fc ON f.film_id=fc.film_id
JOIN category c ON fc.category_id=c.category_id
GROUP BY f.film_id, c.name
ORDER BY rental_count ASC;




-- 4. To find out the most popular film category with the respective total revenues

SELECT c.name, SUM(p.amount) AS total_revenue, COUNT(p.payment_id) AS rental_count
FROM payment p
JOIN rental r ON p.rental_id=r.rental_id
JOIN inventory i ON r.inventory_id=i.inventory_id
JOIN film f ON i.film_id=f.film_id
JOIN film_category fc ON f.film_id=fc.film_id
JOIN category c ON fc.category_id=c.category_id
GROUP BY c.name
ORDER BY rental_count DESC




-- 5. To look at the rental count of each customer and the location
SELECT c.customer_id, y.country, SUM(p.amount) AS total_amount_spent, COUNT(r.rental_id) AS times
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN payment p ON r.rental_id = p.rental_id
JOIN city x ON a.city_id = x.city_id
JOIN country y ON x.country_id = y.country_id
GROUP BY c.customer_id, a.city_id, y.country
ORDER BY times ASC;



--- 6. Revenue of each store with their city stated
SELECT s.store_id, c.city, SUM(p.amount) AS total
FROM store s
JOIN staff sf ON s.store_id = sf.store_id
JOIN payment p ON sf.staff_id=p.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
GROUP BY s.store_id, c.city;



--- 7. To see if there's any correlation between length of movie and the average rental count
--A table of length of movie with respective rental count created, corr = -0.0322


WITH length_vs_rentout AS(

SELECT f.title, f.length, count(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON i.inventory_id=r.inventory_id
GROUP BY f.title, f.length
ORDER BY f.length ASC
	
)

SELECT corr(length, rental_count)

FROM length_vs_rentout;



-- 8. To check the average replacement cost of each movie category

SELECT DISTINCT(c.name) AS movie_cat, AVG(f.replacement_cost) OVER (PARTITION BY c.name) AS avg_replacement_cost
FROM category c
JOIN film_category fc ON c.category_id=fc.category_id
JOIN film f ON fc.film_id=f.film_id
GROUP BY c.name, f.replacement_cost



--- 9.1 To look at those film with 'Boring' in description and comepare its rental duration with the average rental duration of the same category

SELECT f.title, AVG(f.rental_duration) AS avg_duration, 
AVG(f.rental_duration) OVER (PARTITION BY fc.category_id) AS avg_by_cate
FROM film f
JOIN film_category fc ON f.film_id=fc.film_id
WHERE description LIKE '%Boring%'
GROUP BY title, f.rental_duration, fc.category_id;

-- 9.2 Con't to look at if there's any association between.
WITH boring_VS_rentaldur AS(

SELECT f.title, AVG(f.rental_duration) AS avg_duration, 
AVG(f.rental_duration) OVER (PARTITION BY fc.category_id) AS avg_by_cate
FROM film f
JOIN film_category fc ON f.film_id=fc.film_id
WHERE description LIKE '%Boring%'
GROUP BY title, f.rental_duration, fc.category_id
)

SELECT corr(avg_duration,avg_by_cate)
FROM boring_VS_rentaldur;



-- 10. To create a table of movies and the characters listed in columns with no. of characters stated

WITH movie_char AS (
	SELECT f.title AS movie_title, fa.actor_id, 
	CONCAT(a.first_name,' ',a.last_name) as full_name
	FROM film f
	JOIN film_actor fa ON f.film_id=fa.film_id
	JOIN actor a ON a.actor_id = fa.actor_id)


SELECT movie_title, COUNT (full_name) AS no_of_char, STRING_AGG(full_name, ', ') AS character_name
FROM movie_char
GROUP BY movie_title
ORDER BY movie_title ASC;


