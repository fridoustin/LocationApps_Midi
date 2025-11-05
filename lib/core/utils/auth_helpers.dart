import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<bool> tryRestoreSession() async {
  try {
    final res = await supabase.auth.refreshSession();
    final sess = res.session ?? supabase.auth.currentSession;
    return sess != null;
  } catch (_) {
    return false;
  }
}
