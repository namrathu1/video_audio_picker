import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_audio_picker/views/recorded_list_view.dart';
import 'package:video_audio_picker/views/recorder_home_view.dart';
import 'package:video_audio_picker/views/recorder_view.dart';
import 'package:video_player/video_player.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  File _image;
  File _cameraImage;
  File _video;
  File _cameraVideo;
  ImagePicker picker = ImagePicker();
  VideoPlayerController _videoPlayerController;
  VideoPlayerController _cameraVideoPlayerController;

  Directory appDirectory;
  Stream<FileSystemEntity> fileStream;
  List<String> records;

  @override
  void initState() {
    super.initState();
    records = [];
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      appDirectory.list().listen((onData) {
        if (onData.path.endsWith(".aac")) {
          records.add(onData.path);
        }
      }).onDone(() {
        records = records.reversed.toList();
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    fileStream = null;
    appDirectory = null;
    records = null;
    super.dispose();
  }

  _pickImageFromGallery() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    File image = File(pickedFile.path);

    setState(() {
      _image = image;
    });
  }

  _pickImageFromCamera() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 50);

    File image = File(pickedFile.path);

    setState(() {
      _cameraImage = image;
    });
  }

  _pickVideo() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);

    _video = File(pickedFile.path);

    _videoPlayerController = VideoPlayerController.file(_video)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
  }

  _pickVideoFromCamera() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile.path);

    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.play();
      });
  }

  _onRecordComplete() {
    records.clear();
    appDirectory.list().listen((onData) {
      if (onData.path.endsWith(".aac")) {
        records.add(onData.path);
      }
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      setState(() {});
    });
  }

  _recordAudioAndPlay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecorderHomeView(
          title: 'Flutter Voice',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            if (_image != null)
              Image.file(_image)
            else
              Text(
                "Click on Pick Image to select an Image",
                style: TextStyle(fontSize: 18.0),
              ),
            RaisedButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              child: Text("Pick Image From Gallery"),
            ),
            SizedBox(
              height: 16.0,
            ),
            if (_cameraImage != null)
              Image.file(_cameraImage)
            else
              Text(
                "Click on Pick Image to select an Image",
                style: TextStyle(fontSize: 18.0),
              ),
            RaisedButton(
              onPressed: () {
                _pickImageFromCamera();
              },
              child: Text("Pick Image From Camera"),
            ),
            if (_video != null)
              _videoPlayerController.value.initialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : Container()
            else
              Text(
                "Click on Pick Video to select video",
                style: TextStyle(fontSize: 18.0),
              ),
            RaisedButton(
              onPressed: () {
                _pickVideo();
              },
              child: Text("Pick Video From Gallery"),
            ),
            if (_cameraVideo != null)
              _cameraVideoPlayerController.value.initialized
                  ? AspectRatio(
                      aspectRatio: _cameraVideoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_cameraVideoPlayerController),
                    )
                  : Container()
            else
              Text(
                "Click on Pick Video to select video",
                style: TextStyle(fontSize: 18.0),
              ),
            RaisedButton(
              onPressed: () {
                _pickVideoFromCamera();
              },
              child: Text("Pick Video From Camera"),
            ),
            // RaisedButton(
            //   onPressed: () {
            //     _recordAudioAndPlay();
            //   },
            //   child: Text("Audio recording"),
            // ),
            RecordListView(
              records: records,
            ),
            RecorderView(
              onSaved: _onRecordComplete,
            ),
          ],
        ),
      ),
    );
  }
}
