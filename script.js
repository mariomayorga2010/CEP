/* ==========================================================
   GMXT · TPRM · Cuestionario de Evaluación de Riesgos
   script.js — Lógica del formulario (extraído de index.html)
   Contenido del cuestionario: constante questionnaireData.
   Los id (q1..q21) deben coincidir con tprm.Pregunta.CodigoPregunta en BD.
   ========================================================== */
// Validar máximo de 3 archivos
function validarArchivos(input) {
    const warning = input.nextElementSibling;
    if (input.files.length > 3) {
        warning.style.display = 'block';
        input.value = ''; 
    } else {
        warning.style.display = 'none';
    }
}

// Datos completos del cuestionario
const questionnaireData = [
    {
        section: "Seguridad de la Información",
        questions: [
            { id: "q1", text: "¿Cuenta con políticas formales de seguridad de la información?", req: "Evidencia mínima: Índice y portada del manual de seguridad vigente (PDF)." },
            { id: "q2", text: "¿Implementa controles de acceso para usuarios que se conectan a la red del cliente?", req: "Evidencia mínima: Política o procedimiento documentado y lista de usuarios autorizados." },
            { id: "q3", text: "¿Utiliza autenticación multifactor (MFA) para accesos remotos?", req: "Evidencia mínima: Captura de pantalla o política donde se exija el MFA, listado de métodos admitidos y alcance." },
            { id: "q4", text: "¿Realiza pruebas de vulnerabilidad o pentesting periódicamente?", req: "Evidencia mínima: Último reporte o carta de conformidad del tercero, fecha y frecuencia." },
            { id: "q5", text: "¿Tiene procedimientos para la gestión de incidentes de seguridad?", req: "Evidencia mínima: Diagrama de proceso o runbook, contacto 24/7, tiempo objetivo de notificación." }
        ]
    },
    {
        section: "Conexión a la Red y Aplicativos",
        questions: [
            { id: "q6", text: "¿Qué mecanismos utiliza para conectarse a la red del cliente?", req: "Evidencia mínima: Descripción del mecanismo (VPN, ZTNA, bastión), controles de acceso (RBAC), y registro de accesos." },
            { id: "q7", text: "¿Los dispositivos que se conectan cumplen con políticas de hardening y antivirus actualizado?", req: "Evidencia mínima: Política de hardening (baseline), consola AV/EDR en uso, porcentaje de cobertura." },
            { id: "q8", text: "¿Existe segregación de redes para evitar propagación de incidentes?", req: "Evidencia mínima: Mapa lógico (alto nivel), segmentación (VLAN/SDN), controles de lateral movement." }
        ]
    },
    {
        section: "Continuidad del Servicio",
        questions: [
            { id: "q9", text: "¿Cuenta con un plan de continuidad de negocio (BCP) y recuperación ante desastres (DRP)?", req: "Evidencia mínima: Portada e índice de BCP y DRP, fecha de última prueba, responsables." },
            { id: "q10", text: "¿Cuál es el tiempo máximo de recuperación (RTO) y punto de recuperación (RPO) para sus servicios críticos?", req: "Evidencia mínima: Tabla con unidades en horas y minutos, alcance por servicio crítico." },
            { id: "q11", text: "¿Ha realizado pruebas de continuidad en los últimos 12 meses?", req: "Evidencia mínima: Acta o reporte formal de la prueba, resultados, plan de acciones." }
        ]
    },
    {
        section: "Cumplimiento Normativo",
        questions: [
            { id: "q12", text: "¿Cumple con regulaciones aplicables (ej. Ley de Protección de Datos, GDPR, etc.)?", req: "Evidencia mínima: Listado de marcos aplicables, cartas de auditoría o certificación (ISO 27001/SOC 2)." },
            { id: "q13", text: "¿Tiene acuerdos de confidencialidad (NDA) firmados con todo el personal que accede a la red del cliente?", req: "Evidencia mínima: Cláusula tipo o constancia de firma para personal con acceso al cliente." },
            { id: "q14", text: "¿Cuenta con auditorías externas de seguridad o cumplimiento?", req: "Evidencia mínima: Reporte de resultados de la última auditoría y/o carta de certificado o de cumplimiento y fecha de aplicación." }
        ]
    },
    {
        section: "Gestión de Terceros y Subcontratistas",
        questions: [
            { id: "q15", text: "¿Utiliza subcontratistas para la prestación del servicio?", req: "Evidencia mínima: Carta o declaración de uso o no uso de subcontratistas, lista y evidencia de control sobre ellos." },
            { id: "q16", text: "¿Cómo asegura que los subcontratistas cumplen con los mismos estándares de seguridad?", req: "Evidencia mínima: Declaración breve del tercero principal, evidencia mínima de verificación." }
        ]
    },
    {
        section: "Gestión de Riesgos",
        questions: [
            { id: "q17", text: "¿Realiza evaluaciones periódicas de riesgos en sus procesos?", req: "Evidencia mínima: Metodología (breve), periodicidad y bitácora de riesgos." },
            { id: "q18", text: "¿Cuenta con un responsable de gestión de riesgos y seguridad?", req: "Evidencia mínima: Declaración simple con nombre y cargo del responsable y/o screenshot del organigrama actual." },
            { id: "q19", text: "¿Tiene un registro de incidentes y acciones correctivas?", req: "Evidencia mínima: Extracto anonimizado (campos: fecha, severidad, acción correctiva)." }
        ]
    },
    {
        section: "Monitoreo y Reportes",
        questions: [
            { id: "q20", text: "¿Proporciona reportes periódicos de estado del servicio y seguridad?", req: "Evidencia mínima: Ejemplo de informe mensual y/o trimestral." },
            { id: "q21", text: "¿Existe un canal para notificación inmediata de incidentes críticos?", req: "Evidencia mínima: correo, teléfono, escalación, ventana de atención y SLA de notificación crítica." }
        ]
    }
];

