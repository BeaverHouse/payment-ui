import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:payment_flutter/func.dart';
import 'package:payment_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  int year = (DateTime.now()).year;
  int month = (DateTime.now()).month - 1;
  List<File> files = [];

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadState();
  }

  void loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = (prefs.getString("name") ?? "");
      year = (prefs.getInt("year") ?? (DateTime.now()).year);
      month = (prefs.getInt("month") ?? (DateTime.now()).month -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("업로드"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '이름',
                  )
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NumberPicker(
                    value: year,
                    minValue: 2020,
                    maxValue: 2030,
                    itemWidth: 80,
                    step: 1,
                    haptics: true,
                    onChanged: (value) => setState(() => year = value),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text("년", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 50),
                  NumberPicker(
                    value: month,
                    minValue: 1,
                    maxValue: 12,
                    itemWidth: 80,
                    step: 1,
                    haptics: true,
                    onChanged: (value) => setState(() => month = value),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text("월", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  ),
                ]
              ), 
              const SizedBox(height: 30),
              Container(
                height: 100,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(width: 5, color: Colors.grey,),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: InkWell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: true,
                    );
                    if( result != null && result.files.isNotEmpty ){
                      setState(() {
                        files = result.files.map((e) => File(e.path!)).toList();
                      });
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text("이미지 Upload", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 20,),),
                        Icon(Icons.upload_rounded, color: Colors.grey,),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...files.map((e) => Text(e.path.split(Platform.pathSeparator).last)).toList(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;

                  final response = await sendFileRequest(nameController.text, year, month, files);

                  if (response.statusCode == 200) {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('name', nameController.text);
                    await prefs.setInt('year', year);
                    await prefs.setInt('month', month);
                    if(!mounted) return;
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyApp()), (route) => false);
                    return;
                  } else {
                    // ...
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("Go!!", style: TextStyle(fontSize: 20))
              )            
            ],
          ),
        ),
      ),
    );
  }
}