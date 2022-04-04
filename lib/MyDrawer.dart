import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeleteWeight.dart';
import 'main.dart';
import 'WeightHistory.dart';
import 'HomePage.dart';
import 'UpdateWeight.dart';


class MyDrawer extends StatefulWidget {
  MyDrawer({Key? key}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String username = 'user';

  Future<void> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
    username = prefs.getString('usernamex')!;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Column(
                children: [
                ]
              ),
              currentAccountPicture:  Container(
                height: 40,
              width: 40,
              child: ClipRect(
                  child: Image.asset('assets/images/logo.png'),
                    ),
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              title: Text('Add Weight'),
              leading: Icon(Icons.home, color: Colors.deepPurple),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              title: Text('Weight History'),
              leading: Icon(Icons.scale, color: Colors.deepPurple),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeightHistory()),
                );
              },
            ),
            ListTile(
              title: Text('Update Weight'),
              leading: Icon(Icons.scale, color: Colors.deepPurple),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateWeight()),
                );
              },
            ),
            ListTile(
              title: Text('Delete Weight'),
              leading: Icon(Icons.cancel, color: Colors.deepPurple),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteWeight()),
                );
              },
            ),

            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.subdirectory_arrow_left, color: Colors.deepPurple),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MyApp()),
                        (route) => false);
              },
            ),
          ],
        ),
      );
  }
}