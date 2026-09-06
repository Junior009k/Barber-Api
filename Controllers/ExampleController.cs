using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using MiAPI.Data;
using TuProyecto.Models;

namespace TuProyecto.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExampleController : ControllerBase
    {
        private readonly DatabaseConnection _db;

        public ExampleController(DatabaseConnection db)
        {
            _db = db;
        }

        // GET
        [HttpGet]
        public async Task<IActionResult> Get()
        {
            List<Example> lista = new();

            using SqlConnection conn = await _db.OpenConnectionAsync();

            string sql = "SELECT * FROM Maestro";

            using SqlCommand cmd = new(sql, conn);

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                lista.Add(new Example
                {
                    IdMaestro = Convert.ToInt32(reader["IdMaestro"]),
                    IdCentro = Convert.ToInt32(reader["IdCentro"]),
                    Nombre = reader["Nombre"].ToString(),
                    Apellido = reader["Apellido"].ToString(),
                    Cedula = reader["Cedula"].ToString(),
                    Telefono = reader["Telefono"].ToString(),
                    Email = reader["Email"].ToString(),
                    FechaIngreso = Convert.ToDateTime(reader["FechaIngreso"])
                });
            }

            return Ok(lista);
        }

        // GET POR ID
        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            using SqlConnection conn = await _db.OpenConnectionAsync();

            string sql = "SELECT * FROM Maestro WHERE IdMaestro=@Id";

            using SqlCommand cmd = new(sql, conn);

            cmd.Parameters.AddWithValue("@Id", id);

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                Example maestro = new()
                {
                    IdMaestro = Convert.ToInt32(reader["IdMaestro"]),
                    IdCentro = Convert.ToInt32(reader["IdCentro"]),
                    Nombre = reader["Nombre"].ToString(),
                    Apellido = reader["Apellido"].ToString(),
                    Cedula = reader["Cedula"].ToString(),
                    Telefono = reader["Telefono"].ToString(),
                    Email = reader["Email"].ToString(),
                    FechaIngreso = Convert.ToDateTime(reader["FechaIngreso"])
                };

                return Ok(maestro);
            }

            return NotFound();
        }

        // INSERT
        [HttpPost]
        public async Task<IActionResult> Post(Example maestro)
        {
            using SqlConnection conn = await _db.OpenConnectionAsync();

            string sql = @"INSERT INTO Maestro
                          (IdCentro,Nombre,Apellido,Cedula,Telefono,Email,FechaIngreso)
                           VALUES
                          (@IdCentro,@Nombre,@Apellido,@Cedula,@Telefono,@Email,@FechaIngreso)";

            using SqlCommand cmd = new(sql, conn);

            cmd.Parameters.AddWithValue("@IdCentro", maestro.IdCentro);
            cmd.Parameters.AddWithValue("@Nombre", maestro.Nombre);
            cmd.Parameters.AddWithValue("@Apellido", maestro.Apellido);
            cmd.Parameters.AddWithValue("@Cedula", maestro.Cedula);
            cmd.Parameters.AddWithValue("@Telefono", maestro.Telefono);
            cmd.Parameters.AddWithValue("@Email", maestro.Email);
            cmd.Parameters.AddWithValue("@FechaIngreso", maestro.FechaIngreso);

            await cmd.ExecuteNonQueryAsync();

            return Ok("Maestro agregado correctamente.");
        }

        // UPDATE
        [HttpPut]
        public async Task<IActionResult> Put(Example maestro)
        {
            using SqlConnection conn = await _db.OpenConnectionAsync();

            string sql = @"UPDATE Maestro SET
                            IdCentro=@IdCentro,
                            Nombre=@Nombre,
                            Apellido=@Apellido,
                            Cedula=@Cedula,
                            Telefono=@Telefono,
                            Email=@Email,
                            FechaIngreso=@FechaIngreso
                            WHERE IdMaestro=@IdMaestro";

            using SqlCommand cmd = new(sql, conn);

            cmd.Parameters.AddWithValue("@IdMaestro", maestro.IdMaestro);
            cmd.Parameters.AddWithValue("@IdCentro", maestro.IdCentro);
            cmd.Parameters.AddWithValue("@Nombre", maestro.Nombre);
            cmd.Parameters.AddWithValue("@Apellido", maestro.Apellido);
            cmd.Parameters.AddWithValue("@Cedula", maestro.Cedula);
            cmd.Parameters.AddWithValue("@Telefono", maestro.Telefono);
            cmd.Parameters.AddWithValue("@Email", maestro.Email);
            cmd.Parameters.AddWithValue("@FechaIngreso", maestro.FechaIngreso);

            await cmd.ExecuteNonQueryAsync();

            return Ok("Maestro actualizado.");
        }

        // DELETE
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            using SqlConnection conn = await _db.OpenConnectionAsync();

            string sql = "DELETE FROM Maestro WHERE IdMaestro=@Id";

            using SqlCommand cmd = new(sql, conn);

            cmd.Parameters.AddWithValue("@Id", id);

            await cmd.ExecuteNonQueryAsync();

            return Ok("Maestro eliminado.");
        }
    }
}