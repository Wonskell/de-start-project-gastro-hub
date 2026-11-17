CREATE MATERIALIZED VIEW cafe.yearly_average_checks AS
WITH yearly AS (
    SELECT restaurant_uuid, EXTRACT(YEAR FROM date)::integer AS year,
           AVG(avg_check) AS average_check
    FROM cafe.sales
    WHERE EXTRACT(YEAR FROM date) <> 2023
    GROUP BY restaurant_uuid, EXTRACT(YEAR FROM date)
), previous AS (
    SELECT *, LAG(average_check) OVER (
        PARTITION BY restaurant_uuid ORDER BY year
    ) AS previous_average_check
    FROM yearly
)
SELECT p.year, r.restaurant_name, r.restaurant_type,
       ROUND(p.average_check, 2) AS current_avg_check,
       ROUND(p.previous_average_check, 2) AS previous_avg_check,
       ROUND(100 * (p.average_check - p.previous_average_check)
           / NULLIF(p.previous_average_check, 0), 2) AS change_percent
FROM previous AS p
JOIN cafe.restaurants AS r USING (restaurant_uuid);

-- Расчёт процентов использует исходные средние до округления.
SELECT * FROM cafe.yearly_average_checks
ORDER BY restaurant_name, year;
