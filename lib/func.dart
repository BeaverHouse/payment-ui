import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// String url = "http://10.0.2.2:8000";
String url = "http://130.162.149.32:8000";

void getOkSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'OK', 
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void getOpenSnackbar(BuildContext context, String message, Function() func) {
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: '열기', 
      onPressed: func,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


// Multipart 파일 api 전송
Future<http.StreamedResponse> sendFileRequest(
  String name,
  int year,
  int month,
  List<File> files,
) async {  
  Uri uri = Uri.parse('$url/process');
  
  // request 객체 생성
  http.MultipartRequest request = http.MultipartRequest('POST', uri);
  
  // 파일 body 추가
  List<http.MultipartFile> fileData = [];
  for(File file in files){
    final f = await http.MultipartFile.fromPath('files', file.path);
    fileData.add(f);
  }
  request.files.addAll(fileData);
  
  // 일반 body 추가
  request.fields['name'] = name;
  request.fields['year'] = year.toString();
  request.fields['month'] = month.toString();
  
  return await request.send();
}


// 파일 Response 받기
Future<void> fileDownloadAndOpen(
  BuildContext context,
  String name,
  int year,
  int month
) async {
  Uri uri = Uri.parse('$url/download?name=$name&year=$year&month=$month');
  final response = await http.get(uri);

  try { 
    // 디렉토리 선정
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) dir = await getExternalStorageDirectory();
    }
    
    // 엑셀 파일 쓰기
    final filename = '${dir?.path}/$name $year년 $month월 법인카드 내역_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    await File(filename).writeAsBytes(response.bodyBytes);
    
    // ignore: use_build_context_synchronously
    if(!context.mounted) return;
    getOpenSnackbar(context, "다운로드되었습니다.", () async {
      await OpenFilex.open(filename);
    });
  } catch (e) {      
    // ...
  }
}