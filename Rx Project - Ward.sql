--> Q1 <--
-- a. -- Which prescriber had the highest total number of claims (totaled over all drugs)? 
--       * Report the npi and the total number of claims.
SELECT rx.npi, SUM(total_claim_count) AS total_claim_all_drugs
FROM prescription AS rx
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
GROUP BY rx.npi
ORDER BY SUM(total_claim_count) DESC;

-- b. -- Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  
--       specialty_description, and the total number of claims.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, 
       specialty_description, SUM(total_claim_count) AS total_num_claims
FROM prescription AS rx
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
GROUP BY rx.npi,nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC
;

-----------------------------------------------------------------------------------------------------------------

--> Q2 <-- 
-- a. -- Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count) AS num_total_claims
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
-- ANSWER: Family Practice with 9752347 total Rx 

-- b. -- Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS num_total_opioid_claims
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
	INNER JOIN drug AS d 
		ON d.drug_name = rx.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
-- ANSWER: Nurse Practitioner with 900845 Rx


-- c. -- **Challenge Question:** Are there any specialties that appear in the prescriber table
--       that have no associated prescriptions in the prescription table?
SELECT specialty_description, COUNT(drug_name) AS num_drugs_Rx
FROM prescriber AS pr
	FULL JOIN prescription AS rx
		ON pr.npi = rx.npi
GROUP BY specialty_description
ORDER BY num_drugs_Rx;
--ANSWER: NO, All specialties have at least one and six specialties have only one Rx

-- d. -- **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty,
--       report the percentage of total claims by that specialty which are for opioids. Which specialties have 
--       a high percentage of opioids?
WITH total_opioid_table AS 
(SELECT DISTINCT specialty_description, SUM(total_claim_count) AS num_total_opioid_claims
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
	INNER JOIN drug AS d 
		ON d.drug_name = rx.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC)
--
SELECT DISTINCT pr.specialty_description, SUM(total_claim_count) AS num_total_claims, 
CASE WHEN num_total_opioid_claims IS NULL THEN 0
		 WHEN num_total_opioid_claims IS NOT NULL THEN num_total_opioid_claims 
		 END AS num_total_opioid_claims,
		 ROUND((num_total_opioid_claims / SUM(total_claim_count)) * 100,2) AS percent_are_opioids
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
	LEFT JOIN total_opioid_table AS tat
		ON pr.specialty_description = tat.specialty_description
GROUP BY pr.specialty_description, num_total_opioid_claims
ORDER BY percent_are_opioids DESC
;
--ANSWER: Case Manager/Care Coordinator at 72%, Orthopaedic Surgery at 68.98%, and Interventional Pain Management at 60.89% 
--------------------------------------------------------------------------------------------------

--> Q3 <--
-- a. -- Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, MAX(total_drug_cost) AS higest_total_price
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
GROUP BY generic_name
ORDER BY higest_total_price DESC
LIMIT 1;
--ANSWER: PIRFENIDONE at $2,829,174.30		

-- b. -- Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column 
--       to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, ROUND(MAX(total_drug_cost / total_day_supply),2) AS highest_per_day_price
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
GROUP BY generic_name
ORDER BY highest_per_day_price DESC
LIMIT 1;
--ANSWER: Immun Glob G(IGG)/GLY/IGA OV50 at $7,141.11/day

-----------------------------------------------------------------------------------------------------------------

--> Q4 <--
-- a. -- For each drug in the drug table, return the drug name and then a column named 'drug_type' which says
--        'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have
--        antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a 
--        CASE expression for this.
SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither'
		 	END AS drug_type
FROM drug;

-- b. -- Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on 
--       opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost::MONEY) AS total_type_cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither'
		 	END AS drug_type
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
GROUP BY drug_type
ORDER BY total_type_cost DESC;
--ANSWER: More money was spent on opioids ($105,080,626.37) than antibiotics ($38,435,121.26)

------------------------------------------------------------------------------------------------------------------

--> Q5 <--
-- a. -- How many CBSAs are in Tennessee? *The cbsa table contains information for all states, not just Tennessee.*
SELECT COUNT(DISTINCT cbsa) AS num_cbsa_in_tn
FROM cbsa
WHERE cbsaname LIKE '%TN%';
--ANSWER: 10 

-- b. -- Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total
--       population. 
SELECT cbsa, cbsaname, SUM(population) AS total_pop
FROM population AS p
	INNER JOIN cbsa
		ON p.fipscounty =cbsa.fipscounty
GROUP BY cbsa, cbsaname
ORDER BY total_pop DESC;
--ANSWER: (Largest) 34980 Nashville-Davidson-Murfreesboro-Franklin,TN with a population of 1830410.
--        (Smallest) 34100 Morristown, TN with a population of 116352.

-- c. -- What is the largest (in terms of population) county which is not included in a CBSA? Report the county 
--       name and population.
SELECT p.fipscounty, county, population
FROM population AS p
	FULL JOIN cbsa
		ON p.fipscounty = cbsa.fipscounty
	FULL JOIN fips_county AS fc
		ON p.fipscounty = fc.fipscounty
WHERE cbsa IS NULL
	AND state = 'TN'
	AND population IS NOT NULL
ORDER BY population DESC;
--ANSWER: SEVIER county with a population of 95,523.
	
-------------------------------------------------------------------------------------------------------------------

--> Q6 <-- 
-- a. -- Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name 
--       and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

-- b. -- For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT rx.drug_name, total_claim_count, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 ELSE 'legend'
		 	END AS drug_type
