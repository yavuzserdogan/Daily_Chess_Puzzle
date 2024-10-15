import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(String username, String password, int time, String date) async {
    await _firestore.collection('users').doc(username).set({
      'username': username,
      'password': password,
      'time': time,
      'date': date,
    });
  }

  Future<bool> checkUserExists(String username) async {
    final doc = await _firestore.collection('users').doc(username).get();
    return doc.exists;
  }

  Future<bool> checkUserPassword(String username, String password) async {
    final querySnapshot = await _firestore.collection('users').where('username', isEqualTo: username).get();
    if (querySnapshot.docs.isEmpty) {
      return false;
    }
    final userDoc = querySnapshot.docs.first;
    final storedPassword = userDoc['password'];
    return storedPassword == password;
  }

  Future<void> updateUserTime(String username, int time) async {
    await _firestore.collection('users').doc(username).update({
      'time': time,
    });
  }

  Future<int> getUserTime(String username) async {
    final doc = await _firestore.collection('users').doc(username).get();
    return doc.data()?['time'] ?? 0;
  }

  Future<void> updateUserDate(String username, String date) async {
    await _firestore.collection('users').doc(username).update({
      'date': date,
    });
  }

  Future<String> getUserDate(String username) async {
    final doc = await _firestore.collection('users').doc(username).get();
    return doc.data()?['date'] ?? "";
  }

  Future<List<Map<String, dynamic>>> getUsersByDate(String date) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('date', isEqualTo: date)
        .get();

    List<Map<String, dynamic>> users = [];

    for (var doc in querySnapshot.docs) {
      // Cast doc.data() to Map<String, dynamic>
      final data = doc.data() as Map<String, dynamic>;
      users.add({
        'username': doc.id,
        'time': data['time'] ?? 0,
      });
    }
    return users; // Return the list of users
  }
}
