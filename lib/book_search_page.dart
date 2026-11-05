import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Searches the Firestore "books" collection (fields: title, author, copies).
class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key, this.firestore});

  /// Optional override (used by tests with a fake Firestore).
  final FirebaseFirestore? firestore;

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final CollectionReference<Map<String, dynamic>> books =
      (widget.firestore ?? FirebaseFirestore.instance).collection('books');

  Map<String, dynamic>? book;
  bool isLoading = false;
  String message = '';

  /// 1. Exact match:  where('title', isEqualTo: title)
  /// 2. If nothing matched, a case-insensitive match over the collection,
  ///    so "python programming" also finds "Python Programming".
  Future<Map<String, dynamic>?> _findBook(String title) async {
    final exact = await books.where('title', isEqualTo: title).limit(1).get();
    if (exact.docs.isNotEmpty) return exact.docs.first.data();

    final all = await books.get();
    final wanted = title.toLowerCase();
    for (final doc in all.docs) {
      final t = doc.data()['title'];
      if (t is String && t.trim().toLowerCase() == wanted) return doc.data();
    }
    return null;
  }

  Future<void> searchBook() async {
    final title = searchController.text.trim();
    if (title.isEmpty) {
      setState(() {
        book = null;
        message = 'Please enter a book title';
      });
      return;
    }

    setState(() {
      isLoading = true;
      book = null;
      message = '';
    });

    try {
      final result = await _findBook(title);
      if (!mounted) return;
      setState(() {
        book = result;
        message = result == null ? 'Book not found' : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        book = null;
        message = 'Error retrieving book details: $e';
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(
              width: 130,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final copies = book?['copies'];
    final available = copies is num && copies > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Book Search'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Book Title',
                    prefixIcon: Icon(Icons.menu_book),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => searchBook(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : searchBook,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading) const CircularProgressIndicator(),
                if (message.isNotEmpty)
                  Text(message, style: const TextStyle(color: Colors.red)),
                if (book != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Title:', '${book!['title'] ?? '-'}'),
                          _row('Author:', '${book!['author'] ?? '-'}'),
                          _row('Copies Available:', '${copies ?? '-'}'),
                          const SizedBox(height: 8),
                          Chip(
                            avatar: Icon(
                                available ? Icons.check_circle : Icons.cancel,
                                color: available ? Colors.green : Colors.red),
                            label: Text(
                              available
                                  ? 'Available'
                                  : 'Not Available – All Copies Issued',
                              style: TextStyle(
                                  color: available ? Colors.green.shade800 : Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
