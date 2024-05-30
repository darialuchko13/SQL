--DISTINCT
--Task: Create a list of all the different (distinct) replacement costs of the films.
--What's the lowest replacement cost?
SELECT DISTINCT replacement_cost 
FROM film 
ORDER BY replacement_cost
LIMIT 1

--CASE + GROUP BY
--Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
--low: 9.99 - 19.99
--medium: 20.00 - 24.99
--high: 25.00 - 29.99
-- How many films have a replacement cost in the "low" group?
SELECT count(*),
CASE 
WHEN replacement_cost BETWEEN 9.99 and 19.99 THEN 'low'
WHEN replacement_cost BETWEEN 20 and 24.99 THEN 'medium'
ELSE 'high'
END as range
FROM film
GROUP BY range
Having CASE 
WHEN replacement_cost BETWEEN 9.99 and 19.99 THEN 'low'
WHEN replacement_cost BETWEEN 20 and 24.99 THEN 'medium'
ELSE 'high'
END = 'low'


--JOIN
--Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
--In which category is the longest film and how long is it?

SELECT title, length, name from film as f
LEFT JOIN film_category as fc
ON f.film_id = fc.film_id
LEFT JOIN category as c
ON fc.category_id = c.category_id
WHERE name = 'Drama' or name = 'Sports'
ORDER BY length DESC

--JOIN & GROUP BY
--Task: Create an overview of how many movies (titles) there are in each category (name).
-- Which category (name) is the most common among the films?


SELECT name, count(*) from film as f
LEFT JOIN film_category as fc
ON f.film_id = fc.film_id
LEFT JOIN category as c
ON fc.category_id = c.category_id
GROUP BY name 
ORDER BY count(*) DESC
LIMIT 1


--JOIN & GROUP BY
--Task: Create an overview of the actors' first and last names and in how many movies they appear in.
--Question: Which actor is part of most movies??


SELECT first_name, last_name, count(title) from actor as ac
LEFT JOIN film_actor as f_a
ON ac.actor_id=f_a.actor_id
LEFT JOIN film as f
ON f_a.film_id= f.film_id
GROUP BY first_name, last_name
ORDER BY count(title) DESC
LIMIT 1


--LEFT JOIN & FILTERING
--Task: Create an overview of the addresses that are not associated to any customer.
--Question: How many addresses are that?

SELECT address, customer_id from address as ad
LEFT JOIN customer as c
ON ad.address_id = c.address_id
WHERE c.first_name is null


-- JOIN & GROUP BY
--Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.
--What city is that and how much is the amount?

SELECT city, sum(amount)from city ci
LEFT JOIN address ad
ON ci.city_id=ad.city_id
LEFT JOIN customer cu
ON ad.address_id=cu.address_id
LEFT JOIN payment p
ON cu.customer_id = p.customer_id
GROUP BY city
ORDER BY sum(amount) DESC

--JOIN & GROUP BY
--Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
--Which country, city has the least sales?

SELECT country,city, sum(amount)from city ci
LEFT JOIN address ad
ON ci.city_id=ad.city_id
LEFT JOIN customer cu
ON ad.address_id=cu.address_id
LEFT JOIN payment p
ON cu.customer_id = p.customer_id
LEFT JOIN country c
ON ci.country_id=c.country_id
GROUP BY country,city
ORDER BY sum(amount) ASC

--Uncorrelated subquery
--Task: Create a list with the average of the sales amount each staff_id has per customer.
--Which staff_id makes on average more revenue per customer?

SELECT staff_id,round(AVG(revenue),2)
FROM 
(SELECT staff_id, customer_id, sum(amount)as revenue
FROM payment
GROUP BY staff_id, customer_id)as su
GROUP BY staff_id

--EXTRACT + Uncorrelated subquery
--Task: Create a query that shows average daily revenue of all Sundays.
--What is the daily average revenue of all Sundays?

SELECT avg(daily)
FROM (SELECT sum(amount) as daily,date(payment_date),EXTRACT(dow from payment_date) as weekday from payment
	Where extract (dow from payment_date)=0
	GROUP BY date(payment_date),weekday) as sub

-- Correlated subquery
-- Task: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group.
--Which two movies are the shortest on that list and how long are they?

SELECT title,length FROM film f1
WHERE length > (select avg(length) from film f2
where f1.replacement_cost=f2.replacement_cost)
ORDER BY length ASC
LIMIT 2

--Uncorrelated subquery
--Task: Create a list that shows the "average customer lifetime value" grouped by the different districts.
--Question: Which district has the highest average customer lifetime value?

SELECT district, AVG(per_customer) from
(SELECT c.customer_id, a.district, sum(amount) as per_customer from payment p
LEFT JOIN customer c
ON p.customer_id=c.customer_id
LEFT JOIN address a
ON c.address_id = a.address_id
GROUP BY c.customer_id, a.district) as sub
GROUP BY district
ORDER BY AVG(per_customer) DESC

--Correlated query
--Task: Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.
--What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?

SELECT
title,
amount,
name,
payment_id,
(SELECT SUM(amount) FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c1
ON c1.category_id=fc.category_id
WHERE c1.name=c.name)
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
ORDER BY name
	
	
	
	
	