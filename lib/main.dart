import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'URL Shortener';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final _backendUrl = Uri.parse("https://ashortl.herokuapp.com/api/");
  Map _responseMap = Map();
  String _inputUrl = '';
  String _shortenedUrl = '';
  String _currentUrl = '';
  bool _visible = false;

  bool _showProgressBar = false;

  void _submit() async {
    if (_formKey.currentState.validate()) {
      // Show the progress bar
      setState(() => _showProgressBar = true);
      var response = await http.post(_backendUrl,
          body: '{"url": "$_inputUrl"}',
          headers: {"Content-Type": 'application/json'});
      if (response.statusCode >= 200 && response.statusCode <= 400) {
        // Close the progress bar
        setState(() => _showProgressBar = false);

        setState(() {
          _responseMap = jsonDecode(response.body);
          _shortenedUrl = _responseMap['short'];
          _currentUrl = _responseMap['url'];

          // Short Url becomes visible
          _visible = true;
        });
      }
    }
  }

  String _validateURL(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }

    return null;
  }

  // Copies the shortened url to Clipboard
  void _copyToClipBoard() async {
    ClipboardData data = ClipboardData(text: _shortenedUrl);
    await Clipboard.setData(data);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Link Copied to Clipboard!'),
        backgroundColor: Colors.blueGrey,
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     child: Text('URL', style: TextStyle(fontSize: 18.0))),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Url',
                    hintText: 'Enter the url...'),
                validator: _validateURL,
                onChanged: (val) {
                  setState(() => _inputUrl = val);
                  setState(() {
                    if (_visible) {
                      _visible = false;
                    }
                    if (_currentUrl == val) {
                      _visible = true;
                    }
                  });
                },
              )),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _submit,
                child: Text('Shorten'),
              )),
          Opacity(
              opacity: !_visible && _showProgressBar ? 1.0 : 0.0,
              child: Center(child: CircularProgressIndicator())),
          AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Shortened URL',
                          style: TextStyle(fontSize: 18.0))),
                  Container(
                    width: double.maxFinite,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                    ),
                    child: Text(_shortenedUrl,
                        style: TextStyle(
                          fontSize: 18.0,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _copyToClipBoard,
                      child: Icon(
                        Icons.copy,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
