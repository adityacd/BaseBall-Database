/* IS631 Enterprise Database Management */

/* Aditya Deshmukh (acd53) */

/* Part 3 - Problems */

-- Question 1

SELECT min(Date_Local) as First_Date, max(date_local) as Last_Date from Temperature;

-- Question 2

SELECT State_Name, MIN(Average_Temp) AS MINIMUM_TEMP, MAX(Average_Temp) AS MAX_TEMP, 
AVG(Average_Temp) AS TEMP_AVG
FROM Temperature t , AQS_Sites a
WHERE t.State_Code = a.State_Code AND
t.County_Code = a.County_Code AND
t.Site_Num = a.Site_Number	
GROUP BY State_Name
ORDER BY State_Name;

/* Question 3 */

SELECT A.State_Name,A.State_Code,A.County_Code,A.Site_Number,MIN(cast(Average_Temp as decimal(10,7))) AS Average_Temp, date_local --FORMAT(MAX(Date_Local),'yyyy-MM-dd') AS 'DATE_LOCAL'
FROM AQS_Sites A, Temperature T
WHERE T.State_Code=A.State_Code AND
T.County_Code=A.County_Code AND
T.Site_Num=A.Site_Number
GROUP BY A.State_Name,A.State_Code,A.County_Code,A.Site_Number, Average_Temp, Date_Local
HAVING (Average_Temp < -39 OR Average_Temp > 105)
ORDER BY State_Name DESC, Average_Temp;

/* Question 4 */
GO
CREATE VIEW Updated_Temperature_Data AS 
WITH ta AS 
(SELECT * FROM Temperature t WHERE Average_Temp > -39 AND (( Average_Temp < 125 
AND t.State_Code NOT IN (30, 29, 37, 26, 18, 38)) 
OR (Average_Temp < 105 AND t.State_Code IN (30, 29, 37, 26, 18, 38)))),
a AS (SELECT * FROM aqs_sites a 
WHERE State_Name NOT IN ('Canada','Country Of Mexico','District Of Columbia','Guam',
'Puerto Rico','Virgin Islands'))
SELECT ta.State_Code, ta.Site_Num, ta.County_Code, Date_Local, Average_Temp, Daily_High_Temp,
Date_Last_Change, ta.[1st Max Hour], Latitude, Longitude, Datum, Elevation, 
[Land Use], [Location Setting],[Site Established Date], [Site Closed Date], 
[Met Site State Code], [Met Site County Code], [Met Site Site Number], 
[Met Site Type],[Met Site Distance], [Met Site Direction], [GMT Offset], 
[Owning Agency], Local_Site_Name, Address, Zip_Code,State_Name, County_Name, 
City_Name, CBSA_Name, Tribe_Name, [Extraction Date] FROM ta, a WHERE 
ta.State_Code = a.State_Code AND ta.Site_Num = a.Site_Number
and Ta.County_Code= A.County_Code

select * from Updated_Temperature_Data

/* Question 5 */
GO
SELECT State_Name, MIN(Average_Temp) AS MINIMUM_TEMP, MAX(Average_Temp) AS MAX_TEMP, 
AVG(Average_Temp) AS TEMP_AVG, 
RANK() OVER(order by avg(average_Temp) DESC) AS STATE_RANK
from Updated_Temperature_Data
GROUP BY State_Name;


/* Question 6 */


DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime = GETDATE()

Print 'Before indexing, the query started at - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

  -- Query of Question #2

SELECT State_Name, MIN(Average_Temp) AS MINIMUM_TEMP, MAX(Average_Temp) AS MAX_TEMP, 
AVG(Average_Temp) AS TEMP_AVG
FROM Temperature t , AQS_Sites a
WHERE t.State_Code = a.State_Code AND
t.County_Code = a.County_Code AND
t.Site_Num = a.Site_Number
GROUP BY State_Name
ORDER BY State_Name;

