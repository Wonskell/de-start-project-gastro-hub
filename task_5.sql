WITH menu_cte AS (
    SELECT r.restaurant_uuid, r.restaurant_name, 'Пицца' AS dish_type,
           p.key AS pizza_name, p.value::numeric AS price
    FROM cafe.restaurants AS r
    CROSS JOIN LATERAL jsonb_each_text(r.menu -> 'Пицца') AS p
    WHERE r.restaurant_type = 'pizzeria'
), menu_with_rank AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY restaurant_uuid ORDER BY price DESC, pizza_name
    ) AS price_rank
    FROM menu_cte
)
-- При одинаковой максимальной цене выбирается первая пицца по названию.
SELECT restaurant_name, dish_type, pizza_name, price
FROM menu_with_rank
WHERE price_rank = 1
ORDER BY restaurant_name;
