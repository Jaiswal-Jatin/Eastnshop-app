import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants/GlobalVariables.dart';
import '../Routes/App_Pages.dart';
import '../Services/OtpService.dart';
import '../Utils/ApiService.dart';
import '../Utils/SharedPrefUtils.dart';
import '../Utils/TokenManager.dart';

class LoginController extends GetxController {
  TextEditingController uNameController = TextEditingController();
  TextEditingController eMailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController createPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController userrole = TextEditingController();
  RxBool isUploadingData = false.obs;

  void clearFormFields() {
    uNameController.clear();
    eMailController.clear();
    phoneController.clear();
    otpController.clear();
    createPassController.clear();
    confirmPassController.clear();
    userrole.clear();
    // Clear OTP ticket when form is cleared
    OtpService.clearSignupOtpTicket();
  }

  // Validation functions

  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<Map<String, dynamic>> checkPhoneAlreadyExists(String phone) async {
    final normalizedPhone = phone.trim();

    if (!isValidPhone(normalizedPhone)) {
      return {
        'success': false,
        'exists': false,
        'message': 'Please enter a valid 10-digit phone number',
      };
    }

    const endpoint = '/api/user/check-phone';

    try {
      final response = await ApiService.post(
        endpoint,
        body: {'phone': normalizedPhone, "role": "user"},
        includeAuth: false,
      );

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        data = {'message': response.body};
      }

      final message = (data['message'] ?? '').toString();
      final lowerMessage = message.toLowerCase();

      if (response.statusCode == 200) {
        final exists =
            (data['exists'] == true) ||
            (data['isExists'] == true) ||
            (data['registered'] == true) ||
            (data['is_registered'] == true) ||
            lowerMessage.contains('already') ||
            lowerMessage.contains('exist');

        return {
          'success': true,
          'exists': exists,
          'message':
              exists
                  ? (message.isNotEmpty
                      ? message
                      : 'Phone number already exists')
                  : (message.isNotEmpty
                      ? message
                      : 'Phone number is available'),
        };
      }

      if (response.statusCode == 409) {
        return {
          'success': true,
          'exists': true,
          'message':
              message.isNotEmpty ? message : 'Phone number already exists',
        };
      }

      final likelyExists =
          lowerMessage.contains('already') || lowerMessage.contains('exist');
      return {
        'success': false,
        'exists': likelyExists,
        'message':
            message.isNotEmpty
                ? message
                : 'Unable to validate phone number right now. Please try again.',
      };
    } catch (e) {
      log('Phone existence check failed for $endpoint: $e');
      return {
        'success': false,
        'exists': false,
        'message':
            'Unable to validate phone number right now. Please try again.',
      };
    }
  }

  // Logout method to clear authentication state
  Future<void> logout() async {
    await ApiService.clearAuth();
    await SharedPrefUtils.init();
    await SharedPrefUtils.remove('username'); // Clear username as well
    clearFormFields();

    // Reset global state variables
    resetGlobalState();

    Get.offAllNamed(AppRoutes.appStart);
  }

  Future<Map<String, dynamic>> registerNewUser() async {
    if (uNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        createPassController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      return {
        'success': false,
        'message': 'Please fill all the required fields!',
      };
    }

    // Validate phone number (10 digits)
    if (!isValidPhone(phoneController.text.trim())) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit phone number!',
      };
    }

    // Validate password length (minimum 6 characters)
    if (!isValidPassword(createPassController.text.trim())) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters long!',
      };
    }

    if (createPassController.text.trim() != confirmPassController.text.trim()) {
      return {'success': false, 'message': 'Passwords do not match!'};
    }

    // Check if OTP ticket exists for signup
    final otpTicket = await OtpService.getSignupOtpTicket();
    if (otpTicket == null) {
      log('❌ Registration failed: OTP ticket is null');
      return {
        'success': false,
        'message':
            'OTP verification required. Please verify your phone number first.',
      };
    }
    log('✅ OTP ticket found: ${otpTicket.substring(0, 20)}...');

    isUploadingData.value = true;

    try {
      final body = jsonEncode({
        "username": uNameController.text.trim(),
        "email":
            eMailController.text.trim().isEmpty
                ? ""
                : eMailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": createPassController.text,
        "role": userrole.text,
      });

      log("api/auth/signup : $body");

      final response = await ApiService.postWithCustomHeaders(
        '/api/auth/signup',
        body: {
          "username": uNameController.text.trim(),
          "email":
              eMailController.text.trim().isEmpty
                  ? ""
                  : eMailController.text.trim(),
          "phone": phoneController.text.trim(),
          "password": createPassController.text,
          "role": userrole.text,
        },
        customHeaders: {'x-otp-ticket': otpTicket},
        includeAuth: false, // Registration doesn't need auth
      );

      if (response.statusCode == 201) {
        // Clear the OTP ticket after successful registration
        await OtpService.clearSignupOtpTicket();

        // Save user role to SharedPreferences
        await SharedPrefUtils.init();
        await SharedPrefUtils.setString('user_role', userrole.text);
        log("User role saved to SharedPreferences: ${userrole.text}");

        await Future.delayed(const Duration(seconds: 1));
        clearFormFields();
        Get.toNamed(AppRoutes.login);
        return {'success': true, 'message': 'Registration successful!'};
      } else {
        // Parse error message from response
        String errorMessage = "Registration failed.";
        try {
          dynamic data = jsonDecode(response.body);
          if (data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (e) {
          log('Error parsing response body: $e');
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      log('Exception $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<bool> loginUser() async {
    // Basic validation - UI will handle detailed validation
    if (eMailController.text.isEmpty || confirmPassController.text.isEmpty) {
      return false;
    }

    // Validate mobile number (10 digits)
    if (!isValidPhone(eMailController.text.trim())) {
      return false;
    }

    try {
      print("🚀 CALLING LOGIN API: /api/auth/login");
      print(
        "📦 Payload: {phone: ${eMailController.text.trim()}, password: [MASKED], role: user}",
      );

      final response = await ApiService.post(
        '/api/auth/login',
        body: {
          "phone": eMailController.text.trim(),
          "password": confirmPassController.text.trim(),
          "role": "user",
        },
        includeAuth: false, // Login doesn't need auth
      );

      print("📥 LOGIN RESPONSE STATUS: ${response.statusCode}");
      print("📄 LOGIN RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        String userRole = 'user'; // Default role

        // Parse response to get user role and token
        try {
          dynamic data = jsonDecode(response.body);
          userRole =
              data['user']?['role'] ??
              'user'; // Default to 'user' if role not found
          String token =
              data['accessToken'] ??
              data['token'] ??
              data['access_token'] ??
              ''; // Try different token field names
          int userId =
              data['user']?['id'] ??
              data['id'] ??
              0; // Try different user ID field names
          String username = data['user']?['username'] ?? ''; // Extract username
          String email = data['user']?['email'] ?? '';

          // Validate that we got a valid user ID
          if (userId <= 0) {
            log('Warning: Invalid user ID received from server: $userId');
            // Try to extract from other possible fields
            if (data['user_id'] != null) {
              userId = int.tryParse(data['user_id'].toString()) ?? 0;
            }
            if (userId <= 0) {
              log('Error: No valid user ID found in login response');
            }
          }

          // Debug: Log what tokens we received
          log('🔍 Login response data keys: ${data.keys.toList()}');
          log('🔍 Access token: ${token.isNotEmpty ? "Present" : "Missing"}');
          log(
            '🔍 Refresh token from response: ${data['refresh_token'] ?? data['refreshToken'] ?? data['refresh'] ?? "Missing"}',
          );
          log(
            '🔍 Expires in raw value: ${data['expires_in'] ?? data['expiresIn'] ?? "Missing"}',
          );

          // Store tokens using TokenManager
          await TokenManager.storeTokens(
            accessToken: token,
            refreshToken:
                data['refresh_token'] ??
                data['refreshToken'] ??
                data['refresh'] ?? // Add common variations
                '',
            expiresIn:
                data['expires_in'] ??
                data['expiresIn'], // TokenManager will handle parsing
          );

          // Save user data to SharedPreferences
          await SharedPrefUtils.init();
          await SharedPrefUtils.setBool('is_logged_in', true);
          await SharedPrefUtils.setString('user_role', userRole);
          await SharedPrefUtils.setString('user_id', userId.toString());
          await SharedPrefUtils.setString('username', username);
          await SharedPrefUtils.setString('user_email', email);
          // Persist the login phone number so it can be reused (e.g., for tickets)
          await SharedPrefUtils.setString(
            'user_phone',
            eMailController.text.trim(),
          );

          // Update global state variables using helper function
          await initializeGlobalState();

          log(
            'Login successful - Role: $userRole, UserID: $userId, Username: $username, Token: ${token.isNotEmpty ? "Present" : "Missing"}',
          );
          log(
            'Global state updated - isShopkeeper: ${isShopkeeper.value}, globalUser: ${globalUser.value}',
          );
        } catch (e) {
          log('Error parsing login response: $e');
          // Clear authentication data if parsing fails
          userRole = 'user';
          await TokenManager.clearTokens();
          await SharedPrefUtils.init();
          await SharedPrefUtils.setBool('is_logged_in', false);
          await SharedPrefUtils.setString('user_role', 'user');
          await SharedPrefUtils.setString('user_id', '0');

          // Reset global state variables
          resetGlobalState();
        }

        await Future.delayed(const Duration(seconds: 1));
        eMailController.clear();
        confirmPassController.clear();
        Get.offAllNamed(AppRoutes.home);
        // Redirect based on user role
        // if (userRole == 'shopkeeper') {
        //   Get.offAllNamed(AppRoutes.shopkeeperHome);
        // } else {
        //   Get.offAllNamed(AppRoutes.home);
        // }
        return true;
      } else if (response.statusCode == 403 &&
          response.body.contains("not a user")) {
        // RETRY with shopkeeper role if user role fails
        print("🔄 RETRYING LOGIN WITH ROLE: shopkeeper");
        final retryResponse = await ApiService.post(
          '/api/auth/login',
          body: {
            "phone": eMailController.text.trim(),
            "password": confirmPassController.text.trim(),
            "role": "shopkeeper",
          },
          includeAuth: false,
        );

        print("📥 RETRY LOGIN RESPONSE STATUS: ${retryResponse.statusCode}");
        print("📄 RETRY LOGIN RESPONSE BODY: ${retryResponse.body}");

        if (retryResponse.statusCode == 200) {
          print("✅ Retry login successful (shopkeeper)");
          try {
            dynamic data = jsonDecode(retryResponse.body);
            String userRole = data['user']?['role'] ?? 'shopkeeper';
            String token =
                data['accessToken'] ??
                data['token'] ??
                data['access_token'] ??
                '';
            int userId = data['user']?['id'] ?? data['id'] ?? 0;
            String username = data['user']?['username'] ?? '';
            String email = data['user']?['email'] ?? '';

            await TokenManager.storeTokens(
              accessToken: token,
              refreshToken: data['refresh_token'] ?? data['refreshToken'] ?? '',
              expiresIn: data['expires_in'] ?? data['expiresIn'] ?? 86400,
            );

            await SharedPrefUtils.init();
            await SharedPrefUtils.setBool('is_logged_in', true);
            await SharedPrefUtils.setString('user_role', userRole);
            await SharedPrefUtils.setString('user_id', userId.toString());
            await SharedPrefUtils.setString('username', username);
            await SharedPrefUtils.setString('user_email', email);
            await SharedPrefUtils.setString(
              'user_phone',
              eMailController.text.trim(),
            );

            await initializeGlobalState();
            print(
              'Login successful after retry - Role: $userRole, UserID: $userId',
            );
          } catch (e) {
            print('Error parsing retry login response: $e');
            resetGlobalState();
          }

          await Future.delayed(const Duration(seconds: 1));
          eMailController.clear();
          confirmPassController.clear();
          Get.offAllNamed(AppRoutes.home);
          return true;
        } else {
          print("❌ Retry login also failed");
          return false;
        }
      } else {
        print("❌ Login failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('❌ Login Exception: $e');
      // Return false for login failure - UI will handle the error message
      return false;
    }
  }

  // Forgot Password OTP Methods
  Future<Map<String, dynamic>> requestPasswordResetOtp(String phone) async {
    if (phone.isEmpty) {
      return {'success': false, 'message': 'Please enter phone number'};
    }

    if (!isValidPhone(phone.trim())) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit phone number',
      };
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.sendOtp(
        phone: phone.trim(),
        purpose:
            'reset_password', // Use reset_password purpose for password reset
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Send forgot password OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(
    String phone,
    String otp,
  ) async {
    if (phone.isEmpty) {
      return {'success': false, 'message': 'Phone number is required'};
    }

    if (otp.isEmpty) {
      return {'success': false, 'message': 'Please enter OTP'};
    }

    if (otp.length != 6) {
      return {'success': false, 'message': 'Please enter a valid 6-digit OTP'};
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.verifyOtp(
        phone: phone.trim(),
        otp: otp.trim(),
        purpose:
            'reset_password', // Use reset_password purpose for password reset
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Verify forgot password OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<Map<String, dynamic>> resendForgotPasswordOtp(String phone) async {
    if (phone.isEmpty) {
      return {'success': false, 'message': 'Please enter phone number'};
    }

    if (!isValidPhone(phone.trim())) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit phone number',
      };
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.resendOtp(
        phone: phone.trim(),
        purpose:
            'reset_password', // Use reset_password purpose for password reset
        channel: 'sms',
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Resend forgot password OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to resend OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String phone,
    String newPassword,
  ) async {
    if (phone.isEmpty) {
      return {'success': false, 'message': 'Phone number is required'};
    }

    if (newPassword.isEmpty) {
      return {'success': false, 'message': 'Please enter new password'};
    }

    if (!isValidPassword(newPassword)) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters long',
      };
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.resetPassword(
        phone: phone.trim(),
        newPassword: newPassword,
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Reset password error: $e');
      return {
        'success': false,
        'message': 'Failed to reset password. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  // OTP Methods
  Future<Map<String, dynamic>> sendOtp() async {
    if (phoneController.text.isEmpty) {
      return {'success': false, 'message': 'Please enter phone number'};
    }

    if (!isValidPhone(phoneController.text.trim())) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit phone number',
      };
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.sendOtp(
        phone: phoneController.text.trim(),
        purpose: 'signup',
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Send OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<Map<String, dynamic>> verifyOtp() async {
    if (otpController.text.isEmpty) {
      return {'success': false, 'message': 'Please enter OTP'};
    }

    if (otpController.text.length != 6) {
      return {'success': false, 'message': 'Please enter a valid 6-digit OTP'};
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.verifyOtp(
        phone: phoneController.text.trim(),
        otp: otpController.text.trim(),
        purpose: 'signup',
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Verify OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }

  Future<Map<String, dynamic>> resendOtp() async {
    if (phoneController.text.isEmpty) {
      return {'success': false, 'message': 'Please enter phone number'};
    }

    if (!isValidPhone(phoneController.text.trim())) {
      return {
        'success': false,
        'message': 'Please enter a valid 10-digit phone number',
      };
    }

    isUploadingData.value = true;

    try {
      final result = await OtpService.resendOtp(
        phone: phoneController.text.trim(),
        purpose: 'signup',
        channel: 'sms',
        role: 'user',
      );

      return result;
    } catch (e) {
      log('Resend OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to resend OTP. Please try again.',
      };
    } finally {
      isUploadingData.value = false;
    }
  }
}
