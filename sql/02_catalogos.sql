/* =====================================================================
   GMXT · TPRM — 02_catalogos.sql
   Registros base (catálogos) que el formulario requiere.
   Preguntas generadas desde questionnaireData de script.js (texto idéntico).
   ===================================================================== */
SET NOCOUNT ON; -- tsql-only
GO

INSERT INTO tprm.CuestionarioVersion (NumeroVersion, Descripcion, FechaPublicacion, EsVigente) VALUES
    (N'1.0', N'Versión inicial: 7 secciones, 21 preguntas (index.html / script.js)', '2026-09-29', 1);
GO

INSERT INTO tprm.CatOpcionRespuesta (Codigo, Etiqueta, RequiereComentario) VALUES
    ('Si', N'Sí', 1), ('No', N'No', 0), ('NA', N'N/A', 1);
GO

INSERT INTO tprm.CatSemaforo (Codigo, ClaseCss, ColorHex, Regla) VALUES
    ('VERDE',   'status-green',  '#48bb78', N'Respuesta Sí con al menos un archivo adjunto'),
    ('NARANJA', 'status-orange', '#ed8936', N'Respuesta Sí sin archivo adjunto, o respuesta N/A'),
    ('ROJO',    'status-red',    '#e53e3e', N'Respuesta No');
GO

INSERT INTO tprm.CatEstatusEvaluacion (Codigo, Descripcion, Orden) VALUES
    ('RECIBIDA',   N'Enviada por el proveedor, pendiente de asignación', 1),
    ('EN_REVISION',N'Asignada a analista de Riesgos', 2),
    ('REQUIERE_INFO',N'Se solicitó información o evidencia adicional al proveedor', 3),
    ('APROBADA',   N'Dictamen favorable', 4),
    ('RECHAZADA',  N'Dictamen desfavorable', 5);
GO

INSERT INTO tprm.CatExtensionPermitida (TipoEvidencia, Extension) VALUES
    ('PREGUNTA','.pdf'), ('PREGUNTA','.doc'), ('PREGUNTA','.docx'), ('PREGUNTA','.xls'), ('PREGUNTA','.xlsx'), ('PREGUNTA','.jpg'), ('PREGUNTA','.jpeg'), ('PREGUNTA','.png'),
    ('GLOBAL','.zip'), ('GLOBAL','.rar'), ('GLOBAL','.7z');
GO

INSERT INTO tprm.Seccion (VersionId, NumeroSeccion, Nombre)
SELECT VersionId, 2, N'Seguridad de la Información' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 3, N'Conexión a la Red y Aplicativos' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 4, N'Continuidad del Servicio' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 5, N'Cumplimiento Normativo' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 6, N'Gestión de Terceros y Subcontratistas' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 7, N'Gestión de Riesgos' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0'
UNION ALL SELECT VersionId, 8, N'Monitoreo y Reportes' FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0';
GO

