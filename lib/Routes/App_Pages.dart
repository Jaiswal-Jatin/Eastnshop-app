import 'package:eastnshop/Bindings/Bindings.dart'; 
import 'package:eastnshop/Screen/SplashScreen.dart';
import 'package:eastnshop/Screen/LoadingScreen.dart';
import 'package:eastnshop/Screen/Login/Login.dart';
import 'package:eastnshop/Screen/Login/SignUp.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/UserHome.dart'; 
import 'package:eastnshop/Screen/Userpanel/UserDashboard/FavoritesPage.dart';
import 'package:eastnshop/Screen/Userpanel/OfferDetailsPage.dart';
import 'package:eastnshop/Screen/Userpanel/SpecialPlansScreen.dart';
import 'package:eastnshop/Screen/Userpanel/ActivePlansScreen.dart';
import 'package:eastnshop/Screen/AdminPanel/EditOffer/EditOfferPage.dart';
import 'package:eastnshop/Screen/AdminPanel/AdminDashboard/HomePage.dart';
import 'package:eastnshop/Screen/AdminPanel/ActiveOffer.dart';
import 'package:eastnshop/Screen/AdminPanel/InactiveOffersPage.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

abstract class AppRoutes {
  static const domainName = "https://eastnshoptech.cloud";
  static const splash = '/';
  static const appStart = '/loading';
  static const signUp = "/SignUp";
  static const login = "/login";
  static const dashboard = "/dashboard";
  static const home = "/home";
  static const shopkeeperHome = "/shopkeeper-home";
  static const favorites = "/favorites";
  static const offerDetails = "/offer-details";
  static const specialPlans = "/special-plans";
  static const activePlans = "/active-plans";
  static const editOffer = "/edit-offer";
  static const activeOffers = "/active-offers";
  static const inactiveOffers = "/inactive-offers";
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.appStart,
      page: () => Loadingscreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => Signup(),
      binding: SignUpBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => Home(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.shopkeeperHome,
      page: () => const HomePage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.offerDetails,
      page: () => OfferDetailsPage(offerId: Get.parameters['id'] ?? '1'),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.editOffer,
      page: () => EditOfferPage(offer: Get.arguments),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.specialPlans,
      page: () => const SpecialPlansScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.activePlans,
      page: () => const ActivePlansScreen(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.activeOffers,
      page: () => const ActiveOffersPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.inactiveOffers,
      page: () => const InactiveOffersPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),

  
  ];
}
