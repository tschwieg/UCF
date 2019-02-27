

CREATE TABLE Garages
(
GarageID	INTEGER ,
Location	TEXT NOT NULL ,
MaxSize		INTEGER NOT NULL ,
PRIMARY KEY (GarageID ) );

CREATE TABLE Students
(
StudentID 		INTEGER ,
Schedule 		TEXT NOT NULL,
Residency 		INTEGER NOT NULL,
StudentName		TEXT NOT NULL,
PRIMARY KEY ( StudentID ) );

CREATE TABLE Vehicles
(
VehicleID		 INTEGER ,
CarType 		TEXT NOT NULL ,
StudentID 		INTEGER ,
GarageID 		INTEGER ,
DateRecorded 	TEXT NOT NULL,
FOREIGN KEY ( StudentID ) REFERENCES Students (StudentID ) ,
FOREIGN KEY ( GarageID ) REFERENCES Garages ( GarageID ) ,
PRIMARY KEY ( VehicleID ) );


.separator ,
.import Students.csv Students
.import Garages.csv Garages
.import Vehicles.csv Vehicles

.mode column
.headers on
.output output.txt

SELECT * FROM Garages;
SELECT * FROM Students;
SELECt * FROM Vehicles;




