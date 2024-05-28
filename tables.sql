-- Creates new schema if it doesn't already exist
CREATE SCHEMA IF NOT EXISTS airline;

USE airline;



-- Creates the tables
-- Holds information on planes
CREATE TABLE Plane(
 planeID INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
 model VARCHAR(50), 
 seats INT UNSIGNED NOT NULL
);

-- Holds information on airports
-- Source for length function https://www.w3schools.com/sql/func_mysql_length.asp
CREATE TABLE Airport(
 airportCode VARCHAR(3) PRIMARY KEY CHECK (LENGTH(airportCode) = 3), 
 airportName VARCHAR(100) NOT NULL, 
 city VARCHAR(100) NOT NULL, 
 country VARCHAR(50) NOT NULL
);

-- Holds information on individual crew members
CREATE TABLE CrewMember(
 crewID INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
 firstName VARCHAR(50) NOT NULL, 
 lastName VARCHAR(50) NOT NULL, 
 baseAirport VARCHAR(3) NOT NULL, 
 CONSTRAINT fk_crew_airport FOREIGN KEY (baseAirport) REFERENCES Airport(airportCode) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Holds information on individual pilots
CREATE TABLE Pilot(
 crewID INT UNSIGNED PRIMARY KEY, 
 licenseNo VARCHAR(20) NOT NULL UNIQUE, 
 flightHours INT UNSIGNED, 
 CONSTRAINT fk_pilot_crewID FOREIGN KEY (crewID) REFERENCES CrewMember(crewID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Holds information on individual flight attendants
CREATE TABLE FlightAttendant(
 crewID INT UNSIGNED PRIMARY KEY, 
 seniorityLevel INT UNSIGNED, 
 CONSTRAINT fk_attendant_crewID FOREIGN KEY (crewID) REFERENCES CrewMember(crewID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Holds information to do with specific flights
CREATE TABLE Flight(
 flightID INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
 boardingTime DATETIME NOT NULL, 
 arrivalTime DATETIME NOT NULL, 
 assignedPlane INT UNSIGNED NOT NULL, 
 departingAirport VARCHAR(3) NOT NULL, 
 arrivingAirport VARCHAR(3) NOT NULL,
 CONSTRAINT fk_flight_plane FOREIGN KEY (assignedPlane) REFERENCES Plane(planeID) ON UPDATE CASCADE ON DELETE NO ACTION,
 CONSTRAINT fk_flight_departing FOREIGN KEY (departingAirport) REFERENCES Airport(airportCode) ON UPDATE CASCADE ON DELETE NO ACTION,
 CONSTRAINT fk_flight_arriving FOREIGN KEY (arrivingAirport) REFERENCES Airport(airportCode) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Holds information on flight assignments
CREATE TABLE FlightAssignment(
 flightID INT UNSIGNED, 
 crewID INT UNSIGNED,
 PRIMARY KEY (flightID, crewID),
 CONSTRAINT fk_flightAssignment_ticket FOREIGN KEY (flightID) REFERENCES Flight(flightID) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_flightAssignment_crew FOREIGN KEY (crewID) REFERENCES CrewMember(crewID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Holds information on individual passengers
CREATE TABLE Passenger(
 passengerID INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
 firstName VARCHAR(50) NOT NULL, 
 lastName VARCHAR(50) NOT NULL, 
 DOB DATE NOT NULL, 
 passportNo VARCHAR(20) NOT NULL UNIQUE
);

-- Holds additional information on adult passengers
CREATE TABLE Adult(
 passengerID INT UNSIGNED PRIMARY KEY, 
 email VARCHAR(100) NOT NULL, 
 phoneNo VARCHAR(20) NOT NULL, 
 CONSTRAINT fk_adult_passengerID FOREIGN KEY (passengerID) REFERENCES Passenger(passengerID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Holds additional information on child passengers
CREATE TABLE Child(
 passengerID INT UNSIGNED PRIMARY KEY, 
 guardianFName VARCHAR(50) NOT NULL, 
 guardianLName VARCHAR(50) NOT NULL, 
 guardianEmail VARCHAR(100) NOT NULL, 
 guardianPhoneNo VARCHAR(20) NOT NULL, 
 CONSTRAINT fk_child_passengerID FOREIGN KEY (passengerID) REFERENCES Passenger(passengerID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Holds information on flight tickets
-- Source for help with regex 1-99: https://stackoverflow.com/questions/13473523/regex-number-between-1-and-100
CREATE TABLE Ticket(
 ticketID INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, 
 seat VARCHAR(3) NOT NULL CHECK (seat REGEXP "^[1-9][0-9]?[A-F]$"), 
 fare DECIMAL(5,2) NOT NULL,
 assignedPassenger INT UNSIGNED,
 assignedFlight INT UNSIGNED NOT NULL,
 CONSTRAINT fk_ticket_passenger FOREIGN KEY (assignedPassenger) REFERENCES Passenger(passengerID) ON UPDATE CASCADE ON DELETE SET NULL,
 CONSTRAINT fk_ticket_flight FOREIGN KEY (assignedFlight) REFERENCES Flight(flightID) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Populates the talbes with data
 INSERT INTO Plane(model, seats) VALUES
 ("Boeing 737-800", 190),
 ("Airbus A330-300", 182),
 ("Boeing 737 MAX 8-200", 176),
 ("Airbus A321-200", 195),
 ("Boeing 737-800", 187);
 
 INSERT INTO Airport VALUES
 ("DUB", "Dublin Airport", "Dublin", "Ireland"),
 ("ATL", "Hartsfield–Jackson Atlanta International Airport", "Atlanta", "Unites States"),
 ("DXB", "Dubai International Airport", "Dubai", "United Arab Emirates"),
 ("LHR", "Heathrow Airport", "London", "United Kingdom"),
 ("DEL", "Indira Gandhi International Airport", "Delhi", "India");
 
 INSERT INTO CrewMember(firstName, lastName, baseAirport) VALUES
 ("John", "Smith", "DUB"),
 ("Emily", "Johnson", "DUB"),
 ("Michael", "Williams", "ATL"),
 ("Jessica", "Brown", "ATL"),
 ("Daniel", "Martinez", "DXB"),
 ("Sarah", "Taylor", "DXB"),
 ("Christopher", "Anderson", "LHR"),
 ("Amanda", "Thomas", "LHR"),
 ("James", "Wilson", "DEL"),
 ("Rachel", "Moore", "DEL");
 
 INSERT INTO Pilot(crewID, licenseNo, flightHours) VALUES
 (1, "P12345", 5000),
 (3, "P23456", 4500),
 (5, "P34567", 6000);
 
 INSERT INTO FlightAttendant(crewID, seniorityLEVEL) VALUES
 (2, 1),
 (4, 2),
 (6, 3),
 (7, 4),
 (8, 5),
 (9, 6),
 (10, 7);
 
 INSERT INTO Flight(boardingTime, arrivalTime, assignedPlane, departingAirport, arrivingAirport) VALUES
 ("2024-05-15 06:00:00", "2024-05-15 14:40:00", 5, "DUB", "ATL"), 
 ("2024-05-15 20:00:00", "2024-05-16 04:00:00", 3, "LHR", "DEL"), 
 ("2024-05-16 07:30:00", "2024-05-16 23:30:00", 1, "ATL", "DXB"), 
 ("2024-05-16 15:00:00", "2024-05-16 16:30:00", 4, "DUB", "LHR"), 
 ("2024-05-17 22:00:00", "2024-05-18 08:50:00", 2, "DEL", "DUB");
 
 INSERT INTO FlightAssignment(flightID, crewID) VALUES
 (1, 1),
 (1, 2),
 (2, 3),
 (2, 4),
 (3, 5),
 (3, 6),
 (4, 1),
 (4, 7),
 (5, 2),
 (5, 8);
 
INSERT INTO Passenger(firstName, lastName, DOB, passportNo) VALUES
 ("Alice", "Johnson", "1990-05-15", "AB123456"),
 ("Bob", "Smith", "1985-09-20", "CD234567"),
 ("Charlie", "Brown", "1978-12-10", "EF345678"),
 ("Diana", "Miller", "1998-03-25", "GH456789"),
 ("Ethan", "Wilson", "1973-07-05", "IJ567890"),
 ("Fiona", "Jones", "1989-11-30", "KL678901"),
 ("Greg", "Taylor", "2000-02-18", "MN789012"),
 ("Hannah", "Clark", "1965-08-22", "OP890123"),
 ("Ian", "Davis", "1979-04-12", "QR901234"),
 ("Jennifer", "White", "1995-06-08", "ST012345"),
 ("Kevin", "Anderson", "1987-10-28", "UV123456"),
 ("Laura", "Garcia", "1992-04-15", "WX234567"),
 ("Matthew", "Martinez", "1976-11-03", "YZ345678"),
 ("Natalie", "Thompson", "1983-08-19", "AB456789"),
 ("Oliver", "Hernandez", "1990-12-07", "CD567890"),
 ("Pamela", "Johnson", "2014-03-12", "EF678901"),
 ("Quinn", "Smith", "2013-06-25", "GH789012"),
 ("Rebecca", "Brown", "2012-01-30", "IJ890123"),
 ("Samuel", "Miller", "2011-07-14", "KL901234"),
 ("Tina", "Wilson", "2010-09-05", "MN012345");
 
INSERT INTO Adult(passengerID, email, phoneNo) VALUES
 (1, "alice@gmail.com", "+1234567890"),
 (2, "bob@gmail.com", "+1987654321"),
 (3, "charlie@gmail.com", "+1122334455"),
 (4, "diana@gmail.com", "+9988776655"),
 (5, "ethan@gmail.com", "+6677889900"),
 (6, "fiona@gmail.com", "+1122334455"),
 (7, "greg@gmail.com", "+5566778899"),
 (8, "hannah@gmail.com", "+2233445566"),
 (9, "ian@gmail.com", "+4455667788"),
 (10, "jennifer@gmail.com", "+3322114455"),
 (11, "kevin@gmail.com", "+9988776655"),
 (12, "laura@gmail.com", "+1122334455"),
 (13, "matthew@gmail.com", "+2233445566"),
 (14, "natalie@gmail.com", "+3344556677"),
 (15, "oliver@gmail.com", "+4455667788");
 
INSERT INTO Child(passengerID, guardianFName, guardianLName, guardianEmail, guardianPhoneNo) VALUES
 (16, "Alice", "Johnson", "alice@gmail.com","+1234567890"),
 (17, "Bob", "Smith", "bob@gmail.com", "+1987654321"),
 (18, "Charlie", "Brown", "charlie@gmail.com", "+1122334455"),
 (19, "Diana", "Miller", "diana@gmail.com", "+9988776655"),
 (20, "Ethan", "Wilson", "ethan@gmail.com", "+6677889900");

INSERT INTO Ticket(seat, fare, assignedPassenger, assignedFlight) VALUES
 ("15E", 150.00, 1, 1), 
 ("15F", 130.00, 16, 1),
 ("7A", 160.00, 2, 2),
 ("32A", 120.00, 17, 2),
 ("32B", 170.00, 3, 3),
 ("32C", 130.00, 18, 3),
 ("22B", 110.00, 4, 4),
 ("22C", 170.00, 19, 4),
 ("2C", 100.00, 5, 5),
 ("9E", 90.00, 20, 5),
 ("4F", 210.00, 6, 1),
 ("12D", 150.00, 7, 1),
 ("19B", 160.00, 8, 2),
 ("3A", 160.00, 9, 2),
 ("23B", 110.00, 10, 3),
 ("31C", 200.00, 11, 3),
 ("14D", 210.00, 12, 4),
 ("29E", 230.00, 13, 4),
 ("34F", 250.00, 14, 5),
 ("11A", 190.00, 15, 5),
 ("12A", 135.00, null, 4);