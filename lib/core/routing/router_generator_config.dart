import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/helper/transition_helper.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/clients_details/presentation/pages/all_client_invoices.dart';
import 'package:warshity/features/clients_details/presentation/screens/customerdetails_screen.dart';
import 'package:warshity/features/add_invoices/presentation/screens/add_invoice.dart';
import 'package:warshity/features/auth/access_password/presentation/screens/access_pass_screen.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/forget_password/presentation/screens/forget_pass_screen.dart';
import 'package:warshity/features/auth/login/presentation/screens/login_screen.dart';
import 'package:warshity/features/auth/register/presentation/screens/register_screen.dart';
import 'package:warshity/features/check_invoice/presentation/screens/check_invoice.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/pages/invoice_pages.dart';
import 'package:warshity/features/main/presentation/screens/main_screen.dart';
import 'package:warshity/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:warshity/features/productdetails/presentation/screens/product_details_screen.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/splash/presentation/screens/splash_screen.dart';

class RouterGeneratorConfig {
  /// Routes that must never render without a signed-in Firebase user.
  static const Set<String> protectedRoutes = {
    AppRoutes.mainScreen,
    AppRoutes.invoiceScreen,
    AppRoutes.addInvoicesScreen,
    AppRoutes.checkInvoiceScreen,
    AppRoutes.customerdetailsScreen,
    AppRoutes.allClientInvoicesScreen,
    AppRoutes.productdetailsScreen,
  };

  /// Routes whose page is built from `state.extra` (an id, a model, a cubit).
  /// `extra` does not survive a browser reload / a direct URL open, so these
  /// routes are redirected instead of crashing on an unsafe cast.
  static const Set<String> routesRequiringExtra = {
    AppRoutes.checkInvoiceScreen,
    AppRoutes.customerdetailsScreen,
    AppRoutes.allClientInvoicesScreen,
    AppRoutes.productdetailsScreen,
  };

  /// The location the user originally asked for while the session was still
  /// unknown. Consumed by the splash screen once Firebase answers.
  static String? _pendingLocation;

  /// Returns (and clears) the location held back during session resolution.
  static String? consumePendingLocation() {
    final pending = _pendingLocation;
    _pendingLocation = null;
    return pending;
  }

  static bool _hasExpectedExtra(String location, Object? extra) {
    switch (location) {
      case AppRoutes.productdetailsScreen:
        return extra is Map<String, dynamic>;
      case AppRoutes.checkInvoiceScreen:
        return extra is InvoiceModel;
      case AppRoutes.customerdetailsScreen:
      case AppRoutes.allClientInvoicesScreen:
        return extra is String;
      default:
        return true;
    }
  }

  static GoRouter goRouter = GoRouter(
    // Both platforms start on Splash: it is the single place where the app
    // waits for Firebase to restore (or deny) the persisted session.
    initialLocation: AppRoutes.splashScreen,

    errorBuilder: (context, state) => const NotFoundScreen(),

    redirect: (context, state) {
      final location = state.matchedLocation;
      final authCubit = getIt<AuthCubit>();

      // Splash is the session resolving route, never redirect it.
      if (location == AppRoutes.splashScreen) {
        return null;
      }

      // Firebase has not answered yet (typical right after a reload or when
      // site data was cleared). Hold the requested location and show Splash
      // instead of building a protected page with no user.
      if (authCubit.sessionStatus == AuthSessionStatus.unknown) {
        _pendingLocation = state.uri.toString();
        return AppRoutes.splashScreen;
      }

      // The session is resolved, so `currentUser` can be trusted again.
      final isLoggedIn = getIt<AuthRepo>().currentUser != null;

      if (kIsWeb && location == AppRoutes.onboarding) {
        return isLoggedIn ? AppRoutes.mainScreen : AppRoutes.loginScreen;
      }

      final isGoingToAuthScreen =
          location == AppRoutes.loginScreen ||
          location == AppRoutes.registerScreen ||
          location == AppRoutes.forgetPassScreen ||
          location == AppRoutes.accessPassScreen;

      if (isLoggedIn && isGoingToAuthScreen) {
        return AppRoutes.mainScreen;
      }

      if (!isLoggedIn && protectedRoutes.contains(location)) {
        return AppRoutes.loginScreen;
      }

      // Direct open / reload of a detail route without a usable `extra`.
      if (isLoggedIn &&
          routesRequiringExtra.contains(location) &&
          !_hasExpectedExtra(location, state.extra)) {
        return AppRoutes.mainScreen;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) {
          final locale = state.extra as Locale?;

          return SplashScreen(locale: locale);
        },
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.mainScreen,
        name: AppRoutes.mainScreen,
        builder: (context, state) {
          final locale = state.extra as Locale?;
          return MainScreen(locale: locale);
        },
      ),
      GoRoute(
        path: AppRoutes.invoiceScreen,
        name: AppRoutes.invoiceScreen,
        builder: (context, state) {
          return const InvoicePages();
        },
      ),
      GoRoute(
        path: AppRoutes.productdetailsScreen,
        name: AppRoutes.productdetailsScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final productId = extra['productId'] as String;
          final productsCubit = extra['productsCubit'] as ProductsCubit;
          return BlocProvider.value(
            value: productsCubit,
            child: ProductDetailsScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addInvoicesScreen,
        name: AppRoutes.addInvoicesScreen,
        pageBuilder: (context, state) {
          return fadeSlidePage(key: state.pageKey, child: const AddInvoice());
        },
      ),

      GoRoute(
        path: AppRoutes.checkInvoiceScreen,
        name: AppRoutes.checkInvoiceScreen,
        pageBuilder: (context, state) {
          final invoice = state.extra as InvoiceModel;

          return fadeSlidePage(
            key: state.pageKey,
            child: CheckInvoice(invoice: invoice),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.customerdetailsScreen,
        name: AppRoutes.customerdetailsScreen,

        pageBuilder: (context, state) {
          final customerId = state.extra as String;

          return fadeSlidePage(
            key: state.pageKey,
            child: CustomerdetailsScreen(customerId: customerId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.allClientInvoicesScreen,
        name: AppRoutes.allClientInvoicesScreen,
        pageBuilder: (context, state) {
          final customerId = state.extra as String;

          return fadeSlidePage(
            key: state.pageKey,
            child: AllClientInvoices(customerId: customerId),
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          // Shared AuthCubit instance (owned by get_it): no duplicate
          // listeners and the provider must not close the shared cubit.
          return BlocProvider<AuthCubit>.value(
            value: getIt<AuthCubit>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.loginScreen,
            name: AppRoutes.loginScreen,
            builder: (context, state) => const LoginScreen(),
          ),

          GoRoute(
            path: AppRoutes.registerScreen,
            name: AppRoutes.registerScreen,
            builder: (context, state) => const RegisterScreen(),
          ),

          GoRoute(
            path: AppRoutes.forgetPassScreen,
            name: AppRoutes.forgetPassScreen,
            builder: (context, state) => const ForgetPassScreen(),
          ),

          GoRoute(
            path: AppRoutes.accessPassScreen,
            name: AppRoutes.accessPassScreen,
            builder: (context, state) {
              final email = state.extra as String? ?? '';

              return AccessPassScreen(email: email);
            },
          ),
        ],
      ),
    ],
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('page_not_found'.tr())));
  }
}