SELECT @EndTime=GETDATE()
PRINT 'Before indexing, the query ended at - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

-- This query gives the execution time in milliseconds before indexing

PRINT 'The execution time in seconds before Indexing: ' +(CAST(convert(varchar,DATEDIFF(second,@StartTime,@EndTime),108) AS nvarchar(30)))


-- Checking if the Avg_Temp_Index exists before and creating it

Go
BEGIN
IF EXISTS (SELECT *  FROM SYS.INDEXES
WHERE name in (N'Avg_Temp_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
BEGIN
DROP INDEX Avg_Temp_Index ON Temperature
END
END

-- Creating index for Average_Temp column in Temperature table

Go
Create Index Avg_Temp_Index ON Temperature (Average_Temp)

-- Checking if the Daily_High_Temp_Index exists before and creating it

Go
BEGIN
IF EXISTS (SELECT *  FROM SYS.INDEXES
WHERE name in (N'Daily_High_Temp_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
BEGIN
DROP INDEX Daily_High_Temp_Index ON Temperature
END
END

-- Creating index for Daily_High_Temp column in Temperature table

Go
Create Index Daily_High_Temp_Index ON Temperature (Daily_High_Temp)

-- Checking if the Date_Local_Index exists before and creating it

Go
BEGIN
IF EXISTS (SELECT *  FROM SYS.INDEXES
WHERE name in (N'Date_Local_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
BEGIN
DROP INDEX Date_Local_Index ON Temperature
END
END

-- Creating index for Date_Local column in Temperature table

Go
Create Index Date_Local_Index ON Temperature (Date_Local)

-- Checking if the State_County_Site_Code_Temp_Index exists before and creating it

Go
BEGIN
IF EXISTS (SELECT *  FROM SYS.INDEXES
WHERE name in (N'State_County_Site_Code_Temp_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
BEGIN
DROP INDEX State_County_Site_Code_Temp_Index ON Temperature
END
END

-- Creating Indexes on County_Code, State_Code, Site_Num in Temperature table

Go
Create Index State_County_Site_Code_Temp_Index ON Temperature (State_Code, County_Code, Site_Num)

-- Checking if the State_County_Site_Code_AQS_Index exists before and creating it

Go
BEGIN
IF EXISTS (SELECT *  FROM SYS.INDEXES
WHERE name in (N'State_County_Site_Code_AQS_Index') AND object_id = OBJECT_ID('dbo.aqs_sites'))
BEGIN
DROP INDEX State_County_Site_Code_AQS_Index ON aqs_sites
END
END

-- Creating Indexes on County_Code, State_Code, Site_Num in aqs_sites table

Go
Create Index State_County_Site_Code_AQS_Index ON aqs_sites (State_Code,county_code, Site_Number)

-- After Indexing is done

Go
DECLARE @StartTimeAfterIndex datetime
DECLARE @EndTimeAfterIndex datetime
SELECT @StartTimeAfterIndex = GETDATE()

Print 'After indexing, the query started at - ' + (CAST(CONVERT(VARCHAR, GETDATE(),108) AS NVARCHAR(30)))

-- Query of Question 2

SELECT State_Name, MIN(Average_Temp) AS MINIMUM_TEMP, MAX(Average_Temp) AS MAX_TEMP, 
AVG(Average_Temp) AS TEMP_AVG
FROM Temperature t , AQS_Sites a
WHERE t.State_Code = a.State_Code AND
t.County_Code = a.County_Code AND
t.Site_Num = a.Site_Number
GROUP BY State_Name
ORDER BY State_Name;

SELECT @EndTimeAfterIndex=GETDATE()
PRINT 'After indexing, the query ended at - ' + (CAST(CONVERT(VARCHAR, GETDATE(),108) AS NVARCHAR(30)))

-- This query gives the execution time in milliseconds afer indexing

PRINT 'The execution time in seconds after Indexing: ' +
		(CAST(CONVERT(VARCHAR,DATEDIFF(SECOND, @StartTimeAfterIndex,@EndTimeAfterIndex),108) AS nvarchar(30)))


/* Question 7 */

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp]
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp) DESC) AS [State Rank] 
FROM Updated_Temperature_Data GROUP BY State_Name) S,
(SELECT State_Name, RANK() OVER(PARTITION BY State_Name ORDER BY AVG(Average_Temp) DESC) 
AS [State City Rank], City_Name, AVG(Average_Temp) AS [Avg Temp] 
FROM Updated_Temperature_Data GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name
AND [State Rank] <= 15
ORDER BY [State Rank];

/* Question 8 */

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp]
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp) DESC) AS [State Rank] 
FROM Updated_Temperature_Data GROUP BY State_Name) S,
(SELECT State_Name, RANK() OVER(PARTITION BY State_Name ORDER BY AVG(Average_Temp) DESC) 
AS [State City Rank], City_Name, AVG(Average_Temp) AS [Avg Temp] 
FROM Updated_Temperature_Data
WHERE City_Name <> 'Not in a City'
GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name
AND [State Rank] <= 15
ORDER BY [State Rank];

/* Question 9 */

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp]
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp) DESC) AS [State Rank] 
FROM Updated_Temperature_Data GROUP BY State_Name) S,
(SELECT State_Name, RANK() OVER(PARTITION BY State_Name ORDER BY AVG(Average_Temp) DESC) 
AS [State City Rank], City_Name, AVG(Average_Temp) AS [Avg Temp] 
FROM Updated_Temperature_Data
WHERE City_Name <> 'Not in a City'
GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name
AND [State Rank] <= 15 AND [State City Rank] <=2
ORDER BY [State Rank];

/* Question 10 */

 SELECT City_Name, DATEPART(MONTH,Date_Local) as Month, COUNT(*) as '# of Records',
AVG(Average_Temp) as Average_Temp
FROM Updated_Temperature_Data
WHERE City_Name IN ('Arvin', 'Tucson', 'Mission')
Group by City_Name, DATEPART(MONTH,Date_Local)
Order by City_Name, DATEPART(MONTH,Date_Local);

/* Question 11 */

SELECT *
FROM (SELECT DISTINCT City_Name, Average_Temp,
CUME_DIST() OVER (Partition by City_Name Order by Average_Temp) AS Temp_With_Cume_Dist
FROM Updated_Temperature_Data
WHERE
City_Name IN ('Arvin', 'Tucson', 'Mission')) T
WHERE T.Temp_With_Cume_Dist BETWEEN 0.4 AND 0.6;

/* Question 12 */

SELECT DISTINCT City_Name, PERCENTILE_DISC(0.4) WITHIN GROUP (ORDER BY AVERAGE_TEMP) 
OVER (PARTITION BY CITY_NAME) AS '40 PERCENT TEMP',
PERCENTILE_DISC(0.6) WITHIN GROUP (ORDER BY AVERAGE_TEMP) 
OVER (PARTITION BY CITY_NAME) AS '60 PERCENT TEMP'
FROM Updated_Temperature_Data
WHERE City_Name IN ('Arvin', 'Tucson', 'Mission')
ORDER BY City_Name;

/* Question 13 */

SELECT T.City_Name, T.[Day of the Year],
AVG(T.Average_Temp) OVER (PARTITION BY T.City_Name ORDER BY T.[Day of the Year] 
ROWS BETWEEN 3 Preceding AND 1 following) as Rolling_Avg_Temp
FROM (SELECT DISTINCT City_Name, DATEPART(DY, Date_Local) AS 'Day of the Year', 
AVG(Average_Temp) AS Average_Temp
FROM Updated_Temperature_Data
WHERE
City_Name IN ('Arvin', 'Tucson', 'Mission')
GROUP BY City_Name, DATEPART(DY,Date_Local)) T;

