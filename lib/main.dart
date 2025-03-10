import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(FashionLookbookApp());
}

class FashionLookbookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion Lookbook',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: FashionSearchScreen(),
    );
  }
}

class FashionSearchScreen extends StatefulWidget {
  @override
  _FashionSearchScreenState createState() => _FashionSearchScreenState();
}

class _FashionSearchScreenState extends State<FashionSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _imageUrls = [];
  bool _isLoading = false;

  Future<void> fetchFashionImages(String query) async {
    setState(() => _isLoading = true);

    const String apiKey =
        'AIzaSyBpKVG6btdbU5WbWax4SHO6OXwcKf6hUAg'; // Replace securely
    const String cx = '308a8669e24444efb'; // Replace securely

    final String url =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&key=$apiKey&searchType=image';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> imageUrls = List<String>.from(
            data['items'].map((item) => item['link'].toString()));
        setState(() => _imageUrls = imageUrls);
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fashion Lookbook')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search fashion style...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      fetchFashionImages(_searchController.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(_imageUrls[index],
                            fit: BoxFit.cover);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
