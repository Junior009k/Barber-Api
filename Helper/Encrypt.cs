using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace MiApi.Helper
{
    public class Encrypt
    {
        private readonly string _key;

        public Encrypt(string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                throw new ArgumentException("La clave no puede estar vacía.");

            _key = key;
        }

        // Encriptar
        public string Encriptar(string texto)
        {
            Console.WriteLine(texto);
            if (string.IsNullOrEmpty(texto))
                return texto;

            using (Aes aes = Aes.Create())
            {
                aes.Key = SHA256.HashData(Encoding.UTF8.GetBytes(_key));
                aes.GenerateIV();

                using (MemoryStream ms = new MemoryStream())
                {
                    // Guardamos el IV al principio
                    ms.Write(aes.IV, 0, aes.IV.Length);

                    using (CryptoStream cs = new CryptoStream(
                        ms,
                        aes.CreateEncryptor(),
                        CryptoStreamMode.Write))
                    {
                        byte[] datos = Encoding.UTF8.GetBytes(texto);

                        cs.Write(datos, 0, datos.Length);
                        cs.FlushFinalBlock();
                    }

                    return Convert.ToBase64String(ms.ToArray());
                }
            }
        }

        // Desencriptar
        public string Desencriptar(string textoEncriptado)
        {
            if (string.IsNullOrEmpty(textoEncriptado))
                return textoEncriptado;

            byte[] datos = Convert.FromBase64String(textoEncriptado);

            using (Aes aes = Aes.Create())
            {
                aes.Key = SHA256.HashData(Encoding.UTF8.GetBytes(_key));

                // Los primeros 16 bytes corresponden al IV
                byte[] iv = new byte[16];
                Array.Copy(datos, 0, iv, 0, iv.Length);

                aes.IV = iv;

                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(
                        ms,
                        aes.CreateDecryptor(),
                        CryptoStreamMode.Write))
                    {
                        cs.Write(datos, iv.Length, datos.Length - iv.Length);
                        cs.FlushFinalBlock();
                    }

                    return Encoding.UTF8.GetString(ms.ToArray());
                }
            }
        }
    }
}