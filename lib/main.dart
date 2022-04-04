import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wtapp/HomePage.dart';
import 'SignupPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

final customTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  brightness: Brightness.light,
  fontFamily: 'Poppins',
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: customTheme,
        home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}



class LoginScreenState extends State<LoginScreen> {

  final username = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;
  String myresponse = '';


  @override
  void initState() {
    super.initState();
  }


  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _userName() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          TextField(
            controller: username,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 5.0),
              ),
              fillColor: Color(0xffffffff),
              filled: true,
              hintText: 'Username',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _password() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          TextField(
            controller: password,
            obscureText: _obscureText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 5.0),
              ),
              fillColor: const Color(0xffffffff),
              filled: true,
              hintText: 'Password',
              hintStyle: const TextStyle(fontSize: 14),
              suffixIcon: GestureDetector(
                onTap: () {
                  _toggle();
                },
                child: Icon(
                    _obscureText ? Icons.visibility : Icons
                        .visibility_off, color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Builder(
      builder: (context) => InkWell(
        onTap: () async {
          if (username.text == '' || password.text == '') {
            _loginToast(context);
          }
          else {
            _loginData();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.purple, Colors.deepPurple])),
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('OR'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text("Don't have an account?",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text('Sign up',
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.fitHeight,
          ),
        ));
  }

  void _loginToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('All input fields are required'),
        action: SnackBarAction(
            label: 'X', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Future<void> _loginData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(Uri.parse("https://us-central1-loop-92fb2.cloudfunctions.net/api/login"),
      headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
      body: <String, String>{
        "username": username.text,
        "password": password.text,
      },
    );
    var data = jsonDecode(response.body);
    myresponse = data['status'].toString();

    if (myresponse == 'success') {
      setState(() {
        isLoading = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('usernamex', username.text);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

    else {
      setState(() {
        isLoading = false;
      });
      _loginstatusToast(context);
    }
  }

  void _loginstatusToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('API Response: $myresponse'),
        action: SnackBarAction(
            label: 'X', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weight Tracker"),
        centerTitle: true,
      ),
      body:  SafeArea(
        child: Container(
        color: Colors.white,
        margin: const EdgeInsets.all(10.0),
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    _title(),
                    const SizedBox(height: 20),
                    _userName(),
                    _password(),
                    const SizedBox(height: 20),
                    _submitButton(),
                    const SizedBox(height: 20),
                    _divider(),
                    Visibility(
                      visible: isLoading,
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          child: const CircularProgressIndicator()
                      ),
                    ),
                    _createAccountLabel(),
                  ],
                ),
              ),
            ),
    );
  }
}
