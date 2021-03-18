import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'round_icon_button.dart';
//import 'dart:async';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_1/Services/authentication_services.dart';
import 'constants.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

enum AppState {
  IsInitializing,
  IsError,
  IsReady,
  IsRecording,
  IsPlaying,
  IsPredicting
}
const RECORDING_DURATION = Duration(seconds: 5);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  var url = "";
  var data;
  final AuthenticationServices _auth = AuthenticationServices();
  AppState _appState = AppState.IsInitializing;
  FlutterAudioRecorder _recorder;
  Recording _recording;
  String _feedbackMessage;
  String temp = "";

  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        /// True if the recorder was initialized successfully.
        var hasPermissions = await _checkPermissionsForRecorder();

        if (hasPermissions) {
          setState(() {
            _appState = AppState.IsReady;
            print("Ready");
          });
        } else {
          setState(() {
            _appState = AppState.IsError;
            _feedbackMessage = 'You need to give the app proper permissions';
            print("error");
          });
        }
      } catch (e) {
        print(e);

        setState(() {
          _appState = AppState.IsError;
          _feedbackMessage = e.message;
        });
      }
    });
  }

  Future<void> _initializeRecorder() async {
    String dirPath = (await getExternalStorageDirectory()).path;
    temp = dirPath;
    String filename = 'tempFile.wav';
    String filePath = "$dirPath/$filename";
    File file = File(filePath);

    /// If the file exists, clean it up first
    /// because the FlutterAudioRecorder will
    /// throw an error if the file exists
    if (file.existsSync()) {
      file.deleteSync();
    }

    _recorder = FlutterAudioRecorder(
      filePath,
      audioFormat: AudioFormat.WAV,
    );

    await _recorder.initialized;
  }

  Future<void> _startRecording() async {
    await _initializeRecorder();
    await _recorder.start();

    /// The current status of the recording.
    Recording recordingState = await _recorder.current();

    setState(() {
      _appState = AppState.IsRecording;
      _recording = recordingState;

      // We clear results so we can show the recording status.
    });
  }

  Future<void> _stopRecording() async {
    Recording recordingState = await _recorder.stop();

    setState(() {
      _recording = recordingState;
      _appState = AppState.IsReady;
    });
  }

  Future<void> _recordAudio() async {
    await _startRecording();
    await Future.delayed(RECORDING_DURATION);
    await _stopRecording();
    print("Done");
  }

  Future<bool> _checkPermissionsForRecorder() async {
    // Asks for proper permissions from the user
    return await FlutterAudioRecorder.hasPermissions;
  }

  IconData _recordIcon(AppState state) {
    switch (state) {
      case AppState.IsReady:
        return Icons.mic;
      case AppState.IsRecording:
      case AppState.IsPredicting:
        return Icons.mic_none;
      default:
        return Icons.mic_off;
    }
  }

  uploadImageToServer(File imageFile) async {
    print("attempting to connecto server......");
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    

    var uri = Uri.parse('http://192.168.43.220:5000/file');
    print("connection established.");
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    var result= await response.stream.bytesToString();
    print(result);
  }

  Widget build(BuildContext context) {
    bool _canRecord = _appState == AppState.IsReady;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voice Input',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: FloatingActionButton(
                    /// Calls _recordAudio function if the record button
                    /// is pressed and the app is in ready state.
                    onPressed: _canRecord ? _recordAudio : null,

                    tooltip: 'Record voice',
                    child: Icon(
                      _recordIcon(_appState),
                      color: _canRecord ? Colors.black54 : Colors.black26,
                      size: 60,
                    ),
                    backgroundColor:
                        _canRecord ? Colors.amber : Colors.blueGrey[100],
                  ),
                ),
                margin: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1D1E33),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: RoundIconButton(
                    icon: FontAwesomeIcons.play,
                    onCurrentPressed: () async {
                      String dirPath =
                          (await getExternalStorageDirectory()).path;

                      String filename = 'tempFile.wav';
                      String filePath = "$dirPath/$filename";
                      File file = File(filePath);
                      uploadImageToServer(file);
                      print(file);
                    },
                  ),
                ),
                margin: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1D1E33),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            GestureDetector(
              onTap: ()async {
                await logOut();
                Navigator.of(context).pushNamedAndRemoveUntil("welcomescreen", (Route <dynamic> route) => false);
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                color: buttonButtonColor,
                height: 80,
                width: double.infinity,
                margin: EdgeInsets.only(top: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future logOut() async {
    dynamic authResult = await _auth.logOut();
    
  }
}
