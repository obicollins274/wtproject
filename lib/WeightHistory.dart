import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MyDrawer.dart';


class WeightHistory extends StatefulWidget {
  const WeightHistory({Key? key}) : super(key: key);

  @override
  State<WeightHistory> createState() => _State();
}

class _State extends State<WeightHistory> {

  bool isLoading = false;
  String myresponse = '';
  String username = '';
  Future<List<dynamic>>? _future;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight History for $username'),
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
                                      ListTile(
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
