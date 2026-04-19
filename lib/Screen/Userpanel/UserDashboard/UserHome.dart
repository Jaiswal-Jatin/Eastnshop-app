import 'package:eastnshop/Screen/AdminPanel/Notification/AdminNotification.dart';
import 'package:eastnshop/Screen/DrawerScreen.dart';
import 'package:eastnshop/Screen/Userpanel/OfferDetailsPage.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/SearchOfferpage.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/FavoritesPage.dart';
import 'package:eastnshop/Screen/Userpanel/UserDashboard/CategoryOffersPage.dart';
import 'package:eastnshop/Screen/Userpanel/SpecialPlansScreen.dart';
import 'package:eastnshop/Controllers/FavoritesController.dart';
import 'package:eastnshop/Controllers/NearbyOffersController.dart';
import 'package:eastnshop/Constants/GlobalVariables.dart';
import 'package:eastnshop/Utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eastnshop/Utils/ImageCacheHelper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final FavoritesController favoritesController = Get.put(
    FavoritesController(),
  );
  final NearbyOffersController nearbyController = Get.put(
    NearbyOffersController(),
  );

  // Dynamic carousel images from API
  List<Map<String, dynamic>> carouselImages = [];
  bool isLoadingCarousel = true;
  bool hasCarouselError = false;

  // Dynamic middle banner image from API
  Map<String, dynamic>? middleBannerImage;
  bool isLoadingMiddleBanner = true;
  bool hasMiddleBannerError = false;

  // Dynamic bottom banner image from API
  Map<String, dynamic>? bottomBannerImage;
  bool isLoadingBottomBanner = true;
  bool hasBottomBannerError = false;

  List<Product> filtered = [];
  bool showList = false;
  final Color brandOrange = Colors.orange;
  final Color brandBlue = Colors.blue;
  static const Duration _minimumShimmerDuration = Duration(milliseconds: 300);

  Future<void> _ensureMinimumShimmer(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minimumShimmerDuration) {
      await Future.delayed(_minimumShimmerDuration - elapsed);
    }
  }

  @override
  void initState() {
    super.initState();
    // Respect globalUser/view_mode; just initialize controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize favorites controller
      favoritesController.getUserId();
      // Nearby offers controller is already initialized and will fetch offers automatically
    });

    // Load carousel images from API
    _loadCarouselImages();
    // Load middle banner image from API
    _loadMiddleBannerImage();
    // Load bottom banner image from API
    _loadBottomBannerImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Do not override globalUser here; respect persisted view_mode
    // Refresh nearby offers when page becomes active (e.g., returning from AddShop)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nearbyController.refreshOffers();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // Load carousel images from API
  Future<void> _loadCarouselImages() async {
    final startedAt = DateTime.now();
    try {
      setState(() {
        isLoadingCarousel = true;
        hasCarouselError = false;
      });

      final images = await ApiService.getCarouselImages();
      await _ensureMinimumShimmer(startedAt);

      if (mounted) {
        setState(() {
          carouselImages = images;
          isLoadingCarousel = false;
          hasCarouselError = images.isEmpty;
        });

        // Auto-play is handled by CarouselSlider
      }
    } catch (e) {
      await _ensureMinimumShimmer(startedAt);
      if (mounted) {
        setState(() {
          isLoadingCarousel = false;
          hasCarouselError = true;
        });
      }
      print('Error loading carousel images: $e');
    }
  }

  // Load middle banner image from API
  Future<void> _loadMiddleBannerImage() async {
    final startedAt = DateTime.now();
    try {
      setState(() {
        isLoadingMiddleBanner = true;
        hasMiddleBannerError = false;
      });

      final imageData = await ApiService.getImage1();
      await _ensureMinimumShimmer(startedAt);

      if (mounted) {
        setState(() {
          middleBannerImage = imageData;
          isLoadingMiddleBanner = false;
          hasMiddleBannerError = imageData == null;
        });
      }
    } catch (e) {
      await _ensureMinimumShimmer(startedAt);
      if (mounted) {
        setState(() {
          isLoadingMiddleBanner = false;
          hasMiddleBannerError = true;
        });
      }
      print('Error loading middle banner image: $e');
    }
  }

  // Load bottom banner image from API
  Future<void> _loadBottomBannerImage() async {
    final startedAt = DateTime.now();
    try {
      setState(() {
        isLoadingBottomBanner = true;
        hasBottomBannerError = false;
      });

      final imageData = await ApiService.getImage2();
      await _ensureMinimumShimmer(startedAt);

      if (mounted) {
        setState(() {
          bottomBannerImage = imageData;
          isLoadingBottomBanner = false;
          hasBottomBannerError = imageData == null;
        });
      }
    } catch (e) {
      await _ensureMinimumShimmer(startedAt);
      if (mounted) {
        setState(() {
          isLoadingBottomBanner = false;
          hasBottomBannerError = true;
        });
      }
      print('Error loading bottom banner image: $e');
    }
  }

  // Auto play is handled internally by CarouselSlider options

  Widget _buildShimmerBlock({
    double? width,
    required double height,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: _Shimmer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerShimmer({required EdgeInsetsGeometry margin}) {
    return _buildShimmerBlock(
      height: 200,
      margin: margin,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildCarouselShimmer() {
    return Column(
      children: [
        _buildShimmerBlock(
          height: 240,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => _buildShimmerBlock(
              width: index == 1 ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersLoadingShimmer() {
    return Column(
      children: [
        for (int section = 0; section < 2; section++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBlock(
                  width: 120,
                  height: 18,
                  borderRadius: BorderRadius.circular(10),
                ),
                _buildShimmerBlock(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBlock(
                        height: 120,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildShimmerBlock(width: 120, height: 12),
                      const SizedBox(height: 8),
                      _buildShimmerBlock(width: 70, height: 12),
                      const SizedBox(height: 8),
                      _buildShimmerBlock(width: 95, height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Build middle banner widget
  Widget _buildMiddleBanner() {
    if (isLoadingMiddleBanner) {
      return _buildBannerShimmer(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    }

    if (hasMiddleBannerError || middleBannerImage == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No banner image available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadMiddleBannerImage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final imageUrl = middleBannerImage!['url'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImg(imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,),
      ),
    );
  }

  // Build bottom banner widget
  Widget _buildBottomBanner() {
    if (isLoadingBottomBanner) {
      return _buildBannerShimmer(
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
    }

    if (hasBottomBannerError || bottomBannerImage == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No banner image available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadBottomBannerImage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final imageUrl = bottomBannerImage!['url'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImg(imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,),
      ),
    );
  }

  // Build carousel banner widget
  Widget _buildCarouselBanner() {
    if (isLoadingCarousel) {
      return _buildCarouselShimmer();
    }

    if (hasCarouselError || carouselImages.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No banner images available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCarouselImages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: carouselImages.length,
          options: CarouselOptions(
            aspectRatio: 1.5,
            autoPlay: true,
            enlargeCenterPage: true,
            enlargeFactor: 0.35,
            viewportFraction: 0.36,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOutBack,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
                _currentBanner = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            bool isFocused = _currentBannerIndex == index;
            final imageData = carouselImages[index];
            final imageUrl = imageData['url'] ?? '';
            return AnimatedScale(
              scale: isFocused ? 1.0 : 0.80,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(15),
                //   border: Border.all(color: brandOrange, width: 2.2),
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: CachedNetworkImg(imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    // width: double.infinity,)
                  ),
              ),
            ));
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselImages.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentBannerIndex == i ? 18.0 : 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color:
                    _currentBannerIndex == i
                        ? brandOrange
                        : brandBlue.withOpacity(0.2),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        titleSpacing: 0, // Removes default left padding
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Row(
          children: [
            Image.asset('assets/ENS_Logo_1.png', height: 50, width: 50),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Search best offers",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Heart icon for favorites
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Obx(
                () => Icon(
                  Icons.favorite,
                  size: 26,
                  color:
                      favoritesController.favorites.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            ),
          ),
          // Notification icon
          // InkWell(
          //   onTap: () {
          //     // Replace with your navigation
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const ShopkeeperNotificationScreen()),
          //     );
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 12),
          //     child: Image.asset(
          //       'assets/notification.png',
          //       height: 26,
          //       width: 26,
          //       color: Colors.grey,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 🔥 SLIDING BANNER (PageView) - Dynamic from API
            SizedBox(height: 280, child: _buildCarouselBanner()),

            // Indicator handled inside _buildCarouselBanner
            const SizedBox(height: 20),

            // // ⭐ NEARBY OFFERS TITLE
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         "Nearby Offers",
            //         style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black),
            //       ),
            //
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 10),
            RefreshIndicator(
              onRefresh: nearbyController.refreshOffers,
              child: Obx(() {
                if (nearbyController.isLoadingLocation.value ||
                    nearbyController.isLoadingOffers.value) {
                  return _buildOffersLoadingShimmer();
                } else if (nearbyController.hasError) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_off, color: Colors.orange[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  Text(
                                    nearbyController.errorMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: nearbyController.forceRefresh,
                                  child: const Text('Retry'),
                                ),
                                TextButton(
                                  onPressed:
                                      nearbyController.useDefaultLocation,
                                  child: const Text('Use Default'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (!nearbyController.hasOffers) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Circle background for the icon
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            const Text(
                              'No Nearby Offers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Display offers grouped by type with banner after 2 categories
                  List<Widget> allWidgets = [];
                  int categoryCount = 0;
                  bool bannerShown = false;

                  // Count total categories with offers
                  int totalCategoriesWithOffers = 0;
                  for (int i = 0; i < nearbyController.offerTypes.length; i++) {
                    final offerType = nearbyController.offerTypes[i];
                    final offers = nearbyController.getOffersByType(offerType);
                    if (offers.isNotEmpty) {
                      totalCategoriesWithOffers++;
                    }
                  }

                  for (int i = 0; i < nearbyController.offerTypes.length; i++) {
                    final offerType = nearbyController.offerTypes[i];
                    final offers = nearbyController.getOffersByType(offerType);
                    if (offers.isEmpty) continue;

                    // Add offer type title with View All button
                    allWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              // decoration: BoxDecoration(
                              //   color: Color(0xFFFF9900),
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              child: Text(
                                offerType,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // View All button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CategoryOffersPage(
                                          category: offerType.toLowerCase(),
                                          categoryTitle: offerType,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                // decoration: BoxDecoration(
                                //   color: Colors.grey.shade100,
                                //   borderRadius: BorderRadius.circular(20),
                                //   border: Border.all(color: Colors.grey.shade300),
                                // ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Color(0xFFFF9900),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    // Add offers (limit to 5 per category, show recently added first)
                    final reversedOffers = offers.reversed.toList();
                    final offersToShow =
                        reversedOffers.length > 5 ? reversedOffers.take(5).toList() : reversedOffers;
                    allWidgets.add(
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: offersToShow.length,
                          itemBuilder: (context, index) {
                            final offer = offersToShow[index];
                            return nearbyOfferCard(offer);
                          },
                        ),
                      ),
                    );

                    allWidgets.add(const SizedBox(height: 16));

                    // Count categories and add banner after 2 categories
                    categoryCount++;
                    if (categoryCount == 2 && !bannerShown) {
                      allWidgets.add(_buildMiddleBanner());
                      bannerShown = true; // Mark banner as shown
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: allWidgets,
                  );
                }
              }),
            ),

            const SizedBox(height: 20),

            // 🪔 FESTIVAL OFFERS SECTION - Show only if more than 3 categories
            Obx(() {
              // Count total categories with offers
              int totalCategoriesWithOffers = 0;
              for (int i = 0; i < nearbyController.offerTypes.length; i++) {
                final offerType = nearbyController.offerTypes[i];
                final offers = nearbyController.getOffersByType(offerType);
                if (offers.isNotEmpty) {
                  totalCategoriesWithOffers++;
                }
              }

              // Show bottom banner only if there are more than 2 categories
              if (totalCategoriesWithOffers > 2) {
                return _buildBottomBanner();
              } else {
                return const SizedBox.shrink(); // Hide bottom banner
              }
            }),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  // Nearby Offer Card
  Widget nearbyOfferCard(Map<String, dynamic> offer) {
    final offerId = offer['id']?.toString() ?? '0';
    final distance =
        offer['distance_m'] != null
            ? nearbyController.getFormattedDistance(
              offer['distance_m'].toDouble(),
            )
            : '0m';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsPage(offerId: offerId),
          ),
        );
      },
      child: Container(
        width: 170,

        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with heart icon and distance
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _buildOfferImage(offer),
                ),
                // Distance badge
                // Positioned(
                //   top: 8,
                //   left: 8,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.7),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Text(
                //       '${distance}',
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 10,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                // Heart icon overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(
                    () => GestureDetector(
                      onTap: () {
                        final itemData = {
                          'id': offerId,
                          'offer_id': int.tryParse(offerId) ?? 0,
                          'title': offer['product_name'] ?? 'Unknown Product',
                          'discount': offer['offer_type'] ?? 'Offer',
                          'image': offer['photo_url'],
                          'type': 'offer',
                        };

                        if (favoritesController.isFavorite(offerId)) {
                          favoritesController.removeFromFavorites(offerId);
                        } else {
                          favoritesController.addToFavorites(itemData);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          favoritesController.isFavorite(offerId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color:
                              favoritesController.isFavorite(offerId)
                                  ? Colors.red
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offer type badge
                  // if (offer['offer_type'] != null)
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  //     decoration: BoxDecoration(
                  //       color: Colors.red,
                  //       borderRadius: BorderRadius.circular(4),
                  //     ),
                  //     child: Text(
                  //       offer['offer_type'],
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 10,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  const SizedBox(height: 4),
                  // Product name
                  Text(
                    offer['product_name'] ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Discount badge (from API or computed)
                  Builder(
                    builder: (context) {
                      String? discountLabel = offer['discount']?.toString();
                      if ((discountLabel == null || discountLabel.isEmpty) &&
                          offer['product_price'] != null &&
                          offer['offer_price'] != null) {
                        final String pp = offer['product_price'].toString();
                        final String op = offer['offer_price'].toString();
                        final double? product = double.tryParse(pp);
                        final double? offerP = double.tryParse(op);
                        if (product != null &&
                            offerP != null &&
                            product > 0 &&
                            offerP <= product) {
                          final double pct =
                              ((product - offerP) / product) * 100.0;
                          discountLabel = "${pct.toStringAsFixed(0)}%";
                        }
                      }
                      if (discountLabel == null || discountLabel.isEmpty)
                        return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade400),
                        ),
                        child: Text(
                          '↓$discountLabel',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 6),
                  // Price
                  if (offer['offer_price'] != null &&
                      offer['product_price'] != null)
                    Row(
                      children: [
                        Text(
                          '₹${offer['offer_price']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${offer['product_price']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
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

  /// Build offer image widget - handles multiple images properly
  Widget _buildOfferImage(Map<String, dynamic> offer) {
    // First try to get image from 'images' array (full URLs)
    if (offer['images'] != null &&
        offer['images'] is List &&
        (offer['images'] as List).isNotEmpty) {
      final images = offer['images'] as List;
      final firstImageUrl = images.first.toString();

      return Stack(
        children: [
          Image.network(firstImageUrl,
height: 120,
            width: double.infinity,
            fit: BoxFit.cover,),
          // Show multiple images indicator if more than 1 image
          // if (images.length > 1)
          //   Positioned(
          //     top: 8,
          //     left: 8,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.7),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const Icon(
          //             Icons.photo_library,
          //             color: Colors.white,
          //             size: 12,
          //           ),
          //           const SizedBox(width: 2),
          //           Text(
          //             '${images.length}',
          //             style: const TextStyle(
          //               color: Colors.white,
          //               fontSize: 10,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      );
    }

    // Fallback: try to parse photo_url JSON string
    if (offer['photo_url'] != null &&
        offer['photo_url'].toString().isNotEmpty) {
      try {
        final photoUrlString = offer['photo_url'].toString();

        // Check if it's a JSON array string
        if (photoUrlString.startsWith('[') && photoUrlString.endsWith(']')) {
          final List<dynamic> photoUrls = jsonDecode(photoUrlString);
          if (photoUrls.isNotEmpty) {
            final firstPhotoPath = photoUrls.first.toString();
            // Convert relative path to full URL
            final fullUrl = 'https://eastnshoptech.cloud/$firstPhotoPath';

            return Stack(
              children: [
                Image.network(fullUrl,
height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,),
                // Show multiple images indicator if more than 1 image
                if (photoUrls.length > 1)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${photoUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
        } else {
          // Single photo URL
          return Image.network(photoUrlString,
height: 120,
            width: double.infinity,
            fit: BoxFit.cover,);
        }
      } catch (e) {
        print('Error parsing photo_url: $e');
      }
    }

    // Default placeholder
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  // Reusable Offer Card (keeping for backward compatibility)
  Widget offerCard(String imagePath, String discount, String title) {
    // Create a unique numeric ID for this offer based on content hash
    final contentHash = '${imagePath}_${discount}_${title}'.hashCode.abs();
    final offerId = contentHash.toString();

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with heart icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Heart icon overlay
              Positioned(
                top: 8,
                right: 8,
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      final itemData = {
                        'id': offerId,
                        'offer_id': int.parse(offerId),
                        'title': title,
                        'discount': discount,
                        'image': imagePath,
                        'type': 'offer',
                      };

                      if (favoritesController.isFavorite(offerId)) {
                        favoritesController.removeFromFavorites(offerId);
                      } else {
                        favoritesController.addToFavorites(itemData);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        favoritesController.isFavorite(offerId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color:
                            favoritesController.isFavorite(offerId)
                                ? Colors.red
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Discount Tag
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              discount,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Product Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String description;

  Product({required this.name, required this.description});
}

final List<Product> allProducts = [
  Product(name: "Active Offer", description: " "),
  Product(name: "Favorite Offer", description: " "),
];

class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - (2.0 * _controller.value), 0),
              end: Alignment(1.0 - (2.0 * _controller.value), 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.35, 0.7],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}
