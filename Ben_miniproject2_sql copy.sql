Ben Taylor
Mini-Project 2: SQL

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM country_club.Facilities
WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost = 0) as free_for_members_count
FROM country_club.Facilities


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT (membercost) / (monthlymaintenance) * 100 as percentage,
		facid,
		name,
		membercost,
		monthlymaintenance
FROM country_club.Facilities
GROUP BY membercost, monthlymaintenance
HAVING percentage > 0 AND percentage < 20


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid BETWEEN 1 AND 5
      AND NOT facid BETWEEN 2 AND 4


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT CASE WHEN monthlymaintenance <= 100 THEN 'cheap'
           ELSE 'expensive' END AS general_cost,
        name,
        monthlymaintenance
FROM country_club.Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
        surname,
		joindate
FROM country_club.Members
ORDER BY joindate DESC

'I added the joindate column to check my answer. Is it okay to keep it?


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
        CASE WHEN bookings.facid = 0 THEN 'Tennis Court 1'
        	WHEN bookings.facid = 1 THEN 'Tennis Court 2'
        	ELSE NULL END AS court_name,
        CASE WHEN members.memid = 0 THEN 'Guest'
		WHEN members.memid != 0 THEN CONCAT(members.firstname, ' ', members.surname)
		END AS member_full_name
FROM country_club.Bookings bookings
LEFT JOIN country_club.Members members
    ON bookings.memid = members.memid
WHERE bookings.facid < 2
ORDER BY member_full_name

'Could I have dropped any rows with my join?'
'I do not know why I cannot use DISTINCT only on the CONCAT line under SELECT.
'Would that be better than for both? Here is what I mean:'
SELECT
    CASE...
    CONCAT DISTINCT ...


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT	CASE WHEN mem.memid = 0 THEN CONCAT(fac.name, ': ', 'Guest')
		ELSE CONCAT(fac.name, ': ', mem.firstname, ' ', mem.surname)
		END AS facility_user,
	CASE WHEN mem.memid = 0 THEN fac.guestcost * book.slots
		ELSE fac.membercost * book.slots
		END AS cost
FROM country_club.Bookings book
LEFT JOIN country_club.Members mem ON book.memid = mem.memid
LEFT JOIN country_club.Facilities fac ON book.facid = fac.facid
WHERE CAST(book.starttime as DATE) = '2012-09-14'
HAVING cost > 30
ORDER BY cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

From Jeremy:
SELECT
	DISTINCT f.name as fac_name,
	CASE WHEN b.memid = 0 THEN 'Guest'
		ELSE CONCAT(m.firstname, ' ', m.surname) END as full_name,
	CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
		ELSE f.membercost * b.slots END AS cost
FROM country_club.Facilities f
JOIN country_club.Bookings b ON f.facid = b.facid
JOIN country_club.Members m ON b.memid = m.memid
WHERE b.memid IN
	(SELECT memid FROM country_club.Bookings
	WHERE starttime LIKE '2012-09-14%'
	GROUP BY 1)
	AND f.membercost * b.slots > 30 OR f.guestcost * b.slots > 30
ORDER BY cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name AS facility_name,
	SUM(IF(memid =0, guestcost, membercost ) * slots) as total_revenue
FROM country_club.Bookings b
LEFT OUTER JOIN country_club.Facilities f ON b.facid = f.facid
GROUP BY f.name
HAVING SUM(IF(memid =0, guestcost, membercost ) * slots) < 1000
ORDER BY total_revenue DESC
