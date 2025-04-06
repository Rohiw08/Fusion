import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/models/widget_model.dart';

final widgetsProvider = FutureProvider<List<WidgetModel>>((ref) async {
  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('widgets').get();

    final widgets = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return WidgetModel.fromJson(data);
    }).toList();

    return widgets;
  } catch (e) {
    print("Error fetching widgets: $e");
    return [];
  }
});
