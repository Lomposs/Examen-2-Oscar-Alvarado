USE veterinaria;

CALL sp_listar_mascotas();

SELECT * FROM mascota;

INSERT INTO cliente (cedula, nombre, telefono) VALUES ('999', 'Josue', '000');
DELETE FROM mascota;

CALL sp_insertar_cliente('101110111', 'Duplicado', '80000000');

CALL sp_insertar_mascota('M99', 'Fantasma', 'GATO', 20, '000000000');

CALL sp_insertar_mascota('M98', 'Edad mala', 'PERRO', 5, '101110111');

CALL sp_actualizar_mascota('NOEXISTE', 'X', 'OTRO', 20, '101110111');
CALL sp_eliminar_mascota('NOEXISTE');

DROP TABLE mascota;

CALL sp_listar_mascotas_con_dueno();
