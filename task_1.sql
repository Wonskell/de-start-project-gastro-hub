-- Три заведения каждого типа. При равных чеках порядок по названию.
CREATE OR REPLACE VIEW cafe.top_restaurants AS
WITH average_checks AS (
    SELECT restaurant_uuid, AVG(avg_check) AS average_check
    FROM cafe.sales
    GROUP BY restaurant_uuid
), ranked AS (
    SELECT r.restaurant_name, r.restaurant_type, a.average_check,
           ROW_NUMBER() OVER (
               PARTITION BY r.restaurant_type
               ORDER BY a.average_check DESC, r.restaurant_name
           ) AS position
    FROM average_checks AS a
    JOIN cafe.restaurants AS r USING (restaurant_uuid)
)
SELECT restaurant_name, restaurant_type, ROUND(average_check, 2) AS avg_check
FROM ranked
WHERE position <= 3;

SELECT * FROM cafe.top_restaurants
ORDER BY restaurant_type, avg_check DESC, restaurant_name;
