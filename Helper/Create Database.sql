/* ============================================================
   BASE DE DATOS
   ============================================================ */


CREATE DATABASE myBarberDB;
GO

USE myBarberDB;
GO


/* ============================================================
   TABLA: Barbero
   ============================================================ */

CREATE TABLE Barbero
(
    IdBarbero INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(100),
    Especialidad VARCHAR(100),
    FechaIngreso DATE DEFAULT GETDATE()
);
GO


/* ============================================================
   TABLA: Cliente
   ============================================================ */

CREATE TABLE Cliente
(
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(100),
    Direccion VARCHAR(150),
    FechaRegistro DATE DEFAULT GETDATE()
);
GO


/* ============================================================
   TABLA: Servicio
   ============================================================ */

CREATE TABLE Servicio
(
    IdServicio INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250),
    Precio DECIMAL(10,2) NOT NULL,
    DuracionMinutos INT,
    Activo BIT DEFAULT 1
);
GO


/* ============================================================
   TABLA: Factura
   Barbero 1 - * Factura
   Cliente 1 - * Factura
   Servicio * - 1 Factura
   ============================================================ */

CREATE TABLE Factura
(
    IdFactura INT IDENTITY(1,1) PRIMARY KEY,

    IdBarbero INT NOT NULL,
    IdCliente INT NOT NULL,
    IdServicio INT NOT NULL,

    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Cantidad INT NOT NULL DEFAULT 1,
    Subtotal DECIMAL(10,2) NOT NULL,
    Impuesto DECIMAL(10,2) DEFAULT 0,
    Total DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Factura_Barbero
        FOREIGN KEY (IdBarbero)
        REFERENCES Barbero(IdBarbero),

    CONSTRAINT FK_Factura_Cliente
        FOREIGN KEY (IdCliente)
        REFERENCES Cliente(IdCliente),

    CONSTRAINT FK_Factura_Servicio
        FOREIGN KEY (IdServicio)
        REFERENCES Servicio(IdServicio)
);
GO


/* ============================================================
   TABLA: Inventario
   ============================================================ */

CREATE TABLE Inventario
(
    IdInventario INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250),
    FechaActualizacion DATETIME DEFAULT GETDATE()
);
GO


/* ============================================================
   TABLA: Producto
   Inventario 1 - * Producto
   ============================================================ */

CREATE TABLE Producto
(
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,

    IdInventario INT NOT NULL,

    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250),
    Cantidad INT NOT NULL DEFAULT 0,
    Precio DECIMAL(10,2) NOT NULL,
    Marca VARCHAR(100),
    Activo BIT DEFAULT 1,

    CONSTRAINT FK_Producto_Inventario
        FOREIGN KEY (IdInventario)
        REFERENCES Inventario(IdInventario)
);
GO


/* ============================================================
   TABLA: ServicioFisico
   ============================================================ */

CREATE TABLE ServicioFisico
(
    IdServicioFisico INT IDENTITY(1,1) PRIMARY KEY,

    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250),
    Precio DECIMAL(10,2) NOT NULL,
    DuracionMinutos INT,
    Activo BIT DEFAULT 1
);
GO


/* ============================================================
   RELACIÓN PRODUCTO 1 - * SERVICIO
   Un producto puede utilizarse en varios servicios.
   ============================================================ */

CREATE TABLE ProductoServicio
(
    IdProductoServicio INT IDENTITY(1,1) PRIMARY KEY,

    IdProducto INT NOT NULL,
    IdServicio INT NOT NULL,

    CantidadUtilizada DECIMAL(10,2) DEFAULT 1,

    CONSTRAINT FK_ProductoServicio_Producto
        FOREIGN KEY (IdProducto)
        REFERENCES Producto(IdProducto),

    CONSTRAINT FK_ProductoServicio_Servicio
        FOREIGN KEY (IdServicio)
        REFERENCES Servicio(IdServicio)
);
GO


/* ============================================================
   TABLA: [User]
   
   Un usuario puede ser:
   - Cliente
   - Barbero

   TipoUsuario:
   CLIENTE
   BARBERO
   ============================================================ */

