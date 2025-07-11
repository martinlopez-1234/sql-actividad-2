-- Crear la base de datos
DROP DATABASE IF EXISTS countries_db;
CREATE DATABASE countries_db
  CHARACTER SET utf8
  COLLATE utf8_bin;

USE countries_db;

-- Crear tabla country
CREATE TABLE country (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, 
    capital VARCHAR(100) NOT NULL,
    language VARCHAR(100) NOT NULL,
    area FLOAT NOT NULL,
    population INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Crear tabla city
CREATE TABLE city (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    population INT NOT NULL,
    area FLOAT NOT NULL,
    postal_code VARCHAR(20),
    is_coastal BOOLEAN NOT NULL,
    id_country INT NOT NULL,
    FOREIGN KEY (id_country) REFERENCES country(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Insertar datos de prueba para country
INSERT INTO country (name, capital, language, area, population) VALUES
('Argentina', 'Buenos Aires', 'Spanish', 2780400, 45000000),
('Germany', 'Berlin', 'German', 357022, 83000000),
('Japan', 'Tokyo', 'Japanese', 377975, 126000000),
('Spain', 'Madrid', 'Spanish', 505990, 47000000),
('Brazil', 'Brasilia', 'Portuguese', 8515767, 215000000);

-- Insertar datos de prueba para city

INSERT INTO city (name, population, area, postal_code, is_coastal, id_country) VALUES
-- Argentina (ID asumido 1)
('Buenos Aires', 15000000, 203, 'C1000', TRUE, (SELECT id FROM country WHERE name = 'Argentina')),
('Mar del Plata', 650000, 78, 'B7600', TRUE, (SELECT id FROM country WHERE name = 'Argentina')),
('Cordoba', 1500000, 576, 'X5000', FALSE, (SELECT id FROM country WHERE name = 'Argentina')),
-- Germany (ID asumido 2)
('Berlin', 3700000, 891.8, '10115', FALSE, (SELECT id FROM country WHERE name = 'Germany')),
('Hamburg', 1850000, 755.2, '20095', TRUE, (SELECT id FROM country WHERE name = 'Germany')),
('Munich', 1500000, 310.7, '80331', FALSE, (SELECT id FROM country WHERE name = 'Germany')),
-- Japan (ID asumido 3)
('Tokyo', 14000000, 2194, '100-0001', TRUE, (SELECT id FROM country WHERE name = 'Japan')),
('Osaka', 2700000, 225.2, '530-0001', TRUE, (SELECT id FROM country WHERE name = 'Japan')),
-- Spain (ID asumido 4)
('Madrid', 3300000, 604.3, '28001', FALSE, (SELECT id FROM country WHERE name = 'Spain')),
('Barcelona', 1600000, 101.9, '08001', TRUE, (SELECT id FROM country WHERE name = 'Spain')),
-- Brazil (ID asumido 5)
('Rio de Janeiro', 6700000, 1221, '20000-000', TRUE, (SELECT id FROM country WHERE name = 'Brazil')),
('Sao Paulo', 12300000, 1521, '01000-000', FALSE, (SELECT id FROM country WHERE name = 'Brazil'));


-- Procedimientos Almacenados (ABM para country - Ejercicio 1)
DELIMITER //

-- Procedimiento: Obtener datos de un país por nombre
CREATE PROCEDURE country_get(IN p_name VARCHAR(100))
BEGIN
    SELECT * FROM country WHERE name = p_name;
END;
//

-- Procedimiento: Crear un país
CREATE PROCEDURE country_create(
    IN p_name VARCHAR(100),
    IN p_capital VARCHAR(100),
    IN p_language VARCHAR(100),
    IN p_area FLOAT,
    IN p_population INT
)
BEGIN
    INSERT INTO country (name, capital, language, area, population)
    VALUES (p_name, p_capital, p_language, p_area, p_population);
END;
//

-- Procedimiento: Editar un país
CREATE PROCEDURE country_update(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_capital VARCHAR(100),
    IN p_language VARCHAR(100),
    IN p_area FLOAT,
    IN p_population INT
)
BEGIN
    UPDATE country
    SET name = p_name,
        capital = p_capital,
        language = p_language,
        area = p_area,
        population = p_population
    WHERE id = p_id;
END;
//

-- Procedimiento: Eliminar un país
CREATE PROCEDURE country_delete(IN p_id INT)
BEGIN
    DELETE FROM country WHERE id = p_id;
END;
//

-- Procedimiento: Obtener datos de una ciudad por ID o nombre

CREATE PROCEDURE city_get(IN p_id INT)
BEGIN
    SELECT c.*, co.name AS country_name
    FROM city c
    JOIN country co ON c.id_country = co.id
    WHERE c.id = p_id;
END;
//

-- Procedimiento: Crear una ciudad
CREATE PROCEDURE city_create(
    IN p_name VARCHAR(100),
    IN p_population INT,
    IN p_area FLOAT,
    IN p_postal_code VARCHAR(20),
    IN p_is_coastal BOOLEAN,
    IN p_id_country INT
)
BEGIN
    INSERT INTO city (name, population, area, postal_code, is_coastal, id_country)
    VALUES (p_name, p_population, p_area, p_postal_code, p_is_coastal, p_id_country);
END;
//

-- Procedimiento: Editar una ciudad
CREATE PROCEDURE city_update(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_population INT,
    IN p_area FLOAT,
    IN p_postal_code VARCHAR(20),
    IN p_is_coastal BOOLEAN,
    IN p_id_country INT
)
BEGIN
    UPDATE city
    SET name = p_name,
        population = p_population,
        area = p_area,
        postal_code = p_postal_code,
        is_coastal = p_is_coastal,
        id_country = p_id_country
    WHERE id = p_id;
END;
//

-- Procedimiento: Eliminar una ciudad
CREATE PROCEDURE city_delete(IN p_id INT)
BEGIN
    DELETE FROM city WHERE id = p_id;
END;
//

-- 1. Mostrar el nombre del país que tiene la ciudad más poblada registrada en la base de datos.
CREATE PROCEDURE get_country_of_most_populous_city()
BEGIN
    SELECT co.name AS country_name
    FROM country co
    JOIN city c ON co.id = c.id_country
    ORDER BY c.population DESC
    LIMIT 1;
END;
//

-- 2. Obtener el conjunto de países que poseen ciudades costeras con más de 1 millón de habitantes.
CREATE PROCEDURE get_countries_with_coastal_cities_over_1m()
BEGIN
    SELECT DISTINCT co.name AS country_name
    FROM country co
    JOIN city c ON co.id = c.id_country
    WHERE c.is_coastal = TRUE AND c.population > 1000000;
END;
//

-- 3. Obtener el país y el nombre de la ciudad que posee la ciudad con la densidad de población más alta.
-- Densidad de población: Habitantes/Km^2
CREATE PROCEDURE get_city_with_highest_density()
BEGIN
    SELECT co.name AS country_name, c.name AS city_name, (c.population / c.area) AS population_density
    FROM country co
    JOIN city c ON co.id = c.id_country
    WHERE c.area > 0 -- Evitar división por cero
    ORDER BY (c.population / c.area) DESC
    LIMIT 1;
END;
//

DELIMITER ;

-- Fin del script
