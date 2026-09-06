using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TuProyecto.Models
{
    [Table("Maestro")]
    public class Example
    {
        [Key]
        public int IdMaestro { get; set; }

        [Required]
        public int IdCentro { get; set; }

        [StringLength(50)]
        public string? Nombre { get; set; }

        [StringLength(50)]
        public string? Apellido { get; set; }

        [StringLength(20)]
        public string? Cedula { get; set; }

        [StringLength(20)]
        public string? Telefono { get; set; }

        [StringLength(100)]
        [EmailAddress]
        public string? Email { get; set; }

        [Column(TypeName = "date")]
        public DateTime? FechaIngreso { get; set; }
    }
}