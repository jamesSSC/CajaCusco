import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';

class CapturaDocumentosScreen extends StatefulWidget {
  final String solicitudId;
  const CapturaDocumentosScreen({required this.solicitudId, super.key});

  @override
  State<CapturaDocumentosScreen> createState() => _CapturaDocumentosScreenState();
}

class _CapturaDocumentosScreenState extends State<CapturaDocumentosScreen> {
  final _picker = ImagePicker();
  final _documentos = <String, File>{};
  final _tipos = ['DNI', 'RUC', 'Comprobante de domicilio', 'Estado de cuenta'];

  Future<void> _capturar(String tipo) async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null) {
      setState(() => _documentos[tipo] = File(photo.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$tipo capturado: ${File(photo.path).lengthSync() ~/ 1024}KB')),
        );
      }
    }
  }

  void _galeria(String tipo) async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => _documentos[tipo] = File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Documentos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._tipos.map((tipo) => Card(
            child: ListTile(
              leading: _documentos.containsKey(tipo)
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : const Icon(Icons.document_scanner_outlined),
              title: Text(tipo),
              subtitle: _documentos.containsKey(tipo)
                  ? Text('Guardado: ${File(_documentos[tipo]!.path).lengthSync() ~/ 1024}KB')
                  : const Text('No capturado'),
              trailing: PopupMenuButton(
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    child: const Text('Cámara'),
                    onTap: () => _capturar(tipo),
                  ),
                  PopupMenuItem(
                    child: const Text('Galería'),
                    onTap: () => _galeria(tipo),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _documentos.length >= 2
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Documentos guardados localmente y listos para sincronizar')),
                    );
                    Navigator.pop(context, _documentos);
                  }
                : null,
            icon: const Icon(Icons.upload),
            label: Text('Continuar (${_documentos.length}/${_tipos.length})'),
          ),
        ],
      ),
    );
  }
}
