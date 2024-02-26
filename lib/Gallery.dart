import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'CalculatorView.dart';
import 'Aboutscreen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'themeprovider.dart';
import 'signin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api/google_signin_api.dart';
import 'NewScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contactlist.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';



class GalleryScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  GalleryScreen({
    Key? key,
    required this.user,
  }) :super(key: key);
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Uint8List? _selectedImageBytes;
  File ? _selectedImage;
  int _selectedIndex = 0;
  String _connectionStatus = 'Unknown';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _loadImage();
  }

  void _loadImage() async {
  String? imagePath = await _getImagePath();
  if (imagePath != null) {
    setState(() {
      _selectedImage = File(imagePath);
    });
  }
}

  Future<void> _saveImagePath(String imagePath) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('imagePath', imagePath);
}

Future<String?> _getImagePath() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('imagePath');
}

Future<void> _pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 100,
      minWidth: 100,
      quality: 40,
    );

    // Save the new image path
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = '${appDir.path}/gallery_image.jpg';
    await File(imagePath).writeAsBytes(compressedBytes);
    await _saveImagePath(imagePath);

    setState(() {
      _selectedImage = File(pickedFile.path);
      _selectedImageBytes = compressedBytes;
    });
  }
}

Future<void> _pickImageFromCamera() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 100,
      minWidth: 100,
      quality: 40,
    );

    // Save the new image path
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = '${appDir.path}/camera_image.jpg';
    await File(imagePath).writeAsBytes(compressedBytes);
    await _saveImagePath(imagePath);

    setState(() {
      _selectedImage = File(pickedFile.path);
      _selectedImageBytes = compressedBytes;
    });
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Gallery'),
    ),
    body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100, 
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100), 
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.image, size: 100), 
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImageFromGallery,
            child: const Text('Pick Image from Gallery'),
          ),
          ElevatedButton(
            onPressed: _pickImageFromCamera,
            child: const Text('Pick Image from Camera'),
          ),
          if (_selectedImage != null) // Only show remove button if image is selected
            ElevatedButton(
              onPressed: _removeImage,
              child: const Text('Remove Image'),
            ),
        ],
      ),
    ),
  );
}

void _removeImage() {
  setState(() {
    _selectedImage = null;
    _selectedImageBytes = null;
  });
}


}
