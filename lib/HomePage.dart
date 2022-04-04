import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MyDrawer.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _State();
}

class _State extends State<HomePage> {

  final weight = TextEditingController();
  bool isLoading = false;
  String myresponse = '';
  String username = '';
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('usernamex')!;
    });
  }

  Widget _addWeight() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          TextField(
            controller: weight,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 5.0),
              ),
              fillColor: Color(0xffffffff),
              filled: true,
              hintText: 'Enter Weight Value',
              hintStyle: TextStyle(fontSize: 14),
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
          if (weight.text == '') {
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
            'Add Weight',
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
        content: const Text('input field is required'),
        action: SnackBarAction(
            label: 'X', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Future<void> _sendData() async {
    setState(() {
      isLoading = true;
    });
    var newTime = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(newTime);
    _todayDate = DateFormat('d-M-yyyy h:ma').format(tsdate);

    final response = await http.post(Uri.parse("https://us-central1-loop-92fb2.cloudfunctions.net/api/save_weight"),
      headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
      body: <String, String>{
        "username": username,
        "weight": weight.text,
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
        title: Text('Welcome $username'),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body:  Center(
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              _addWeight(),
              const SizedBox(height: 50),
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
