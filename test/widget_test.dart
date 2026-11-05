import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exp08_firestore_book_search/book_search_page.dart';
import 'package:exp08_firestore_book_search/main.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() async {
    db = FakeFirebaseFirestore();
    await db.collection('books').add({'title': 'Python Programming', 'author': 'David', 'copies': 5});
    await db.collection('books').add({'title': 'Artificial Intelligence', 'author': 'Andrew', 'copies': 7});
    await db.collection('books').add({'title': 'Flutter Basics', 'author': 'John Smith', 'copies': 0});
  });

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
  }

  testWidgets('Setup screen when Firebase is not configured', (tester) async {
    await tester.pumpWidget(MyApp(initError: UnsupportedError('x')));
    expect(find.text('Firebase setup required'), findsOneWidget);
  });

  testWidgets('Search results, case-insensitive match, availability, errors',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: BookSearchPage(firestore: db)));

    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(find.text('Please enter a book title'), findsOneWidget);

    await search(tester, 'Python Programming');
    expect(find.text('David'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);

    await search(tester, 'artificial intelligence');
    expect(find.text('Andrew'), findsOneWidget);

    await search(tester, 'Flutter Basics');
    expect(find.text('Not Available – All Copies Issued'), findsOneWidget);

    await search(tester, 'Unknown Book');
    expect(find.text('Book not found'), findsOneWidget);
  });
}
