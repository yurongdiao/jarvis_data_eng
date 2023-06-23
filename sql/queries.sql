-- The club is adding a new facility - a spa. We need to add it into the facilities table. 
insert into cd.facilities 
VALUES
	(9, 'Spa', 20, 30, 100000, 800);

-- Let's try adding the spa to the facilities table again. 
-- This time we want to automatically generate the value for the next facid, rather than specifying it as a constant. 
insert into cd.facilities
	(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
select (select max(facid) from cd.facilities )+1, 'Spa', 20, 30, 100000, 800;

-- We made a mistake when entering the data for the second tennis court. 
-- The initial outlay was 10000 rather than 8000
update 
	cd.facilities 
set 
	initialoutlay = 10000
where 
	name = 'Tennis Court 2';

-- We want to alter the price of the second tennis court so that it costs 10% more than the first one. 
-- Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
update 
	cd.facilities
set 
	membercost = (select membercost * 1.1 from cd.facilities where name = 'Tennis Court 1') ,
	guestcost = (select guestcost * 1.1 from cd.facilities where name = 'Tennis Court 1') 
where 
	name = 'Tennis Court 2';
	
-- As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. 
delete from cd.bookings

-- We want to remove member 37, who has never made a booking, from our database.
delete from cd.members
where 
	memid =37;
	
-- How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? 
-- Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
select 
	facid,
	name,
	membercost,
	monthlymaintenance
from 
	cd.facilities
where 
	membercost < monthlymaintenance / 50 
	and membercost > 0;
	
-- How can you produce a list of all facilities with the word 'Tennis' in their name?
select 
	* 
from 
	cd.facilities
where 
	name like '%Tennis%';

-- How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
select 
	* 
from 
	cd.facilities
where 
	facid in (1,5);

-- How can you produce a list of members who joined after the start of September 2012? 
-- Return the memid, surname, firstname, and joindate of the members in question.
select 
	memid, 
	surname, 
	firstname, 
	joindate
from 
	cd.members
where 
	joindate > '2012-09-01 00:00:00';
	
-- You, for some reason, want a combined list of all surnames and all facility names.
select 
	surname 
from 
	cd.members
union 
select 
	name 
from 
	cd.facilities;
	
-- How can you produce a list of the start times for bookings by members named 'David Farrell'?
select 
	starttime 
from 
	cd.bookings b
	join cd.members m 
  	on b.memid = m.memid
where 
	firstname = 'David' 
	and surname = 'Farrell';

--How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? 
-- Return a list of start time and facility name pairings, ordered by the time.
select 
	starttime, 
	name
from 
	cd.bookings b
	left join cd.facilities f
	on b.facid =f.facid
where 
	starttime >'2012-09-21 00:00:00' 
	and starttime < '2012-09-22 00:00:00' 
	and name like 'Tennis Court%'
order by 
	starttime;

-- How can you output a list of all members, including the individual who recommended them (if any)? 
-- Ensure that results are ordered by (surname, firstname).
select 
	m1.firstname,
	m1.surname, 
	m2.firstname, 
	m2.surname
from 
	cd.members m1
	left join cd.members m2
	on m1.recommendedby = m2.memid
order by 
	m1.surname, 
	m1.firstname;
	
-- How can you output a list of all members who have recommended another member? 
-- Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
select distinct
	m2.firstname as firstname, 
	m2.surname as surname
from 
	cd.members m1
	join cd.members m2
	on m1.recommendedby = m2.memid
order by 
	m2.surname, 
	m2.firstname;
	
-- How can you output a list of all members, including the individual who recommended them (if any), without using any joins? 
-- Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
select distinct 
	concat(firstname, ' ',surname) as member,
	(select 
		concat(firstname, ' ',surname) as recommender
	from 
		cd.members m2
	where 
		m1.recommendedby = m2.memid)
from 
	cd.members m1
order by 
	1;


-- Produce a count of the number of recommendations each member has made. Order by member ID.
select 
	recommendedby,
	count(recommendedby)
from 
	cd.members
where 
	recommendedby is not null
group by 
	recommendedby
order by 
	recommendedby;
	
-- Produce a list of the total number of slots booked per facility. 
-- For now, just produce an output table consisting of facility id and slots, sorted by facility id.
select 
	facid, 
	sum(slots)
from 
	cd.bookings
group by 
	facid
order by 
	facid;

-- Produce a list of the total number of slots booked per facility in the month of September 2012. 
-- Produce an output table consisting of facility id and slots, sorted by the number of slots.
select 
	facid,
	sum(slots)
from 
	cd.bookings
where 
	starttime >= '2012-09-01' 
	and starttime <'2012-10-01'
group by 
	facid
order by 
	sum(slots);

-- Produce a list of the total number of slots booked per facility per month in the year of 2012. 
-- Produce an output table consisting of facility id and slots, sorted by the id and month.
select 
	facid, 
	extract(month from starttime),
	sum(slots)
from 
	cd.bookings
where 
	starttime >= '2012-01-01' 
	and starttime < '2013-01-01'
group by 
	facid,
	extract(month from starttime)
order by 
	facid, 
	extract(month from starttime);

-- Find the total number of members (including guests) who have made at least one booking.
select 
	count(distinct memid)
from 
	cd.bookings;
	
-- Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
select 
	surname,
	firstname,
	b.memid,
	min(starttime)
from 
	cd.bookings b
	left join cd.members m
	on b.memid = m.memid
where 
	starttime >= '2012-09-01'
group by 
	b.memid,surname,firstname
order by 
	b.memid;

-- Produce a list of member names, with each row containing the total member count. 
-- Order by join date, and include guest members.
select 
	count(memid) over (),
	firstname,
	surname
from 
	cd.members
order by 
	joindate;

-- Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. 
-- Remember that member IDs are not guaranteed to be sequential.
select 
	row_number()over(),
	firstname,
	surname
from 
	cd.members
order by 
	joindate;

-- Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
select 
	facid,
	sum
from 
	(select
		facid,
		sum(slots) as sum,
		rank()over(order by sum(slots) desc) as rnk
	from 
		cd.bookings
	group by 
		facid) a
where 
	rnk =1;

-- Output the names of all members, formatted as 'Surname, Firstname'
select
	concat(surname, ', ', firstname)
from 
	cd.members;

select 
	surname || ', ' || firstname as name
from 
	cd.members;

-- You've noticed that the club's member table has telephone numbers with very inconsistent formatting. 
-- You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
select 
	memid, 
	telephone 
from 
	cd.members 
where 
	telephone ~ '[()]';

-- You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. 
-- Sort by the letter, and don't worry about printing out a letter if the count is 0.
select 
	substr (mems.surname,1,1) as letter, 
	count(*) as count 
from 
	cd.members mems]
group by 
	letter
order by 
	letter;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

