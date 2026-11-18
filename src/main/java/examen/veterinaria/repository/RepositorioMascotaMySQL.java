package examen.veterinaria.repository;

import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioMascotaMySQL implements RepositorioMascota {
    private static final String SP_LISTAR = "{CALL sp_listar_mascotas()}";
    private static final String SP_INSERTAR = "{CALL sp_insertar_mascota(?, ?, ?, ?, ?)}";
    private static final String SP_ACTUALIZAR = "{CALL sp_actualizar_mascota(?, ?, ?, ?, ?)}";
    private static final String SP_ELIMINAR = "{CALL sp_eliminar_mascota(?)}";
    private static final String SP_LISTAR_CON_DUENO = "{CALL sp_listar_mascotas_con_dueno()}";

    private final ConexionMySQL conexion;

    public RepositorioMascotaMySQL(ConexionMySQL conexion) {
        if (conexion == null) throw new IllegalArgumentException("La conexión es obligatoria.");
        this.conexion = conexion;
    }

    @Override
    public List<Mascota> cargarTodos() {
        List<Mascota> lista = new ArrayList<>();
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(SP_LISTAR);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
            return lista;
        } catch (SQLException e) {
            throw ErroresSQL.traducir("No se pudieron cargar las mascotas", e);
        }
    }

    @Override
    public void insertar(Mascota mascota) {
        ejecutarConDatos(SP_INSERTAR, mascota, "No se pudo registrar la mascota");
    }

    @Override
    public void actualizar(Mascota mascota) {
        ejecutarConDatos(SP_ACTUALIZAR, mascota, "No se pudo actualizar la mascota");
    }

    @Override
    public void eliminar(String codigo) {
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(SP_ELIMINAR)) {
            cs.setString(1, codigo);
            cs.execute();
        } catch (SQLException e) {
            throw ErroresSQL.traducir("No se pudo eliminar la mascota", e);
        }
    }

    @Override
    public List<String> listarConDueno() {
        List<String> filas = new ArrayList<>();
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(SP_LISTAR_CON_DUENO);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) filas.add(mapear(rs) + " | Cliente: " + rs.getString("nombre_cliente"));
            return filas;
        } catch (SQLException e) {
            throw ErroresSQL.traducir("No se pudo listar las mascotas con su dueño", e);
        }
    }

    private void ejecutarConDatos(String sql, Mascota m, String operacion) {
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(sql)) {
            cs.setString(1, m.getCodigo());
            cs.setString(2, m.getNombre());
            cs.setString(3, m.getEspecie().name());
            cs.setInt(4, m.getEdad());
            cs.setString(5, m.getCedulaCliente());
            cs.execute();
        } catch (SQLException e) {
            throw ErroresSQL.traducir(operacion, e);
        }
    }

    private static Mascota mapear(ResultSet rs) throws SQLException {
        String especie = rs.getString("especie");
        try {
            return new Mascota(rs.getString("codigo"), rs.getString("nombre"),
                    Especie.valueOf(especie), rs.getInt("edad"), rs.getString("cedula_cliente"));
        } catch (IllegalArgumentException e) {
            throw new PersistenciaException("Registro de mascota inválido en la base (especie " + especie + "): " + e.getMessage(), e);
        }
    }
}
