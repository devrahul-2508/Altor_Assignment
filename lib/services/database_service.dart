import 'package:altor_assignment/models/altor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference altorCollection =
      FirebaseFirestore.instance.collection("altordata");

  Future<void> addAltorModel(AltorModel altorModel) async {
    try {
      await altorCollection.add(altorModel.toFirestore());
    } catch (e) {
      print(e.toString());
      print('Error adding AltarModel to Firestore: $e');
      rethrow; // You can handle the error according to your app's needs
    }
  }
}
