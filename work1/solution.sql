-- Задача 1

SELECT maker, motorcycle.model FROM `motorcycle` JOIN `vehicle` ON motorcycle.model = vehicle.model WHERE horsepower > 150

-- Задача 2

SELECT 
  v.maker, v.model, c.horsepower, c.engine_capacity, v.type 
FROM 
  `car` c JOIN `vehicle` v ON c.model = v.model 
WHERE 
  horsepower > 150 AND engine_capacity < 3.0 AND price < 35000

UNION

SELECT 
  v.maker, v.model, m.horsepower, m.engine_capacity, v.type 
FROM 
  `motorcycle` m JOIN `vehicle` v ON m.model = v.model 
WHERE 
  horsepower > 150 AND engine_capacity < 1.5 AND price < 20000

UNION

SELECT 
  v.maker, v.model, NULL AS horsepower, NULL AS engine_capacity, v.type 
FROM 
  `bicycle` b JOIN `vehicle` v ON b.model = v.model 
WHERE 
  gear_count > 18 AND price < 4000

ORDER BY ISNULL(horsepower), horsepower DESC