import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CalculatorView.dart';
import 'homescreen.dart';
import 'themeprovider.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'api/google_signin_api.dart';

class AboutUs extends StatefulWidget {
  final GoogleSignInAccount user; 
  AboutUs({
    Key? key,
    required this.user, 
  }):super(key: key);

  @override
  _AboutUsState createState() => _AboutUsState();
}


class _AboutUsState extends State<AboutUs> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          ThemeData theme = themeProvider.themeData;
          bool isDarkTheme = theme.brightness == Brightness.dark;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      'Welcome to Pet Guardians!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(
                        child: Image.asset(
                          'assets/images/image 2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Our Mission:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'At Our Pet Shop Adoption, we are dedicated to finding loving homes for pets in need. Our mission is to provide a safe and caring environment for animals while matching them with compassionate and responsible adopters.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Our Services:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '- Pet Adoption: We offer a variety of pets for adoption, including dogs, cats, rabbits, and more. Each animal in our care receives proper veterinary care and socialization to ensure they are ready for their forever home.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '- Pet Supplies: In addition to adoption services, we also provide a range of pet supplies to help you care for your new furry friend. From food and toys to grooming products, we have everything you need to keep your pet happy and healthy.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '- Community Outreach: We are committed to educating the community about responsible pet ownership and the importance of spaying and neutering. Through outreach programs and events, we strive to make a positive impact on animal welfare in our community.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Contact Us:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Phone: (123) 456-7890\nEmail: info@ourpetshopadoption.com\nAddress: 1234 Pet Avenue, City, State, ZIP',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
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
              label: 'Home',
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
              label: 'Calculator',
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
              label: 'About',
            ),
          ],
          selectedItemColor: Color(0xFF5271FF),
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(user : widget.user)),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalculatorScreen(user : widget.user)),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUs(user : widget.user)),
              );
            }
          },
        ),
      ),
    );
  }
}
