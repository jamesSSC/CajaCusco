class AsesorModel {
  const AsesorModel({
    required this.id,
    required this.userId,
    required this.codigoEmpleado,
    required this.nombres,
    required this.apellidos,
    required this.agenciaId,
    required this.perfil,
    required this.activo,
    this.tokenFcm,
  });

  final String id;
  final String userId;
  final String codigoEmpleado;
  final String nombres;
  final String apellidos;
  final String agenciaId;

  /// operador | super_operador | supervisor | administrador
  final String perfil;
  final bool activo;
  final String? tokenFcm;

  factory AsesorModel.fromJson(Map<String, dynamic> json) {
    return AsesorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      codigoEmpleado: json['codigo_empleado'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      agenciaId: json['agencia_id'] as String,
      perfil: json['perfil'] as String,
      activo: json['activo'] as bool,
      tokenFcm: json['token_fcm'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'codigo_empleado': codigoEmpleado,
        'nombres': nombres,
        'apellidos': apellidos,
        'agencia_id': agenciaId,
        'perfil': perfil,
        'activo': activo,
        'token_fcm': tokenFcm,
      };

  // ── Helpers de perfil ─────────────────────────────────────────────────────

  String get nombreCompleto => '$nombres $apellidos';

  bool get esOperador =>
      perfil == 'operador' || perfil == 'super_operador';

  bool get esSupervisor =>
      perfil == 'supervisor' || perfil == 'administrador';

  bool get esAdministrador => perfil == 'administrador';

  // ── Permisos de menú (RF-05, RF-06) ──────────────────────────────────────

  bool get puedeVerReportes => esSupervisor;
  bool get puedeReasignarTareas => esSupervisor;
  bool get puedeVerMonitorMapa => esSupervisor;
  bool get puedeGestionarUsuarios => esAdministrador;
}
