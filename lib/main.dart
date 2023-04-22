import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payment_flutter/func.dart';
import 'package:payment_flutter/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class FileState {
  final String state;
  final int order;

  FileState({required this.state, required this.order});

  factory FileState.fromJson(Map<String, dynamic> json) {
    return FileState(
      state: json['state'],
      order: json['order']
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '법인카드'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int year = (DateTime.now()).year;
  int month = (DateTime.now()).month - 1;
  String name = "이름";
  FileState myState = FileState(state: 'Loading...', order: 0);

  Timer? t;

  @override
  void initState() {
    super.initState();
    loadState();
    t = Timer.periodic(const Duration(seconds: 5), (t) => fetchApi(name, year, month));
  }
  
  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }
  
  void loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = (prefs.getString("name") ?? "이름");
      year = (prefs.getInt("year") ?? (DateTime.now()).year);
      month = (prefs.getInt("month") ?? (DateTime.now()).month);
    });
    await fetchApi(name, year, month);
  }

  Future<void> fetchApi(String name, int year, int month) async {
    final response2 =
        await http.get(Uri.parse('$url/process/status?name=$name&year=$year&month=$month'));

    if (response2.statusCode == 200) {
      final res = FileState.fromJson(json.decode(response2.body));
      setState(() {
        myState = res;
      });
    } else {
      if(!mounted) return;
      getOkSnackbar(context, "API 호출에 실패했습니다...");
    }
  }

  Future<void> downloadExcel() => fileDownloadAndOpen(context, name, year, month);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "$name, $year년, $month월",
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text("현재 상태...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 30),
              Text(
                myState.state, 
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.purple)
              ),
              const SizedBox(height: 30),
              myState.order <= 0
              ? Container() 
              : Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "앞에 ${myState.order-1}명 있음",
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.purple)
                ),
              ),
              const SizedBox(height: 30),
              myState.state == "complete"
              ? ElevatedButton(
                onPressed: downloadExcel, 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("다운로드", style: TextStyle(fontSize: 20))
              )
              : Container()  
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadPage()),
          );
        }
      ),
    );
  }
}
