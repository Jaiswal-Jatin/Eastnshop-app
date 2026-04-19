import 'package:eastnshop/Screen/AdminPanel/AdminDashboard/HomePage.dart';
import 'package:eastnshop/Screen/AdminPanel/Notification/AdminNotification.dart';
import 'package:eastnshop/Screen/Userpanel/AboutUs.dart';
import 'package:eastnshop/Constants/app_colors.dart';
import 'package:eastnshop/Screen/Userpanel/FAQPage.dart';
import 'package:eastnshop/Screen/Userpanel/SpecialPlansScreen.dart';
import 'package:eastnshop/Screen/Userpanel/ActivePlansScreen.dart';
import 'package:eastnshop/Screen/Userpanel/Setting.dart/EditProfile.dart';
import 'package:eastnshop/Screen/Userpanel/Setting.dart/SettingPage.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/HelpCenter/HelpCenterPage.dart';
import 'package:eastnshop/Screen/AdminPanel/CreateOffer/PrivacyPolicy.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/UserHome.dart';
import 'package:eastnshop/Utils/SharedPrefUtils.dart';
import 'package:eastnshop/Controllers/LoginController.dart';
import 'package:eastnshop/Constants/GlobalVariables.dart';
import 'package:eastnshop/Routes/App_Pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final RxString userName = 'User'.obs;

  @override
  void initState() {
    super.initState();
    // Defer the state change until after the build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
      _loadUserName();
    });
  }

  Future<void> _checkUserRole() async {
    await SharedPrefUtils.init();
    await initializeGlobalState();
    print(
      "DrawerScreen - User role from SharedPreferences: ${SharedPrefUtils.getString('user_role')}",
    );
    print("DrawerScreen - Is shopkeeper: ${isShopkeeper.value}");
  }

  Future<void> _loadUserName() async {
    await SharedPrefUtils.init();
    String? name = SharedPrefUtils.getString('username');
    if (name != null && name.isNotEmpty) {
      userName.value = name;
    } else {
      // Fallback to user_id if name is not available
      String? userId = SharedPrefUtils.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        userName.value = 'User$userId';
      }
    }
    print("DrawerScreen - Loaded user name: ${userName.value}");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 15, top: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/ENS_Logo_1.png', height: 80, width: 80),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Obx(
                            () => Text(
                              userName.value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.orange,
                                // shadows: [
                                //   Shadow(
                                //     color: Colors.blue,
                                //     offset: Offset(2, 2),
                                //     blurRadius: 1,
                                //   ),
                                // ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Only show the switch button if user is a shopkeeper
                    // Obx(() {
                    //   if (isShopkeeper.value) {
                    //     return InkWell(
                    //       onTap: () async {
                    //         Navigator.pop(context); // Close drawer first
                    //         await switchUserRole();
                    //         final current = Get.currentRoute;
                    //         // Decide target route based on current route to avoid redundant nav
                    //         if (current != AppRoutes.home && globalUser.value == true) {
                    //           print("🚀 Navigating to User Home: ${AppRoutes.home} (from $current)");
                    //           Get.offAllNamed(AppRoutes.home);
                    //         } else if (current != AppRoutes.shopkeeperHome && globalUser.value == false) {
                    //           print("🚀 Navigating to Shopkeeper Home: ${AppRoutes.shopkeeperHome} (from $current)");
                    //           Get.offAllNamed(AppRoutes.shopkeeperHome);
                    //         } else {
                    //           print("ℹ️ Already on target route: $current");
                    //         }
                    //       },
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //             border: Border.all(color: Colors.black),
                    //             color: Colors.black,
                    //             borderRadius: BorderRadius.circular(20),
                    //           ),
                    //           child: Padding(
                    //             padding: EdgeInsets.all(5),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text(
                    //                   globalUser.value == true
                    //                       ? 'User to Shop'
                    //                       : 'Shop to User ',
                    //                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }
                    //   return SizedBox.shrink(); // Hide button if not shopkeeper
                    // }),
                    // InkWell(
                    //     onTap: () {
                    //       Navigator.pop(context); // Close drawer first
                    //       Navigator.push(context, MaterialPageRoute(builder: (context) => ShopkeeperNotificationScreen(),),);
                    //     },
                    //     child: dividerAndRow(text:'Notification',  trailingWidget: Image.asset(
                    //       'assets/Bell.png',
                    //       height: 25,
                    //       width: 25,
                    //       color: Colors.black,
                    //     ),color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage(),
                          ),
                        );
                      },
                      child: dividerAndRow(
                        text: 'Privacy Policy',
                        trailingWidget: Image.asset(
                          'assets/Privacypolicy.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        ),
                        color: Colors.black,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        updateGlobalSettings("true");
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      child: dividerAndRow(
                        text: 'Settings',
                        trailingWidget: Image.asset(
                          'assets/SettingIcon.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        ),
                        color: Colors.black,
                      ),
                    ),
                    //             InkWell(
                    //               onTap: (){
                    //                Navigator.pop(context); // Close drawer first
                    //                Navigator.push(context, MaterialPageRoute(builder: (context)=> HelpCenterPage(),));
                    //               },
                    //               child: dividerAndRow(text:'Help Center',  trailingWidget: Image.asset(
                    //   'assets/HelpQue.png',
                    //   height: 25,
                    //   width: 25,
                    //   color: Colors.black,
                    // ),color: Colors.black)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsPage(),
                          ),
                        );
                      },
                      child: dividerAndRow(
                        text: 'About Us',
                        trailingWidget: Image.asset(
                          'assets/Aboutus.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        ),
                        color: Colors.black,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FAQPage()),
                        );
                      },
                      child: dividerAndRow(
                        text: 'FAQs',
                        trailingWidget: Image.asset(
                          'assets/Faq.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        ),
                        color: Colors.black,
                      ),
                    ),
                    // Only show Active Plans if user is a shopkeeper
                    //  Obx(() {
                    //    if (isShopkeeper.value) {
                    //      return InkWell(
                    //          onTap: (){
                    //            Navigator.pop(context); // Close drawer first
                    //            Navigator.push(context, MaterialPageRoute(builder: (context)=>ActivePlansScreen()));
                    //          },
                    //          child: dividerAndRow(text:'Active Plans',  trailingWidget: Image.asset(
                    //            'assets/reward.png',
                    //            height: 25,
                    //            width: 25,
                    //            color: Colors.black,
                    //          ),color: Colors.black));
                    //    }
                    //    return SizedBox.shrink(); // Hide if not shopkeeper
                    //  }),
                    InkWell(
                      onTap: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 40,
                                        color: Colors.orange.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Title
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 12),

                                    // Content
                                    Text(
                                      'Are you sure you want to logout?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Poppins',
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 30),

                                    // Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                foregroundColor:
                                                    Colors.grey.shade700,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                // Get the LoginController and call logout
                                                final loginController =
                                                    Get.find<LoginController>();
                                                loginController.logout();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.orange.shade600,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: dividerAndRow(
                        text: 'Logout',
                        trailingWidget: Image.asset(
                          'assets/Logout.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        ),
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dividerAndRow({
    required String text,
    required Widget trailingWidget, // Accepts Image.asset, Icon, etc.
    required Color color,
  }) {
    return Column(
      children: [
        Divider(color: Colors.grey),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: color,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Spacer(),
              trailingWidget,
            ],
          ),
        ),
      ],
    );
  }
}
