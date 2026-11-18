package examen.veterinaria.repository;

import java.sql.SQLException;

final class ErroresSQL {
    private ErroresSQL() { }

    static PersistenciaException traducir(String operacion, SQLException e) {
        String estado = e.getSQLState() == null ? "" : e.getSQLState();
        String detalle;
        if ("45000".equals(estado)) {
            detalle = e.getMessage();
        } else if (e.getErrorCode() == 1062) {
            detalle = "Ya existe un registro con esa clave (dato duplicado).";
        } else if (e.getErrorCode() == 1452) {
            detalle = "El cliente dueño no existe. Regístrelo primero.";
        } else if (e.getErrorCode() == 1451) {
            detalle = "No se puede eliminar: hay mascotas asociadas a ese cliente.";
        } else if (e.getErrorCode() == 3819 || e.getErrorCode() == 4025) {
            detalle = "Los datos no cumplen las reglas de la base (edad entre 18 y 60, campos no vacíos).";
        } else if (e.getErrorCode() == 1406) {
            detalle = "Uno de los campos supera la longitud permitida.";
        } else if (e.getErrorCode() == 1142 || e.getErrorCode() == 1370) {
            detalle = "El usuario de la aplicación no tiene permiso para esta operación.";
        } else if (e.getErrorCode() == 1045) {
            detalle = "Usuario o contraseña de MySQL incorrectos (revise VET_DB_USER y VET_DB_PASSWORD).";
        } else if (e.getErrorCode() == 1049) {
            detalle = "La base de datos indicada en VET_DB_URL no existe. Ejecute database/01_veterinaria.sql.";
        } else if (estado.startsWith("08")) {
            detalle = "No hay conexión con el servidor MySQL. Verifique que esté encendido y que VET_DB_URL sea correcta.";
        } else {
            detalle = e.getMessage();
        }
        return new PersistenciaException(operacion + ": " + detalle, e);
    }
}
