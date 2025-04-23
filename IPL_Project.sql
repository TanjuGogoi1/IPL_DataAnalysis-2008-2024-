USE [IPL(2008-2024)];
SELECT * FROM deliveries;
SELECT*FROM matches;

--Top 10 Players That best perform under last final overs.
SELECT TOP 10 batter,
COUNT(*)AS ball_faced,
SUM(batsman_runs) AS total_runs,
ROUND(SUM(batsman_runs)*1.0/COUNT(*),2)AS strike_rate,
SUM(CASE WHEN batsman_runs =4 THEN 1 ELSE 0 END) AS fours,
SUM(CASE WHEN batsman_runs =6 THEN 1 ELSE 0 END) AS sixes
FROM deliveries
WHERE [over] BETWEEN 17 AND 20
GROUP BY batter
HAVING COUNT(*)>=30
ORDER BY total_runs DESC;

--Most Valuable Pairs of Batsman Have the Highest Average Partnership Runs.
SELECT TOP 10 
pair.batter AS batter1,
pair.non_striker AS batter2,
COUNT(DISTINCT pair.match_inning) AS partnership,
SUM(pair.total_runs) AS total_runs,
CAST(SUM(pair.total_runs)*1.0/
COUNT(DISTINCT pair.match_inning) AS
DECIMAL(6,2)) AS avg_Partnership_runs
FROM(
SELECT match_id,inning,batter,non_striker,
(CAST(match_id AS VARCHAR) + '-'+CAST(inning AS VARCHAR)) AS match_inning,
total_runs FROM deliveries) AS pair
GROUP BY pair.batter, pair.non_striker
HAVING COUNT(DISTINCT pair.match_inning)>=5
ORDER BY avg_Partnership_runs DESC;

--Bowlers That Consistently Take 1 Wicket Every Match Over Multiple Season.
SELECT TOP 10
bowler,
COUNT(DISTINCT match_id) AS match_played,
COUNT(*) AS total_wickets,
CAST(COUNT(*)*1.0/COUNT(DISTINCT match_id) AS DECIMAL(5,2)) AS
avg_wicket_per_match
FROM deliveries
WHERE is_wicket=1
AND dismissal_kind NOT IN('NA', 'caught','hit wicket','obstructing the field',
'retired hurt','run out')
GROUP BY bowler
HAVING COUNT(DISTINCT match_id)>=10
AND CAST(COUNT(*)*1.0/COUNT(DISTINCT match_id) AS DECIMAL(5,2))>=1.0
ORDER BY avg_wicket_per_match DESC;

--Teams that scores the most runs in the first half(10) overs of the match on avarage.
SELECT TOP 10
deliveries.batting_team,
COUNT(DISTINCT deliveries.match_id)AS matches_played,
SUM(deliveries.total_runs)AS total_runs_in_first_10_overs,
CAST(SUM(deliveries.total_runs)*1.0/
COUNT(DISTINCT deliveries.match_id)AS
DECIMAL(5,2))AS avg_runs_in_first_10_overs
FROM deliveries
WHERE deliveries.[over] BETWEEN 1 AND 10
GROUP BY deliveries.batting_team
HAVING COUNT(DISTINCT deliveries.match_id)>=5
ORDER BY total_runs_in_first_10_overs DESC;
