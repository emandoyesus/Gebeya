import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/supabase_config.dart';
import 'price_report_model.dart';

class ReportingRepository {
  final SupabaseClient? _supabase;
  static const String _deviceIdKey = 'gebeya_device_id';

  ReportingRepository({SupabaseClient? supabase})
      : _supabase = SupabaseConfig.isConfigured ? (supabase ?? Supabase.instance.client) : null;

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }
    return id;
  }

  Future<bool> submitReport(PriceReportModel report) async {
    if (_supabase != null) {
      try {
        await _supabase.from('price_reports').insert(report.toJson());
        return true;
      } catch (e) {
        // Log error and handle offline queue
        return false;
      }
    }
    // Simulated offline/local success
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
