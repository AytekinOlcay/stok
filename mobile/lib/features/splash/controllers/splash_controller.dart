import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

class SplashController extends GetxController {
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      final session = Get.find<SessionService>();
      final hasOrg = await session.loadSession();

      if (hasOrg) {
        Get.offAllNamed('/');
      } else {
        Get.offAllNamed('/onboarding');
      }
    } catch (e, st) {
      debugPrint('SplashController error: $e\n$st');
      errorMessage.value = e.toString();
    }
  }

  void retry() {
    errorMessage.value = null;
    _checkAuth();
  }
}