CREATE TABLE [User]
(
    IdUser INT IDENTITY(1,1) PRIMARY KEY,

    IdCliente INT NULL,
    IdBarbero INT NULL,

    Username VARCHAR(50) NOT NULL UNIQUE,
    TipoUsuario VARCHAR(20) NOT NULL,

    Activo BIT DEFAULT 1,

    CONSTRAINT FK_User_Cliente
        FOREIGN KEY (IdCliente)
        REFERENCES Cliente(IdCliente),

    CONSTRAINT FK_User_Barbero
        FOREIGN KEY (IdBarbero)
        REFERENCES Barbero(IdBarbero),

    CONSTRAINT CK_User_Tipo
        CHECK (TipoUsuario IN ('CLIENTE', 'BARBERO'))
);
GO


/* ============================================================
   TABLA: [Password]
   User 1 - * Password
   ============================================================ */

CREATE TABLE [Password]
(
    IdPassword INT IDENTITY(1,1) PRIMARY KEY,

    IdUser INT NOT NULL,

    PasswordHash VARCHAR(255) NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1,

    CONSTRAINT FK_Password_User
        FOREIGN KEY (IdUser)
        REFERENCES [User](IdUser)
);
GO


/* ============================================================
   TABLA: Agenda
   User(Barbero) 1 - 1 Agenda
   ============================================================ */

CREATE TABLE Agenda
(
    IdAgenda INT IDENTITY(1,1) PRIMARY KEY,

    IdUser INT NOT NULL UNIQUE,

    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,
    DiasTrabajo VARCHAR(100),

    Activa BIT DEFAULT 1,

    CONSTRAINT FK_Agenda_User
        FOREIGN KEY (IdUser)
        REFERENCES [User](IdUser)
);
GO


/* ============================================================
   TABLA: Cita
   Servicio * - 1 Cita
   User(Barbero) 1 - * Cita
   User(Cliente) 1 - * Cita
   ============================================================ */

CREATE TABLE Cita
(
    IdCita INT IDENTITY(1,1) PRIMARY KEY,

    IdUserBarbero INT NOT NULL,
    IdUserCliente INT NOT NULL,
    IdServicio INT NOT NULL,

    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,

    Detalle VARCHAR(500),
    Estado VARCHAR(30) DEFAULT 'PENDIENTE',

    FechaCreacion DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Cita_UserBarbero
        FOREIGN KEY (IdUserBarbero)
        REFERENCES [User](IdUser),

    CONSTRAINT FK_Cita_UserCliente
        FOREIGN KEY (IdUserCliente)
        REFERENCES [User](IdUser),

    CONSTRAINT FK_Cita_Servicio
        FOREIGN KEY (IdServicio)
        REFERENCES Servicio(IdServicio),

    CONSTRAINT CK_Cita_Estado
        CHECK (Estado IN
        (
            'PENDIENTE',
            'CONFIRMADA',
            'ATENDIDA',
            'CANCELADA'
        ))
);
GO


/* ============================================================
   INSERTAR BARBEROS
   ============================================================ */

INSERT INTO Barbero
(
    Nombre,
    Apellido,
    Telefono,
    Email,
    Especialidad,
    FechaIngreso
)
VALUES
('Carlos', 'Rodriguez', '809-555-1001',
 'carlos@mybarber.com', 'Cortes clásicos', '2025-01-15'),

('Miguel', 'Martinez', '809-555-1002',
 'miguel@mybarber.com', 'Fade y degradados', '2025-02-10'),

('Juan', 'Perez', '809-555-1003',
 'juan@mybarber.com', 'Barba y diseño', '2025-03-20'),

('Daniel', 'Gomez', '809-555-1004',
 'daniel@mybarber.com', 'Corte ejecutivo', '2025-04-05'),

('Luis', 'Hernandez', '809-555-1005',
 'luis@mybarber.com', 'Diseño y color', '2025-05-12');
GO


/* ============================================================
   INSERTAR CLIENTES
   ============================================================ */

INSERT INTO Cliente
(
    Nombre,
    Apellido,
    Telefono,
    Email,
    Direccion,
    FechaRegistro
)
VALUES
('Pedro', 'Ramirez', '809-555-2001',
 'pedro@gmail.com', 'Santo Domingo', '2026-01-10'),

('Jose', 'Castillo', '809-555-2002',
 'jose@gmail.com', 'Santo Domingo Este', '2026-01-15'),

('Andres', 'Santos', '809-555-2003',
 'andres@gmail.com', 'Santo Domingo Norte', '2026-02-05'),

('Fernando', 'Diaz', '809-555-2004',
 'fernando@gmail.com', 'Los Alcarrizos', '2026-02-20'),

('Ricardo', 'Morales', '809-555-2005',
 'ricardo@gmail.com', 'Santo Domingo', '2026-03-01'),

