USE airline;

/*
Creating Users
*/
CREATE USER Manager IDENTIFIED BY "MANAGINGPASS";
GRANT ALL ON airline.* TO Manager WITH GRANT OPTION;

CREATE USER Administrator IDENTIFIED BY "ADMINPASS";
GRANT ALL ON Passenger TO Administrator;
GRANT ALL ON Adult TO Administrator;
GRANT ALL ON Child TO Administrator;
GRANT ALL ON Ticket TO Administrator;
GRANT SELECT ON CrewMember TO Administrator;
GRANT SELECT ON Pilot TO Administrator;
GRANT SELECT ON FlightAttendant TO Administrator;
GRANT SELECT ON Airport TO Administrator;
GRANT SELECT ON Plane TO Administrator;
GRANT UPDATE ON Plane TO Administrator;
GRANT SELECT ON FlightAssignment TO Administrator;
GRANT ALL ON Flight TO Administrator;

/*
Search Queries
*/

-- Query to generate information found on a ticket
SELECT CONCAT(firstName, " ", lastName) AS "Passenger Name",
       seat AS "Seat",
       CONCAT(departing.city) AS "Departing From",
       DATE_FORMAT(boardingTime, "%a, %D %b") AS "Date",
       DATE_FORMAT(boardingTime, "%H:%i") AS "Boarding Time",
       CONCAT(arriving.city) AS "Arriving At",
       DATE_FORMAT(arrivalTime, "%H:%i") AS "Arrival Time"
FROM ticket
JOIN passenger ON ticket.assignedPassenger = passenger.passengerID
JOIN flight ON ticket.assignedflight = flight.flightID
JOIN airport departing ON flight.departingAirport = departing.airportCode
JOIN airport arriving ON flight.arrivingAirport = arriving.airportCode
ORDER BY ticketID;

-- Query to list all crew members on flight 4
SELECT crewID AS "Crew ID", CONCAT(firstName, " ", lastName) AS "Name"
FROM CrewMember
WHERE crewID IN (SELECT crewID
				 FROM FlightAssignment
                 WHERE flightID = 4)
ORDER BY crewID;

-- Query to list all flights happening on the 15th of May 2024
SELECT flightID AS "Flight ID",
	   departingAirport AS "Departing Airport",
       arrivingAirport AS "Arriving Airport",
       assignedPlane AS "Assigned Plane",
       boardingTime AS "Boarding Time",
       arrivalTime AS "Arrival Time"
FROM Flight
WHERE DATE(boardingTime) = "2024-05-15"
ORDER BY boardingTime;

-- Query to list all children associated with the guardian email "alice@gmail.com"
SELECT passengerID AS "Passenger ID",
	   CONCAT(firstName, " ", lastName) AS "Passenger Name",
       DOB,
       passportNo AS "Passport No"
FROM Passenger
WHERE passengerID IN (SELECT passengerID
					  FROM Child
                      WHERE guardianEmail = "alice@gmail.com");

-- Query to get the total flight time for flight 2
SELECT TIMEDIFF(arrivalTime, boardingTime) AS "Flight Time"
FROM Flight
WHERE flightID = 2;

-- Query to list planes with at least 185 seats
SELECT planeID AS "Plane ID", model AS "Model", seats as "Seat No"
FROM Plane
WHERE seats >= 185;

-- Query to get the information of the passenger on seat 23B from flight 3
SELECT passengerID AS "Passenger ID",
	   CONCAT(firstName, " ", lastName) AS "Passenger Name",
       DOB,
       passportNo AS "Passport No"
FROM Passenger
WHERE passengerID IN (SELECT assignedPassenger
					  FROM Ticket
                      WHERE assignedFlight = 3 AND seat = "23B");

-- Query to get all flights going from airport DUB to airport LHR
SELECT flightID AS "Flight ID",
	   departingAirport AS "Departing Airport",
       arrivingAirport AS "Arriving Airport",
       assignedPlane AS "Assigned Plane",
       boardingTime AS "Boarding Time",
       arrivalTime AS "Arrival Time"
FROM Flight
WHERE departingAirport = "DUB" AND arrivingAirport = "LHR"
ORDER BY flightID;

-- Query to list all passengers on flight 1
SELECT *
FROM Passenger
WHERE passengerID IN (SELECT assignedPassenger
					  FROM Ticket
                      WHERE assignedFlight = 1);

-- Query to list all flights under 2 hours
SELECT flightID AS "Flight ID",
	   departingAirport AS "Departing Airport",
       arrivingAirport AS "Arriving Airport",
       assignedPlane AS "Assigned Plane",
       boardingTime AS "Boarding Time",
       arrivalTime AS "Arrival Time",
       TIMEDIFF(arrivalTime, boardingTime) AS "Total Flight Time"
FROM Flight
WHERE TIMEDIFF(arrivalTime, boardingTime) <= "02:00:00";

-- Query to list how many tickets are left for flight 4
SELECT COUNT(ticketID) AS "Tickets left for flight 4"
FROM Ticket
WHERE assignedFlight = 4 AND assignedPassenger IS NULL;

-- Query to get all flights happening between 15/5/24 and 16/5/24
SELECT flightID AS "Flight ID",
	   departingAirport AS "Departing Airport",
       arrivingAirport AS "Arriving Airport",
       assignedPlane AS "Assigned Plane",
       boardingTime AS "Boarding Time",
       arrivalTime AS "Arrival Time"
FROM Flight
WHERE DATE(boardingTime) >= "2024-05-15" AND DATE(arrivalTime) <= "2024-05-16";

-- Query to get the number of flights arriving at the airport DEL on May 16th 2024
SELECT COUNT(flightID) AS "Flights arriving at Indira Gandhi International Airport on 16/5/2024"
FROM Flight
WHERE DATE(arrivalTime) = "2024-05-16" AND arrivingAirport = "DEL";

CREATE VIEW V_DETAILED_FLIGHT
AS
SELECT flightID AS "Flight ID",
       CONCAT(departing.city, ", ", departing.country) AS "Departing From",
       DATE_FORMAT(boardingTime, "%a, %D %b %Y") AS "Date",
       DATE_FORMAT(boardingTime, "%H:%i") AS "Boarding Time",
       CONCAT(arriving.city, ", ", arriving.country) AS "Arriving At",
       DATE_FORMAT(arrivalTime, "%H:%i") AS "Arrival Time",
       TIME_FORMAT(TIMEDIFF(arrivalTime, boardingTime), "%khr %imin") AS "Flight Time"
FROM flight
JOIN airport departing ON flight.departingAirport = departing.airportCode
JOIN airport arriving ON flight.arrivingAirport = arriving.airportCode
ORDER BY flightID;
GRANT ALL ON V_DETAILED_FLIGHT TO Administrator;
GRANT ALL ON V_DETAILED_FLIGHT TO Manager;