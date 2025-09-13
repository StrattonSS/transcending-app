import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  String? _selectedState;
  String? _selectedCity;
  String? _selectedCategory;

  final List<String> _states = ['California', 'New York', 'Texas'];
  final Map<String, List<String>> _cities = {
    'California': ['Los Angeles', 'San Francisco'],
    'New York': ['New York City', 'Buffalo'],
    'Texas': ['Austin', 'Houston'],
  };

  final List<String> _categories = [
    'Mental Health',
    'Medical',
    'Housing',
    'Legal',
    'Employment',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Slight top breathing room (tiny)
              const SizedBox(height: 5),

              // 🌈 LOGO/TITLE — crop extra transparent space at the bottom
              // Align(heightFactor: 0.58) keeps the TOP 58% of the image (cropping the rest).
              // Tweak 0.58 → 0.62 or 0.54 if you want more/less crop.
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.30,
                  child: Image.asset(
                    'assets/images/name.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 🎨 Splash art directly under logo, nudged up a bit to close any micro-gap
              Transform.translate(
                offset: const Offset(0, -6), // pull upward slightly
                child: Opacity(
                  opacity: 0.70,
                  child: Image.asset(
                    'assets/images/bird.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    height: 360,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔍 Search bar
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search resources...',
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() => _searchText = value.toLowerCase());
                },
              ),
              const SizedBox(height: 12),

              // State dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select a state',
                  fillColor: Colors.white,
                  filled: true,
                ),
                value: _selectedState,
                items: _states
                    .map((state) =>
                    DropdownMenuItem(value: state, child: Text(state)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                  });
                },
              ),
              const SizedBox(height: 12),

              // City dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select a city',
                  fillColor: Colors.white,
                  filled: true,
                ),
                value: _selectedCity,
                items: (_cities[_selectedState] ?? [])
                    .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCity = value);
                },
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select a category',
                  fillColor: Colors.white,
                  filled: true,
                ),
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),

              // Firestore results
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resources')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading resources',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        data['name']?.toString().toLowerCase() ?? '';
                    final state =
                        data['state']?.toString().toLowerCase() ?? '';
                    final city =
                        data['city']?.toString().toLowerCase() ?? '';
                    final category =
                        data['category']?.toString().toLowerCase() ?? '';

                    return name.contains(_searchText) &&
                        (_selectedState == null ||
                            state == _selectedState!.toLowerCase()) &&
                        (_selectedCity == null ||
                            city == _selectedCity!.toLowerCase()) &&
                        (_selectedCategory == null ||
                            category == _selectedCategory!.toLowerCase());
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No resources found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final resource = docs[index];
                      final data = resource.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          tileColor: Colors.white,
                          title: Text(data['name'] ?? 'No Name'),
                          subtitle: Text(
                            '${data['city']}, ${data['state']} - ${data['category']}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () {
                              final url = data['website'];
                              if (url != null) {
                                launchUrl(Uri.parse(url));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
