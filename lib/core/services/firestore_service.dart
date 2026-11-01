import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService._();

  static CollectionReference<Map<String, dynamic>> _snippets() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in to continue.');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('snippets');
  }

  static Future<List<Map<String, dynamic>>> getMySnippets() async {
    final snapshot = await _snippets()
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final snippets = await getMySnippets();
    return snippets.where((item) => item['favorite'] == true).toList();
  }

  static Future<Set<String>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((item) => item['id'].toString()).toSet();
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final snippets = await getMySnippets();
    final favorites = snippets.where((item) => item['favorite'] == true).length;
    final categories = <String>{};
    for (final item in snippets) {
      final tags = item['tags'] as List<dynamic>? ?? const [];
      if (tags.isNotEmpty) categories.add(tags.first.toString());
    }
    return {
      'snippetCount': snippets.length,
      'favoriteCount': favorites,
      'categoryCount': categories.length,
    };
  }

  static Future<Map<String, dynamic>> createSnippet({
    required String title,
    required String code,
    required String language,
    required String description,
    required List<String> tags,
  }) async {
    final now = FieldValue.serverTimestamp();
    final doc = await _snippets().add({
      'title': title.trim(),
      'code': code,
      'language': language,
      'description': description.trim(),
      'tags': tags,
      'favorite': false,
      'createdAt': now,
      'updatedAt': now,
    });
    return {
      'id': doc.id,
      'title': title.trim(),
      'code': code,
      'language': language,
      'description': description.trim(),
      'tags': tags,
      'favorite': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> setFavorite(String id, bool isFavorite) async {
    await _snippets().doc(id).update({
      'favorite': isFavorite,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
