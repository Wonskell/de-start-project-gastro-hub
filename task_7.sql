-- Подготовка структуры — отдельная короткая транзакция.
-- ALTER TABLE ADD/DROP COLUMN требует ACCESS EXCLUSIVE и кратковременно
-- блокирует чтение. Строго непрерывное чтение во время такой DDL-миграции
-- невозможно. Этап изменения данных ниже сохраняет доступность SELECT.
BEGIN;
ALTER TABLE cafe.managers ADD COLUMN phone_numbers text[];
COMMIT;

BEGIN;
-- SHARE ROW EXCLUSIVE запрещает конкурентные INSERT/UPDATE/DELETE,
-- допускает обычный SELECT и исключает одновременную такую миграцию.
LOCK TABLE cafe.managers IN SHARE ROW EXCLUSIVE MODE;

WITH numbered AS (
    SELECT manager_uuid, manager_phone,
           ROW_NUMBER() OVER (
               ORDER BY manager_name COLLATE "ru-x-icu", manager_uuid
           ) + 99 AS phone_suffix
    FROM cafe.managers
)
UPDATE cafe.managers AS m
SET phone_numbers = ARRAY[
    CONCAT('8-800-2500-', n.phone_suffix), n.manager_phone
]
FROM numbered AS n
WHERE n.manager_uuid = m.manager_uuid;

-- Удаляем исходный столбец после копирования в массив. До COMMIT эта
-- финальная DDL-операция кратковременно блокирует также чтение.
ALTER TABLE cafe.managers DROP COLUMN manager_phone;
COMMIT;

SELECT manager_name, phone_numbers
FROM cafe.managers
ORDER BY manager_name COLLATE "ru-x-icu";
