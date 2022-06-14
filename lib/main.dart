import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* ====================== fetch data =============================== */

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

Future<Album> fetchData(int id) async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

/* ============================================================== */

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refresh with StreamBuilder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  late StreamController<Album?> _events; // latest data will be used (data that is at the end of the stream)

  @override
  initState() {
    super.initState();
    _events = StreamController<Album?>();
    _getData();
  }

  // call this if you want to getData / refresh
  Future<void> _getData() async {
    // _events.add(null); // if you want to display loading every time you call this
    try {
      Album res = await fetchData(_counter);
      _events.add(res);
      _counter++;
    } catch (e) {
      print('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: StreamBuilder<Album?>(
          stream: _events.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Text('${snapshot.data!.userId}'),
                  Text(snapshot.data!.title),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _getData,
        tooltip: 'fetch next data',
        child: const Icon(Icons.add),
      ),
    );
  }
}
