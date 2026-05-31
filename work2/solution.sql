-- Задача 1

CREATE TEMPORARY TABLE car_avg_positions AS 
	SELECT c.name, c.class, AVG(r.position) AS avg_position, COUNT(r.race) AS race_count 
    FROM cars c JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class;
    
CREATE TEMPORARY TABLE min_avg_per_class AS
	SELECT class, MIN(avg_position) AS min_avg 
    FROM car_avg_positions 
    GROUP BY class;
    
SELECT 
	cap.name AS car_name,
	cap.class AS car_class,
    cap.avg_position,
    cap.race_count
FROM car_avg_positions cap JOIN min_avg_per_class mapc 
	ON cap.class = mapc.class AND cap.avg_position = mapc.min_avg
    ORDER BY cap.avg_position;
    
DROP TEMPORARY TABLE car_avg_positions;
DROP TEMPORARY TABLE min_avg_per_class;

-- Задача 2

SELECT 
	c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
GROUP BY c.class, c.name, cl.country
ORDER BY avg_position ASC, c.name ASC
LIMIT 1;

-- Задача 3

-- средняя позиция каждого автомобиля
CREATE TEMPORARY TABLE car_avg AS
SELECT 
    c.class,
    c.name,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS race_count
FROM Cars c
JOIN Results r ON c.name = r.car
GROUP BY c.class, c.name;

-- средняя позиция каждого класса
CREATE TEMPORARY TABLE class_avg AS
SELECT 
    class,
    AVG(avg_position) AS class_avg_position
FROM car_avg
GROUP BY class;

-- наименьшая средняя позиция среди классов
CREATE TEMPORARY TABLE min_class_avg AS
SELECT MIN(class_avg_position) AS min_avg
FROM class_avg;

-- классы с наименьшей средней позицией
CREATE TEMPORARY TABLE best_classes AS
SELECT class
FROM class_avg
WHERE class_avg_position = (SELECT min_avg FROM min_class_avg);

-- общее количество гонок для каждого класса
CREATE TEMPORARY TABLE class_total_races AS
SELECT 
    c.class,
    COUNT(r.race) AS total_races
FROM Cars c
JOIN Results r ON c.name = r.car
GROUP BY c.class;

-- финальный результат
SELECT 
	ca.name AS car_name,
    ca.class AS car_class,
    ca.avg_position,
    ca.race_count AS race_count,
    cl.country AS car_country,
    ctr.total_races AS total_races
FROM car_avg ca
JOIN best_classes bc ON ca.class = bc.class
JOIN Classes cl ON ca.class = cl.class
JOIN class_total_races ctr ON ca.class = ctr.class
ORDER BY ca.class, ca.name;

DROP TEMPORARY TABLE car_avg;
DROP TEMPORARY TABLE class_avg;
DROP TEMPORARY TABLE min_class_avg;
DROP TEMPORARY TABLE best_classes;
DROP TEMPORARY TABLE class_total_races;

-- Задача 4

-- средняя позиция каждого автомобиля
CREATE TEMPORARY TABLE car_avg AS
SELECT 
    c.class,
    c.name,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS race_count
FROM Cars c
JOIN Results r ON c.name = r.car
GROUP BY c.class, c.name;

-- средняя позиция каждого класса и количество автомобилей в классе
CREATE TEMPORARY TABLE class_stats AS
SELECT 
    class,
    AVG(avg_position) AS class_avg_position,
    COUNT(*) AS car_count
FROM car_avg
GROUP BY class;

-- выбираем автомобили с средней позицией лучше средней по классу
-- и только из классов, где минимум 2 автомобиля
SELECT 
    ca.name AS car_name,
    ca.class AS car_class,
    ca.avg_position,
    ca.race_count,
    cl.country
FROM car_avg ca
JOIN class_stats cs ON ca.class = cs.class
JOIN Classes cl ON ca.class = cl.class
WHERE cs.car_count >= 2
  AND ca.avg_position < cs.class_avg_position
ORDER BY ca.class, ca.avg_position;

DROP TEMPORARY TABLE car_avg;
DROP TEMPORARY TABLE class_stats;

-- Задача 5

-- автомобили с низкой средней позицией (> 3.0)
CREATE TEMPORARY TABLE low_avg_cars AS
SELECT 
    c.class,
    c.name,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS car_race_count
FROM Cars c
JOIN Results r ON c.name = r.car
GROUP BY c.class, c.name
HAVING AVG(r.position) > 3.0;

-- количество таких автомобилей по классам
CREATE TEMPORARY TABLE low_cars_count AS
SELECT 
    class,
    COUNT(*) AS low_position_count
FROM low_avg_cars
GROUP BY class;

-- максимальное количество
CREATE TEMPORARY TABLE max_low_count AS
SELECT MAX(low_position_count) AS max_count
FROM low_cars_count;

-- классы с максимальным количеством
CREATE TEMPORARY TABLE best_classes AS
SELECT class
FROM low_cars_count
WHERE low_position_count = (SELECT max_count FROM max_low_count);

-- общее количество гонок для каждого класса
CREATE TEMPORARY TABLE class_total_races AS
SELECT 
    c.class,
    COUNT(r.race) AS total_races
FROM Cars c
JOIN Results r ON c.name = r.car
GROUP BY c.class;

-- финальный результат
SELECT 
    lac.name AS car_name,
    lac.class AS car_class,
    lac.avg_position,
    lac.car_race_count AS race_count,
    cl.country,
    ctr.total_races,
    lcc.low_position_count
FROM low_avg_cars lac
JOIN best_classes bc ON lac.class = bc.class
JOIN Classes cl ON lac.class = cl.class
JOIN class_total_races ctr ON lac.class = ctr.class
JOIN low_cars_count lcc ON lac.class = lcc.class
ORDER BY lcc.low_position_count DESC, lac.class, lac.name;

DROP TEMPORARY TABLE low_avg_cars;
DROP TEMPORARY TABLE low_cars_count;
DROP TEMPORARY TABLE max_low_count;
DROP TEMPORARY TABLE best_classes;
DROP TEMPORARY TABLE class_total_races;