FROM prescription AS rx
	INNER JOIN drug AS d
		ON rx.drug_name = d.drug_name
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

-- c. -- Add another column to you answer from the previous part which gives the prescriber first and last name 
--       associated with each row.
SELECT rx.npi, nppes_provider_first_name, nppes_provider_last_org_name, rx.drug_name, total_claim_count, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 ELSE 'legend'
		 	END AS drug_type
FROM prescription AS rx
	INNER JOIN drug AS d
		ON rx.drug_name = d.drug_name
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

----------------------------------------------------------------------------------------------------------------------

--> Q7 <-- The goal of this exercise is to generate a full list of all pain management specialists in Nashville 
--         and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will 
--         have 637 rows.

-- a. -- First, create a list of all npi/drug_name combinations for pain management specialists 
--       (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
--       where the drug is an opioid (opioid_drug_flag = 'Y'). **Warning:** Double-check your query before running it.
--       You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi, drug_name
FROM prescriber AS pr
	CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY npi;

-- b. -- Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or 
--       not the prescriber had any claims. You should report the npi, the drug name, and the number of claims 
--       (total_claim_count).
WITH npi_opioid_table AS
(SELECT pr.npi, d.drug_name
FROM prescriber AS pr
	CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY pr.npi)
-- TABLE SEPERATION --
SELECT npit.npi, npit.drug_name, total_claim_count
FROM npi_opioid_table AS npit
	LEFT JOIN prescription AS rx
		ON npit.npi = rx.npi
		AND npit.drug_name = rx.drug_name
ORDER BY npit.npi;

-- c. -- Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. 
--       **Hint - Google the COALESCE function.
WITH npi_opioid_table AS
(SELECT pr.npi, d.drug_name
FROM prescriber AS pr
	CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY pr.npi)
-- TABLE SEPERATION --
SELECT npit.npi, npit.drug_name,
	CASE WHEN total_claim_count IS NULL THEN 0
	     WHEN total_claim_count IS NOT NULL THEN total_claim_count END AS claim
FROM npi_opioid_table AS npit
	LEFT JOIN prescription AS rx
		ON npit.npi = rx.npi
		AND npit.drug_name = rx.drug_name
ORDER BY claim DESC;



--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--> BOUNS <--

--> Q1 <-- How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT npi
FROM prescriber
	EXCEPT
SELECT npi
FROM prescription
--ANSWER: 4458

--------------------------------------------------------------------------------------------------------------------------------

--> Q2 <-- 
-- a. -- Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT generic_name, COUNT(generic_name) AS times_prescribed
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;
--ANSWER: METFORMIN HCL (2296Rx), ALBUTEROL SULFATE (2246Rx), LEVOTHYROXINE SODIUM (2084Rx), POTASSIUM CHLORIDE (1992Rx), and DILTIAZEM HCL (1881Rx)

-- b. -- Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name, COUNT(generic_name) AS times_prescribed
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;
--ANSWER: DILTIAZEM HCL(961Rx), POTASSIUM CHLORIDE (634Rx), NITROGLYCERIN (502Rx), WARFARIN SODIUM (501Rx), and DIGOXIN (480Rx)

-- c. -- Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? 
--       Combine what you did for parts a and b into a single query to answer this question.
SELECT generic_name, COUNT(generic_name) AS times_prescribed
FROM drug AS d
	INNER JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
	INNER JOIN prescriber AS pr
		ON rx.npi = pr.npi
WHERE specialty_description = 'Family Practice' 
	OR specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY times_prescribed DESC
LIMIT 5;


--------------------------------------------------------------------------------------------------------------------------------

--> Q3 <-- Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
-- a. -- First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims 
--       (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, SUM(total_claim_count) AS total_claims
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY total_claims
LIMIT 5;

-- b. -- Now, report the same for Memphis.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, SUM(total_claim_count) AS total_claims
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY total_claims
LIMIT 5;
-- c. -- Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, SUM(total_claim_count) AS total_claims, nppes_provider_city
FROM prescriber AS pr
	INNER JOIN prescription AS rx
		ON pr.npi = rx.npi
WHERE nppes_provider_city = 'MEMPHIS'
	OR nppes_provider_city = 'NASHVILLE'
	OR nppes_provider_city = 'KNOXVILLE'
	OR nppes_provider_city = 'CHATTANOOGA'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, nppes_provider_city
ORDER BY total_claims
LIMIT 5;
---------------------------------------------------------------------------------------------------------------------------------

--> Q4 <-- Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
SELECT county, SUM(overdose_deaths) AS overdose_deaths
FROM fips_county AS c
	INNER JOIN overdose_deaths AS od
		ON c.fipscounty::NUMERIC = od.fipscounty
WHERE overdose_deaths > (SELECT ROUND(AVG(overdose_deaths),1)
						  FROM overdose_deaths)
GROUP BY county
ORDER BY overdose_deaths DESC;
---------------------------------------------------------------------------------------------------------------------------------

--> Q5 <-- 
-- a. -- Write a query that finds the total population of Tennessee.
SELECT SUM(population)
FROM population;
-- b. -- Build off of the query that you wrote in part (a) to write a query that returns for each county that county's name,
--       its population, and the percentage of the total population of Tennessee that is contained in that county.
SELECT county, population, ROUND((population / (SELECT SUM(population) FROM population)) * 100,2)  AS percent_of_tn_pop
FROM fips_county AS c
	INNER JOIN population AS p
		ON c.fipscounty = p.fipscounty
ORDER BY percent_of_tn_pop DESC;





