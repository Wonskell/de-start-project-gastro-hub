WITH pizza_counts AS (
    SELECT r.restaurant_name, COUNT(p.key) AS pizza_count
    FROM cafe.restaurants AS r
    LEFT JOIN LATERAL jsonb_each_text(r.menu -> 'Пицца') AS p ON true
    WHERE r.restaurant_type = 'pizzeria'
    GROUP BY r.restaurant_uuid, r.restaurant_name
), ranked AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY pizza_count DESC) AS position
    FROM pizza_counts
)
SELECT restaurant_name, pizza_count
FROM ranked
WHERE position = 1
ORDER BY restaurant_name;
