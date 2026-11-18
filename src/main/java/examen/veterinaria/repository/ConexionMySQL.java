package examen.veterinaria.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class ConexionMySQL {
    public static final String VAR_URL = "VET_DB_URL";
    public static final String VAR_USUARIO = "VET_DB_USER";
    public static final String VAR_PASSWORD = "VET_DB_PASSWORD";

    private final String url;
    private final String usuario;
    private final String password;

    public ConexionMySQL(String url, String usuario, String password) {
        this.url = url;
        this.usuario = usuario;
        this.password = password;
    }

    public static ConexionMySQL VariablesEnv() {
        return new ConexionMySQL(System.getenv(VAR_URL), System.getenv(VAR_USUARIO), System.getenv(VAR_PASSWORD));
    }

    Connection abrir() throws SQLException {
        Verificar(VAR_URL, url);
        Verificar(VAR_USUARIO, usuario);
        Verificar(VAR_PASSWORD, password);
        return DriverManager.getConnection(url, usuario, password);
    }

    private static void Verificar(String variable, String valor) {
        if (valor == null || valor.isBlank())
            throw new PersistenciaException("Falta la variable de entorno " + variable, null);
    }
}
