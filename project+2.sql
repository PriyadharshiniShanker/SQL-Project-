
-- Question 1: Find the top 3 customers who have the maximum number of orders

with t as (
select distinct cust_id, ord_id
from market_fact),

t1 as(
select cust_id,
(select customer_name from cust_dimen where cust_id = t.cust_id)as customer_name,
count(ord_id) as Number_of_orders,DENSE_RANK() over(order by count(ord_id) desc )  as rk
from t

group by 1
order by 2 desc) 
select * from t1 where rk < 4;

 -- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.


select *,datediff(ship_date,order_date) as DaysTakenForDelivery
from orders_dimen od
join shipping_dimen sd
on od.order_id = sd.order_id;



-- Question 3: Find the customer whose order took the maximum time to get delivered.

with t as (
select od.order_id,order_date,ord_id,ship_mode,ship_id,datediff(ship_date,order_date) as DaysTakenForDelivery
from orders_dimen od
join shipping_dimen sd
on od.order_id = sd.order_id)

select mf.cust_id,cd.* from market_fact mf 
join cust_dimen cd
on cd.cust_id = mf.cust_id
where ord_id =(
select ord_id from t where DaysTakenForDelivery = (select max(DaysTakenForDelivery) from t));


-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select prod_id,
round(sum(sales) over(partition by prod_id),2) as totalsales_product 
from market_fact;

-- Question 5: Retrieve the total profit made from each product from the data (use windows function)


select prod_id, round(sum(profit) over(partition by prod_id),2)
from market_fact;
    
-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011


select count(distinct mf.cust_id) as total_customers  from market_fact mf
join orders_dimen od
on od.ord_id = mf.ord_id
where month(order_date) = 1 and year(order_date) = 2011;


with t as(
select distinct mf.cust_id as cust_id  from market_fact mf
join orders_dimen od
on od.ord_id = mf.ord_id
where month(order_date) = 1 and year(order_date) = 2011)


select month(order_date) as monthname ,count(cust_id) no_of_returning_customer from market_fact mf
join orders_dimen od
on od.ord_id = mf.ord_id
where month(order_date)  >1 and  year(order_date) = 2011 and cust_id in (select cust_id from t )
group by 1;



-- Part 2 – Restaurant:

use restaurantdataset;



-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select placeid,count(userid) as no_of_visits from restaurantdataset.rating_final
where placeID in (select placeid from restaurantdataset.geoplaces2 
where alcohol not like 'NO%')
group by 1;


/*Question 2: -Let's find out the average rating according to alcohol and 
price so that we can understand the rating in respective price categories as well.*/

select alcohol,price,round(avg(rating),2) avg_rating,round(avg(food_rating),2) avg_food_rating,round(avg(service_rating),2) avg_service_rating from rating_final rf
join geoplaces2 gp
on rf.placeid = gp.placeid
group by 1,2
order by 1 ,2;


/* Question 3:  Let’s write a query to quantify that what are the parking availability
 as well in different alcohol categories along with the total number of restaurants*/
 
 
select parking_lot,alcohol,count(gp.placeid) as No_of_restaurants from chefmozparking cp
join geoplaces2 gp
on cp.placeid = gp.placeid
group by 1,2
order by 1,2;

-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
with t as
(select distinct alcohol as alcohol ,rcuisine cuisine from geoplaces2 gp
join chefmozcuisine cc
on cc.placeid = gp.placeid)

select  alcohol,count(cuisine) cuisine_available,(select count(distinct rcuisine) from chefmozcuisine) as total_cuisine,
count(cuisine)/(select count(distinct rcuisine) from chefmozcuisine) *100 percent_available
from t
group by 1;



-- Questions 5: - let’s take out the average rating of each state.

select state,round(avg(rating),2) avg_rating,round(avg(food_rating),2) avg_food_rating,round(avg(service_rating),2) avg_service_rating 
from geoplaces2 gp
join rating_final rf
on rf.placeid = gp.placeid
group by 1;

-- Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

with t as( select distinct state as state ,alcohol as alcohol ,rcuisine cuisine from geoplaces2 gp
join chefmozcuisine cc
on cc.placeid = gp.placeid)

select  state,alcohol,count(cuisine) cuisine_available,(select count(distinct rcuisine) from chefmozcuisine) as total_cuisine,
count(cuisine)/(select count(distinct rcuisine) from chefmozcuisine) *100 percent_available

from t
group by 1,2;

/* Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.
We encourage you to give it a try by not using joins.*/


select * from rating_final where placeid =(select placeid from geoplaces2 where name = 'KFC');


with t as(
select * from rating_final 
where placeid in ( select placeid from chefmozcuisine where rcuisine in ('Mexican','Italian'))
and userid in (select userid from rating_final where placeid =(select placeid from geoplaces2 where name = 'KFC'))
and userid in (select userid from userprofile where budget = 'low'))
    
select  avg( (select weight from userprofile where userid = t.userid )) as avg_weight ,avg(rating) avg_r,avg(food_rating) avg_f ,avg(service_rating) avg_s
from t;

