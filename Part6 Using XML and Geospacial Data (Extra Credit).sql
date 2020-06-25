/* IS631 Enterprise Database Management */

/* Aditya Deshmukh (acd53) */

/* Part 6 – Using XML and Geospacial Data – Extra Credit */


-- Graph for Tucson
SELECT * FROM Temperature

DECLARE @WKT AS VARCHAR(8000);
SET @WKT =
  STUFF(
    (SELECT ',' + CAST( Day_of_Year AS CHAR(4) ) + ' ' + CAST( Rolling_Average_Temp AS VARCHAR(30) )
    FROM (SELECT a.City_Name, a.Day_of_Year, AVG(a.Average_Temp)
		OVER (PARTITION BY a.City_Name ORDER BY Day_of_Year
		ROWS BETWEEN 3 preceding and 1 following) as Rolling_Average_Temp
		FROM (SELECT a.City_Name, datepart(dayofyear, Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Average_Temp
		FROM Updated_Temperature_Data a
		where 
		City_Name in ('Tucson')
		GROUP BY City_Name, datepart(dayofyear, Date_Local)) a ) graphdata
		ORDER BY Day_of_Year
FOR XML PATH('')), 1, 1, '');
SELECT geometry::STGeomFromText( 'LINESTRING(' + @WKT + ')', 0 );



-- Graph for Mission

DECLARE @WKT1 AS VARCHAR(8000);
SET @WKT1 =
  STUFF(
    (SELECT ',' + CAST( Day_of_Year AS CHAR(4) ) + ' ' + CAST( Rolling_Average_Temp AS VARCHAR(30) )
    FROM (SELECT a.City_Name, a.Day_of_Year, AVG(a.Average_Temp)
		OVER (PARTITION BY a.City_Name ORDER BY Day_of_Year
		ROWS BETWEEN 3 preceding and 1 following) as Rolling_Average_Temp
		FROM (SELECT a.City_Name, datepart(dayofyear, Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Average_Temp
		FROM Updated_Temperature_Data a
		WHERE 
		City_Name in ('Mission')
		GROUP BY City_Name, datepart(dayofyear, Date_Local)) a ) graphdata
		ORDER BY Day_of_Year
FOR XML PATH('')), 1, 1, '');
SELECT geometry::STGeomFromText( 'LINESTRING(' + @WKT1 + ')', 0 );



-- Graph for both

DECLARE @WKT2 AS VARCHAR(max);
SET @WKT2 =
  STUFF(
    (SELECT ',' + CAST( Day_of_Year AS CHAR(4) ) + ' ' + CAST( Rolling_Average_Temp AS VARCHAR(30) )
    FROM (SELECT a.City_Name, a.Day_of_Year, AVG(a.Avg_Temp)
		OVER (PARTITION BY a.City_Name ORDER BY Day_of_Year
		ROWS BETWEEN 3 preceding and 1 following) as Rolling_Average_Temp
		FROM (SELECT a.City_Name, datepart(dayofyear, Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Avg_Temp
		FROM Temperature t, AQS_Sites a
		WHERE a.State_Code = t.State_Code and
			a.County_Code = t.County_Code and
			a.Site_Number = t.Site_Num and
			a.City_Name in ('Tucson')
			GROUP BY City_Name, datepart(dayofyear, Date_Local)

		UNION

		SELECT a.City_Name, datepart(dayofyear, t.Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Avg_Temp
		FROM Temperature t, AQS_Sites a
		WHERE a.State_Code = t.State_Code and
			a.County_Code = t.County_Code and
			a.Site_Number = t.Site_Num and
			a.City_Name in ('Mission')
			GROUP BY a.City_Name, DATEPART(dayofyear, t.Date_Local)) a) graphdata

		FOR XML PATH('')), 1, 1, '');
SELECT geometry::STGeomFromText( 'LINESTRING(' + @WKT2 + ')', 0 );
	
				

-- Difference in temp between Tucson and Mission

DECLARE @WKT3 AS VARCHAR(max);
SET @WKT3 =
  STUFF(
    (SELECT ',' + CAST( Day_of_Year AS CHAR(4) ) + ' ' + CAST( Rolling_Average_Temp AS VARCHAR(30) )
    FROM (SELECT a.City_Name, a.Day_of_Year, AVG(a.Avg_Temp)
		OVER (PARTITION BY a.City_Name ORDER BY Day_of_Year
		ROWS BETWEEN 3 preceding and 1 following) as Rolling_Average_Temp
		FROM (SELECT a.City_Name, datepart(dayofyear, Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Avg_Temp
		FROM Temperature t, AQS_Sites a
		where a.State_Code = t.State_Code and
		a.County_Code = t.County_Code and
		a.Site_Number = t.Site_Num and
		a.City_Name in ('Tucson')
		GROUP BY City_Name, datepart(dayofyear, Date_Local)

		union

		SELECT a.City_Name, datepart(dayofyear, t.Date_Local) as Day_of_Year,
		AVG(Average_Temp) as Avg_Temp
		FROM Temperature t, AQS_Sites a
		where a.State_Code = t.State_Code and
		a.County_Code = t.County_Code and
		a.Site_Number = t.Site_Num and
		a.City_Name in ('Mission')
		GROUP BY a.City_Name, DATEPART(dayofyear, t.Date_Local)) a) graphdata
		ORDER BY Day_of_Year

		FOR XML PATH('')), 1, 1, '');
SELECT geometry::STGeomFromText( 'LINESTRING(' + @WKT3 + ')', 0 );

