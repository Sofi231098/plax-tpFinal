-- =====================================================================
-- generate_dataset.sql
-- Genera: USERS -> STAYS -> STAY_FEATURE -> RESERVATIONS
-- =====================================================================

/* ============================================================
    1) PROCEDURE: GenerateUsers
   ============================================================ */
DELIMITER //

DROP PROCEDURE IF EXISTS GenerateUsers;

CREATE PROCEDURE GenerateUsers(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    -- Hash de la contraseña '12345678'
    DECLARE encrypted_password VARCHAR(255) 
        DEFAULT '$2a$12$3QmyP5Ad4l/o4082KVPpmuaqtzjEaDlSVE2zMeBILbykC17OJKBbi';

    START TRANSACTION;

    WHILE i < num_rows DO
        INSERT INTO users (id, email, firstname, lastname, password, role)
        VALUES (
            UUID_TO_BIN(UUID()), 
            CONCAT('user_', i, '@test.com'), 
            CONCAT('User', i), 
            'Test', 
            encrypted_password,
            'USER'
        );

        SET i = i + 1;

        IF (i % 5000 = 0) THEN
            COMMIT;
            START TRANSACTION;
        END IF;
    END WHILE;

    COMMIT;
END //



/* ============================================================
    2) PROCEDURE: GenerateStays
   ============================================================ */
DROP PROCEDURE IF EXISTS GenerateStays;

CREATE PROCEDURE GenerateStays(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE random_category_id BINARY(16);
    DECLARE last_address_id BINARY(16);

    -- Tabla temporal con IDs de categorías
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_categories (id BINARY(16));
    TRUNCATE TABLE temp_categories;
    INSERT INTO temp_categories SELECT id FROM categories;

    START TRANSACTION;

    WHILE i < num_rows DO
        -- 1) Dirección
        SET last_address_id = UUID_TO_BIN(UUID());

        INSERT INTO addresses (id, street, city, country)
        VALUES (
            last_address_id,
            CONCAT('Street ', i),
            (SELECT ELT(1 + FLOOR(RAND() * 5),
                        'Buenos Aires','Mendoza','Santa Fe','Neuquén','Córdoba')),
            (SELECT ELT(1 + FLOOR(RAND() * 2),
                        'Argentina','Brasil'))
        );

        -- 2) Categoría aleatoria
        SET random_category_id = (
            SELECT id FROM temp_categories ORDER BY RAND() LIMIT 1
        );

        -- 3) Stay
        INSERT INTO stays (id, appreciation, description, name, price, id_address, id_category)
        VALUES (
            UUID_TO_BIN(UUID()),
            ROUND(RAND() * 5, 1),
            CONCAT('Description for Stay ', i),
            CONCAT('Stay Name ', i),
            ROUND(20000 + (RAND() * 80000), 2),
            last_address_id,
            random_category_id
        );

        SET i = i + 1;

        IF (i % 5000 = 0) THEN
            COMMIT;
            START TRANSACTION;
        END IF;
    END WHILE;

    COMMIT;
    DROP TABLE temp_categories;
END //



/* ============================================================
    3) PROCEDURE: GenerateStayFeatures
   ============================================================ */
DROP PROCEDURE IF EXISTS GenerateStayFeatures;

CREATE PROCEDURE GenerateStayFeatures()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE current_stay_id BINARY(16);
    DECLARE done INT DEFAULT FALSE;
    DECLARE feature_limit INT;

    -- Cursor para recorrer todos los stays
    DECLARE stay_cursor CURSOR FOR SELECT id FROM stays;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Tabla temporal con features disponibles
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_features (id BINARY(16));
    TRUNCATE TABLE temp_features;
    INSERT INTO temp_features SELECT id FROM features;

    OPEN stay_cursor;

    START TRANSACTION;

    stay_loop: LOOP
        FETCH stay_cursor INTO current_stay_id;
        IF done THEN
            LEAVE stay_loop;
        END IF;

        -- Cantidad de features (entre 3 y 8)
        SET feature_limit = 3 + FLOOR(RAND() * 6);

        -- Inserto combinaciones nuevas; si se repiten, las ignora
        INSERT IGNORE INTO stay_feature (stay_id, feature_id)
        SELECT current_stay_id, id
        FROM temp_features
        ORDER BY RAND()
        LIMIT feature_limit;

        SET i = i + 1;

        IF (i % 5000 = 0) THEN
            COMMIT;
            START TRANSACTION;
        END IF;
    END LOOP;

    CLOSE stay_cursor;
    COMMIT;

    DROP TABLE temp_features;