('Alejandro', 'Torres', '809-555-2006',
 'alejandro@gmail.com', 'Gazcue', '2026-03-10'),

('Gabriel', 'Jimenez', '809-555-2007',
 'gabriel@gmail.com', 'Piantini', '2026-03-15'),

('Manuel', 'Cruz', '809-555-2008',
 'manuel@gmail.com', 'Naco', '2026-04-01');
GO


/* ============================================================
   INSERTAR SERVICIOS
   ============================================================ */

INSERT INTO Servicio
(
    Nombre,
    Descripcion,
    Precio,
    DuracionMinutos,
    Activo
)
VALUES
('Corte clásico',
 'Corte tradicional con máquina y tijera',
 500.00, 30, 1),

('Corte Fade',
 'Degradado profesional',
 700.00, 45, 1),

('Corte + Barba',
 'Corte de cabello y arreglo de barba',
 900.00, 60, 1),

('Barba',
 'Perfilado y arreglo completo de barba',
 400.00, 30, 1),

('Corte ejecutivo',
 'Corte elegante para oficina',
 800.00, 45, 1),

('Diseño',
 'Diseño personalizado en el cabello',
 1000.00, 60, 1),

('Corte infantil',
 'Corte para niños',
 400.00, 30, 1),

('Lavado de cabello',
 'Lavado profesional',
 250.00, 15, 1);
GO


/* ============================================================
   INSERTAR SERVICIOS FÍSICOS
   ============================================================ */

INSERT INTO ServicioFisico
(
    Nombre,
    Descripcion,
    Precio,
    DuracionMinutos
)
VALUES
('Lavado Premium',
 'Lavado con shampoo especializado',
 300.00, 20),

('Tratamiento Capilar',
 'Tratamiento hidratante',
 600.00, 30),

('Masaje Capilar',
 'Masaje relajante del cuero cabelludo',
 400.00, 20);
GO


/* ============================================================
   INVENTARIO
   ============================================================ */

INSERT INTO Inventario
(
    Nombre,
    Descripcion
)
VALUES
('Inventario Principal',
 'Productos utilizados en la barbería'),

('Productos de Limpieza',
 'Productos utilizados para limpieza'),

('Productos Capilares',
 'Productos para cabello y barba');
GO


/* ============================================================
   PRODUCTOS
   ============================================================ */

INSERT INTO Producto
(
    IdInventario,
    Nombre,
    Descripcion,
    Cantidad,
    Precio,
    Marca
)
VALUES
(1, 'Máquina de cortar cabello',
 'Máquina profesional',
 10, 3500.00, 'Wahl'),

(1, 'Navaja profesional',
 'Navaja para barbería',
 20, 750.00, 'Andis'),

(1, 'Tijera profesional',
 'Tijera de corte',
 15, 1800.00, 'Jaguar'),

(3, 'Shampoo',
 'Shampoo profesional',
 30, 450.00, 'American Crew'),

(3, 'Gel',
 'Gel fijador',
 25, 350.00, 'Gatsby'),

(3, 'Cera',
 'Cera para cabello',
 20, 500.00, 'Reuzel'),

(3, 'Aceite para barba',
 'Aceite hidratante',
 25, 600.00, 'Proraso'),

(2, 'Alcohol',
 'Alcohol para desinfección',
 40, 250.00, 'Genérico'),

(2, 'Guantes',
 'Guantes desechables',
 100, 50.00, 'Genérico');
GO


/* ============================================================
   PRODUCTO - SERVICIO
   ============================================================ */

INSERT INTO ProductoServicio
(
    IdProducto,
    IdServicio,
    CantidadUtilizada
)
VALUES
(4, 1, 0.10),
(4, 2, 0.15),
(4, 3, 0.15),
(4, 8, 0.10),

(5, 2, 0.05),
(5, 6, 0.10),

(6, 2, 0.05),
(6, 5, 0.05),
(6, 6, 0.10),

(7, 4, 0.10),
(7, 3, 0.10),

(8, 1, 0.02),
(8, 2, 0.03),
(8, 3, 0.03),
(8, 4, 0.02);
GO


/* ============================================================
   USUARIOS DE BARBEROS
   ============================================================ */

INSERT INTO [User]
(
    IdBarbero,
    Username,
    TipoUsuario
)
VALUES
(1, 'carlos.barber', 'BARBERO'),
(2, 'miguel.barber', 'BARBERO'),
(3, 'juan.barber', 'BARBERO'),
(4, 'daniel.barber', 'BARBERO'),
(5, 'luis.barber', 'BARBERO');
GO


