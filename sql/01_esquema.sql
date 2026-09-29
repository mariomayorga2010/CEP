/* =====================================================================
   GMXT · TPRM · Base de datos del Cuestionario de Evaluación de Riesgos
   01_esquema.sql — Esquema, tablas, restricciones, índices y vistas
   Motor objetivo: Microsoft SQL Server 2016+ / Azure SQL Database (T-SQL)
   Mapeo con el formulario (index.html + script.js):
     providerName          -> tprm.Proveedor.RazonSocial
     contactEmail          -> tprm.Evaluacion.CorreoResponsable
     qN_res                -> tprm.Respuesta.Respuesta ('Si','No','NA')
     qN_comments           -> tprm.Respuesta.Comentarios
     qN_files[] (máx. 3)   -> tprm.Evidencia (TipoEvidencia = 'PREGUNTA')
     globalEvidenceZip     -> tprm.Evidencia (TipoEvidencia = 'GLOBAL')
   Los archivos NO se guardan en la BD: solo metadatos + ruta + hash.
   ===================================================================== */
SET NOCOUNT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; -- tsql-only
GO
IF SCHEMA_ID('tprm') IS NULL EXEC('CREATE SCHEMA tprm AUTHORIZATION dbo'); -- tsql-only
GO

/* ---------- Catálogos ---------- */
CREATE TABLE tprm.CuestionarioVersion (
    VersionId          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CuestionarioVersion PRIMARY KEY,
    NumeroVersion      NVARCHAR(10)  NOT NULL CONSTRAINT UQ_CuestionarioVersion_Numero UNIQUE,
    Descripcion        NVARCHAR(300) NULL,
    FechaPublicacion   DATE          NOT NULL,
    EsVigente          BIT           NOT NULL CONSTRAINT DF_CuestionarioVersion_EsVigente DEFAULT (0)
);
GO
CREATE UNIQUE INDEX UX_CuestionarioVersion_Vigente ON tprm.CuestionarioVersion (EsVigente) WHERE EsVigente = 1;
GO

CREATE TABLE tprm.Seccion (
    SeccionId          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Seccion PRIMARY KEY,
    VersionId          INT           NOT NULL CONSTRAINT FK_Seccion_Version REFERENCES tprm.CuestionarioVersion (VersionId),
    NumeroSeccion      TINYINT       NOT NULL,   -- número mostrado en la leyenda del formulario (2..8)
    Nombre             NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Seccion_Version_Numero UNIQUE (VersionId, NumeroSeccion)
);
GO

CREATE TABLE tprm.Pregunta (
    PreguntaId         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Pregunta PRIMARY KEY,
    SeccionId          INT           NOT NULL CONSTRAINT FK_Pregunta_Seccion REFERENCES tprm.Seccion (SeccionId),
    CodigoPregunta     VARCHAR(10)   NOT NULL,   -- id en script.js (q1..q21); prefijo de los campos del form
    NumeroPregunta     TINYINT       NOT NULL,   -- número consecutivo mostrado (1..21)
    Texto              NVARCHAR(500) NOT NULL,   -- questionnaireData[].questions[].text
    EvidenciaMinima    NVARCHAR(500) NOT NULL,   -- questionnaireData[].questions[].req
    Activa             BIT           NOT NULL CONSTRAINT DF_Pregunta_Activa DEFAULT (1),
    CONSTRAINT UQ_Pregunta_Seccion_Codigo UNIQUE (SeccionId, CodigoPregunta),
    CONSTRAINT CK_Pregunta_Codigo CHECK (CodigoPregunta LIKE 'q%')
);
GO

CREATE TABLE tprm.CatOpcionRespuesta (
    Codigo             VARCHAR(2)    NOT NULL CONSTRAINT PK_CatOpcionRespuesta PRIMARY KEY,  -- valor del radio
    Etiqueta           NVARCHAR(10)  NOT NULL,
    RequiereComentario BIT           NOT NULL
);
GO

