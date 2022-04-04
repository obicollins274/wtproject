import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _State();
}

class _State extends State<SignupPage> {

  final username = TextEditingController();
  final password = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;
  String _todayDate = '';
  String myresponse = '';

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _firstName() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          TextField(
            controller: firstname,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 5.0),
              ),
              fillColor: Color(0xffffffff),
              filled: true,
              hintText: 'First Name',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastName() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          TextField(
            controller: lastname,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 5.0),
              ),
              fillColor: Color(0xffffffff),
              filled: true,
              hintText: 'Last Name',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
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
          if (firstname.text == '' || lastname.text == '' || username.text == '' || password.text == '') {
            _signupToast(context);
          }
          else {
              _sendData();
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
            'Sign Up',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }


  void _signupToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('All input fields are required'),
        action: SnackBarAction(
            label: 'X', onPressed: scaffold.hideCurrentSnackBar),
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

  Future<void> _sendData() async {
    setState(() {
      isLoading = true;
    });
    var newTime = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(newTime);
    _todayDate = DateFormat('d-M-yyyy h:ma').format(tsdate);

    final response = await http.post(Uri.parse("https://us-central1-loop-92fb2.cloudfunctions.net/api/sign_up"),
      headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
      body: <String, String>{
        "userid": DateTime.now().microsecondsSinceEpoch.toString(),
        "firstname": firstname.text,
        "lastname": lastname.text,
        "username": username.text,
        "password": password.text,
        "dateofreg": _todayDate,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    var data = jsonDecode(response.body);
    myresponse = data['status'].toString();

    if (myresponse == 'success') {
      setState(() {
        isLoading = false;
      });
      _statusToast(context);
    }

    else {
      setState(() {
        isLoading = false;
      });
      _statusToast(context);
    }
  }

  void _statusToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Response: $myresponse'),
        action: SnackBarAction(
            label: 'X', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
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
              _firstName(),
              _lastName(),
              _userName(),
              _password(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 20),
              Visibility(
                visible: isLoading,
                child: Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const CircularProgressIndicator()
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