/* ============================================================
   USUARIOS DE CLIENTES
   ============================================================ */

INSERT INTO [User]
(
    IdCliente,
    Username,
    TipoUsuario
)
VALUES
(1, 'pedro.ramirez', 'CLIENTE'),
(2, 'jose.castillo', 'CLIENTE'),
(3, 'andres.santos', 'CLIENTE'),
(4, 'fernando.diaz', 'CLIENTE'),
(5, 'ricardo.morales', 'CLIENTE'),
(6, 'alejandro.torres', 'CLIENTE'),
(7, 'gabriel.jimenez', 'CLIENTE'),
(8, 'manuel.cruz', 'CLIENTE');
GO


/* ============================================================
   PASSWORD
   NOTA:
   Estos son valores de ejemplo.
   En una aplicación real se deben almacenar hashes.
   ============================================================ */

INSERT INTO [Password]
(
    IdUser,
    PasswordHash
)
VALUES
(1, 'HASH_CARLOS_123'),
(2, 'HASH_MIGUEL_123'),
(3, 'HASH_JUAN_123'),
(4, 'HASH_DANIEL_123'),
(5, 'HASH_LUIS_123'),

(6, 'HASH_PEDRO_123'),
(7, 'HASH_JOSE_123'),
(8, 'HASH_ANDRES_123'),
(9, 'HASH_FERNANDO_123'),
(10, 'HASH_RICARDO_123'),
(11, 'HASH_ALEJANDRO_123'),
(12, 'HASH_GABRIEL_123'),
(13, 'HASH_MANUEL_123');
GO


/* ============================================================
   AGENDA
   Solo los usuarios que son BARBEROS.
   User(Barbero) 1 - 1 Agenda
   ============================================================ */

INSERT INTO Agenda
(
    IdUser,
    HoraInicio,
    HoraFin,
    DiasTrabajo
)
VALUES
(1, '09:00', '18:00', 'Lunes-Martes-Miercoles-Jueves-Viernes'),

(2, '10:00', '19:00', 'Lunes-Martes-Miercoles-Jueves-Viernes'),

(3, '09:00', '17:00', 'Martes-Miercoles-Jueves-Viernes-Sabado'),

(4, '11:00', '20:00', 'Lunes-Miercoles-Jueves-Viernes-Sabado'),

(5, '09:00', '18:00', 'Lunes-Martes-Jueves-Viernes-Sabado');
GO


/* ============================================================
   CITAS
   ============================================================ */

INSERT INTO Cita
(
    IdUserBarbero,
    IdUserCliente,
    IdServicio,
    Fecha,
    Hora,
    Detalle,
    Estado
)
VALUES

(1, 6, 1,
 '2026-09-07', '10:00',
 'Corte clásico', 'CONFIRMADA'),

(2, 7, 2,
 '2026-09-07', '11:00',
 'Fade bajo', 'PENDIENTE'),

(3, 8, 4,
 '2026-09-08', '09:30',
 'Perfilado de barba', 'CONFIRMADA'),

(4, 9, 5,
 '2026-09-08', '12:00',
 'Corte ejecutivo', 'PENDIENTE'),

(5, 10, 6,
 '2026-09-09', '15:00',
 'Diseño personalizado', 'CONFIRMADA'),

(1, 11, 3,
 '2026-09-09', '16:00',
 'Corte y barba', 'PENDIENTE'),

(2, 12, 2,
 '2026-09-10', '10:30',
 'Fade medio', 'CONFIRMADA'),

(3, 13, 4,
 '2026-09-10', '14:00',
 'Arreglo de barba', 'PENDIENTE'),

(4, 6, 1,
 '2026-09-11', '11:00',
 'Corte clásico', 'CONFIRMADA'),

(5, 7, 3,
 '2026-09-12', '13:00',
 'Corte + barba', 'PENDIENTE');
GO


/* ============================================================
   FACTURAS
   ============================================================ */
