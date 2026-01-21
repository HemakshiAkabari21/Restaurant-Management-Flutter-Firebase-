import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dhtoyx0gv";
  static const String uploadPreset = "menu_upload";

  static Future<String?> uploadImage(File image) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.path,
          ),
        );

      final response = await request.send();
      final responseData =
      await response.stream.bytesToString();

      final decoded = json.decode(responseData);

      return decoded['secure_url'];
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}

