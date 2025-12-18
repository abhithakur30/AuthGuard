import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInitializer {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://gnvehbdeqibxbjhokswv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdudmVoYmRlcWlieGJqaG9rc3d2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxMTczMjUsImV4cCI6MjA2NDY5MzMyNX0.O-6LOrlWeekWWLpcsIsn2TgEZ6hyNxrDn4XaMwk8MTU',
    );
  }
}