INSERT INTO tprm.Pregunta (SeccionId, CodigoPregunta, NumeroPregunta, Texto, EvidenciaMinima)
SELECT s.SeccionId, 'q1', 1, N'¿Cuenta con políticas formales de seguridad de la información?',
       N'Evidencia mínima: Índice y portada del manual de seguridad vigente (PDF).'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 2 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q2', 2, N'¿Implementa controles de acceso para usuarios que se conectan a la red del cliente?',
       N'Evidencia mínima: Política o procedimiento documentado y lista de usuarios autorizados.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 2 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q3', 3, N'¿Utiliza autenticación multifactor (MFA) para accesos remotos?',
       N'Evidencia mínima: Captura de pantalla o política donde se exija el MFA, listado de métodos admitidos y alcance.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 2 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q4', 4, N'¿Realiza pruebas de vulnerabilidad o pentesting periódicamente?',
       N'Evidencia mínima: Último reporte o carta de conformidad del tercero, fecha y frecuencia.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 2 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q5', 5, N'¿Tiene procedimientos para la gestión de incidentes de seguridad?',
       N'Evidencia mínima: Diagrama de proceso o runbook, contacto 24/7, tiempo objetivo de notificación.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 2 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q6', 6, N'¿Qué mecanismos utiliza para conectarse a la red del cliente?',
       N'Evidencia mínima: Descripción del mecanismo (VPN, ZTNA, bastión), controles de acceso (RBAC), y registro de accesos.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 3 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q7', 7, N'¿Los dispositivos que se conectan cumplen con políticas de hardening y antivirus actualizado?',
       N'Evidencia mínima: Política de hardening (baseline), consola AV/EDR en uso, porcentaje de cobertura.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 3 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q8', 8, N'¿Existe segregación de redes para evitar propagación de incidentes?',
       N'Evidencia mínima: Mapa lógico (alto nivel), segmentación (VLAN/SDN), controles de lateral movement.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 3 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q9', 9, N'¿Cuenta con un plan de continuidad de negocio (BCP) y recuperación ante desastres (DRP)?',
       N'Evidencia mínima: Portada e índice de BCP y DRP, fecha de última prueba, responsables.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 4 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q10', 10, N'¿Cuál es el tiempo máximo de recuperación (RTO) y punto de recuperación (RPO) para sus servicios críticos?',
       N'Evidencia mínima: Tabla con unidades en horas y minutos, alcance por servicio crítico.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 4 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q11', 11, N'¿Ha realizado pruebas de continuidad en los últimos 12 meses?',
       N'Evidencia mínima: Acta o reporte formal de la prueba, resultados, plan de acciones.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 4 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q12', 12, N'¿Cumple con regulaciones aplicables (ej. Ley de Protección de Datos, GDPR, etc.)?',
       N'Evidencia mínima: Listado de marcos aplicables, cartas de auditoría o certificación (ISO 27001/SOC 2).'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 5 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q13', 13, N'¿Tiene acuerdos de confidencialidad (NDA) firmados con todo el personal que accede a la red del cliente?',
       N'Evidencia mínima: Cláusula tipo o constancia de firma para personal con acceso al cliente.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 5 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q14', 14, N'¿Cuenta con auditorías externas de seguridad o cumplimiento?',
       N'Evidencia mínima: Reporte de resultados de la última auditoría y/o carta de certificado o de cumplimiento y fecha de aplicación.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 5 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q15', 15, N'¿Utiliza subcontratistas para la prestación del servicio?',
       N'Evidencia mínima: Carta o declaración de uso o no uso de subcontratistas, lista y evidencia de control sobre ellos.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 6 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q16', 16, N'¿Cómo asegura que los subcontratistas cumplen con los mismos estándares de seguridad?',
       N'Evidencia mínima: Declaración breve del tercero principal, evidencia mínima de verificación.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 6 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q17', 17, N'¿Realiza evaluaciones periódicas de riesgos en sus procesos?',
       N'Evidencia mínima: Metodología (breve), periodicidad y bitácora de riesgos.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 7 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q18', 18, N'¿Cuenta con un responsable de gestión de riesgos y seguridad?',
       N'Evidencia mínima: Declaración simple con nombre y cargo del responsable y/o screenshot del organigrama actual.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 7 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q19', 19, N'¿Tiene un registro de incidentes y acciones correctivas?',
       N'Evidencia mínima: Extracto anonimizado (campos: fecha, severidad, acción correctiva).'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 7 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q20', 20, N'¿Proporciona reportes periódicos de estado del servicio y seguridad?',
       N'Evidencia mínima: Ejemplo de informe mensual y/o trimestral.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 8 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0')
UNION ALL
SELECT s.SeccionId, 'q21', 21, N'¿Existe un canal para notificación inmediata de incidentes críticos?',
       N'Evidencia mínima: correo, teléfono, escalación, ventana de atención y SLA de notificación crítica.'
  FROM tprm.Seccion s WHERE s.NumeroSeccion = 8 AND s.VersionId = (SELECT VersionId FROM tprm.CuestionarioVersion WHERE NumeroVersion = N'1.0');
GO
