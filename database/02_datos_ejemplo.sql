USE veterinaria;

CALL sp_insertar_cliente('101110111', 'Ana',   '88881111');
CALL sp_insertar_cliente('202220222', 'Luis', '87772222');

CALL sp_insertar_mascota('M01', 'Luna',  'GATO',  18, '101110111');
CALL sp_insertar_mascota('M02', 'Rocky', 'PERRO', 20, '202220222');
CALL sp_insertar_mascota('M03', 'Marianon',  'PERRO', 19, '101110111');

CALL sp_listar_clientes();
CALL sp_listar_mascotas_con_dueno();
