import 'package:eastnshop/Screen/AdminPanel/ActiveOffer.dart';
import 'package:eastnshop/Screen/AdminPanel/ShopDetails/AddShop.dart';
import 'package:eastnshop/Constants/app_colors.dart';
import 'package:eastnshop/Screen/AdminPanel/CreateOffer/CreateOffer.dart';
import 'package:eastnshop/Screen/AdminPanel/ShopDetails/Shopdetails.dart';
import 'package:eastnshop/Screen/DrawerScreen.dart';
import 'package:eastnshop/Screen/Userpanel/Customappbar.dart'; 
import 'package:eastnshop/Constants/GlobalVariables.dart';
import 'package:eastnshop/Utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:developer' as developer;
import 'dart:async';

import '../InactiveOffersPage.dart';
import '../../../../Utils/ImageCacheHelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  int _currentBannerIndex = 0;

  // Dynamic carousel images from API
  List<Map<String, dynamic>> _carouselImages = [];
  bool _isLoadingImages = true;
  String _errorMessage = '';

  // Auto-play functionality
  Timer? _autoPlayTimer;
  bool _isAutoPlaying = true;

  final Color primaryRed = const Color(0xFFEB1C23);
  final Color brandBlue = Colors.blue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Do not override globalUser here; respect persisted view_mode
    // Fetch carousel images from API
    _fetchCarouselImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Do not override globalUser here; respect persisted view_mode
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Fetch carousel images from API
  Future<void> _fetchCarouselImages() async {
    try {
      developer.log('🖼️ Fetching carousel images from API');
      
      final images = await ApiService.getMediaImages();
      
      if (mounted) {
        setState(() {
          _carouselImages = images;
          _isLoadingImages = false;
          _errorMessage = '';
        });
        
        developer.log('✅ Carousel images loaded successfully: ${images.length} images');
        
        // Start auto-play after images are loaded
        if (images.isNotEmpty) {
          _startAutoPlay();
        }
      }
    } catch (e) {
      developer.log('❌ Error fetching carousel images: $e');
      
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
          _errorMessage = 'Failed to load images';
          // Fallback to default images if API fails
          _carouselImages = [
            {'filename': 'banner1.png', 'url': 'assets/banner1.png'},
            {'filename': 'banner2.png', 'url': 'assets/banner2.png'},
            {'filename': 'banner3.png', 'url': 'assets/banner3.png'},
          ];
        });
        
        // Start auto-play with fallback images
        _startAutoPlay();
      }
    }
  }

  // Start auto-play timer
  void _startAutoPlay() {
    if (_carouselImages.length <= 1) return; // Don't auto-play if only one image
    
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isAutoPlaying && mounted) {
        _nextImage();
      }
    });
    
    developer.log('🔄 Auto-play started: changing images every 2 seconds');
  }

  // Stop auto-play timer
  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _isAutoPlaying = false;
    developer.log('⏸️ Auto-play stopped');
  }

  // Resume auto-play timer
  void _resumeAutoPlay() {
    if (_carouselImages.length <= 1) return;
    
    _isAutoPlaying = true;
    _startAutoPlay();
    developer.log('▶️ Auto-play resumed');
  }

  // --- WIDGET: THE LOCKED BANNER CAROUSEL ---
  Widget _buildCompactNarrowCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _carouselImages.length,
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
                currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            bool isFocused = _currentBannerIndex == index;
            final imageData = _carouselImages[index];
            final imageUrl = imageData['url'] ?? '';
            return AnimatedScale(
              scale: isFocused ? 1.0 : 0.80,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryRed, width: 2.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: imageUrl.startsWith('http')
                      ? CachedNetworkImg(imageUrl: imageUrl,
fit: BoxFit.fill,)
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            developer.log('❌ Error loading asset: $imageUrl');
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentBannerIndex == i ? 18.0 : 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentBannerIndex == i ? primaryRed : brandBlue.withOpacity(0.2),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Navigate to next image
  void _nextImage() {
    if (_carouselImages.isEmpty) return;
    
    int nextIndex = (currentIndex + 1) % _carouselImages.length;
    
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to previous image
  void _previousImage() {
    if (_carouselImages.isEmpty) return;
    
    int prevIndex = currentIndex == 0 ? _carouselImages.length - 1 : currentIndex - 1;
    
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
          appBar: const CustomAppBarWithDrawer(),
      drawer: const DrawerScreen(), // Your drawer widget
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Top Image Carousel
            SizedBox(
              height: 200,
              child: _isLoadingImages
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    )
                  : _carouselImages.isEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'No images available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : _buildCompactNarrowCarousel(),
            ),

            const SizedBox(height: 8),

            /// Dot Indicator
            // Indicator handled inside _buildCompactNarrowCarousel

            const SizedBox(height: 20),

            /// Top Action Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddShop()));
                        },
                        child: _homeIconButton('Add Shop', 'assets/add_shop.png')),
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOfferPage())),
                        child: _homeIconButton('Add Offer', 'assets/add_offer.png')),

                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveOffersPage())),
                        child: _homeIconButton('Active Offer', 'assets/active_offer.png')),
                    InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InactiveOffersPage())),
                        child: _homeIconButton('Inactive Offer', 'assets/img_2.png',  )),
                  ],)
                ],
              ),
            ),

            const SizedBox(height: 30),


              Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                                height: 35, // Adjust height if needed
                                child: ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ShopDetailsPage()),
                                    );


                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black, // Button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30), // Rounded edges
                                    ),   
                                  ),
                                  child: const Text(
                                    "Manage Shops",
                                    style: TextStyle(
                                      color: Colors.white, // Text color
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        ),

            // /// Section Title
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, bottom: 10),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       'Create new you want!',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16,
            //         fontFamily: 'Poppins',
            //       ),
            //     ),
            //   ),
            // ),

            // /// Bottom Action Row
            // Container(
            //   margin: const EdgeInsets.symmetric(horizontal: 10),
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _homeIconButton('Reels', 'assets/reels.png'),
            //       _homeIconButton('Banners', 'assets/banner_icon.png'),
            //       _homeIconButton('Rewards', 'assets/reward.png'),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 20),
        
        
        
          ],
        ),
      ),
    );
  }

  Widget _homeIconButton(String label, String assetPath) {
    return Column(
      children: [
        Image.asset(assetPath, height: 40, width: 40),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
