import 'package:flutter/material.dart';
import 'package:radio_taxi_alfa_app/src/models/historial_viaje.dart';
import 'package:radio_taxi_alfa_app/src/providers/historial_viaje_provider.dart';

class AdministradorHistorialControlador {

  Function refresh;
  BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  HistorialViajeProvider _historialViajeProvider;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _historialViajeProvider = new HistorialViajeProvider();

    refresh();
  }

  Future<List<HistorialViaje>> obtenerHistorial() async {
    return await _historialViajeProvider.getAll();
  }

  void abrirHistorialDetalle(String id) {
    Navigator.pushNamed(context, 'administrador/historial/detalle', arguments: id);
  }

}