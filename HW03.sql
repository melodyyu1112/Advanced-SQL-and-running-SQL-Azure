/*1. For each origin city, find the destination city (or cities) with the longest direct flight.
By direct flight, we mean a flight with no intermediate stops. Judge the longest flight in time, not distance. 
Name the output columns `origin_city`, `dest_city`, and `time` representing the the flight time between them.
Order the result by `origin_city` and then `dest_city` (ascending, i.e. alphabetically). [Output relation cardinality: 334 rows] */

select distinct f.origin_city, f.dest_city, f.actual_time as time
from FLIGHTS as f,
     (select origin_city, max(actual_time) as max_time
      from FLIGHTS
      group by origin_city) as X
where f.origin_city = X.origin_city
and F.actual_time = X.max_time
order by f.origin_city, f.dest_city;


/* 2. Find all origin cities that only serve flights shorter than 3 hours.
You can assume that flights with `NULL` actual_time are not 3 hours or more.
Name the output column `city` and sort them. List each city only once in the result. [Output relation cardinality: 109]*/

select distinct f1.origin_city as city
from flights f1
where f1.origin_city not in (select f2.origin_city from flights f2 where f2.actual_time >= 60*3)
order by city;


/*3. For each origin city, find the percentage of departing flights shorter than 3 hours.
For this question, treat flights with `NULL` `actual_time` values as longer than 3 hours. 
Name the output columns `origin_city` and `percentage` Order by percentage value, ascending. 
Be careful to handle cities without any flights shorter than 3 hours. We will accept either `0` or `NULL` as the result for those cities.
Report percentages as percentages not decimals (e.g., report 75.25 rather than 0.7525). Output relation cardinality: 327] */

select y.city2, (x.count * 100.0) / y.total as percentage
from (select count(*) as count, f.origin_city as city1
      from flights f
      where f.actual_time < 60*3 and f.actual_time is not null and (f.origin_city is not null)
      group by f.origin_city) as x
right outer join (
      select count(*) as total, f1.origin_city as city2
      from flights f1
      where f1.origin_city is not null
      group by f1.origin_city) as y
on x.city1 = y.city2
order by percentage asc;


/*4. List all cities that cannot be reached from Seattle though a direct flight but can be reached with
one stop (i.e., with any two flights that go through an intermediate city).
Do not include Seattle as one of these destinations (even though you could get back with two flights).
Name the output column `city`. Order the output ascending by city. [Output relation cardinality: 256]*/

select distinct f2.dest_city as city
from flights f, flights f2
where f.origin_city like 'Seattle%'
and f.dest_city = f2.origin_city
and f2.dest_city not like 'Seattle%'
and f2.dest_city not in (select f3.dest_city
               from flights f3
               where f3.origin_city like 'Seattle%')
order by city;


/* 5 List all cities that cannot be reached from Seattle through a direct flight nor with one stop
(i.e., with any two flights that go through an intermediate city). Warning: this query might take a while to execute.
We will learn about how to speed this up in lecture. 
Name the output column city. Order the output ascending by city. (You can assume all cities to be the collection of all origin_city or all dest_city)
[Output relation cardinality: 3 or 4, depending on what you consider to be the set of all cities]*/

select distinct f3.dest_city as city
from flights f3
where f3.dest_city not in (select distinct f2.dest_city
                          from flights f, flights f2
                          where f.origin_city like 'Seattle%'
                          and f.dest_city = f2.origin_city
                          and f2.dest_city not like 'Seattle%'
                          and f2.dest_city not in (select f3.dest_city
                                                   from flights f3
                                                   where f3.origin_city like 'Seattle%'))
and f3.dest_city not in (select distinct f2.dest_city
                         from flights f, flights f2
                         where f.origin_city like 'Seattle%'
                         and f.dest_city = f2.origin_city
                         and f2.dest_city not like 'Seattle%')
and f3.dest_city not like 'Seattle%'
order by city;


/* 6. Express the same query as above, but do so without using a nested query. Again, name the output column
`carrier` and order ascending. List the names of carriers that operate flights from Seattle to San Francisco, CA.
Return each carrier's name only once. Use a nested query to answer this question.*/ 

select c.name as carrier
from flights f, carriers c
where f.carrier_id = c.cid and
      f.origin_city LIKE 'Seattle%' and
      f.dest_city LIKE 'San Francisco%'
group by c.name
order by carrier;
