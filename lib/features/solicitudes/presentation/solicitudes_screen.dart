import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'captura_documentos_screen.dart';
import 'estado_solicitudes_screen.dart';
import 'transmision_screen.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCliente;
  double _monto = 0;
  int _plazo = 12;
  int _documentosCargados = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Crédito'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nueva Solicitud'),
            Tab(text: 'Mis Solicitudes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          const EstadoSolicitudesScreen(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Cliente
          Text(
            'Datos de la Solicitud',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Cliente',
                prefixIcon: const Icon(Icons.person_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              items: ['Pedro Avendaño', 'Lucía Ttito', 'Juan Mamani']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => _selectedCliente = v,
              validator: (v) => v == null ? 'Selecciona un cliente' : null,
            ),
          ),
          const SizedBox(height: 20),

          // Monto
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Monto (S/)',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _monto = double.tryParse(v) ?? 0,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
          ),
          const SizedBox(height: 24),

          // Plazo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Plazo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_plazo meses',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(100),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _plazo.toDouble(),
                    min: 6,
                    max: 36,
                    divisions: 30,
                    label: '$_plazo meses',
                    onChanged: (v) => setState(() => _plazo = v.toInt()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Botón Capturar Documentos
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tipoNuevaSolicitud.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: () async {
                final docs = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        const CapturaDocumentosScreen(solicitudId: 'sol_001'),
                  ),
                );
                if (docs != null) {
                  setState(() => _documentosCargados = docs.length);
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: AppColors.tipoNuevaSolicitud,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(
                _documentosCargados > 0
                    ? 'Documentos: $_documentosCargados/4'
                    : 'Capturar Documentos',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón Enviar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _documentosCargados >= 2 ? () => _showResumen() : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Enviar Solicitud',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResumen() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resumen de Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: $_selectedCliente'),
            Text('Monto: S/ ${_monto.toStringAsFixed(2)}'),
            Text('Plazo: $_plazo meses'),
            const SizedBox(height: 12),
            Text('Cuota mensual: S/ ${(_monto / _plazo).toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            Text('Documentos: $_documentosCargados/4'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => TransmisionScreen(
                    solicitudData: {
                      'cliente': _selectedCliente,
                      'monto': _monto,
                      'plazo': _plazo,
                    },
                    documentosCount: _documentosCargados,
                  ),
                ),
              );
            },
            child: const Text('Enviar al comité'),
          ),
        ],
      ),
    );
  }
}
