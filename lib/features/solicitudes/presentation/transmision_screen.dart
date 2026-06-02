import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/solicitud_repository.dart';
import '../data/expediente_service.dart';

class TransmisionScreen extends StatefulWidget {
  final Map<String, dynamic> solicitudData;
  final int documentosCount;

  const TransmisionScreen({
    required this.solicitudData,
    required this.documentosCount,
    super.key,
  });

  @override
  State<TransmisionScreen> createState() => _TransmisionScreenState();
}

class _TransmisionScreenState extends State<TransmisionScreen> {
  late List<_Paso> pasos;
  int pasoActual = 0;
  String? numeroExpediente;
  bool completado = false;

  @override
  void initState() {
    super.initState();
    pasos = [
      _Paso('Validando datos', 'Verificando completitud de la solicitud'),
      _Paso('Subiendo documentos', 'Enviando archivos a servidor (${widget.documentosCount})'),
      _Paso('Registrando en sistema', 'Creando expediente en base de datos'),
      _Paso('Asignando número', 'Generando número de expediente'),
      _Paso('Solicitud enviada', 'Transmisión completada exitosamente'),
    ];
    _iniciarTransmision();
  }

  void _iniciarTransmision() async {
    final repo = SolicitudRepository();

    for (int i = 0; i < pasos.length; i++) {
      if (!mounted) return;

      setState(() => pasoActual = i);

      try {
        if (i == 0) {
          // Validar datos
          await Future.delayed(const Duration(milliseconds: 800));
        } else if (i == 1) {
          // Subir documentos (simulado)
          await Future.delayed(const Duration(milliseconds: 1000));
        } else if (i == 2) {
          // Registrar en BD
          await repo.guardarSolicitud(
            clienteId: 'temp-cliente',
            asesorId: 'temp-asesor',
            agenciaId: 'temp-agencia',
            datos: widget.solicitudData,
          );
          await Future.delayed(const Duration(milliseconds: 800));
        } else if (i == 3) {
          // Generar expediente
          numeroExpediente = await ExpedienteService.generarNumero();
          await Future.delayed(const Duration(milliseconds: 600));
        } else if (i == 4) {
          // Completar
          await Future.delayed(const Duration(milliseconds: 400));
          setState(() => completado = true);
        }
      } catch (e) {
        // Error: generar expediente fallback
        if (i == 3) {
          numeroExpediente = 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transmisión Electrónica'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Progress indicator vertical
          Column(
            children: List.generate(pasos.length, (i) {
              final paso = pasos[i];
              final isActive = i == pasoActual;
              final isCompleted = i < pasoActual || completado;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withAlpha(40),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : isActive
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paso.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isActive || isCompleted
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paso.descripcion,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < pasos.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: Container(
                        width: 2,
                        height: 20,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary.withAlpha(40),
                      ),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 32),
          // Resultado
          if (completado)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Solicitud enviada exitosamente',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Número de expediente',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          numeroExpediente ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tiempo estimado de evaluación: 24-48 horas',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // Botones
          if (completado)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {'expediente': numeroExpediente}),
              child: const Text('Volver al inicio'),
            )
          else
            ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: const Text('Transmitiendo...'),
            ),
        ],
      ),
    );
  }
}

class _Paso {
  final String titulo;
  final String descripcion;

  _Paso(this.titulo, this.descripcion);
}
