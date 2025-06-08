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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Transcending"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          // Future: Show admin button here conditionally
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x40000000), // Black
              Color(0x40784F17), // Brown
              Color(0x405BCEFA), // Trans Blue
              Color(0x40F5A9B8), // Trans Pink
              Color(0x40FFFFFF), // White
              Color(0x40FF0000), // Red
              Color(0x40FF8C00), // Orange
              Color(0x40FFFF00), // Yellow
              Color(0x40008000), // Green
              Color(0x400000FF), // Blue
              Color(0x408B00FF), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔍 Search Bar
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
                const SizedBox(height: 16),

                // ⬇️ State Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select a state',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  value: _selectedState,
                  items: _states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _selectedCity = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // ⬇️ City Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select a city',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  value: _selectedCity,
                  items: (_cities[_selectedState] ?? []).map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                ),
                const SizedBox(height: 16),

                // ⬇️ Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select a category',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 24),

                // Firestore Results List
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('resources')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading resources');
                    }
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name']?.toString().toLowerCase() ?? '';
                      final state =
                          data['state']?.toString().toLowerCase() ?? '';
                      final city = data['city']?.toString().toLowerCase() ?? '';
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
                      return const Text('No resources found');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final resource = docs[index];
                        final data = resource.data() as Map<String, dynamic>;
                        return ListTile(
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
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
