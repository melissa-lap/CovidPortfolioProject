SELECT *
FROM Breast_Cancer

-- Cleaning the data first
-- Changing Date formats

SELECT Date_of_surgery, CONVERT(Date,date_of_surgery)
FROM Breast_Cancer

ALTER TABLE Breast_Cancer
ADD Surgery_date DATE

UPDATE Breast_Cancer
SET Surgery_date = CONVERT(DATE,Date_of_Surgery)

ALTER TABLE Breast_Cancer
ADD Last_visit DATE

UPDATE Breast_Cancer
SET Last_visit = CONVERT(DATE, Date_of_last_visit)


-- Changing NULL to "Unknown" for Patient_status

SELECT Patient_Status,
	CASE WHEN Patient_status IS NULL THEN 'Unknown'
	ELSE Patient_Status
	END as Patient_Status_Fixed
FROM Breast_Cancer

UPDATE Breast_Cancer
SET Patient_Status = CASE WHEN Patient_status IS NULL THEN 'Unknown'
	ELSE Patient_Status
	END
FROM Breast_Cancer


-- Creating age bracket column


SELECT age,
	CASE WHEN age < 30 THEN 'Under 30'
		WHEN age >=30 AND age <40 THEN 'Thirties'
		WHEN age >=40 AND age <50 THEN 'Forties'
		WHEN age >=50 AND age <60 THEN 'Fifties'
		WHEN age >=60 AND age <70 THEN 'Sixties'
		WHEN age >=70 AND age <80 THEN 'Seventies'
		WHEN age >=80 THEN 'Over 80'
		END as age_bracket
FROM Breast_Cancer

ALTER TABLE Breast_Cancer
ADD age_bracket nvarchar(50)

UPDATE Breast_Cancer
SET age_bracket = CASE WHEN age < 30 THEN 'Under 30'
		WHEN age >=30 AND age <40 THEN 'Thirties'
		WHEN age >=40 AND age <50 THEN 'Forties'
		WHEN age >=50 AND age <60 THEN 'Fifties'
		WHEN age >=60 AND age <70 THEN 'Sixties'
		WHEN age >=70 AND age <80 THEN 'Seventies'
		WHEN age >=80 THEN 'Over 80'
		END


-- Looking at different metrics


SELECT Tumour_Stage, count(*) as num_cases, count(*) * 100/sum(count(*)) OVER () as 'Percent_of_total'
FROM Breast_Cancer
GROUP by Tumour_Stage


SELECT age_bracket, Count(*) as num_cases, Count(*)*100 / sum(COUNT(*)) over () as 'Percent_of_total'
FROM Breast_Cancer
GROUP BY age_bracket
ORDER BY Percent_of_total DESC

SELECT histology, COUNT(*) as num_cases, count(*)*100 / sum(count(*)) over () as 'Percent_of_Total'
FROM Breast_Cancer
GROUP BY histology
ORDER BY Percent_of_Total DESC

SELECT Patient_Status, COUNT(*) as num_of_cases
FROM Breast_Cancer
GROUP BY Patient_Status 