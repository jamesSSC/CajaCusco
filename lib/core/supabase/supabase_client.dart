import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  AppSupabase._();

  // ── CONFIGURA AQUÍ tu proyecto Supabase ──────────────────────────────────
  // Obtenlos en: Dashboard → Project Settings → API
  static const String url = 'https://wzbzdkxuyljjdlixvoxa.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6Ynpka3h1eWxqamRsaXh2b3hhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMzM1OTQsImV4cCI6MjA5NTkwOTU5NH0.iWOt7dPf22KzLyQZJ36uyGJPPGurLzCv8dNmipS0GuY';

  // Dominio de correo interno para convertir código de empleado → email
  // Ejemplo: código 12345 → 12345@cajacusco.app
  static const String emailDomain = '@cajacusco.app';

  static SupabaseClient get client => Supabase.instance.client;

  static String codigoToEmail(String codigo) => '$codigo$emailDomain';
}
