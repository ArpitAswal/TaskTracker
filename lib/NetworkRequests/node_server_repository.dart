import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../Utils/constants/app_constants.dart';

class NodeServerRepository {
  final timeoutDuration = const Duration(seconds: 15);

  Future<String> storeTokenToBackend(String token) async {
    try {
      final url = Uri.parse(
          "http://192.168.29.103:5000/store-token"); // Change IP for real device

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "collection": FirestoreConstants.tokenCollection,
              "docId": FirebaseAuth.instance.currentUser!.uid,
              "token": token
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return "Success";
      } else {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Extract the message field
        String serverMessage =
            responseData["message"] ?? "Unexpected error occurred";
        return "Notification Request Failed: $serverMessage";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<String> deleteTokenFromBackend() async {
    try {
      final url = Uri.parse(
          "http://192.168.29.103:5000/delete-token"); // Change IP for real device

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "collection": FirestoreConstants.tokenCollection,
              "userId": FirebaseAuth.instance.currentUser!.uid,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return "Success";
      } else {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Extract the message field
        String serverMessage =
            responseData["message"] ?? "Unexpected error occurred";
        return "Notification Request Failed: $serverMessage";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<String> sendNotification(
      {required String title, required String body}) async {
    try {
      final url = Uri.parse("http://192.168.29.103:5000/send-notification");
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "collection": FirestoreConstants.tokenCollection,
              "adminId": FirebaseAuth.instance.currentUser!.uid,
              "title": title,
              "body": body,
            }),
          )
          .timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return "Notification Successfully Sent";
      } else {
        // Decode the JSON response
        final responseData = jsonDecode(response.body);

        // Extract the message field
        String serverMessage =
            responseData["message"] ?? "Unexpected error occurred";
        return "Notification Request Failed: $serverMessage";
      }
    } catch (e) {
      // Handle TimeoutException or SocketException
      if (e is TimeoutException) {
        return 'Request timed out after ${timeoutDuration.inSeconds} seconds';
      } else if (e is SocketException) {
        return 'Socket exception: $e';
      } else {
        return 'An error occurred: $e';
      }
    }
  }
}
