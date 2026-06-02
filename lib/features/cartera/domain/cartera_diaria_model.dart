class CarteraDiariaModel {
  final String id;
  final String asesorId;
  final String clienteId;
  final String? agenciaId;
  final String fechaAsignacion;
  final String tipoGestion;
  final String prioridad;
  final int scorePrioridad;
  final String estadoVisita;
  final String? resultadoVisita;
  final String? observacionVisita;
  final String? timestampVisita;
  final double? latVisita;
  final double? lngVisita;
  final int? ordenManual;
  
  // Campos cruzados con la tabla clientes e historial para la caché local
  final String clienteNombre;
  final String clienteDocumento;
  final String? clienteTelefono;
  final double? clienteLat;
  final double? clienteLng;

  CarteraDiariaModel({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    this.agenciaId,
    required this.fechaAsignacion,
    required this.tipoGestion,
    required this.prioridad,
    required this.scorePrioridad,
    required this.estadoVisita,
    this.resultadoVisita,
    this.observacionVisita,
    this.timestampVisita,
    this.latVisita,
    this.lngVisita,
    this.ordenManual,
    required this.clienteNombre,
    required this.clienteDocumento,
    this.clienteTelefono,
    this.clienteLat,
    this.clienteLng,
  });

  /// Parsear desde la respuesta compuesta de Supabase (cartera_diaria join clientes)
  factory CarteraDiariaModel.fromSupabase(Map<String, dynamic> json) {
    final cliente = json['clientes'] as Map<String, dynamic>? ?? {};
    return CarteraDiariaModel(
      id: json['id'],
      asesorId: json['asesor_id'],
      clienteId: json['cliente_id'],
      agenciaId: json['agencia_id'],
      fechaAsignacion: json['fecha_asignacion'],
      tipoGestion: json['tipo_gestion'],
      prioridad: json['prioridad'],
      scorePrioridad: json['score_prioridad'] ?? 0,
      estadoVisita: json['estado_visita'] ?? 'pendiente',
      resultadoVisita: json['resultado_visita'],
      observacionVisita: json['observacion_visita'],
      timestampVisita: json['timestamp_visita'],
      latVisita: json['lat_visita'] != null ? (json['lat_visita'] as num).toDouble() : null,
      lngVisita: json['lng_visita'] != null ? (json['lng_visita'] as num).toDouble() : null,
      ordenManual: json['orden_manual'],
      clienteNombre: '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim(),
      clienteDocumento: cliente['numero_documento'] ?? '',
      clienteTelefono: cliente['telefono'],
      clienteLat: cliente['lat'] != null ? (cliente['lat'] as num).toDouble() : null,
      clienteLng: cliente['lng'] != null ? (cliente['lng'] as num).toDouble() : null,
    );
  }

  /// Parsear desde tu tabla `cartera_cache` en SQLite
  factory CarteraDiariaModel.fromSqlite(Map<String, dynamic> json) {
    return CarteraDiariaModel(
      id: json['id'],
      asesorId: json['asesor_id'],
      clienteId: json['cliente_id'],
      agenciaId: json['agencia_id'],
      fechaAsignacion: json['fecha_asignacion'],
      tipoGestion: json['tipo_gestion'],
      prioridad: json['prioridad'],
      scorePrioridad: json['score_prioridad'] ?? 0,
      estadoVisita: json['estado_visita'],
      resultadoVisita: json['resultado_visita'],
      observacionVisita: json['observacion_visita'],
      timestampVisita: json['timestamp_visita'],
      latVisita: json['lat_visita'],
      lngVisita: json['lng_visita'],
      ordenManual: json['orden_manual'],
      clienteNombre: json['cliente_nombre'] ?? '',
      clienteDocumento: json['cliente_documento'] ?? '',
      clienteTelefono: json['cliente_telefono'],
      clienteLat: json['cliente_lat'],
      clienteLng: json['cliente_lng'],
    );
  }

  /// Convertir a Map plano listo para guardarse en tu `cartera_cache` de SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'asesor_id': asesorId,
      'cliente_id': clienteId,
      'agencia_id': agenciaId,
      'fecha_asignacion': fechaAsignacion,
      'tipo_gestion': tipoGestion,
      'prioridad': prioridad,
      'score_prioridad': scorePrioridad,
      'estado_visita': estadoVisita,
      'resultado_visita': resultadoVisita,
      'observacion_visita': observacionVisita,
      'timestamp_visita': timestampVisita,
      'lat_visita': latVisita,
      'lng_visita': lngVisita,
      'orden_manual': ordenManual,
      'cliente_nombre': clienteNombre,
      'cliente_documento': clienteDocumento,
      'cliente_telefono': clienteTelefono,
      'cliente_lat': clienteLat,
      'cliente_lng': clienteLng,
      'synced_at': DateTime.now().toIso8601String(),
    };
  }
}