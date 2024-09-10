import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paginated ListView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaginatedListPage(),
    );
  }
}

class PaginatedListPage extends StatefulWidget {
  @override
  _PaginatedListPageState createState() => _PaginatedListPageState();
}

class _PaginatedListPageState extends State<PaginatedListPage> {
  List _data = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  final String _apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$_apiUrl?_page=$_page&_limit=$_limit'));
      if (response.statusCode == 200) {
        List newData = json.decode(response.body);
        if (newData.length < _limit) {
          _hasMore = false;
        }
        setState(() {
          _page++;
          _data.addAll(newData);
        });
      } else {
        _showError('Failed to load data');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchData();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paginated ListView'),
      ),
      body: ListView.builder(
        itemCount: _data.length + 1,
        itemBuilder: (context, index) {
          if (index == _data.length) {
            if (_hasMore) {
              _fetchData();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }
          final item = _data[index];
          return ListTile(
            title: Text(item['title']),
            subtitle: Text(item['body']),
          );
        },
      ),
    );
  }
}
