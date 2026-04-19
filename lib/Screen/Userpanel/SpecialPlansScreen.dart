import 'package:flutter/material.dart';
import 'package:eastnshop/Constants/app_colors.dart';

import '../../Constants/GlobalVariables.dart';
import '../../Utils/ApiService.dart';
import '../../Utils/SharedPrefUtils.dart';
import '../AdminPanel/AdminDashboard/HomePage.dart';
import '../DrawerScreen.dart';
import 'Customappbar.dart';
import 'UserDashboard/UserHome.dart';

class SpecialPlansScreen extends StatefulWidget {
  const SpecialPlansScreen({super.key});

  @override
  State<SpecialPlansScreen> createState() => _SpecialPlansScreenState();
}

class _SpecialPlansScreenState extends State<SpecialPlansScreen> {
  int selectedPlanIndex = -1;
  bool isLoading = false;
  bool hasActiveSubscription = false;
  Map<String, dynamic>? subscriptionData;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      // Get user ID from SharedPreferences
      await SharedPrefUtils.init();
      String? userIdStr = SharedPrefUtils.getString('user_id');

      if (userIdStr == null || userIdStr.isEmpty) {
        _selectMostPopularPlan();
        return;
      }

      int? userId = int.tryParse(userIdStr);
      if (userId == null || userId <= 0) {
        _selectMostPopularPlan();
        return;
      }

      // Fetch subscription details
      Map<String, dynamic> result = await ApiService.getSubscriptionDetails(
        userId,
      );

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          subscriptionData = result['data'];
          String planType =
              subscriptionData?['plan']?.toString().toLowerCase() ?? '';
          String status =
              subscriptionData?['status']?.toString().toLowerCase() ?? '';

          // Check if it's a trial plan or active subscription (but not trial)
          hasActiveSubscription = status == 'active' && planType != 'trial';
        });

        if (!hasActiveSubscription) {
          _selectMostPopularPlan();
        }
      } else {
        _selectMostPopularPlan();
      }
    } catch (e) {
      _selectMostPopularPlan();
    }
  }

  void _selectMostPopularPlan() {
    for (int i = 0; i < plans.length; i++) {
      if (plans[i].isPopular) {
        setState(() {
          selectedPlanIndex = i;
        });
        break;
      }
    }
  }

  // Regular subscription plans
  final List<SubscriptionPlan> regularPlans = [
    SubscriptionPlan(
      duration: "1 months",
      adsCount: "6 offer",
      price: "₹50",
      isPopular: false,
      savings: null,
      borderColor: Colors.grey.shade300,
      apiPlan: "1m",
    ),
    SubscriptionPlan(
      duration: "3 months",
      adsCount: "21 offer",
      price: "₹150",
      isPopular: false,
      savings: "Save 25%",
      borderColor: Colors.grey.shade300,
      apiPlan: "3m",
    ),
    SubscriptionPlan(
      duration: "6 months",
      adsCount: "45 offer",
      price: "₹300",
      isPopular: true,
      savings: "Save 40%",
      borderColor: AppColors.primaryRed,
      apiPlan: "6m",
    ),
    SubscriptionPlan(
      duration: "1 year",
      adsCount: "100 offer",
      price: "₹600",
      isPopular: false,
      savings: null,
      borderColor: Colors.grey.shade300,
      apiPlan: "1y",
    ),
  ];

  // Single ad plan for active subscribers
  final List<SubscriptionPlan> activeSubscriberPlans = [
    SubscriptionPlan(
      duration: "Recommended extra plan",
      adsCount: "1 offer",
      price: "₹10",
      isPopular: true,
      savings: null,
      borderColor: AppColors.primaryRed,
      apiPlan: "1 offer",
    ),
  ];

  // Get the appropriate plans list based on subscription status
  List<SubscriptionPlan> get plans {
    return hasActiveSubscription ? activeSubscriberPlans : regularPlans;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Simply navigate back to previous screen
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBarWithDrawer(),
        drawer: const DrawerScreen(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Special Plans",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    _buildHeader(),
                    SizedBox(height: 8),
                    _buildPlansList(),
                    const SizedBox(height: 20),
                    _buildSubscribeButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Special Plans",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String planType = subscriptionData?['plan']?.toString().toLowerCase() ?? '';
    String status = subscriptionData?['status']?.toString().toLowerCase() ?? '';
    bool isTrialPlan = planType == 'trial' && status == 'active';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        hasActiveSubscription
            ? "You have an active subscription! Purchase individual ads below."
            : isTrialPlan
            ? "You're on a trial plan. Choose a subscription plan to continue."
            : "Pick the right plan for you.",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return Column(
      children:
          plans.asMap().entries.map((entry) {
            int index = entry.key;
            SubscriptionPlan plan = entry.value;
            return _buildPlanCard(plan, index);
          }).toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    return GestureDetector(
      onTap: () {
        _showSubscriptionDialog(plan, index);
      },
      child: Column(
        children: [
          if (plan.isPopular && selectedPlanIndex == index)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9900),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Text(
                "Most Popular",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          // Main Plan Card
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedPlanIndex == index
                        ? Color(0xFFFF9900)
                        : Colors.grey.shade300,
                width: selectedPlanIndex == index ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color:
                  selectedPlanIndex == index
                      ? AppColors.primaryRed.withValues(alpha: 0.05)
                      : Colors.white,
            ),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.duration,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.adsCount,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              plan.price,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Savings Badge
                if (plan.savings != null)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            plan.savings!.contains("25%")
                                ? Colors.orange
                                : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        plan.savings!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed:
            (isLoading || selectedPlanIndex < 0)
                ? null
                : () async {
                  await _handleSubscriptionConfirmation(
                    plans[selectedPlanIndex],
                  );
                },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              (isLoading || selectedPlanIndex < 0)
                  ? Colors.grey
                  : Color(0xFFFF9900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  selectedPlanIndex >= 0
                      ? (hasActiveSubscription
                          ? "Proceed To Pay"
                          : "Activate Plan")
                      : "Select a Plan First",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
      ),
    );
  }

  void _showSubscriptionDialog(SubscriptionPlan plan, int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.duration,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.adsCount,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Select this plan
                      setState(() {
                        selectedPlanIndex = index;
                      });
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('${plan.duration} plan selected!'),
                      //     backgroundColor: Colors.green,
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9900),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      hasActiveSubscription
                          ? "Add To Offer"
                          : "Select This Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubscriptionConfirmation(SubscriptionPlan plan) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the subscription API
      Map<String, dynamic> result = await ApiService.subscribeToPlan(
        plan.apiPlan,
      );

      if (result['success'] == true) {
        // Subscription successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasActiveSubscription
                  ? 'Ad purchased successfully!'
                  : '${plan.duration} subscription activated successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to previous screen after successful subscription
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        // Subscription failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasActiveSubscription
                  ? 'Ad purchase failed: ${result['error']}'
                  : 'Subscription failed: ${result['error']}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class SubscriptionPlan {
  final String duration;
  final String adsCount;
  final String price;
  final bool isPopular;
  final String? savings;
  final Color borderColor;
  final String apiPlan;

  SubscriptionPlan({
    required this.duration,
    required this.adsCount,
    required this.price,
    required this.isPopular,
    this.savings,
    required this.borderColor,
    required this.apiPlan,
  });
}
