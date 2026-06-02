class ClienteDetalleModel {
  final String id;
  final String nombreCompleto;
  final String documento;
  final String celular;
  final String direccionCompleta;
  final String actividadEconomica;
  final String calificacionSbs; // NORMAL, CPP, DEFICIENTE, DUDOSO, PERDIDA
  final double saldoDeudaCaja;
  final double saldoDeudaOtros;
  final int diasMora;

  ClienteDetalleModel({
    required this.id,
    required this.nombreCompleto,
    required this.documento,
    required this.celular,
    required this.direccionCompleta,
    required this.actividadEconomica,
    required this.calificacionSbs,
    required this.saldoDeudaCaja,
    required this.saldoDeudaOtros,
    required this.diasMora,
  });
}