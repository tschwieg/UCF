create table Reports(
BugID integer,
CurResolution text not null,
CurStatus text,
OpeningTime integer not null,
ReporterID integer not null,
primary key (BugID));




CREATE TABLE AssignedTo(
RowID integer,
BugID INTEGER ,
Assignment VARCHAR(128) NOT NULL,
Timestamp INTEGER NOT NULL,
ReporterID INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID) );

CREATE TABLE BugStatus(
RowID integer,
BugID INTEGER,
BugStatus TEXT NOT NULL,
Timestamp INTEGER NOT NULL,
ReporterID INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE ComponentType(
RowID		integer,
BugID		INTEGER,
Component	TEXT NOT NULL,
Timestamp	INTEGER NOT NULL,
Reporterid	INTEGER NOT NULL,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE OperatingSystem(
RowID			integer,
BugID			INTEGER,
OperatingSystem	text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Priority(
RowID			integer,
BugID			INTEGER,
Priority		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Product(
RowID			integer,
BugID			INTEGER,
ProductType		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Resolution(
RowID			integer,
BugID			INTEGER,
Resolution		text,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Severity(
RowID			integer,
BugID			INTEGER,
Severity		text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Version(
RowID			integer,
BugID			INTEGER,
Version			text not null,
Timestamp		integer not null,
Reporterid		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY ( RowID ) );

CREATE TABLE Description(
RowID 			integer,
BugID			INTEGER,
Descript		Varchar( 256),
Timestamp		integer not null,
ReporterID		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY( RowID ) );

CREATE TABLE CC(
RowID 			integer,
BugID			INTEGER,
Copied		Varchar( 256),
Timestamp		integer not null,
ReporterID		integer not null,
FOREIGN KEY ( BugID ) REFERENCES Reports( BugID ),
PRIMARY KEY( RowID ) );

.separator ,
.import csvs/reports.csv Reports
.import csvs/assigned_to.csv AssignedTo
.import csvs/bug_status.csv BugStatus
.import csvs/component.csv ComponentType
.import csvs/op_sys.csv OperatingSystem
.import csvs/priority.csv Priority
.import csvs/product.csv Product
.import csvs/resolution.csv Resolution
.import csvs/severity.csv Severity
.import csvs/version.csv Version
.import csvs/fixed_desc.csv Description
.import csvs/fixed_cc.csv CC

.mode column
.headers on
.output output.txt




create table CleanAssignedTo( BugID int, Assignment Varchar( 256 ), Timestamp int, NumAssignments int );
INSERT INTO CleanAssignedTo( BugID, Assignment, Timestamp,NumAssignments )  
SELECT a.BugID
     , group_concat(DISTINCT ca.Assignment), a.Timestamp, Count(*)
     
FROM   AssignedTo AS a
JOIN   AssignedTo AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanBugStatus( BugID int, BugStatus Varchar( 256 ), Timestamp int, BugChanges int );
INSERT INTO CleanBugStatus( BugID, BugStatus, Timestamp, BugChanges )  
SELECT a.BugID
     , group_concat(DISTINCT ca.BugStatus), a.Timestamp, Count(*)
     
FROM   BugStatus AS a
JOIN   BugStatus AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;



create table CleanComponentType( BugID int, Component Varchar( 256 ), Timestamp int, NumTypes int );
INSERT INTO CleanComponentType( BugID, Component, Timestamp, NumTypes )  
SELECT a.BugID
     , group_concat(DISTINCT ca.Component), a.Timestamp, Count(*)
     
FROM   ComponentType AS a
JOIN   ComponentType AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;


create table CleanOperatingSystem( BugID int, OperatingSystem Varchar( 256 ), Timestamp int, NumSystems int );
INSERT INTO CleanOperatingSystem( BugID, OperatingSystem, Timestamp,NumSystems )  
SELECT a.BugID
     , group_concat( DISTINCT ca.OperatingSystem), a.Timestamp, Count(*)
     
FROM   OperatingSystem AS a
JOIN   OperatingSystem AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanPriority( BugID int, Priority Varchar( 256 ), Timestamp int, PrioChanges int );
INSERT INTO CleanPriority( BugID, Priority, Timestamp, PrioChanges )  
SELECT a.BugID
     , group_concat( DISTINCT ca.Priority), a.Timestamp, Count(*)
     
FROM   Priority AS a
JOIN   Priority AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanProduct( BugID int, ProductType Varchar( 256 ), Timestamp int, NumProducts int );
INSERT INTO CleanProduct( BugID, ProductType, Timestamp, NumProducts )  
SELECT a.BugID
     , group_concat( DISTINCT ca.ProductType), a.Timestamp, Count(*)
     
FROM   Product AS a
JOIN   Product AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanResolution( BugID int, Resolution Varchar( 256 ), Timestamp int, ResolutionChanges int );
INSERT INTO CleanResolution( BugID, Resolution, Timestamp, ResolutionChanges )  
SELECT a.BugID
     , group_concat( DISTINCT ca.Resolution), a.Timestamp, Count(*)
     
FROM   Resolution AS a
JOIN   Resolution AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanSeverity( BugID int, Severity Varchar( 256 ), Timestamp int, SeverityChanges int );
INSERT INTO CleanSeverity( BugID, Severity, Timestamp, SeverityChanges )  
SELECT a.BugID
     , group_concat( DISTINCT ca.Severity), a.Timestamp, Count(*)
     
FROM   Severity AS a
JOIN   Severity AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanVersion( BugID int, Version Varchar( 256 ), Timestamp int, NumVersions int );
INSERT INTO CleanVersion( BugID, Version, Timestamp, NumVersions )  
SELECT a.BugID
     , group_concat(DISTINCT ca.Version), a.Timestamp, Count(*)
     
FROM   Version AS a
JOIN   Version AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;


create table CleanDesc( BugID int, Descript Varchar( 256 ), Timestamp int, NumDescriptions int );
INSERT INTO CleanDesc( BugID, Descript, Timestamp, NumDescriptions )  
SELECT a.BugID
     , group_concat( DISTINCT ca.Descript), a.Timestamp, Count(*)
     
FROM   Description AS a
JOIN   Description AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

create table CleanCC( BugID int, Copied Varchar( 256 ), Timestamp int, NumCCs int );
INSERT INTO CleanCC( BugID, Copied, Timestamp, NumCCs )  
SELECT DISTINCT a.BugID
     , group_concat( DISTINCT ca.Copied), a.Timestamp, Count(*)
     
FROM   CC AS a
JOIN   CC AS ca ON ca.BugID = a.BugID
GROUP  BY a.BugID;

UPDATE CleanCC Set Copied = REPLACE( Copied, ",", ";" );
UPDATE CleanDesc Set Descript = REPLACE( Descript, ",", ";" );
UPDATE CleanVersion Set Version = REPLACE( Version, ",", ";" );
UPDATE CleanSeverity Set Severity = REPLACE( Severity, ",", ";" );
UPDATE CleanResolution Set Resolution = REPLACE( Resolution, ",", ";" );
UPDATE CleanProduct Set ProductType = REPLACE( ProductType, ",", ";" );
UPDATE CleanPriority Set Priority = REPLACE( Priority, ",", ";" );
UPDATE CleanOperatingSystem Set OperatingSystem = REPLACE( OperatingSystem, ",", ";" );
UPDATE CleanComponentType Set Component = REPLACE( Component, ",", ";" );
UPDATE CleanBugStatus Set BugStatus = REPLACE( BugStatus, ",", ";" ); 
UPDATE CleanAssignedTo Set Assignment = REPLACE( Assignment, ",", ";" );



create table FinalProduct as
SELECT Reports.BugID,Reports.CurResolution, Reports.CurStatus, Reports.OpeningTime, Reports.ReporterID, CleanAssignedTo.Assignment, CleanBugStatus.BugStatus, CleanOperatingSystem.OperatingSystem, CleanPriority.Priority, CleanResolution.Resolution, CleanSeverity.Severity, CleanVersion.Version, max( Reports.OpeningTime, CleanAssignedTo.TimeStamp, CleanBugStatus.TimeStamp, CleanOperatingSystem.TimeStamp, CleanPriority.TimeStamp, CleanResolution.TimeStamp, CleanSeverity.TimeStamp, CleanVersion.TimeStamp ) - min( Reports.OpeningTime, CleanAssignedTo.TimeStamp, CleanBugStatus.TimeStamp, CleanOperatingSystem.TimeStamp, CleanPriority.TimeStamp, CleanResolution.TimeStamp, CleanSeverity.TimeStamp, CleanVersion.TimeStamp ), CleanDesc.Descript, CleanProduct.ProductType, CleanCC.Copied, CleanBugStatus.BugChanges, CleanComponentType.Component 
FROM Reports, CleanAssignedTo, CleanBugStatus, CleanComponentType, CleanOperatingSystem, CleanPriority, CleanProduct, CleanResolution, CleanSeverity, CleanVersion, CleanDesc,CleanCC 
Where Reports.BugID = CleanAssignedTo.BugID and Reports.BugID = CleanBugStatus.BugID and Reports.BugID = CleanComponentType.BugID and Reports.bugID = CleanOperatingSystem.bugID and Reports.bugID = CleanPriority.bugID and Reports.bugID = CleanProduct.bugID and Reports.bugID = CleanResolution.bugID and Reports.bugID = CleanSeverity.bugID and Reports.bugID = CleanVersion.bugID and Reports.bugID = CleanDesc.bugID and Reports.bugID = CleanCC.bugID;

.headers off
.mode csv
.output csvs/BigCsv.csv
SELECT * FROM FinalProduct;

drop table FinalProduct;
drop table CleanAssignedTo;
drop table CleanComponentType;
drop table CleanOperatingSystem;
drop table CleanPriority;
drop table CleanProduct;
drop table CleanResolution;
drop table CleanSeverity;
drop table CleanVersion;
drop table CleanCC;
drop table CleanBugStatus;
drop table CleanDesc;

