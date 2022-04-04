import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MyDrawer.dart';


class UpdateWeight extends StatefulWidget {
  const UpdateWeight({Key? key}) : super(key: key);

  @override
  State<UpdateWeight> createState() => _State();
}

class _State extends State<UpdateWeight> {

  bool isLoading = false;
  String username = '';
  Future<List<dynamic>>? _future;
  String timestamp = '';
  final weight = TextEditingController();
  String myresponse = '';

  @override
  void initState() {
    super.initState();
    _getUser();
    _future = _fetchData();
  }

  Future<void> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('usernamex')!;
    });
  }

  Future<List<dynamic>> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse("https://us-central1-loop-92fb2.cloudfunctions.net/api/get_weight_history"),
      headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
      body: <String, String>{
        "username": prefs.getString('usernamex')!,
      },
    );

    var data = jsonDecode(response.body);
    return data;
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
              hintText: 'Enter New Weight Value',
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showEdit() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(10.0),
          content: Stack(
            children: <Widget>[
              Opacity(
                opacity: 1,
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 0, right: 0, top: 0),
                        color: Colors.deepPurple,
                        child: Center(
                          child: Text(' EDIT WEIGHT ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(15.0),
                          child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text('ID: $timestamp'),
                                  _addWeight(),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _updateData();
                                    },
                                    child: Text('UPDATE WEIGHT VALUE'),
                                  )
                                  ),
                                  Visibility(
                                    visible: isLoading,
                                    child: Container(
                                        margin: const EdgeInsets.only(bottom: 30),
                                        child: const CircularProgressIndicator()
                                    ),
                                  ),
                                  SizedBox(height: 60)
                                ],
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(Uri.parse("https://us-central1-loop-92fb2.cloudfunctions.net/api/update_weight"),
      headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"},
      body: <String, String>{
        "username": username,
        "weight": weight.text,
        "timestamp": timestamp,
      },
    );
    var data = jsonDecode(response.body);
    myresponse = data['status'].toString();

    if (myresponse == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UpdateWeight()),
      );
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
        title: Text('Click to Update Weight'),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      body:  Center(
        child: FutureBuilder<List<dynamic>>(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Card(
                                elevation: 2,
                                clipBehavior: Clip.hardEdge,
                                child: Container(
                                  height: 80,
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                      child: ListTile(
                                        title: Text(snapshot.data[index]['weight'], style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.w800, color: Colors.black)),
                                        subtitle: Text(snapshot.data[index]['timestamp'], style: TextStyle(fontSize: 10,
                                            fontWeight: FontWeight.w800, color: Colors.black)),
                                        leading: Icon(Icons.scale, color: Colors.green, size: 16),
                                        trailing: Text(snapshot.data[index]['dateofreg'], style: TextStyle(fontSize: 14,
                                            fontWeight: FontWeight.w800, color: Colors.black)),
                                        dense: true,
                                        contentPadding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                      ),
                                        onTap: () {
                                        timestamp = snapshot.data[index]['timestamp'];
                                        _showEdit();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 100,
                          height: 100,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: ExactAssetImage('assets/images/logo.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          )
                      ),
                      SizedBox(height:20),
                      Text('There are no data available at the moment',
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                    ]
                );
              }
              else {
                return Center(child: CircularProgressIndicator());
              }
            }
        ),
      ),
    );
  }
}
