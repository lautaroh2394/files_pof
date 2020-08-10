import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Files POF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    countTotalFiles();
    textController.text = "Inicio";
    print("InitState");
  }

  final iconNew = Icon(Icons.add);
  final iconInit = Icon(Icons.update);
  final iconRead = Icon(Icons.receipt);
  final iconDelete = Icon(Icons.delete);

  final textController = TextEditingController();
  num totalFiles;

  Future<List<String>> getFilePaths() async{
    final directory = await getApplicationDocumentsDirectory();
    var dir = Directory(directory.path);
    var listado = await dir.list(recursive: false).toList();
    return listado.map((FileSystemEntity file) => file.path).where((path) => validatePath(path)).toList();
  }
  
  bool validatePath(String path){
    return path.contains("prueba") && path.contains(".txt");
  }
  void countTotalFiles() async{
    textController.text = "Un momento...";
    var listado = await getFilePaths();
    totalFiles = listado.length;
    print("totalFiles: $totalFiles");
    textController.text = "Ok. total archivos: $totalFiles";
  }
  
  void newFile() async{
    print("new file");
    textController.text = "Un momento...";
    final directory = await getApplicationDocumentsDirectory();
    print("${directory.path}");
    totalFiles = totalFiles + 1;
    File f = File("${directory.path}/prueba${totalFiles}.txt");
    await f.create();
    await f.writeAsString("hola ${totalFiles}");
    textController.text = "Ok";
  }

  Future<String> readContent(path) async {
    if (await FileSystemEntity.isFile(path) && validatePath(path)) {
      var f = File(path);
      String content = await f.readAsString();
      return content;
    }
    return null;
  }

  void deleteAll() async{
    var filespaths = await getFilePaths();
    for (int i = 0; i < totalFiles ;i++){
      var path = filespaths[i];
      File f = await File(path);
      await f.delete();
    }
    textController.text = "Borradas";
  }

  void readFiles() async{
    textController.text = "Un momento...";
    final directory = await getApplicationDocumentsDirectory();
    print("${directory.path}");
    List filespaths = await getFilePaths();
    var text = "";
    for (num i = 0; i < totalFiles ;i++){
      var path = filespaths[i];
      print("path: $path");
      var content = await readContent(path);
      if (content != null){
        print("file $i");
        print("content: $content");
        text = text + "\n ----\n" + content;
      }
    }
    /*
    //Este enfoque no espera a cada future. Debería mejorarlo
    filespaths.forEach((path) async {
      if (await FileSystemEntity.isFile(path) && path.contains("prueba")){
        var f = File(path);
        String content = await f.readAsString();
        text = text + "\n ----\n" + content;
      }
    });
    */
    textController.text = text;
  }

  @override
  Widget build(BuildContext context) {
    final logText = TextField(
      controller: textController,
      enabled: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: newFile,
                  child: iconNew,
                ),
                GestureDetector(
                  onTap: countTotalFiles,
                  child: iconInit,
                ),
                GestureDetector(
                  onTap: readFiles,
                  child: iconRead,
                ),
                GestureDetector(
                  onTap: deleteAll,
                  child: iconDelete,
                )
              ],
            ),
            Padding(padding: EdgeInsets.all(10),),
            logText,
          ],
        ),
      ),
    );
  }
}
