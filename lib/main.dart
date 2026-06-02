import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/storage/local_db.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo vertical en móvil
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa Supabase (RF-02)
  await Supabase.initialize(
    url: AppSupabase.url,
    anonKey: AppSupabase.anonKey,
  );

  // Inicializa la base de datos SQLite local (offline-first)
  await LocalDb.instance.init();

  runApp(
    const ProviderScope(
      child: CajaCuscoApp(),
    ),
  );
}