const container = document.getElementById('questionsContainer');
let globalQuestionIndex = 0;

// Generar el DOM
questionnaireData.forEach((sec, secIndex) => {
    const fieldset = document.createElement('fieldset');
    const legend = document.createElement('legend');
    legend.textContent = `${secIndex + 2}. ${sec.section}`;
    fieldset.appendChild(legend);

    sec.questions.forEach(q => {
        const qBlock = document.createElement('div');
        qBlock.className = `question-block ${globalQuestionIndex === 0 ? 'active-block' : 'disabled-block'}`;
        qBlock.dataset.index = globalQuestionIndex;
        
        qBlock.innerHTML = `
            <div class="question-header">
                <span class="status-indicator" id="status-${q.id}"></span>
                <div class="question-text">${globalQuestionIndex + 1}. ${q.text}</div>
            </div>
            <div class="evidence-req">${q.req}</div>
            
            <div class="options">
                <label><input type="radio" name="${q.id}_res" value="Si" required> Sí</label>
                <label><input type="radio" name="${q.id}_res" value="No"> No</label>
                <label><input type="radio" name="${q.id}_res" value="NA"> N/A</label>
            </div>
            
            <textarea name="${q.id}_comments" placeholder="Ingrese sus comentarios a detalle (Obligatorio para Sí o N/A)"></textarea>
            
            <div class="evidence-upload">
                <label for="${q.id}_files">📎 Adjuntar evidencia (Máx. 3 archivos):</label>
                <input type="file" id="${q.id}_files" name="${q.id}_files[]" multiple accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png">
                <div class="file-warning">⚠️ Máximo 3 archivos permitidos.</div>
            </div>
        `;
        fieldset.appendChild(qBlock);
        globalQuestionIndex++;
    });

    container.appendChild(fieldset);
});

const totalQuestions = globalQuestionIndex;

// Lógica para actualizar el semáforo
function updateTrafficLight(block) {
    const indicator = block.querySelector('.status-indicator');
    const radioChecked = block.querySelector('input[type="radio"]:checked');
    const fileInput = block.querySelector('input[type="file"]');
    
    // Reset classes
    indicator.className = 'status-indicator';

    if (!radioChecked) return;

    const val = radioChecked.value;
    const hasFiles = fileInput.files.length > 0;

    if (val === "Si") {
        if (hasFiles) {
            indicator.classList.add('status-green'); // Sí + Adjunto
        } else {
            indicator.classList.add('status-orange'); // Sí sin Adjunto
        }
    } else if (val === "NA") {
        indicator.classList.add('status-orange'); // N/A
    } else if (val === "No") {
        indicator.classList.add('status-red'); // No
    }
}

// Escuchar eventos en radios y archivos para el Semáforo y el flujo UX
document.querySelectorAll('.question-block').forEach(block => {
    const radios = block.querySelectorAll('input[type="radio"]');
    const fileInput = block.querySelector('input[type="file"]');
    
    // Escuchar cambios en los radio buttons
    radios.forEach(radio => {
        radio.addEventListener('change', () => {
            updateTrafficLight(block); // Actualizar color
            
            const currentIndex = parseInt(block.dataset.index);
            const nextIndex = currentIndex + 1;
            
            // Efecto visual de bloque contestado
            block.style.borderLeftColor = "#3182ce"; 
            
            // Lógica de avance al siguiente bloque
            if (nextIndex < totalQuestions) {
                const nextBlock = document.querySelector(`.question-block[data-index="${nextIndex}"]`);
                if (nextBlock && nextBlock.classList.contains('disabled-block')) {
                    nextBlock.classList.remove('disabled-block');
                    nextBlock.classList.add('active-block');
                    
                    setTimeout(() => {
                        nextBlock.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }, 200);
                }
            } else {
                const finalSection = document.getElementById('finalSection');
                finalSection.classList.remove('disabled-block');
                finalSection.classList.add('active-block');
                document.getElementById('submitBtn').disabled = false;
                
                setTimeout(() => {
                    finalSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 200);
            }
        });
    });

    // Escuchar cambios en el input de archivos
    fileInput.addEventListener('change', function() {
        validarArchivos(this);
        updateTrafficLight(block); // Actualizar color si suben/quitan archivo
    });
});
