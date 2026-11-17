-- Наполнение таблиц Gastro Hub.
BEGIN;

INSERT INTO cafe.restaurants (restaurant_name, restaurant_type, menu)
SELECT s.cafe_name, s.type::cafe.restaurant_type, m.menu
FROM (SELECT DISTINCT cafe_name, type FROM raw_data.sales) AS s
LEFT JOIN raw_data.menu AS m ON m.cafe_name = s.cafe_name;

INSERT INTO cafe.managers (manager_name, manager_phone)
SELECT DISTINCT manager, manager_phone
FROM raw_data.sales;

INSERT INTO cafe.restaurant_manager_work_dates (
    restaurant_uuid, manager_uuid, start_date, end_date
)
SELECT r.restaurant_uuid, m.manager_uuid,
       MIN(s.report_date), MAX(s.report_date)
FROM raw_data.sales AS s
JOIN cafe.restaurants AS r ON r.restaurant_name = s.cafe_name
JOIN cafe.managers AS m
    ON m.manager_name = s.manager AND m.manager_phone = s.manager_phone
GROUP BY r.restaurant_uuid, m.manager_uuid;

INSERT INTO cafe.sales (date, restaurant_uuid, avg_check)
SELECT s.report_date, r.restaurant_uuid, s.avg_check
FROM raw_data.sales AS s
JOIN cafe.restaurants AS r ON r.restaurant_name = s.cafe_name;

COMMIT;

