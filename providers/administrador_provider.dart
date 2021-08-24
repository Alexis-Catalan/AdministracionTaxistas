import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:radio_taxi_alfa_app/src/models/administrador.dart';

class AdministradorProvider {
  CollectionReference _ref;

  AdministradorProvider() {
    _ref = FirebaseFirestore.instance.collection('Administrador');
  }

  Future<void> crearAdministrador(Administrador administrador) {
    String errorMessage;

    try {
      return _ref.doc(administrador.id).set(administrador.toJson());
    } catch (error) {
      print('Error de Registro Administrador: ${error.code} \n ${error.message}');
      errorMessage = error.code;
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
  }

  Future<Administrador> obtenerId(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      Administrador administrador = Administrador.fromJson(document.data());
      return administrador;
    }

    return null;
  }

  Stream<DocumentSnapshot> obtenerIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void> actualizar(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }
}
