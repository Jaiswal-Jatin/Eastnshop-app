import 'dart:convert';
import 'dart:typed_data';
import 'package:eastnshop/Controllers/shopController.dart';
import 'package:eastnshop/Models/ShopModel.dart';
import 'package:eastnshop/Screen/AdminPanel/ShopDetails/AddShop.dart';
import 'package:eastnshop/Screen/AdminPanel/ShopDetails/EditShop.dart';
import 'package:eastnshop/Screen/DrawerScreen.dart';
import 'package:eastnshop/Screen/Userpanel/Customappbar.dart'
    show CustomAppBarWithDrawer;
import 'package:eastnshop/Constants/app_colors.dart';
import 'package:eastnshop/Constants/CommonWidgets.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late ShopListController shopController;
  late ShopController shopFormController;

  @override
  void initState() {
    super.initState();
    shopController = Get.put(ShopListController());
    shopFormController = Get.put(ShopController());

    // Defer the API call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopController.fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'My Shops',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => shopController.refreshShops(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddShop()),
              );
              shopController.refreshShops();
            },
          ),
        ],
      ),
      drawer: const DrawerScreen(),
      body: Obx(() {
        if (shopController.isLoadingShops.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
          );
        }

        if (shopController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  shopController.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => shopController.refreshShops(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (shopController.shops.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 20),
                Text(
                  'No Shops Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddShop()),
                    );
                    shopController.refreshShops();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Add Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: RefreshIndicator(
            onRefresh: () => shopController.refreshShops(),
            color: AppColors.primaryRed,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shopController.shops.length,
              itemBuilder: (context, index) {
                final shop = shopController.shops[index];
                return _buildShopCard(context, shop);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Image
            GestureDetector(
              onTap:
                  shop.photoUrl.isNotEmpty
                      ? () => _showFullImageDialog(context, shop.photoUrl)
                      : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[200],
                  child:
                      shop.photoUrl.isNotEmpty
                          ? _buildShopImage(shop.photoUrl)
                          : const Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Right Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Owner Name
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shop.ownerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shop.shopAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (shop.pinCode.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PIN: ${shop.pinCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          shopFormController.populateFormForEdit(shop);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateShop(shop: shop),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          padding: const EdgeInsets.all(6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showDeleteDialog(context, shop),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.all(6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getShopTypeColor(String shopType) {
    switch (shopType.toLowerCase()) {
      case 'book store':
        return const Color(0xFF4CAF50); // Green
      case 'electronics':
        return const Color(0xFF2196F3); // Blue
      case 'clothing':
        return const Color(0xFFE91E63); // Pink
      case 'food':
        return const Color(0xFFFF9800); // Orange
      case 'pharmacy':
        return const Color(0xFF9C27B0); // Purple
      case 'grocery':
        return const Color(0xFF4CAF50); // Green
      case 'furniture':
        return const Color(0xFF795548); // Brown
      case 'automotive':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return const Color(0xFF4CAF50); // Default Green
    }
  }

  Widget _buildShopImage(String photoUrl) {
    // Check if it's a base64 image or a URL
    if (photoUrl.startsWith('data:image')) {
      // Handle base64 image
      try {
        // Extract base64 data from data URL
        String base64Data = photoUrl.split(',')[1];
        Uint8List bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        );
      } catch (e) {
        return _buildPlaceholderImage();
      }
    } else if (photoUrl.isNotEmpty) {
      // Handle URL image
      String fullUrl =
          photoUrl.startsWith('http')
              ? photoUrl
              : 'https://eastnshoptech.cloud/$photoUrl';

      return Image.network(fullUrl, fit: BoxFit.cover);
    } else {
      // No image available
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.store_outlined,
              size: 32,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Full screen image
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildShopImage(photoUrl),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ShopModel shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primaryRed,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Delete Shop',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${shop.shopName}"?',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween, // spread buttons
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 15)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await shopController.deleteShop(shop.id);
                if (success) {
                  await shopController.refreshShops();
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete', style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );
  }
}