CREATE TABLE tprm.CatSemaforo (
    Codigo             VARCHAR(10)   NOT NULL CONSTRAINT PK_CatSemaforo PRIMARY KEY,
    ClaseCss           VARCHAR(20)   NOT NULL,
    ColorHex           CHAR(7)       NOT NULL,
    Regla              NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE tprm.CatEstatusEvaluacion (
    Codigo             VARCHAR(15)   NOT NULL CONSTRAINT PK_CatEstatusEvaluacion PRIMARY KEY,
    Descripcion        NVARCHAR(150) NOT NULL,
    Orden              TINYINT       NOT NULL
);
GO

CREATE TABLE tprm.CatExtensionPermitida (
    TipoEvidencia      VARCHAR(10)   NOT NULL,   -- PREGUNTA | GLOBAL
    Extension          VARCHAR(6)    NOT NULL,   -- replica el atributo accept del <input type="file">
    CONSTRAINT PK_CatExtensionPermitida PRIMARY KEY (TipoEvidencia, Extension),
    CONSTRAINT CK_CatExtension_Tipo CHECK (TipoEvidencia IN ('PREGUNTA','GLOBAL'))
);
GO

/* ---------- Transaccionales ---------- */
CREATE TABLE tprm.Proveedor (
    ProveedorId        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Proveedor PRIMARY KEY,
    RazonSocial        NVARCHAR(200) NOT NULL CONSTRAINT UQ_Proveedor_RazonSocial UNIQUE,  -- providerName
    FechaAltaUtc       DATETIME2(0)  NOT NULL CONSTRAINT DF_Proveedor_FechaAlta DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Proveedor_RazonSocial CHECK (LEN(LTRIM(RTRIM(RazonSocial))) >= 3)
);
GO

CREATE TABLE tprm.Evaluacion (
    EvaluacionId       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Evaluacion PRIMARY KEY,
    Folio              VARCHAR(20)   NOT NULL CONSTRAINT UQ_Evaluacion_Folio UNIQUE,   -- p. ej. TPRM-2026-000001 (lo genera el backend)
    ProveedorId        INT           NOT NULL CONSTRAINT FK_Evaluacion_Proveedor REFERENCES tprm.Proveedor (ProveedorId),
    VersionId          INT           NOT NULL CONSTRAINT FK_Evaluacion_Version REFERENCES tprm.CuestionarioVersion (VersionId),
    CorreoResponsable  NVARCHAR(254) NOT NULL,   -- contactEmail
    FechaEnvioUtc      DATETIME2(0)  NOT NULL CONSTRAINT DF_Evaluacion_FechaEnvio DEFAULT (SYSUTCDATETIME()),
    IpOrigen           VARCHAR(45)   NULL,       -- IPv4/IPv6, trazabilidad
    UserAgent          NVARCHAR(400) NULL,
    AceptaAvisoPrivacidad BIT        NOT NULL CONSTRAINT DF_Evaluacion_Aviso DEFAULT (0),  -- LFPDPPP (campo pendiente en el form)
    EstatusCodigo      VARCHAR(15)   NOT NULL CONSTRAINT DF_Evaluacion_Estatus DEFAULT ('RECIBIDA')
                                     CONSTRAINT FK_Evaluacion_Estatus REFERENCES tprm.CatEstatusEvaluacion (Codigo),
    AnalistaAsignado   NVARCHAR(254) NULL,
    FechaDictamenUtc   DATETIME2(0)  NULL,
    DictamenObservaciones NVARCHAR(MAX) NULL,
    CONSTRAINT CK_Evaluacion_Correo CHECK (CorreoResponsable LIKE '%_@_%._%' AND CorreoResponsable NOT LIKE '% %'),
    CONSTRAINT CK_Evaluacion_Dictamen CHECK (EstatusCodigo NOT IN ('APROBADA','RECHAZADA') OR FechaDictamenUtc IS NOT NULL)
);
GO
CREATE INDEX IX_Evaluacion_Proveedor ON tprm.Evaluacion (ProveedorId, FechaEnvioUtc);
GO

CREATE TABLE tprm.Respuesta (
    RespuestaId        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Respuesta PRIMARY KEY,
    EvaluacionId       INT           NOT NULL CONSTRAINT FK_Respuesta_Evaluacion REFERENCES tprm.Evaluacion (EvaluacionId),
    PreguntaId         INT           NOT NULL CONSTRAINT FK_Respuesta_Pregunta REFERENCES tprm.Pregunta (PreguntaId),
    Respuesta          VARCHAR(2)    NOT NULL CONSTRAINT FK_Respuesta_Opcion REFERENCES tprm.CatOpcionRespuesta (Codigo),  -- qN_res
    Comentarios        NVARCHAR(MAX) NULL,       -- qN_comments
    CONSTRAINT UQ_Respuesta_Evaluacion_Pregunta UNIQUE (EvaluacionId, PreguntaId),
    -- Candado de servidor: la regla "Obligatorio para Sí o N/A" que el formulario anuncia
    CONSTRAINT CK_Respuesta_Comentario CHECK (Respuesta = 'No' OR LEN(LTRIM(RTRIM(ISNULL(Comentarios,'')))) > 0)
);
GO

CREATE TABLE tprm.Evidencia (
    EvidenciaId        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Evidencia PRIMARY KEY,
    EvaluacionId       INT           NOT NULL CONSTRAINT FK_Evidencia_Evaluacion REFERENCES tprm.Evaluacion (EvaluacionId),
    RespuestaId        INT           NULL     CONSTRAINT FK_Evidencia_Respuesta REFERENCES tprm.Respuesta (RespuestaId),
    TipoEvidencia      VARCHAR(10)   NOT NULL,
    Consecutivo        TINYINT       NOT NULL,   -- 1..3 por pregunta; 1 para GLOBAL
    Extension          VARCHAR(6)    NOT NULL,
    NombreOriginal     NVARCHAR(260) NOT NULL,
    TipoMime           VARCHAR(150)  NULL,
    TamanoBytes        BIGINT        NOT NULL,
    HashSHA256         CHAR(64)      NOT NULL,
    RutaAlmacenamiento NVARCHAR(500) NOT NULL,   -- SharePoint / Blob; nunca ruta pública
    EstatusAntimalware VARCHAR(12)   NOT NULL CONSTRAINT DF_Evidencia_AV DEFAULT ('PENDIENTE'),
    FechaCargaUtc      DATETIME2(0)  NOT NULL CONSTRAINT DF_Evidencia_Fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Evidencia_Extension FOREIGN KEY (TipoEvidencia, Extension) REFERENCES tprm.CatExtensionPermitida (TipoEvidencia, Extension),
    CONSTRAINT CK_Evidencia_Tipo CHECK ((TipoEvidencia = 'PREGUNTA' AND RespuestaId IS NOT NULL AND Consecutivo BETWEEN 1 AND 3)
                                     OR (TipoEvidencia = 'GLOBAL'   AND RespuestaId IS NULL     AND Consecutivo = 1)),
    CONSTRAINT CK_Evidencia_Tamano CHECK (TamanoBytes > 0),
    CONSTRAINT CK_Evidencia_AV CHECK (EstatusAntimalware IN ('PENDIENTE','LIMPIO','INFECTADO','ERROR'))
);
GO
-- Candado "máx. 3 archivos por pregunta" (consecutivo 1..3 único por respuesta)
CREATE UNIQUE INDEX UX_Evidencia_Respuesta_Consecutivo ON tprm.Evidencia (RespuestaId, Consecutivo) WHERE RespuestaId IS NOT NULL;
GO
-- Candado "un único archivo comprimido global por evaluación"
CREATE UNIQUE INDEX UX_Evidencia_Global ON tprm.Evidencia (EvaluacionId) WHERE TipoEvidencia = 'GLOBAL';
GO

CREATE TABLE tprm.BitacoraEvaluacion (
    BitacoraId         BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BitacoraEvaluacion PRIMARY KEY,
    EvaluacionId       INT           NOT NULL CONSTRAINT FK_Bitacora_Evaluacion REFERENCES tprm.Evaluacion (EvaluacionId),
    Evento             VARCHAR(30)   NOT NULL,   -- ENVIO, CAMBIO_ESTATUS, DESCARGA_EVIDENCIA, DICTAMEN...
    Usuario            NVARCHAR(254) NOT NULL,
    FechaUtc           DATETIME2(0)  NOT NULL CONSTRAINT DF_Bitacora_Fecha DEFAULT (SYSUTCDATETIME()),
    Detalle            NVARCHAR(1000) NULL
);
GO
CREATE INDEX IX_Bitacora_Evaluacion ON tprm.BitacoraEvaluacion (EvaluacionId, FechaUtc);
GO

/* ---------- Vistas ---------- */
-- Replica la lógica de updateTrafficLight() de script.js
CREATE VIEW tprm.vw_SemaforoRespuesta AS
SELECT r.RespuestaId, r.EvaluacionId, p.CodigoPregunta, p.NumeroPregunta, s.Nombre AS Seccion,
       r.Respuesta, r.Comentarios,
       (SELECT COUNT(*) FROM tprm.Evidencia e WHERE e.RespuestaId = r.RespuestaId) AS NumEvidencias,
       CASE
         WHEN r.Respuesta = 'Si' AND EXISTS (SELECT 1 FROM tprm.Evidencia e WHERE e.RespuestaId = r.RespuestaId) THEN 'VERDE'
         WHEN r.Respuesta IN ('Si','NA') THEN 'NARANJA'
         WHEN r.Respuesta = 'No' THEN 'ROJO'
       END AS Semaforo
FROM tprm.Respuesta r
JOIN tprm.Pregunta p ON p.PreguntaId = r.PreguntaId
JOIN tprm.Seccion  s ON s.SeccionId  = p.SeccionId;
GO

CREATE VIEW tprm.vw_ResumenEvaluacion AS
SELECT ev.EvaluacionId, ev.Folio, pr.RazonSocial, ev.CorreoResponsable, ev.FechaEnvioUtc, ev.EstatusCodigo,
       cv.NumeroVersion,
       COUNT(sr.RespuestaId) AS PreguntasRespondidas,
       SUM(CASE WHEN sr.Semaforo = 'VERDE'   THEN 1 ELSE 0 END) AS TotalVerde,
       SUM(CASE WHEN sr.Semaforo = 'NARANJA' THEN 1 ELSE 0 END) AS TotalNaranja,
       SUM(CASE WHEN sr.Semaforo = 'ROJO'    THEN 1 ELSE 0 END) AS TotalRojo,
       (SELECT COUNT(*) FROM tprm.Evidencia g WHERE g.EvaluacionId = ev.EvaluacionId AND g.TipoEvidencia = 'GLOBAL') AS TieneZipGlobal
FROM tprm.Evaluacion ev
JOIN tprm.Proveedor pr ON pr.ProveedorId = ev.ProveedorId
JOIN tprm.CuestionarioVersion cv ON cv.VersionId = ev.VersionId
LEFT JOIN tprm.vw_SemaforoRespuesta sr ON sr.EvaluacionId = ev.EvaluacionId
GROUP BY ev.EvaluacionId, ev.Folio, pr.RazonSocial, ev.CorreoResponsable, ev.FechaEnvioUtc, ev.EstatusCodigo, cv.NumeroVersion;
GO
