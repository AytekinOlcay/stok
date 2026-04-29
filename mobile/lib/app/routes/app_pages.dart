import 'package:get/get.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/auth_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/package/bindings/package_binding.dart';
import '../../features/package/views/package_view.dart';
import '../../features/products/bindings/products_binding.dart';
import '../../features/products/views/products_view.dart';
import '../../features/qr_scanner/bindings/qr_scanner_binding.dart';
import '../../features/qr_scanner/views/qr_scanner_view.dart';
import '../../features/search/bindings/search_binding.dart';
import '../../features/search/views/search_view.dart';
import '../../features/shelf/bindings/shelf_binding.dart';
import '../../features/shelf/views/shelf_view.dart';
import '../../features/account/bindings/account_binding.dart';
import '../../features/account/views/account_view.dart';
import '../../features/invite/bindings/join_org_binding.dart';
import '../../features/invite/views/join_org_view.dart';
import '../../features/shelves_list/bindings/shelves_list_binding.dart';
import '../../features/shelves_list/views/shelves_list_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/statistics/bindings/statistics_binding.dart';
import '../../features/statistics/views/statistics_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.qrScanner,
      page: () => const QrScannerView(),
      binding: QrScannerBinding(),
    ),
    GetPage(
      name: Routes.shelf,
      page: () => const ShelfView(),
      binding: ShelfBinding(),
    ),
    GetPage(
      name: Routes.packageDetail,
      page: () => const PackageView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.statistics,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: Routes.shelvesList,
      page: () => const ShelvesListView(),
      binding: ShelvesListBinding(),
    ),
    GetPage(
      name: Routes.account,
      page: () => const AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: Routes.joinOrg,
      page: () => const JoinOrgView(),
      binding: JoinOrgBinding(),
    ),
  ];
}
