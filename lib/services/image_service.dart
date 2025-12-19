import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  // Save image file and return the path
  static Future<String> saveImageFile(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory(path.join(directory.path, 'recipe_images'));
      
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      final savedImage = await imageFile.copy(
        path.join(imageDir.path, fileName),
      );
      
      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  // Get image file from path
  static Future<File?> getImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if path is a local file path
  static bool isLocalPath(String path) {
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  // Delete image file
  static Future<void> deleteImageFile(String imagePath) async {
    try {
      if (isLocalPath(imagePath)) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore errors when deleting
    }
  }
}

