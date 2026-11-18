DROP DATABASE IF EXISTS veterinaria;
CREATE DATABASE veterinaria
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE veterinaria;

CREATE TABLE cliente (
    cedula   VARCHAR(20) NOT NULL,
    nombre   VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (cedula),
    CONSTRAINT chk_cliente_cedula   CHECK (CHAR_LENGTH(TRIM(cedula))   > 0),
    CONSTRAINT chk_cliente_nombre   CHECK (CHAR_LENGTH(TRIM(nombre))   > 0),
    CONSTRAINT chk_cliente_telefono CHECK (CHAR_LENGTH(TRIM(telefono)) > 0)
) ENGINE = InnoDB;

CREATE TABLE mascota (
    codigo         VARCHAR(15) NOT NULL,
    nombre         VARCHAR(80) NOT NULL,
    especie        ENUM('PERRO','GATO','OTRO') NOT NULL,
    edad           INT NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,
    CONSTRAINT pk_mascota PRIMARY KEY (codigo),
    CONSTRAINT chk_mascota_codigo CHECK (CHAR_LENGTH(TRIM(codigo)) > 0),
    CONSTRAINT chk_mascota_nombre CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT chk_mascota_edad   CHECK (edad BETWEEN 18 AND 60),
    CONSTRAINT fk_mascota_cliente FOREIGN KEY (cedula_cliente)
        REFERENCES cliente (cedula)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE = InnoDB;

CREATE INDEX idx_mascota_cedula_cliente ON mascota (cedula_cliente);

DROP USER IF EXISTS 'vet_app'@'localhost';
DROP USER IF EXISTS 'vet_definer'@'localhost';

CREATE USER 'vet_definer'@'localhost'
    IDENTIFIED BY 'CAMBIAR PASSWORD DEFINER'
    ACCOUNT LOCK;

CREATE USER 'vet_app'@'localhost'
    IDENTIFIED BY 'CAMBIAR PASSWORD APP';

GRANT SELECT, INSERT ON veterinaria.cliente TO 'vet_definer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria.mascota TO 'vet_definer'@'localhost';

DROP PROCEDURE IF EXISTS sp_listar_clientes;
DROP PROCEDURE IF EXISTS sp_insertar_cliente;
DROP PROCEDURE IF EXISTS sp_listar_mascotas;
DROP PROCEDURE IF EXISTS sp_insertar_mascota;
DROP PROCEDURE IF EXISTS sp_actualizar_mascota;
DROP PROCEDURE IF EXISTS sp_eliminar_mascota;
DROP PROCEDURE IF EXISTS sp_listar_mascotas_con_dueno;

DELIMITER $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_listar_clientes()
    SQL SECURITY DEFINER
    READS SQL DATA
BEGIN
    SELECT cedula, nombre, telefono
      FROM cliente
     ORDER BY nombre;
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_insertar_cliente(
    IN p_cedula   VARCHAR(20),
    IN p_nombre   VARCHAR(80),
    IN p_telefono VARCHAR(20))
    SQL SECURITY DEFINER
    MODIFIES SQL DATA
BEGIN
    INSERT INTO cliente (cedula, nombre, telefono)
    VALUES (TRIM(p_cedula), TRIM(p_nombre), TRIM(p_telefono));
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_listar_mascotas()
    SQL SECURITY DEFINER
    READS SQL DATA
BEGIN
    SELECT codigo, nombre, especie, edad, cedula_cliente
      FROM mascota
     ORDER BY codigo;
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_insertar_mascota(
    IN p_codigo         VARCHAR(15),
    IN p_nombre         VARCHAR(80),
    IN p_especie        VARCHAR(10),
    IN p_edad           INT,
    IN p_cedula_cliente VARCHAR(20))
    SQL SECURITY DEFINER
    MODIFIES SQL DATA
BEGIN
    IF p_especie IS NULL OR UPPER(p_especie) NOT IN ('PERRO','GATO','OTRO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Especie inválida: use PERRO, GATO u OTRO.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cedula = TRIM(p_cedula_cliente)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente dueño no existe. Regístrelo primero.';
    END IF;
    INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente)
    VALUES (TRIM(p_codigo), TRIM(p_nombre), UPPER(p_especie), p_edad, TRIM(p_cedula_cliente));
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_actualizar_mascota(
    IN p_codigo         VARCHAR(15),
    IN p_nombre         VARCHAR(80),
    IN p_especie        VARCHAR(10),
    IN p_edad           INT,
    IN p_cedula_cliente VARCHAR(20))
    SQL SECURITY DEFINER
    MODIFIES SQL DATA
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE codigo = TRIM(p_codigo)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe la mascota que desea actualizar.';
    END IF;
    IF p_especie IS NULL OR UPPER(p_especie) NOT IN ('PERRO','GATO','OTRO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Especie inválida: use PERRO, GATO u OTRO.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cedula = TRIM(p_cedula_cliente)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente dueño no existe. Regístrelo primero.';
    END IF;
    UPDATE mascota
       SET nombre         = TRIM(p_nombre),
           especie        = UPPER(p_especie),
           edad           = p_edad,
           cedula_cliente = TRIM(p_cedula_cliente)
     WHERE codigo = TRIM(p_codigo);
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_eliminar_mascota(
    IN p_codigo VARCHAR(15))
    SQL SECURITY DEFINER
    MODIFIES SQL DATA
BEGIN
    DELETE FROM mascota WHERE codigo = TRIM(p_codigo);
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe la mascota que desea eliminar.';
    END IF;
END $$

CREATE DEFINER = 'vet_definer'@'localhost' PROCEDURE sp_listar_mascotas_con_dueno()
    SQL SECURITY DEFINER
    READS SQL DATA
BEGIN
    SELECT m.codigo,
           m.nombre,
           m.especie,
           m.edad,
           m.cedula_cliente,
           c.nombre AS nombre_cliente
      FROM mascota m
     INNER JOIN cliente c ON c.cedula = m.cedula_cliente
     ORDER BY m.codigo;
END $$

DELIMITER ;

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes           TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente          TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas           TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota          TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota        TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota          TO 'vet_definer'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno TO 'vet_definer'@'localhost';

GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes           TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente          TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas           TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota          TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota        TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota          TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno TO 'vet_app'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'vet_definer'@'localhost';
SHOW GRANTS FOR 'vet_app'@'localhost';

SELECT ROUTINE_NAME, DEFINER, SECURITY_TYPE
  FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA = 'veterinaria'
 ORDER BY ROUTINE_NAME;
