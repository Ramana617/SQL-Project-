/*
SQL Case Study Pizza Project
*/

-- Now understand each table (all columns)
select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients



-- Basic--


--1. Retrieve the Total Number of Orders Placed 

select * from orders

select COUNT(distinct order_id) as 'Total Orders' from orders

--2. Calculate the Total Revenue generated from pizza sales 

select * from order_details
select * from pizzas

-- To see the Details:

select od.pizza_id,od.quantity,p.price
from order_details od
inner join pizzas p 
on od.pizza_id = p.pizza_id

-- To get the Answer 

select  cast(sum(pizzas.price*order_details.quantity) as decimal(10,2)) as 'Total Revenue'
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id

-- 3.Identify the Highest Priced Pizza

select * from pizza_types
select * from pizzas

-- using Top/Limit Function

select top 1 pizza_types.name as 'pizza name' ,cast(pizzas.price as decimal(10,2)) as 'price'
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc

-- Uisng the Window Function - without using the top function

with cte as
(select pizza_types.name as 'pizza name', pizzas.price as 'price',
RANK() over (order by price desc) rnk
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id)

select [pizza name],price from cte where rnk = 1

--4. Identify the Most Common Pizza size Ordered --

select * from order_details
select * from pizzas

select pizzas.size, COUNT(distinct order_id) as 'No of Orders', SUM(quantity) as 'Total Quantity Ordered'
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by COUNT(distinct order_id) desc

--5. List the top 5 most ordered pizza types along with their quantities. 

select * from order_details
select * from pizzas
select * from pizza_types

select top 5 pizza_types.name as Pizza, SUM(quantity) as 'Total Ordered' 
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by SUM(quantity) desc

-- 6. Join the Necessary Tables to find the total Quantity of each pizza category ordered 

select * from order_details
select * from pizzas
select * from pizza_types

select top 5 pizza_types.category, SUM(quantity) as 'Total Quantity Ordered'
from order_details
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by SUM(quantity) desc

-- 7. Determine the Distribution of Orders by hour of the day

select * from order_details
select * from orders

select DATEPART(hour,time) as 'Hour of the Day',
COUNT(distinct order_id) as 'No of Orders'
from orders
group by DATEPART(hour,time)
order by [No of Orders] desc

--8. Find The Category wise distribution of pizzas

select * from pizza_types

select category,COUNT(distinct pizza_type_id) as 'No of Pizzas' 
from pizza_types
group by category
order by [No of Pizzas]

--9. Calculate the Average Number of Pizzas Ordered per day 

select * from order_details
select * from orders

with cte as
(select orders.date as 'Date',SUM(order_details.quantity) as 'Total pizzas ordered per day'
from order_details 
join orders
on order_details.order_id = orders.order_id
group by Date
)
select AVG([Total pizzas ordered per day]) as [Average Number of Pizzas Ordered per day] from cte 

-- alternate using the subquery:

select AVG([Total orders per day]) from
(select orders.date as 'Date', cast(SUM(order_details.quantity) as decimal(10,2)) as 'Total orders per day'
from order_details
join orders
on order_details.order_id = orders.order_id
group by Date) as pizzas

-- 10. Determine the top 3 most ordered pizza types based on revenue 

select * from order_details
select * from pizzas
select * from pizza_types

select top 3 pizza_types.name, SUM(order_details.quantity*pizzas.price) as 'Revenue from pizza'
from order_details
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue from pizza] desc

-- using the window function

select name,[Revenue from pizza] from
(select pizza_types.name as name,SUM(order_details.quantity*pizzas.price) as 'Revenue from pizza'
,RANK() over(order by SUM(order_details.quantity*pizzas.price)desc) rnk
from order_details
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name) as pizzas
where rnk between 1 and 3

-- Advanced --

-- calculate the percentage contribution of each pizza type to total revenues

select pizza_types.category,
concat(cast((SUM(order_details.quantity*pizzas.price)
/
(select sum(order_details.quantity*pizzas.price) -- To get the total revenue --
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id

))*100 as decimal (10,2)),'%') as 'Revenue contribution from pizza'

from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category


-- Revenue contribution from each pizza by pizza name --

select pizza_types.name, concat(cast((SUM(order_details.quantity * pizzas.price)
/
(select SUM(order_details.quantity * pizzas.price)
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id)) *100 as decimal(10,2)),'%')
as 'Revenue contribution from pizza'
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue contribution from pizza] desc

-- Analyze the Cumulative Revenue Generated over time --

select * from order_details
select * from pizzas
select * from orders

with cte as
(select orders.date as 'Date', cast(SUM(price*quantity) as decimal(10,2)) as 'Revenue'
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.date)

select Date,[Revenue],SUM(Revenue) over(order by Date) as 'Cumulative sum'
from cte
group by Date,Revenue


-- Determine the Top 3 Most ordered pizza types based on revenue for each pizza category --

select * from pizza_types
select * from order_details
select * from pizzas

with cte as
(select pizza_types.category, pizza_types.name, cast(SUM(order_details.quantity*pizzas.price) as decimal (10,2)) as 'Revenue'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category, pizza_types.name),
cte1 as
(select category, name, Revenue, RANK() over (partition by category order by Revenue desc) as rnk
from cte)
-- select * from cte1
select category, name, Revenue from cte1
where rnk in (1,2,3)
order by category, name, Revenue

