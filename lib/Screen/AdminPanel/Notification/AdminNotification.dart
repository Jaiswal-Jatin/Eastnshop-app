import 'package:eastnshop/Screen/DrawerScreen.dart';
import 'package:eastnshop/Screen/Userpanel/Customappbar.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/UserHome.dart';
import 'package:eastnshop/Screen/AdminPanel/AdminDashboard/HomePage.dart';
import 'package:eastnshop/Constants/GlobalVariables.dart';
import 'package:flutter/material.dart';

class ShopkeeperNotificationScreen extends StatelessWidget {
  const ShopkeeperNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "New Order Received",
        "subtitle": "Order #1234 placed by John",
        "time": "2 min ago",
        "icon": "shopping_cart",
        "color": Colors.red,
        "isRead": false,
      },
      {
        "title": "Offer Approved",
        "subtitle": "Your Diwali offer is live now!",
        "time": "10 min ago",
        "icon": "local_offer",
        "color": Colors.red,
        "isRead": false,
      },
      {
        "title": "Ticket Resolved",
        "subtitle": "Your query has been resolved by support.",
        "time": "1 hr ago",
        "icon": "support_agent",
        "color": Colors.red,
        "isRead": true,
      },
      {
        "title": "Account Verified",
        "subtitle": "Your shop details have been verified.",
        "time": "Yesterday",
        "icon": "verified_user",
        "color": Colors.red,
        "isRead": true,
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => globalUser.value == true ? Home() : Home(),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: const CustomAppBarWithDrawer(),
        drawer: const DrawerScreen(),
        body: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => globalUser.value == true ? Home() : Home(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${notifications.where((n) => !n['isRead']).length}",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(notif, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, BuildContext context) {
    final isRead = notif['isRead'] as bool;
    final color = notif['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle notification tap
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(notif['icon'] ?? ''),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] ?? '',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF9900),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['subtitle'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif['time'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'local_offer':
        return Icons.local_offer_outlined;
      case 'support_agent':
        return Icons.support_agent_outlined;
      case 'verified_user':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
