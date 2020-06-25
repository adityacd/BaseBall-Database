/* IS631 Enterprise Database Management */

/* Aditya Deshmukh (acd53) */

/* Part 4 Front End and Geospatial Data */

--Creating the GeoLocation Column in AQS_Sites Table
IF COL_LENGTH('AQS_sites', 'GeoLocation') IS  NULL
BEGIN
	alter table AQS_Sites
	add GeoLocation Geography
END

--Populating the GoeLocation Column
UPDATE [dbo].[AQS_Sites]
SET [GeoLocation] = geography::Point([Latitude], [Longitude], 4326)

--Checking if the stored procedure exists or not
IF OBJECT_ID('acd53_Spring2020_Calc_GEO_Distance') IS NOT NULL
   DROP procedure acd53_Spring2020_Calc_GEO_Distance
GO


--Creating the Stored procedure acd53_Spring2020_Calc_GEO_Distance
CREATE PROCEDURE dbo.acd53_Spring2020_Calc_GEO_Distance
@longitude varchar(255),
@latitude varchar(255),
@State varchar(255),
@rownum int

AS
BEGIN

DECLARE @h geography
SET @h = geography::Point(@longitude, @latitude, 4326)

	SELECT TOP(@rownum)
	      site_number,
	         Local_Site_Name =
	    CASE
	    WHEN Local_Site_Name IS NULL OR Local_Site_Name = ' ' THEN Site_Number + ' ' + City_Name
	    ELSE Local_Site_Name
	    END,

		  Address,
		  City_Name,
		  State_Name,
		  Zip_Code,
		  Geolocation.STDistance(@h) AS Distance_In_Meters,
		  Latitude,
		  Longitude,
		  (Geolocation.STDistance(@h))/8000 AS Hours_of_Travel
	FROM [AQS_Sites]

	WHERE State_Name = @State
END
GO


--Execute the queries to check the stored procedure
EXEC acd53_Spring2020_Calc_GEO_Distance '-74.426598','40.4991','Arizona',20
GO

EXEC acd53_Spring2020_Calc_GEO_Distance '-74.426598','40.4991','California',5
GO

EXEC acd53_Spring2020_Calc_GEO_Distance '-81.33821','27.48589','Florida',15
GO