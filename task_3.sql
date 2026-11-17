-- Первый менеджер начинает работу. Каждое следующее назначение — смена.
SELECT r.restaurant_name, COUNT(*) - 1 AS manager_changes
FROM cafe.restaurant_manager_work_dates AS w
JOIN cafe.restaurants AS r USING (restaurant_uuid)
GROUP BY r.restaurant_uuid, r.restaurant_name
ORDER BY manager_changes DESC, r.restaurant_name
LIMIT 3;
