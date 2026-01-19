import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getOrdersByUser(String uid) async {
    final snap = await _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<Map<String, int>> getOrderStats(String uid) async {
    final orders = await getOrdersByUser(uid);
    int total = orders.length;
    int delivered = orders.where((o) => o['status'] == 'delivered').length;
    int pending = orders.where((o) => o['status'] == 'pending').length;
    int confirmed = orders.where((o) => o['status'] == 'confirmed').length;
    int shipped = orders.where((o) => o['status'] == 'shipped').length;
    return {
      'total': total,
      'delivered': delivered,
      'pending': pending,
      'confirmed': confirmed,
      'shipped': shipped,
    };
  }
}
