# Written by: Josh Bode
# July 21, 2018
# UCB Data Analytics Bootcamp Homework # 10 

use sakila; 

#1. DISPLAY STUFF

-- 1a. Display the first and last names of all actors from the table `actor`.
describe sakila.actor;
select first_name, last_name from actor; 

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select GROUP_CONCAT(first_name, " ",  last_name)
as 'fullname'
from actor
group by actor_id; 

#2. QUERY STUFF

-- 2a. You need to find the ID number, first`name, and last name 
-- of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from actor
where first_name = "Joe"; 

-- 2b. Find all actors whose last name contain the letters `GEN`:
select * 
from actor
where last_name like'%GEN%'; 

-- 2c. Find all actors whose last names contain the letters `LI`. ///
-- This time, order the rows by last name and first name, in that order:
select * 
from actor
where last_name like'%LI%'
order by last_name, first_name; 

-- 2d. Using `IN`, display the `country_id` and `country` columns ///
-- of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in("Afghanistan", "Bangladesh", "China");


-- 3a. Add a `middle_name` column to the table `actor`. 
-- Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(30) after first_name; 


-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY middle_name BLOB;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP COLUMN middle_name; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as 'Number of actors'
from actor
group by last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(last_name) as Count
from actor
group by last_name
having Count > 1; 

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in ///
-- the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's 
-- second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO", last_name = "WILLIAMS"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, 
-- change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
-- (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
SHOW CREATE TABLE address; 

#6 JOINS

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address 
ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member
-- in August of 2005. Use tables `staff` and `payment`.
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount) as 'Total'
FROM payment 
INNER JOIN staff 
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '%2005-08%'
GROUP BY staff.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) 'Count'
FROM film  
INNER JOIN film_actor 
ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.inventory_id) 'Copies'
FROM film  
INNER JOIN inventory 
ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible" 
GROUP BY film.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. ///
-- List the customers alphabetically by last name:
SELECT customer.customer_id, customer.last_name, customer.first_name, sum(payment.amount) as 'total_paid'
FROM payment   
INNER JOIN customer
ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

#7. SUBQUERIES

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE (title LIKE 'K%' or title LIKE 'Q%') 
AND language_id IN
(
	SELECT language_id FROM language
    WHERE name = "Italian"
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
DESCRIBE film; 
DESCRIBE actor;
DESCRIBE film_actor;

SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(
	SELECT actor_id 
    FROM film_actor
    WHERE film_id IN 
	(
		SELECT film_id 
        FROM film
        WHERE title = "Alone Trip"
	)
); 

-- 7c. You want to run an email marketing campaign in Canada, for which 
-- you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
#SOLUTION WIH JOINS
SELECT customer.first_name, customer.last_name, customer.email 
FROM customer

INNER JOIN address 
	ON customer.address_id = address.address_id

INNER JOIN city
	ON address.city_id = city.city_id

INNER JOIN country
	ON city.country_id = country.country_id
    WHERE country = "Canada"; 
    
# SOLUTION WITH SUB-QUERIES

SELECT first_name, last_name, email 
FROM customer
WHERE address_id IN 
(
	SELECT address_id 
    FROM address
    WHERE city_id IN 
	(
		SELECT city_id 
        FROM city
        WHERE country_id IN
        (
			SELECT country_id
            FROM country
            WHERE country = "Canada"
		)
	)
);

    
-- 7d. Sales have been lagging among young families, and you wish to target 
-- all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT film.title 
FROM film

INNER JOIN film_category
	ON film.film_id = film_category.film_id

INNER JOIN category
	ON film_category.category_id = category.category_id
	WHERE category.name = "Family"; 

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental_id) as 'Count'
from rental

INNER JOIN inventory
	ON inventory.inventory_id = rental.inventory_id

INNER JOIN film
	ON film.film_id = inventory.film_id
    
GROUP BY film.title
ORDER BY Count DESC;     

-- 7f. Write a query to display how much business, in dollars, each store brought in.
describe payment;
describe rental; 
describe inventory;
describe store; 

SELECT store.store_id, sum(payment.amount) as 'Revenue'
from payment 

INNER JOIN rental
	ON rental.rental_id = payment.rental_id

INNER JOIN inventory
	ON inventory.inventory_id = rental.inventory_id

INNER JOIN store
	ON store.store_id  = inventory.store_id
	
GROUP BY store.store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store

INNER JOIN address
	ON address.address_id = store.address_id

INNER JOIN city
	ON city.city_id = address.city_id

INNER JOIN country
	ON country.country_id  = city.country_id;
	    
-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
describe payment; 
describe rental; 
describe inventory;
describe film;
describe film_category;
describe category;

SELECT category.name, sum(payment.amount) as "Revenue" 
FROM payment

INNER JOIN rental
	ON rental.rental_id = payment.rental_id
INNER JOIN inventory
	ON inventory.inventory_id = rental.inventory_id
INNER JOIN film
	ON film.film_id = inventory.film_id
INNER JOIN film_category
	ON film_category.film_id = film.film_id
INNER JOIN category
	on category.category_id = film_category.category_id

GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;     


-- 8a. In your new role as an executive, you would like to have an easy way 
-- of viewing the Top five genres by gross revenue. Use the solution from the problem above 
-- to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5

AS SELECT category.name, sum(payment.amount) as "Revenue" 
FROM payment

INNER JOIN rental
	ON rental.rental_id = payment.rental_id
INNER JOIN inventory
	ON inventory.inventory_id = rental.inventory_id
INNER JOIN film
	ON film.film_id = inventory.film_id
INNER JOIN film_category
	ON film_category.film_id = film.film_id
INNER JOIN category
	on category.category_id = film_category.category_id

GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;     


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top5; 
