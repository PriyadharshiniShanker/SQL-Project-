create database bank1;
use bank1;

create table branch (
branch_no int not null primary key,
name varchar(50	) not null
);


create table employee(
emp_no int not null primary key,
branch_no  int,
fname varchar(20),
mname varchar(20),
lname varchar(20),
dept varchar(20),
design varchar(10),
mngr_no int not null,
foreign key(branch_no)   REFERENCES branch(branch_no)
);


create table customers(
cust_no int not null primary key,

fname varchar(20),
mname varchar(20),
lname varchar(20),
occupation varchar(20),
dob date);



create table accounts(
acc_no int not null primary key,
cust_no int,
branch_no  int,
curbal int,
opnDT date,
atype varchar(15),
astatus varchar(10)  	,
foreign key(cust_no)   REFERENCES customers(cust_no),
foreign key (branch_no) references branch(branch_no)
);



insert into  branch values
(1,"Delhi"),
(2,'Mumbai');


insert into customers values
(1,'Ramesh','Chandra','Sharma','service','1976-12-06'),
(2,'Avinash','Sunder','Minha','Business','1974-10-16');


insert into accounts  values
(1,1,1,10000,'2012-12-15','Saving','Active'),
(2,2,2,5000,'2012-06-12','Saving','Active');

insert into employee value
(1,1,'Mark','Steve','Lara','Account','Accountant',2),
(2,2,'Bella','James','Ronald','Loan','Manager',1);



-- 3.	Select unique occupation from customer table
select distinct occupation from customers;

-- 4.	Sort accounts according to current balance 
select * from accounts order by curbal;

-- 5.	Find the Date of Birth of customer name ‘Ramesh’

select dob from customers where fname = 'Ramesh';

-- 6.	Add column city to branch table 
alter table branch add column city varchar(20);

-- 7.	Update the mname and lname of employee ‘Bella’ and set to ‘Karan’, ‘Singh’ 
update  employee
set mname = 'karan', lname = 'Singh' where fname = 'Bella';

--  8.	Select accounts opened between '2012-07-01' AND '2013-01-01'

select * from accounts where opndt between '2012-07-01' and '2013-01-01';

-- 9.	List the names of customers having ‘a’ as the second letter in their names 

select * from customers where fname like '_a%';

-- 10.	Find the lowest balance from customer and account table

select * from customers where cust_no = (
select  cust_no from accounts
where curbal = (select min(curbal) from accounts));

-- 11.	Give the count of customer for each occupation

select occupation , count(cust_no) as cnt
from customers
group by 1;

-- 12.	Write a query to find the name (first_name, last_name) of the employees who are managers.

select emp_no,concat(fname,' ' ,lname) as employee_name,mngr_no,( select concat(fname,' ' ,lname) from employee where emp_no = e1.mngr_no)  as manager_name
from employee e1;

-- 13.	List name of all employees whose name ends with a

select * from employee where lname like '%a';


-- 14.	Select the details of the employee who work either for department ‘loan’ or ‘credit’

select * from employee where dept in ('loan','credit');

-- 15.	Write a query to display the customer number, customer firstname, account number for the 

select cust_no,(select fname from customers where cust_no = a.cust_no)  as cust_name ,acc_no from accounts a;

-- 16.	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.

select customers.cust_no,fname,branch_no,curbal from customers
join accounts on accounts.cust_no = customers.cust_no;

-- 17.	Create a virtual table to store the customers who are having the accounts in the same city as they live same city as they live

select * from customers;


/*

18.	A. Create a transaction table with following details 
TID – transaction ID – Primary key with autoincrement 
Custid – customer id (reference from customer table
account no – acoount number (references account table)
bid – Branch id – references branch table
amount – amount in numbers
type – type of transaction (Withdraw or deposit)
DOT -  date of transaction

a. Write trigger to update balance in account table on Deposit or Withdraw in transaction table
b. Insert values in transaction table to show trigger success
*/

create table transt (
TID int AUTO_INCREMENT primary key,
custid int,
acc_no int,
bid INT,
amount int,
type varchar(20),
DOT date,
foreign key(custid) REFERENCES customers(cust_no),
foreign key (acc_no) references accounts(acc_no),
foreign key (bid) REFERENCES branch(branch_no)    
 );

create trigger blc_update 
after insert on transt for each row
update accounts set curbal = curbal + new.amount 
where acc_no = new.acc_no ;

insert into transt(custid, acc_no, bid, amount, type, DOT) values
(1,1,2,500,'savings',current_date());

-- 19.	Write a query to display the details of customer with second highest balance 

select * from (
select *,dense_rank() over(order by curbal desc ) rk from accounts) t
where rk =  2;

-- 20.	Take backup of the databse created in this case study



use casestudy;


/*

1. Display the product details as per the following criteria and sort them in descending order of category:
   #a.  If the category is 2050, increase the price by 2000
   #b.  If the category is 2051, increase the price by 500
   #c.  If the category is 2052, increase the price by 600

*/

select product_id ,product_desc,product_class_code,product_price,
case when product_class_code =2050 then product_price + 2000
when product_class_code =2051 then product_price + 500
when product_class_code =2052 then product_price + 600
else product_price
end as new_price
from product
order  by product_class_code desc;

-- 2. List the product description, class description and price of all products which are shipped. 

select product_desc,product_class_desc,product_price
from product p
join product_class pc
on p.product_class_code= pc.product_class_code where product_id in (
select distinct product_id from order_items where order_id in ( 
select order_id from order_header where order_status = 'Shipped'));


/*
. Show inventory status of products as below as per their available quantity:
#a. For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c. Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.

*/
select product_desc,product_quantity_avail,product_class_desc,
case 
when product_class_desc in ('Electronics','Computer') then (case  when product_quantity_avail <= 10 then 'low stock'
															when product_quantity_avail  between 11 and 30 then 'in stock'
															when product_quantity_avail > 30 then 'enough stock' end)
when product_class_desc in ('Stationery','Clothing') then  (case  when product_quantity_avail <= 20 then 'low stock'
															when product_quantity_avail  between 21 and 80 then 'in stock'
															when product_quantity_avail > 80 then 'enough stock' end )
	else 													(case  when product_quantity_avail <= 15 then 'low stock'
															when product_quantity_avail  between 16 and 50 then 'in stock'
															when product_quantity_avail > 50 then 'enough stock' end)
 
end as Inventory_status
 from product p
 join product_class pc
 on p.product_class_code = pc.product_class_code;





-- 4. List customers from outside Karnataka who haven’t bought any toys or books

select *  from online_customer where address_id in (
select address_id from address where state != 'Karnataka')
and customer_id in (select customer_id from order_header 
where order_id in(select distinct order_id from order_items 
where order_id not in(select distinct order_id from order_items
where PRODUCT_ID in (select PRODUCT_ID from product
where PRODUCT_CLASS_CODE in (select PRODUCT_CLASS_CODE from product_class
where product_class_desc  in('Toys','books'))))));
