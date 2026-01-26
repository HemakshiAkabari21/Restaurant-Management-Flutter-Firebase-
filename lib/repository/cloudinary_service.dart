import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dhtoyx0gv";
  static const String uploadPreset = "menu_upload";

  static Future<String?> uploadImage(File image) async {
    debugPrint("File Picked:::::$image");
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload",);
      debugPrint("URI::::::::::$uri");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.path,
          ),
        );
      debugPrint("Request::::::::$request");
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      debugPrint("Response Data ::::::::::: $responseData");
      final decoded = json.decode(responseData);
      debugPrint("secure_url :::::::::: ${decoded['secure_url']}");
      return decoded['secure_url'];
    } catch (e) {
      debugPrint("Cloudinary Error: $e");
      return null;
    }
  }
}

