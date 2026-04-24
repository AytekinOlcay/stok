import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the currently logged-in user's organization context.
/// Persists across the whole app lifetime via GetX service.
class SessionService extends GetxService {
  final _supabase = Supabase.instance.client;

  final orgId = Rxn<String>();
  final orgName = Rxn<String>();
  final role = Rxn<String>();

  /// Shorthand — throws if org not loaded yet.
  String get currentOrgId => orgId.value!;

  bool get hasOrg => orgId.value != null;

  @override
  void onInit() {
    super.onInit();
    // When the user signs out from anywhere, clear state and go to login.
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        clear();
        Get.offAllNamed('/login');
      }
    });
  }

  /// Calls get_my_org() RPC and stores the result.
  /// Returns true if the user belongs to an org.
  Future<bool> loadSession() async {
    try {
      final result = await _supabase.rpc('get_my_org');
      if (result == null) {
        orgId.value = null;
        return false;
      }
      orgId.value = result['org_id'] as String?;
      orgName.value = result['org_name'] as String?;
      role.value = result['role'] as String?;
      return orgId.value != null;
    } catch (_) {
      orgId.value = null;
      return false;
    }
  }

  void clear() {
    orgId.value = null;
    orgName.value = null;
    role.value = null;
  }
}
