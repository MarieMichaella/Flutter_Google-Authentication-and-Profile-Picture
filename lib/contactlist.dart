import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api/google_signin_api.dart';


class ContactList extends StatefulWidget {
        final GoogleSignInAccount user;
  ContactList({
    Key? key,
    required this.user,
  }):super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Contact List"),
                      leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
        ),
        body: Container(
          height: double.infinity,
          child: FutureBuilder(
  future: getContacts(),
  builder: (context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    } else if (!snapshot.hasData || snapshot.data.isEmpty) {
      return Center(
        child: Text('No contacts available'),
      );
    } else {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          Contact contact = snapshot.data[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                title: Text(contact.displayName ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.phones.isNotEmpty ? contact.phones[0] : ''),
                    Text(contact.emails.isNotEmpty ? contact.emails[0] : ''),
                  ],
                ),
              ),
              Divider(),
            ],
          );
        },
      );
    }
  },
),

        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }
}
