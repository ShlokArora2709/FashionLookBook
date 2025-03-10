import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

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
      home: FashionHomeScreen(),
    );
  }
}

class FashionHomeScreen extends StatefulWidget {
  @override
  _FashionHomeScreenState createState() => _FashionHomeScreenState();
}

class _FashionHomeScreenState extends State<FashionHomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _imageUrls = [];
  List<String> _trendImages = [];
  bool _isLoading = false;

  static const String apiKey =
      'AIzaSyBpKVG6btdbU5WbWax4SHO6OXwcKf6hUAg'; // Replace securely
  static const String cx = '308a8669e24444efb'; // Replace securely

  @override
  void initState() {
    super.initState();
    fetchTrends(); // Load trends on startup
  }

  // Fetches trending fashion images
  Future<void> fetchTrends() async {
    await fetchImages("latest fashion trends 2024", true);
  }

  // Fetches images for search queries
  Future<void> fetchImages(String query, bool isTrend) async {
    setState(() => _isLoading = true);

    final String url =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&key=$apiKey&searchType=image';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> images = List<String>.from(
            data['items'].map((item) => item['link'].toString()));

        setState(() {
          if (isTrend) {
            _trendImages = images;
          } else {
            _imageUrls = images;
          }
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Predefined styling categories
  final Map<String, String> stylingIdeas = {
    "Casual Wear": "casual street style outfits 2024",
    "Formal Wear": "formal wear trends 2024",
    "Party Look": "party outfit ideas 2024",
    "Summer Vibes": "summer fashion trends 2024",
    "Winter Outfits": "winter street style 2024",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fashion Lookbook')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explore Trends - Carousel
              Text("Explore Trends",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _trendImages.isEmpty
                  ? CircularProgressIndicator()
                  : CarouselSlider(
                      options: CarouselOptions(height: 200, autoPlay: true),
                      items: _trendImages.map((img) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(img, fit: BoxFit.cover),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 20),

              // Search Fashion Styles
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search fashion style...',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        fetchImages(_searchController.text, false);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Discover Styling Ideas - Buttons
              Text("Discover Styling Ideas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: stylingIdeas.keys.map((category) {
                  return ElevatedButton(
                    onPressed: () =>
                        fetchImages(stylingIdeas[category]!, false),
                    child: Text(category),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Search Results Grid
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _imageUrls.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(_imageUrls[index],
                                  fit: BoxFit.cover),
                            );
                          },
                        )
                      : Center(
                          child:
                              Text("Search or select a style to see images")),
            ],
          ),
        ),
      ),
    );
  }
}
