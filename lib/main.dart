import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UrlSaver(),
    );
  }
}

class UrlSaver extends StatefulWidget {
  @override
  _UrlSaverState createState() => _UrlSaverState();
}

class _UrlSaverState extends State<UrlSaver> {
  TextEditingController _urlController = TextEditingController();
  String _savedUrl = '';
  List<String> _savedUrls = [];

  @override
  void initState() {
    super.initState();
    _loadSavedUrls();
  }

  Future<void> _loadSavedUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUrls = prefs.getStringList('saved_urls') ?? [];
    });
  }

  Future<void> _saveUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newUrl = _urlController.text;

    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL cannot be empty'),
        ),
      );
    } else if (_savedUrls.contains(newUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL already saved: $newUrl'),
        ),
      );
    } else {
      _savedUrls.add(newUrl);
      await prefs.setStringList('saved_urls', _savedUrls);
      setState(() {
        _savedUrl = newUrl;
        _urlController.clear();
      });
    }
  }

  Future<void> _deleteUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _savedUrls.remove(url);
    await prefs.setStringList('saved_urls', _savedUrls);
    setState(() {
      _savedUrl = '';
    });
  }

  Future<void> _openSavedUrlInApp(String url) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved URL'),
            ),
            body: WebView(
              initialUrl: url,
            ),
          );
        },
      ),
    );
    // Implement the logic to open the URL in your app here.
    // You can use a WebView widget or navigate to a specific screen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Saver'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Enter URL',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveUrl,
              child: Text('Save URL'),
            ),
            SizedBox(height: 20),
            if (_savedUrls.isNotEmpty)
              Text('Saved URLs:'),
            Expanded(
              child: ListView.builder(
                itemCount: _savedUrls.length,
                itemBuilder: (context, index) {
                  final url = _savedUrls[index];
                  return ListTile(
                    title: InkWell(
                      child: Text(
                        url,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () => _openSavedUrlInApp(url),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteUrl(url),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}












