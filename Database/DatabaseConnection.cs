using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using MiApi.Helper;

namespace MiAPI.Data
{
    public class DatabaseConnection
    {
        private readonly string _connectionString;

        public DatabaseConnection(IConfiguration configuration)
        {
            string connectionString =
                 configuration.GetConnectionString("DefaultConnection")
                 ?? throw new Exception("No se encontró la cadena de conexión.");

            bool encryptionEnabled =
                configuration.GetValue<bool>("Encryption:Enabled");
            Console.WriteLine(connectionString);
            if (encryptionEnabled)
            {
                string key =
                    configuration["Encryption:Key"]
                    ?? throw new Exception("No se encontró la clave de encriptación.");

                Encrypt encrypt = new Encrypt(key);

                _connectionString = encrypt.Desencriptar(connectionString);
            }
            else
            {
                string key =
                    configuration["Encryption:Key"]
                    ?? throw new Exception("No se encontró la clave de encriptación.");

                Encrypt encrypt = new Encrypt(key);
                string test = encrypt.Encriptar(connectionString);
               // System.Diagnostics.Debug.WriteLine(test);
                _connectionString = connectionString;
            }
        }

        public SqlConnection GetConnection()
        {
            return new SqlConnection(_connectionString);
        }

        public string TestConnection()
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            conn.Open();
            return "Conexión exitosa";
        }

        public async Task<SqlConnection> OpenConnectionAsync()
        {
           // System.Diagnostics.Debug.WriteLine(_connectionString);
            SqlConnection connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            return connection;
        }
    }
}