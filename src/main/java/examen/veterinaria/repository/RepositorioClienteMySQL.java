package examen.veterinaria.repository;

import examen.veterinaria.model.Cliente;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {
    private static final String SP_LISTAR = "{CALL sp_listar_clientes()}";
    private static final String SP_INSERTAR = "{CALL sp_insertar_cliente(?, ?, ?)}";

    private final ConexionMySQL conexion;

    public RepositorioClienteMySQL(ConexionMySQL conexion) {
        if (conexion == null) throw new IllegalArgumentException("La conexión es obligatoria.");
        this.conexion = conexion;
    }

    @Override
    public List<Cliente> cargarTodos() {
        List<Cliente> lista = new ArrayList<>();
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(SP_LISTAR);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
            return lista;
        } catch (SQLException e) {
            throw ErroresSQL.traducir("No se pudieron cargar los clientes", e);
        }
    }

    @Override
    public void insertar(Cliente cliente) {
        try (Connection cn = conexion.abrir();
             CallableStatement cs = cn.prepareCall(SP_INSERTAR)) {
            cs.setString(1, cliente.getCedula());
            cs.setString(2, cliente.getNombre());
            cs.setString(3, cliente.getTelefono());
            cs.execute();
        } catch (SQLException e) {
            throw ErroresSQL.traducir("No se pudo registrar el cliente", e);
        }
    }

    private static Cliente mapear(ResultSet rs) throws SQLException {
        return new Cliente(rs.getString("cedula"), rs.getString("nombre"), rs.getString("telefono"));
    }
}
