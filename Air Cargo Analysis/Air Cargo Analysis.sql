--- Air Cargo Analysis ---

--- create a database named Cargo ---
create database Cargo;

--- Importing the Datasets and Activating the database ---
use Cargo;

-- Defining Primary, Unique and foreign keys for the imported tables --  
alter table customer
add primary key(customer_id);
alter table routes
add primary key(route_id);
alter table routes 
add unique key(flight_num);
alter table passengers_on_flights
add foreign key(customer_id) references customer(customer_id);
alter table passengers_on_flights
add foreign key(route_id) references routes(route_id);
alter table passengers_on_flights
add foreign key(flight_num) references routes(flight_num);
alter table ticket_details
add foreign key(customer_id) references customer(customer_id);

--- Defining Constraints for flight number, route_id, distance_miles ---
alter table routes
add check (flight_num like "11__"),
add unique (route_id),
add check (distance_miles > 0);

--- display all the passengers (customers) who have travelled in routes 01 to 25 ---
select * from passengers_on_flights
where route_id between 01 and 25
order by route_id;

--- identify the number of passengers and total revenue in business class from the ticket_details table ---
select count(customer_id) as number_of_passengers, sum(no_of_tickets*Price_per_ticket) as total_revenue from ticket_details
where class_id = "Bussiness";

-- display the full name of the customer by extracting the first name and last name from the customer table ---
select concat(first_name," ", last_name) as full_name from Customer;

--- extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables ---
select * from customer 
where customer_id IN (Select customer_id from ticket_details);

--- identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table ---
select first_name, last_name from customer
where customer_id IN (select customer_id from ticket_details where brand="Emirates");

--- identify customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table ---
select * from passengers_on_flights
having class_id = "Economy Plus";

--- identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table ---
select if(sum(no_of_tickets*Price_per_ticket) > 10000, "Crossed 10000", "Not Crossed 10000") as Revenue from ticket_details;

--- find the maximum ticket price for each class using window functions on the ticket_details table ---
select distinct class_id, max(price_per_ticket) over (partition by class_id) as Max_Price from ticket_details;

--- extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table ---
explain select customer_id from passengers_on_flights
where route_id = 4;
create index idx_route on passengers_on_flights(route_id);
select customer_id from passengers_on_flights
where route_id = 4;

--- calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function 
select aircraft_id, sum(price_per_ticket) as Total_Price from ticket_details
group by aircraft_id;
select coalesce(aircraft_id, "All_Aircrafts") as aircraft_id, sum(price_per_ticket) as Total_Price from ticket_details
group by aircraft_id with rollup;

--- create a view with only business class customers along with the brand of airlines --- 
create view vw_Business
as
select customer_id, class_id, brand from ticket_details 
having class_id = "Bussiness";
select * from vw_Business;

--- query to return an error create a stored procedure to get the details of all passengers flying between a range of routes defined in run time ---
--- Also message if the table doesnt exist ---;

-- create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles ---
delimiter //
create procedure sp_distance()
begin 
select * from routes 
where distance_miles > 2000;
end//
delimiter ;

call sp_distance();

--- query to create a stored procedure that groups the distance travelled by each flight into three categories --- 
--- short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500 ---
--- using case statements ---
select *, 
case when distance_miles between 0 and 2000 then "Short Distance Travel(SDT)"
when distance_miles between 2000 and 6500 then "Intermediate Distance Travel(IDT)"
else "Long Distance Travel(LDT)" end as Type_of_Travel
from routes;

--- extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class 
--- using a stored function in stored procedure ---
--- Condition - If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No ---
delimiter //
create procedure sp_comp()
begin 
select p_date, customer_id, class_id, if(class_id IN ("Bussiness","Economy Plus"), "Yes", "No") as Comp_Services 
from ticket_details;
end//
delimiter ;
call sp_comp();

--- 






