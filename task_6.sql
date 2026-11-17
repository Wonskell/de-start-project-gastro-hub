-- Выполнить один раз. Повторный запуск снова повысит текущие цены на 20%.
BEGIN;

-- FOR UPDATE удерживает блокировку затронутых строк до COMMIT.
-- Конкурирующие изменения этих заведений ожидают завершения транзакции.
-- Остальные строки restaurants доступны для чтения и изменения.
SELECT restaurant_uuid
FROM cafe.restaurants
WHERE menu #> '{Кофе,Капучино}' IS NOT NULL
ORDER BY restaurant_uuid
FOR UPDATE;

WITH new_prices AS (
    SELECT restaurant_uuid,
           ROUND((menu #>> '{Кофе,Капучино}')::numeric * 1.20, 2) AS price
    FROM cafe.restaurants
    WHERE menu #> '{Кофе,Капучино}' IS NOT NULL
)
UPDATE cafe.restaurants AS r
SET menu = jsonb_set(r.menu, '{Кофе,Капучино}', to_jsonb(p.price), false)
FROM new_prices AS p
WHERE p.restaurant_uuid = r.restaurant_uuid
RETURNING r.restaurant_name, r.menu #> '{Кофе,Капучино}' AS cappuccino_price;

COMMIT;

-- PostgreSQL использует MVCC. Обычный SELECT во время транзакции может
-- видеть старую зафиксированную цену. Для отчётов требуется согласованный
-- протокол чтения с FOR SHARE в режиме READ COMMITTED. Он ждёт освобождения
-- обновляемых строк и получает актуальную цену. Пример запроса отчёта
-- для отдельной сессии (запускать самостоятельно).
-- BEGIN ISOLATION LEVEL READ COMMITTED;
-- SELECT restaurant_name, menu #> '{Кофе,Капучино}' AS cappuccino_price
-- FROM cafe.restaurants
-- WHERE menu #> '{Кофе,Капучино}' IS NOT NULL
-- FOR SHARE;
-- COMMIT;
