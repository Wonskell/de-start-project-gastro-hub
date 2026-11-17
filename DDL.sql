-- Gastro Hub. Этап 1. Выполнять после загрузки дампа в raw_data.
-- Все шаги выполняются в одной транзакции.
BEGIN;

CREATE SCHEMA cafe;

-- Шаг 1. Тип заведения.
CREATE TYPE cafe.restaurant_type AS ENUM (
    'coffee_shop', 'restaurant', 'bar', 'pizzeria'
);

-- Шаг 2. Заведения и меню.
CREATE TABLE cafe.restaurants (
    restaurant_uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_name varchar NOT NULL UNIQUE,
    restaurant_type cafe.restaurant_type NOT NULL,
    menu jsonb
);

-- Шаг 3. Менеджеры. Телефон хранится как строка.
CREATE TABLE cafe.managers (
    manager_uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    manager_name varchar NOT NULL,
    manager_phone varchar NOT NULL,
    UNIQUE (manager_name, manager_phone)
);

-- Шаг 4. Границы периода включают первый и последний день работы.
CREATE TABLE cafe.restaurant_manager_work_dates (
    restaurant_uuid uuid NOT NULL REFERENCES cafe.restaurants (restaurant_uuid),
    manager_uuid uuid NOT NULL REFERENCES cafe.managers (manager_uuid),
    start_date date NOT NULL,
    end_date date NOT NULL,
    PRIMARY KEY (restaurant_uuid, manager_uuid),
    CHECK (end_date >= start_date)
);

-- Шаг 5. Средний чек заведения за день.
CREATE TABLE cafe.sales (
    date date NOT NULL,
    restaurant_uuid uuid NOT NULL REFERENCES cafe.restaurants (restaurant_uuid),
    avg_check numeric(6, 2) NOT NULL,
    PRIMARY KEY (date, restaurant_uuid)
);
COMMIT;
