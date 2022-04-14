import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Sudoku(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       splash: splash,
//       nextScreen:const Sudoku());
//   }
// }


class Sudoku extends StatefulWidget {
  const Sudoku({Key? key}) : super(key: key);

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  File? selectedimage;
  String? message;
  Uint8List? _img;
  File? selectedImg;
  String path = '';
  var _permissionStatus;
  bool loading = true;

  uploadImg() async{
    showDialog(context: context, builder: (context){
      return Center(child: SizedBox(height:200,width: 200,child: CircularProgressIndicator()),);
    });
    final request = http.MultipartRequest(
        "POST",Uri.parse("http://0436-182-48-236-85.ngrok.io/upload")
    );
    final header = {"Content-type":"multipart/form-data","Connection":"keep-alive"};
    request.files.add(http.MultipartFile('image',selectedImg!.readAsBytes().asStream(),selectedImg!.lengthSync(),filename: selectedImg!.path.split("/").last));
    request.headers.addAll(header);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    String img_str = resJson['payload'];
    final decodeBytes = base64Decode(img_str);
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    setState(() {
      path = "${directory.path}/solved_image.png";
      loading = false;
      Navigator.of(context).pop();
    });
    var file = File(path);
    file.writeAsBytesSync(decodeBytes);



    setState(() {
    });

  }
  imagepicker() async {
    final ImagePicker _imagepicker = ImagePicker();
    final img = await _imagepicker.getImage(source: ImageSource.gallery);
    selectedImg = File(img!.path);
    return await img.readAsBytes();
  }
  @override
  Widget build(BuildContext context) {
    _selectimage(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Choose an Image'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Take a Photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final image = await imagepicker();
                  setState(() {
                    _img = image;
                  });
                },
              ),
              CupertinoDialogAction(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List image = await imagepicker();
                  setState(() {
                    _img = image;
                  });
                },
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku Solver"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white60
          ),
          child: _img != null ? Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: ()async{
                    _selectimage(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 70,horizontal: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height /2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(_img!),
                          fit: BoxFit.cover,
                        ),
                      ),

                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: ()async {
                          await uploadImg();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Page2(path: path,)));
                          },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            height: 80,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black,
                            ),
                            child: Center(child: Text("Find Solution",style: TextStyle(color: Colors.cyanAccent,fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: ()async {
                          setState(() {
                            _img = null;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            height: 80,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black,
                            ),
                            child: Center(child: Text("Remove Image",style: TextStyle(color: Colors.cyanAccent,fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Add a Suduko Puzzle',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500),),
                Text('to solve',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500),),
                SizedBox(height: 40,),
                GestureDetector(
                  onTap: ()async{
                    _selectimage(context);
                  },
                  child: Container(
                    height: 80,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: Center(child: Text("Pick Image",style: TextStyle(color: Colors.cyanAccent,fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({Key? key, required this.path}) : super(key: key);

  final String path;

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solution'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(child: Container(child: Image.file(File(widget.path)))),
    );
  }
}

