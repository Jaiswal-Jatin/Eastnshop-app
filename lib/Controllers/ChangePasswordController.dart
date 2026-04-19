import 'dart:convert';
import 'dart:developer';
import 'package:eastnshop/Constants/CommonWidgets.dart';
import 'package:eastnshop/Utils/SharedPrefUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eastnshop/Utils/ApiService.dart';

class ChangePasswordController extends GetxController {
  // Text controllers
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final repeatPassController = TextEditingController();

  // Observable variables
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    currentPassController.dispose();
    newPassController.dispose();
    repeatPassController.dispose();
    super.onClose();
  }

  // Validate form inputs
  bool validateInputs() {
    final currentPass = currentPassController.text.trim();
    final newPass = newPassController.text.trim();
    final repeatPass = repeatPassController.text.trim();

    // Clear previous error
    errorMessage.value = '';

    // Validation
    if (currentPass.isEmpty) {
      errorMessage.value = "Please enter current password";
      // AppSnackBar.show(
      //   message: errorMessage.value,
      //   type: SnackType.error,
      // );
      return false;
    }

    if (newPass.isEmpty) {
      errorMessage.value = "Please enter new password";
      // AppSnackBar.show(
      //   message: errorMessage.value,
      //   type: SnackType.error,
      // );
      return false;
    }

    if (newPass.length < 8) {
      errorMessage.value = "New password must be at least 8 characters";
      // AppSnackBar.show(
      //   message: errorMessage.value,
      //   type: SnackType.error,
      // );
      return false;
    }

    if (newPass != repeatPass) {
      errorMessage.value = "New passwords do not match";
      // AppSnackBar.show(
      //   message: errorMessage.value,
      //   type: SnackType.error,
      // );
      return false;
    }

    if (currentPass == newPass) {
      errorMessage.value = "New password must be different from current password";
      // AppSnackBar.show(
      //   message: errorMessage.value,
      //   type: SnackType.error,
      // );
      return false;
    }

    return true;
  }

  // Change password API call
  Future<bool> changePassword() async {
    try {
      // Validate inputs first
      if (!validateInputs()) {
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Get user ID from SharedPreferences
      await SharedPrefUtils.init();
      String? userIdStr = SharedPrefUtils.getString('user_id');
      
      if (userIdStr == null || userIdStr.isEmpty) {
        errorMessage.value = "User not authenticated. Please login again.";
        // AppSnackBar.show(
        //   message: errorMessage.value,
        //   type: SnackType.error,
        // );
        return false;
      }
      
      int? userId = int.tryParse(userIdStr);
      if (userId == null || userId <= 0) {
        errorMessage.value = "Invalid user ID. Please login again.";
        // AppSnackBar.show(
        //   message: errorMessage.value,
        //   type: SnackType.error,
        // );
        return false;
      }

      Map<String, dynamic> requestBody = {
        "newPassword": newPassController.text.trim(),
        "role": "user",
      };

      log("=== CHANGE PASSWORD API CALL ===");
      log("User ID: $userId");
      log("Endpoint: /api/password/change-password");
      log("Request Body: $requestBody");

      final response = await ApiService.post(
        '/api/password/change-password',
        body: requestBody,
        includeAuth: true,
      );

      log("=== CHANGE PASSWORD RESPONSE ===");
      log("Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Password changed successfully!");
        // Clear form after successful change
        clearForm();
        CommonWidgets.CustomeSnackBar(
          title: 'Success',
          message: 'Password changed successfully',
          backgroundColor: Colors.green,
        );
        return true;
      } else {
        String errorMsg = "Failed to change password";
        try {
          dynamic errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? errorMsg;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMsg = response.body;
          }
        }
        
        log("❌ API Error: $errorMsg");
        CommonWidgets.CustomeSnackBar(
          title: 'Error',
          message: errorMsg,
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      log("Error changing password: $e");
      errorMessage.value = "Network error: ${e.toString()}";
      // AppSnackBar.show(
      //   message: "Network error: ${e.toString()}",
      //   type: SnackType.error,
      // );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form
  void clearForm() {
    currentPassController.clear();
    newPassController.clear();
    repeatPassController.clear();
    errorMessage.value = '';
  }

  // Reset form
  void resetForm() {
    clearForm();
    isLoading.value = false;
  }
}