END //



/* ============================================================
    4) PROCEDURE: GenerateReservations
   ============================================================ */
DROP PROCEDURE IF EXISTS GenerateReservations;

CREATE PROCEDURE GenerateReservations(IN num_reservations INT, IN num_stays INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE user_id BINARY(16);
    DECLARE stay_id BINARY(16);
    DECLARE price_per_night DECIMAL(10, 2);
    DECLARE check_in_date DATE;
    DECLARE check_out_date DATE;
    DECLARE total_price DECIMAL(10, 2);
    DECLARE num_nights INT;

    -- Usuarios de rol USER
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_users (
        id BINARY(16),
        row_num INT PRIMARY KEY
    );
    TRUNCATE TABLE temp_users;
    INSERT INTO temp_users (id, row_num)
    SELECT id, @rownum := @rownum + 1
    FROM users
    JOIN (SELECT @rownum := 0) r
    WHERE role = 'USER'
    LIMIT num_reservations;

    -- Stays
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_stays (
        id BINARY(16),
        price DECIMAL(10, 2),
        row_num INT PRIMARY KEY
    );
    TRUNCATE TABLE temp_stays;
    INSERT INTO temp_stays (id, price, row_num)
    SELECT id, price, @rownum2 := @rownum2 + 1
    FROM stays
    JOIN (SELECT @rownum2 := 0) r
    LIMIT num_stays;

    START TRANSACTION;

    WHILE i < num_reservations DO
        -- Usuario por índice
        SET user_id = (SELECT id FROM temp_users WHERE row_num = i + 1);

        -- Stay aleatorio
        SELECT id, price
        INTO stay_id, price_per_night
        FROM temp_stays
        ORDER BY RAND()
        LIMIT 1;

        -- Fechas y total
        SET check_in_date  = DATE_ADD(CURDATE(), INTERVAL 1 + FLOOR(RAND() * 180) DAY);
        SET num_nights     = 1 + FLOOR(RAND() * 7);
        SET check_out_date = DATE_ADD(check_in_date, INTERVAL num_nights DAY);
        SET total_price    = price_per_night * num_nights;

        INSERT INTO reservations (id, check_in, check_out, total, id_stay, id_user, confirmed, reviewed)
        VALUES (
            UUID_TO_BIN(UUID()),
            check_in_date,
            check_out_date,
            total_price,
            stay_id,
            user_id,
            ROUND(RAND()),  -- 0 o 1
            0
        );

        SET i = i + 1;

        IF (i % 5000 = 0) THEN
            COMMIT;
            START TRANSACTION;
        END IF;
    END WHILE;

    COMMIT;

    DROP TABLE temp_users;
    DROP TABLE temp_stays;
END //

DELIMITER ;



-- ============================================================
--  LLAMADAS EN ORDEN
-- ============================================================

CALL GenerateUsers(500000);
CALL GenerateStays(50000);
CALL GenerateStayFeatures();
CALL GenerateReservations(500000, 5000);

-- Limpieza de procedimientos (opcional)
DROP PROCEDURE IF EXISTS GenerateReservations;
DROP PROCEDURE IF EXISTS GenerateStayFeatures;
DROP PROCEDURE IF EXISTS GenerateStays;
DROP PROCEDURE IF EXISTS GenerateUsers;