INSERT INTO Factura
(
    IdBarbero,
    IdCliente,
    IdServicio,
    Fecha,
    Cantidad,
    Subtotal,
    Impuesto,
    Total
)
VALUES
(1, 1, 1, '2026-08-20T10:30:00', 1, 500.00, 90.00, 590.00),
(2, 2, 2, '2026-08-21T11:00:00', 1, 700.00, 126.00, 826.00),
(3, 3, 4, '2026-08-22T14:00:00', 1, 400.00, 72.00, 472.00),
(4, 4, 5, '2026-08-23T16:00:00', 1, 800.00, 144.00, 944.00),
(5, 5, 6, '2026-08-24T12:00:00', 1, 1000.00, 180.00, 1180.00),
(1, 6, 3, '2026-08-25T13:00:00', 1, 900.00, 162.00, 1062.00),
(2, 7, 2, '2026-08-26T15:30:00', 1, 700.00, 126.00, 826.00),
(3, 8, 4, '2026-08-27T17:00:00', 1, 400.00, 72.00, 472.00);

/* ============================================================
   CONSULTAS DE PRUEBA
   ============================================================ */


/* BARBEROS */
SELECT *
FROM Barbero;


/* CLIENTES */
SELECT *
FROM Cliente;


/* SERVICIOS */
SELECT *
FROM Servicio;


/* PRODUCTOS */
SELECT *
FROM Producto;


/* USUARIOS */
SELECT *
FROM [User];


/* PASSWORD */
SELECT *
FROM [Password];


/* AGENDA */
SELECT *
FROM Agenda;


/* CITAS */
SELECT *
FROM Cita;


/* FACTURAS */
SELECT *
FROM Factura;


/* ============================================================
   CONSULTA COMPLETA DE CITAS
   ============================================================ */

SELECT
    C.IdCita,

    B.Nombre + ' ' + B.Apellido AS Barbero,

    CL.Nombre + ' ' + CL.Apellido AS Cliente,

    S.Nombre AS Servicio,

    C.Fecha,
    C.Hora,
    C.Detalle,
    C.Estado

FROM Cita C

INNER JOIN [User] UB
    ON C.IdUserBarbero = UB.IdUser

INNER JOIN Barbero B
    ON UB.IdBarbero = B.IdBarbero

INNER JOIN [User] UC
    ON C.IdUserCliente = UC.IdUser

INNER JOIN Cliente CL
    ON UC.IdCliente = CL.IdCliente

INNER JOIN Servicio S
    ON C.IdServicio = S.IdServicio

ORDER BY
    C.Fecha,
    C.Hora;
GO


/* ============================================================
   CONSULTA DE FACTURAS
   ============================================================ */

SELECT

    F.IdFactura,

    B.Nombre + ' ' + B.Apellido AS Barbero,

    C.Nombre + ' ' + C.Apellido AS Cliente,

    S.Nombre AS Servicio,

    F.Fecha,
    F.Cantidad,
    F.Subtotal,
    F.Impuesto,
    F.Total

FROM Factura F

INNER JOIN Barbero B
    ON F.IdBarbero = B.IdBarbero

INNER JOIN Cliente C
    ON F.IdCliente = C.IdCliente

INNER JOIN Servicio S
    ON F.IdServicio = S.IdServicio

ORDER BY F.Fecha DESC;
GO


/* ============================================================
   CONSULTA PRODUCTOS UTILIZADOS POR SERVICIO
   ============================================================ */

SELECT

    S.Nombre AS Servicio,

    P.Nombre AS Producto,

    PS.CantidadUtilizada,

    P.Precio AS PrecioProducto

FROM ProductoServicio PS

INNER JOIN Producto P
    ON PS.IdProducto = P.IdProducto

INNER JOIN Servicio S
    ON PS.IdServicio = S.IdServicio

ORDER BY S.Nombre;
GO


/* ============================================================
   CREAR LOGIN Y USUARIO DE BASE DE DATOS
   ============================================================ */

USE master;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.sql_logins
    WHERE name = 'usr_Barber'
)
BEGIN

    CREATE LOGIN usr_Barber
    WITH PASSWORD = 'BarberDB@2026#Secure';

END
GO


USE myBarberDB;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'usr_Barber'
)
BEGIN

    CREATE USER usr_Barber
    FOR LOGIN usr_Barber;

END
GO


/* ============================================================
   DAR PERMISOS db_owner
   ============================================================ */

ALTER ROLE db_owner
ADD MEMBER usr_Barber;
GO


/* ============================================================
   VERIFICAR USUARIO
   ============================================================ */

SELECT
    dp.name AS Usuario,
    rp.name AS Rol
FROM sys.database_role_members drm

INNER JOIN sys.database_principals rp
    ON drm.role_principal_id = rp.principal_id

INNER JOIN sys.database_principals dp
    ON drm.member_principal_id = dp.principal_id

WHERE dp.name = 'usr_Barber';
GO

                                                                              
