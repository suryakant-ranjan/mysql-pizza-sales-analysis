# PIZZA SALES ANALYSIS PROJECT

# (1) Retrieve the total number of orders placed.

SELECT COUNT(ORDER_ID) AS "COUNT OF ORDERS" FROM ORDERS;

# (2) Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE),2) AS TOTAL_REVENUE 
FROM PIZZAS
INNER JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID;

# (3) Identify the highest priced pizza.

SELECT PIZZA_TYPES.NAME ,PIZZAS.PRICE AS HIGHEST_PRICE FROM PIZZAS
INNER JOIN PIZZA_TYPES
ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
ORDER BY PRICE DESC
LIMIT 1;

# (4) Identify the most common pizza size ordered.

SELECT pizzas.SIZE ,COUNT(order_details.quantity) AS QUANTITY_ORDERED 
FROM order_details
INNER JOIN pizzas
ON order_details.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY SIZE
ORDER BY QUANTITY_ORDERED DESC
LIMIT 1;

# (5) List the top 5 most ordered pizza types along with their quantities.

SELECT PIZZA_TYPES.NAME ,SUM(ORDER_details.quantity) AS COUNT_OF_QUANTITY 
from PIZZA_TYPES
INNER JOIN  PIZZAS
ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID
INNER JOIN ORDER_details
ON ORDER_details.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.NAME
ORDER BY COUNT_OF_QUANTITY DESC
LIMIT 5;

# (6) Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT PIZZA_TYPES.CATEGORY ,SUM(ORDER_DETAILS.QUANTITY) AS "COUNT OF CATEGORY" 
FROM  ORDER_DETAILS
INNER JOIN PIZZAS
ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
INNER JOIN PIZZA_TYPES
ON PIZZAS.PIZZA_TYPE_ID  = PIZZA_TYPES.PIZZA_TYPE_ID 
GROUP BY CATEGORY;

# (7) Determine the distribution of orders by hour of the day.

SELECT hour(TIME) ,SUM(ORDER_ID) FROM ORDERS
GROUP BY HOUR(TIME)
ORDER BY HOUR(TIME);

# (8) find the category-wise distribution of pizzas.

SELECT PIZZA_TYPES.CATEGORY ,COUNT(PIZZA_TYPES.NAME) AS COUNT_OF_NAME 
FROM PIZZA_TYPES
GROUP BY CATEGORY;

# (9) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(ORDERS),0) AVG_QUANTIY FROM 
(SELECT day(ORDERS.ORDER_DATE) ,ROUND(SUM(ORDER_DETAILS.QUANTITY),2) AS ORDERS FROM ORDERS
INNER JOIN ORDER_DETAILS
ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY day(ORDERS.ORDER_DATE)) AS ORDER_QUANTITY;

# (10) Determine the top 3 most ordered pizza types based on revenue.

SELECT PIZZA_TYPES.NAME , ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE),2) AS REVENUE 
FROM PIZZA_TYPES
INNER JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
INNER JOIN ORDER_DETAILS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY NAME
ORDER BY REVENUE DESC
LIMIT 3;

# (11) Calculate the percentage contribution of each pizza type to total revenue.

SELECT PIZZA_TYPES.CATEGORY ,ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) /
(SELECT ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE),2) FROM PIZZAS
INNER JOIN ORDER_DETAILS
ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID) *100,2) AS REVENUE
FROM PIZZA_TYPES
INNER JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
INNER JOIN ORDER_DETAILS
ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID
GROUP BY CATEGORY;

# (12) Analyze the cumulative revenue generated over time.

SELECT ORDER_DATE ,SUM(REVENUE) OVER(ORDER BY ORDER_DATE) AS CUMULATIVE_REVENUE FROM
(SELECT ORDERS.ORDER_DATE ,ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE)) AS REVENUE
FROM ORDERS
INNER JOIN ORDER_DETAILS
ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
INNER JOIN PIZZAS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY ORDER_DATE) AS SALES;

# (13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name ,ROUND(revenue) AS REVENUE from 
(SELECT CATEGORY ,NAME ,REVENUE ,RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RN FROM
(SELECT PIZZA_TYPES.CATEGORY,PIZZA_TYPES.NAME,SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE
FROM ORDER_DETAILS
INNER JOIN PIZZAS
ON ORDER_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
INNER JOIN PIZZA_TYPES
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
GROUP BY CATEGORY,NAME) AS A) AS B
WHERE RN <= 3;