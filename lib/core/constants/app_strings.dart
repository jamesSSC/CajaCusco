class AppStrings {
  AppStrings._();

  // ── Identidad ─────────────────────────────────────────────────────────────
  static const String appName = 'Caja Cusco';
  static const String appSubtitle = 'Asesor de Negocios';
  static const String appFullName = 'Caja Cusco — Fuerza de Ventas';
  static const String emailDomain = '@cajacusco.app';

  // ── Autenticación ─────────────────────────────────────────────────────────
  static const String codigoEmpleado = 'Código de empleado';
  static const String contrasena = 'Contraseña';
  static const String ingresar = 'Ingresar';
  static const String problemasIngresar = 'Problemas para ingresar';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String accesoBloquedo = 'Acceso bloqueado';
  static const String tiempoRestante = 'Tiempo restante';

  // ── Offline ───────────────────────────────────────────────────────────────
  static const String modoOffline = 'Sin conexión — datos locales';
  static const String sincronizando = 'Sincronizando…';
  static const String sincronizacionCompleta = 'Datos actualizados';
  static const String pendientesSync = 'pendientes de envío';

  // ── Cartera ───────────────────────────────────────────────────────────────
  static const String miCartera = 'Mi Cartera';
  static const String ultimaActualizacion = 'Última actualización';
  static const String visitados = 'visitados';
  static const String pendientes = 'pendientes';
  static const String clientes = 'clientes';
  static const String actualizar = 'Actualizar';
  static const String buscarCliente = 'Buscar cliente o documento…';

  // ── Tipos de gestión (RF-10) ──────────────────────────────────────────────
  static const String renovacion = 'RENOVACIÓN';
  static const String ampliacion = 'AMPLIACIÓN';
  static const String nuevaSolicitud = 'NUEVA SOLICITUD';
  static const String seguimiento = 'SEGUIMIENTO';
  static const String recuperacionMora = 'RECUPERACIÓN MORA';
  static const String desertor = 'DESERTOR';

  // ── Prioridad ─────────────────────────────────────────────────────────────
  static const String prioridadAlta = 'ALTA';
  static const String prioridadMedia = 'MEDIA';
  static const String prioridadNormal = 'NORMAL';

  // ── Resultado visita (HU-07) ──────────────────────────────────────────────
  static const String visitadoOk = 'Visitado';
  static const String noEncontrado = 'No encontrado';
  static const String reagendar = 'Reagendar';
  static const String negocioCerrado = 'Negocio cerrado';

  // ── Menú lateral ─────────────────────────────────────────────────────────
  static const String cartera = 'Cartera';
  static const String ruta = 'Ruta';
  static const String solicitudes = 'Solicitudes';
  static const String borradores = 'Borradores';
  static const String simulador = 'Simulador';
  static const String cobranza = 'Cobranza';
  static const String reportes = 'Reportes';
  static const String configuracion = 'Configuración';

  // ── Solicitud de crédito ──────────────────────────────────────────────────
  static const String nuevaSolicitudCredito = 'Nueva Solicitud';
  static const String datosSolicitante = 'Datos del Solicitante';
  static const String datosNegocio = 'Datos del Negocio';
  static const String condicionesCredito = 'Condiciones del Crédito';
  static const String confirmacionFirma = 'Confirmación y Firma';
  static const String guardarBorrador = 'Guardar borrador';
  static const String descartar = 'Descartar';
  static const String cancelar = 'Cancelar';
  static const String siguiente = 'Siguiente';
  static const String anterior = 'Anterior';
  static const String enviarComite = 'Enviar al Comité';
  static const String pendienteDeEnvio = 'Pendiente de envío';

  // ── Documentos ────────────────────────────────────────────────────────────
  static const String dniAnverso = 'DNI Anverso';
  static const String dniReverso = 'DNI Reverso';
  static const String fotoNegocio = 'Foto del Negocio';
  static const String fotoVisita = 'Foto con el Cliente';
  static const String documentoListo = 'LISTO';
  static const String documentoPendiente = 'PENDIENTE';
  static const String documentoObligatorio = 'OBLIGATORIO';
  static const String fotoBlurosa = 'Foto sin nitidez. Por favor, retoma la foto.';
  static const String retomarFoto = 'Retomar foto';

  // ── Simulador ─────────────────────────────────────────────────────────────
  static const String cuotaMensual = 'Cuota Mensual';
  static const String totalPagar = 'Total a Pagar';
  static const String costoFinanciero = 'Costo Financiero';
  static const String crearSolicitudConEstosDatos = 'Crear solicitud con estos datos';

  // ── Buró ─────────────────────────────────────────────────────────────────
  static const String consultaBuro = 'Consulta de Buró';
  static const String consentimientoRequerido = 'Se requiere consentimiento del cliente';
  static const String clienteEnListaNegra = 'Cliente en lista de restricción';
  static const String clienteLimpio = 'Cliente verificado — Sin restricciones';

  // ── Mora ─────────────────────────────────────────────────────────────────
  static const String carteraVencida = 'Cartera Vencida';
  static const String monteTotalVencido = 'Monto total vencido';
  static const String compromisoDepago = 'Compromiso de pago';
  static const String pagoParicial = 'Pago parcial';
  static const String sinContacto = 'Sin contacto';
  static const String seNiegaPagar = 'Se niega a pagar';

  // ── Errores ───────────────────────────────────────────────────────────────
  static const String errorGenerico = 'Ocurrió un error. Intente nuevamente.';
  static const String errorSinConexion = 'Sin conexión. Los datos se guardarán localmente.';
  static const String campoObligatorio = 'Este campo es obligatorio';
}
