/* =====================================================================
   GMXT · TPRM — 03_seguridad.sql  (solo T-SQL)
   Mínimo privilegio para la cuenta del backend y para analistas.
   Nunca conectar el navegador directamente a la BD: solo el backend.
   ===================================================================== */
IF DATABASE_PRINCIPAL_ID('rol_tprm_backend') IS NULL CREATE ROLE rol_tprm_backend;
IF DATABASE_PRINCIPAL_ID('rol_tprm_analista') IS NULL CREATE ROLE rol_tprm_analista;
GO
-- Backend (API que recibe el formulario): lee catálogos e inserta envíos; no borra ni actualiza respuestas
GRANT SELECT ON tprm.CuestionarioVersion  TO rol_tprm_backend;
GRANT SELECT ON tprm.Seccion              TO rol_tprm_backend;
GRANT SELECT ON tprm.Pregunta             TO rol_tprm_backend;
GRANT SELECT ON tprm.CatOpcionRespuesta   TO rol_tprm_backend;
GRANT SELECT ON tprm.CatExtensionPermitida TO rol_tprm_backend;
GRANT SELECT, INSERT ON tprm.Proveedor    TO rol_tprm_backend;
GRANT INSERT ON tprm.Evaluacion           TO rol_tprm_backend;
GRANT INSERT ON tprm.Respuesta            TO rol_tprm_backend;
GRANT INSERT ON tprm.Evidencia            TO rol_tprm_backend;
GRANT UPDATE (EstatusAntimalware) ON tprm.Evidencia TO rol_tprm_backend;
GRANT INSERT ON tprm.BitacoraEvaluacion   TO rol_tprm_backend;
GO
-- Analistas de Riesgos: consultan y dictaminan
GRANT SELECT ON SCHEMA::tprm TO rol_tprm_analista;
GRANT UPDATE (EstatusCodigo, AnalistaAsignado, FechaDictamenUtc, DictamenObservaciones) ON tprm.Evaluacion TO rol_tprm_analista;
GRANT INSERT ON tprm.BitacoraEvaluacion TO rol_tprm_analista;
DENY  DELETE ON SCHEMA::tprm TO rol_tprm_analista;
GO
-- Asignación de miembros [POR CONFIRMAR usuarios/grupos de Entra ID]:
-- ALTER ROLE rol_tprm_backend  ADD MEMBER [app-tprm-backend];
-- ALTER ROLE rol_tprm_analista ADD MEMBER [grp-riesgos-ti];
