import 'package:eastnshop/Controllers/LoginController.dart';
import 'package:eastnshop/Controllers/ticketListController.dart';
import 'package:eastnshop/Controllers/FavoritesController.dart';
import 'package:eastnshop/Controllers/NearbyOffersController.dart';
import 'package:eastnshop/Controllers/OfferDetailsController.dart';
import 'package:get/get.dart';

class SignUpBinding extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<LoginController>(()=> LoginController());
  }
}

class LoginBinding extends Bindings{

 @override
  void dependencies(){
    Get.lazyPut<LoginController>(()=> LoginController());
    Get.lazyPut<FavoritesController>(()=> FavoritesController());
    Get.lazyPut<NearbyOffersController>(()=> NearbyOffersController());
    Get.lazyPut<OfferDetailsController>(()=> OfferDetailsController());
  }
}

class TicketListBinding extends Bindings{

 @override
  void dependencies(){
    Get.lazyPut<TicketListController>(()=> TicketListController());
  }
}
