-- Задача 1

SELECT 
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS hotel_list,
    ROUND(AVG(DATEDIFF(b.check_out_date, b.check_in_date)), 4) AS avg_stay_duration_days
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(DISTINCT r.ID_hotel) > 1
   AND COUNT(b.ID_booking) > 2
ORDER BY total_bookings DESC, c.name;

-- Задача 2

SELECT 
    c.ID_customer,
    c.name,
    COUNT(b.ID_booking) AS total_bookings,
    SUM(r.price) AS total_spent,
    COUNT(DISTINCT r.ID_hotel) AS unique_hotels
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
GROUP BY c.ID_customer, c.name
HAVING COUNT(b.ID_booking) > 2
   AND COUNT(DISTINCT r.ID_hotel) > 1
   AND SUM(r.price) > 500
ORDER BY total_spent ASC;

-- Задача 3

-- Определяем категорию каждого отеля
CREATE TEMPORARY TABLE hotel_category AS
SELECT 
    h.ID_hotel,
    h.name AS hotel_name,
    CASE 
        WHEN AVG(r.price) < 175 THEN 'Дешевый'
        WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
        ELSE 'Дорогой'
    END AS category
FROM Hotel h
JOIN Room r ON h.ID_hotel = r.ID_hotel
GROUP BY h.ID_hotel, h.name;

-- Для каждого клиента определяем категории отелей, которые он посещал
CREATE TEMPORARY TABLE customer_hotel_categories AS
SELECT 
    c.ID_customer,
    c.name,
    hc.category,
    hc.hotel_name
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN hotel_category hc ON r.ID_hotel = hc.ID_hotel
GROUP BY c.ID_customer, c.name, hc.category, hc.hotel_name;

-- Определяем предпочитаемый тип и список отелей
SELECT 
    ID_customer,
    name,
    CASE 
        WHEN SUM(CASE WHEN category = 'Дорогой' THEN 1 ELSE 0 END) > 0 THEN 'Дорогой'
        WHEN SUM(CASE WHEN category = 'Средний' THEN 1 ELSE 0 END) > 0 THEN 'Средний'
        ELSE 'Дешевый'
    END AS preferred_hotel_type,
    GROUP_CONCAT(DISTINCT hotel_name ORDER BY hotel_name SEPARATOR ', ') AS visited_hotels
FROM customer_hotel_categories
GROUP BY ID_customer, name
ORDER BY 
    CASE 
        WHEN SUM(CASE WHEN category = 'Дорогой' THEN 1 ELSE 0 END) > 0 THEN 3
        WHEN SUM(CASE WHEN category = 'Средний' THEN 1 ELSE 0 END) > 0 THEN 2
        ELSE 1
    END;

DROP TEMPORARY TABLE hotel_category;
DROP TEMPORARY TABLE customer_hotel_categories;