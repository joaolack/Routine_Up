import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Habit>> getHabits(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) => Habit.fromMap(doc.data(), id: doc.id)).toList());
  }

  Future<void> addHabit(String uid, Habit habit) async {
    final doc = _firestore.collection('users').doc(uid).collection('habits').doc();
    habit.id = doc.id;
    await doc.set(habit.toMap());
  }

  Future<void> updateHabit(String uid, Habit habit) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toMap());
  }

  Future<void> deleteHabit(String uid, String habitId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('habits')
        .doc(habitId)
        .delete();
  }
}