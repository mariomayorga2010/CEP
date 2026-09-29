/* =====================================================================
   GMXT · TPRM — 04_datos_prueba.sql
   Evaluación ficticia completa para QA. NO ejecutar en producción.
   ===================================================================== */
INSERT INTO tprm.Proveedor (RazonSocial) VALUES (N'Proveedor Demo QA S.A. de C.V.');
GO
INSERT INTO tprm.Evaluacion (Folio, ProveedorId, VersionId, CorreoResponsable, IpOrigen, UserAgent, AceptaAvisoPrivacidad)
SELECT 'TPRM-2026-000001', p.ProveedorId, v.VersionId, N'seguridad@proveedordemo.mx', '203.0.113.10', N'QA', 1
FROM tprm.Proveedor p, tprm.CuestionarioVersion v
WHERE p.RazonSocial = N'Proveedor Demo QA S.A. de C.V.' AND v.EsVigente = 1;
GO
-- Respuestas: q1..q14 = Si, q15..q18 = NA, q19..q21 = No
INSERT INTO tprm.Respuesta (EvaluacionId, PreguntaId, Respuesta, Comentarios)
SELECT e.EvaluacionId, q.PreguntaId,
       CASE WHEN q.NumeroPregunta <= 14 THEN 'Si' WHEN q.NumeroPregunta <= 18 THEN 'NA' ELSE 'No' END,
       CASE WHEN q.NumeroPregunta <= 18 THEN N'Comentario de prueba QA' ELSE NULL END
FROM tprm.Evaluacion e
JOIN tprm.Seccion s ON s.VersionId = e.VersionId
JOIN tprm.Pregunta q ON q.SeccionId = s.SeccionId
WHERE e.Folio = 'TPRM-2026-000001';
GO
-- Evidencia: 1 archivo en q1..q10 (verde), q11..q14 sin archivo (naranja)
INSERT INTO tprm.Evidencia (EvaluacionId, RespuestaId, TipoEvidencia, Consecutivo, Extension, NombreOriginal, TipoMime, TamanoBytes, HashSHA256, RutaAlmacenamiento, EstatusAntimalware)
SELECT r.EvaluacionId, r.RespuestaId, 'PREGUNTA', 1, '.pdf', N'evidencia.pdf', 'application/pdf', 102400,
       REPLICATE('a', 64), N'/tprm/TPRM-2026-000001/evidencia.pdf', 'LIMPIO'
FROM tprm.Respuesta r JOIN tprm.Pregunta q ON q.PreguntaId = r.PreguntaId
JOIN tprm.Evaluacion e ON e.EvaluacionId = r.EvaluacionId
WHERE e.Folio = 'TPRM-2026-000001' AND q.NumeroPregunta <= 10;
GO
INSERT INTO tprm.Evidencia (EvaluacionId, RespuestaId, TipoEvidencia, Consecutivo, Extension, NombreOriginal, TipoMime, TamanoBytes, HashSHA256, RutaAlmacenamiento, EstatusAntimalware)
SELECT EvaluacionId, NULL, 'GLOBAL', 1, '.zip', N'evidencia_global.zip', 'application/zip', 5242880,
       REPLICATE('b', 64), N'/tprm/TPRM-2026-000001/evidencia_global.zip', 'LIMPIO'
FROM tprm.Evaluacion WHERE Folio = 'TPRM-2026-000001';
GO
INSERT INTO tprm.BitacoraEvaluacion (EvaluacionId, Evento, Usuario, Detalle)
SELECT EvaluacionId, 'ENVIO', N'seguridad@proveedordemo.mx', N'Envío de prueba QA'
FROM tprm.Evaluacion WHERE Folio = 'TPRM-2026-000001';
GO
-- Resultado esperado: 21 respondidas | 10 verde | 8 naranja | 3 rojo | 1 ZIP
SELECT * FROM tprm.vw_ResumenEvaluacion WHERE Folio = 'TPRM-2026-000001';
GO
