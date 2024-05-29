-- Total Number of orders placed
select count(order_id) as total_orders from orders;

-- Calculate total revenue generated from Pizza sales
select round(sum(order_detail.quantity * pizzas.price),2) as total_sales 
from order_detail join pizzas 
on pizzas.pizza_id = order_detail.pizza_id

-- Identify Highest Price pizza
select pizza_types.name , pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id order by pizzas.price desc limit 1;

-- Identify most common pizza size
select pizzas.size, count(order_detail.order_detail_id) as order_count from order_detail join pizzas on pizzas.pizza_id=order_detail.pizza_id group by pizzas.size order by order_count desc limit 1;

-- List most 5 ordered pizza type along with quantity
select pizza_types.name,sum(order_detail.quantity) as total_order from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_detail on order_detail.pizza_id = pizzas.pizza_id group by pizza_types.name order by total_order desc limit 5;

-- (Intermediate)
-- Total quantity of pizza with its category
select pizza_types.category, sum(order_detail.quantity) as category_order from pizzas join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_detail on order_detail.pizza_id = pizzas.pizza_id group by pizza_types.category order by category_order desc;

-- Pizza Order distribution based on hour of day
select hour(order_time), count(order_id) as order_count
from orders group by hour(order_time) order by order_count desc;

-- Category-wise distribution of pizza
select category, count(name) from pizza_types group by category;

-- Group order by date aordersnd calculate average number of order pizzas per day
select round(avg(quantity),0) as avg_pizza_order_per_day
from (select orders.order_date , sum(order_detail.quantity) as quantity 
      from orders join order_detail on orders.order_id=order_detail.order_id 
      group by orders.order_date)
      as order_quantity;
      
-- Determine most ordered pizza based on revenue
select pizza_types.name, round(sum(order_detail.quantity*pizzas.price),1) as pizza_revenue from pizzas join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id join order_detail on pizzas.pizza_id = order_detail.pizza_id group by pizza_types.name order by pizza_revenue desc limit 3;

-- (Advanced)
-- Calculate % contribution of each pizza type to total revenue
select pizza_types.category, round(sum(order_detail.quantity*pizzas.price)/(select sum(order_detail.quantity*pizzas.price) as total_sales
 from order_detail join pizzas on pizzas.pizza_id = order_detail.pizza_id)*100
,2) as revenue_percent from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_detail on order_detail.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue_percent desc; 

-- Cumulative Revenue Generated over Time
select order_date,round(sum(revenue) over (order by order_date),2) as cum_revenue from(
select orders.order_date, sum(order_detail.quantity*pizzas.price) as revenue from
order_detail join pizzas on order_detail.pizza_id = pizzas.pizza_id
join orders on order_detail.order_id = orders.order_id
group by orders.order_date) as sales;

-- Determine top 3 ordered pizzatypes based on revenue for each pizza category
select name, category, round(revenue,2) as Revenue from(
select category, name, revenue,rank() over(partition by category order by revenue desc) as r from(
select pizza_types.category, pizza_types.name, sum((order_detail.quantity)*pizzas.price) as revenue from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_detail on order_detail.pizza_id = pizzas.pizza_id group by pizza_types.category,pizza_types.name)as a) as b where r<=3;