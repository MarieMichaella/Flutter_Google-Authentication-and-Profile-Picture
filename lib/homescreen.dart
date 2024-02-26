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
import 'Gallery.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  HomeScreen({
    Key? key,
    required this.user,
  }) :super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _selectedImageBytes;
  File ? _selectedImage;
  int _selectedIndex = 0;
  String _connectionStatus = 'Unknown';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _listenForConnectivityChanges();
    _listenForConnectivityChanges();
    _loadImage();
  }

  void _removeImage() {
  setState(() {
    _selectedImage = null;
    _selectedImageBytes = null;
  });
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

  Future<void> _initConnectivity() async {
    bool isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      _connectionStatus = isConnected ? 'Connected' : 'Disconnected';
    });
  }

  void _listenForConnectivityChanges() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        _connectionStatus =
            status == InternetConnectionStatus.connected ? 'Connected' : 'Disconnected';
      });
      _showConnectivitySnackbar();
    });
  }

  void _showConnectivitySnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_connectionStatus),
        duration: Duration(seconds: 10),
      ),
    );
  }

// Widget _buildGalleryItem(String title, String imagePath) {
//   return Container(
//     margin: EdgeInsets.only(bottom: 40), 
//     child: Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'DOGS',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(width: 20),
//         Expanded(
//           flex: 3,
//           child: Image.asset(
//             imagePath,
//             height: 200, // Adjusted height
//             width: 100, // Adjusted width
//             fit: BoxFit.cover,
//           ),
//         ),
//       ],
//     ),
//   );
// }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Home'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 30.0),
          child: IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
                  ? Icons.brightness_3 // Brightness icon for light theme
                  : Icons.brightness_high, // Brightness icon for dark theme
            ),
            onPressed: () {
              // Toggle theme here
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Sign In'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async{
                  await GoogleSignInApi.logout();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    ),
    drawer: Drawer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF5271FF),
              ),
              height: 100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 70, // Adjust the size as needed
              height: 70, // Adjust the size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100), // Half of the width or height for a circle
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.image, size: 100), // Placeholder icon if no image is selected
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(user: widget.user)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorScreen(user: widget.user)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Change Profile Picture'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryScreen(user: widget.user)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),

            ElevatedButton(
              onPressed: () {
                _pickImageFromGallery();
              },
                style: ElevatedButton.styleFrom(
    primary: Colors.grey[200], 
  ),
              child: ListTile(
                title: Text('Add Image From Gallery'),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _pickImageFromCamera();
              },
                              style: ElevatedButton.styleFrom(
    primary: Colors.grey[200], 
  ),
              child: ListTile(
                title: Text('Add Image From Camera'),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _removeImage();
              },
                              style: ElevatedButton.styleFrom(
    primary: Colors.grey[200], 
  ),
              child: ListTile(
                title: Text('Remove Image'),
              ),
            ),
          ],
        ),
      ),
    ),
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
                ? 'assets/images/Untitled design (1).jpg'
                : 'assets/images/Untitled design (2).jpg', 
            fit: BoxFit.cover,
          ),
        ),

        Column(
          children: [
            SizedBox(height: 20),
            _connectionStatus == 'Connected'
              ? Container(
                  width: double.infinity,
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Guardians!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              _connectionStatus,
                              style: TextStyle(
                                fontSize: 18,
                                color: _connectionStatus == 'Connected'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/image 2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: SizedBox(
                    height: 70, 
                    child: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Please connect to the internet to access this content.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
items: <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          child: Icon(Icons.home),
          backgroundColor: Color(0xFF5271FF),
        ),
      ),
      label: 'Home', // Add label for the Home item
    ),
    BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          child: Icon(Icons.calculate),
          backgroundColor: Color(0xFF5271FF),
        ),
      ),
      label: 'Calculator', // Add label for the Calculator item
    ),
    BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          child: Icon(Icons.info),
          backgroundColor: Color(0xFF5271FF),
        ),
      ),
      label: 'About', // Add label for the About item
    ),
    BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          child: Icon(Icons.contacts),
          backgroundColor: Color(0xFF5271FF),
        ),
      ),
      label: 'Contact', // Add label for the Contact item
    ),
  ],
        selectedItemColor: Color(0xFF5271FF),
        currentIndex: _selectedIndex,
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(user: widget.user)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalculatorScreen(user: widget.user)),
            );
          } else if (index == 2) {
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUs(user :widget.user)),
                );
          }
          else if (index == 3) {
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactList(user :widget.user)),
                );
          }
        },
      ),
    ),
  );
}

  // Future _pickImageFromGallery() async {
  //   final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if(returnedImage == null) return;
  //   setState(() {
  //     _selectedImage = File(returnedImage.path);
  //   });
  // }

  //   Future _pickImageFromCamera() async {
  //   final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
  //   if(returnedImage == null) return;
  //   setState(() {
  //     _selectedImage = File(returnedImage.path);
  //   });
  // }
}
