En la carpeta `database` están los scripts:

- `01_veterinaria.sql`: crea la base, las tablas `cliente` y `mascota`, los usuarios y los procedimientos. Se corre como root.
- `02_datos_ejemplo.sql`: inserta unos datos de prueba. Se corre con el usuario `vet_app`.
- `03_pruebas_seguridad.sql`: pruebas para ver que `vet_app` solo puede ejecutar los procedimientos.

Antes de correr el primer script hay que cambiar `CAMBIAR_PASSWORD_DEFINER` y `CAMBIAR_PASSWORD_APP` por contraseñas reales.


Un cliente puede tener varias mascotas, por eso `mascota` tiene la cédula del cliente como llave.

Usuarios:
- `vet_definer`: dueño de los procedimientos, la cuenta está bloqueada.
- `vet_app`: el que usa Java, solo tiene permiso de EXECUTE.

## Cómo correrlo

1. Abrir el proyecto en IntelliJ.
2. En la configuración de ejecución de `Main` poner estas variables de entorno:

```
VET_DB_URL=jdbc:mysql://localhost:3306/veterinaria?serverTimezone=UTC
VET_DB_USER=vet_app
VET_DB_PASSWORD=la contraseña de vet_app
```

3. Ejecutar `examen.veterinaria.Main`.

Si falta alguna variable o MySQL no está encendido, la app muestra un mensaje de error.

La VET_DB_PASSWORD debe ser la misma que en CAMBIAR_PASSWORD_APP para que pueda entrar sin problemas con el usuario vet_app.
