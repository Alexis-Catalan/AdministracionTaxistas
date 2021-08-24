import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as ubicacion;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:radio_taxi_alfa_app/src/models/administrador.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:radio_taxi_alfa_app/src/models/taxista.dart';
import 'package:radio_taxi_alfa_app/src/providers/administrador_provider.dart';
import 'package:radio_taxi_alfa_app/src/providers/push_notificaciones_provider.dart';
import 'package:radio_taxi_alfa_app/src/providers/auth_provider.dart';
import 'package:radio_taxi_alfa_app/src/providers/taxista_provider.dart';
import 'package:radio_taxi_alfa_app/src/utils/snackbar.dart' as utils;
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;
import 'package:radio_taxi_alfa_app/src/providers/geofire_provider.dart';
import 'package:radio_taxi_alfa_app/src/widgets/bottom_sheet_taxistas_info.dart';

class AdministradorMapaControlador {
  BuildContext context;
  Function refresh;

  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(target: LatLng(17.5694024, -99.5181556), zoom: 14.0);

  AuthProvider _authProvider;
  AdministradorProvider _administradorProvider;
  GeofireProvider _geofireProvider;
  PushNotificacionesProvider _pushNotificacionesProvider;
  TaxistaProvider _taxistaProvider;

  Administrador administrador;
  Taxista taxista;
  Position _posicion;

  BitmapDescriptor marcadorTaxista;

  Map<MarkerId, Marker> marcadores = <MarkerId, Marker>{};

  StreamSubscription<DocumentSnapshot> _administradorInfoSuscription;
  StreamSubscription<List<DocumentSnapshot>> _taxisDisponiblesSuscription;

  double rotacion;

  Future init(BuildContext context, Function refresh) async {
    print('Se Inicio Mapa Administrador Controlador');
    this.context = context;
    this.refresh = refresh;
    _authProvider = new AuthProvider();
    _administradorProvider = new AdministradorProvider();
    _geofireProvider = new GeofireProvider();
    _pushNotificacionesProvider = new PushNotificacionesProvider();
    _taxistaProvider = new TaxistaProvider();
    marcadorTaxista = await crearMarcadorImagen('assets/img/taxi_icon.png');
    comprobarGPS();
    guardarToken();
    obtenerInfoAdministrador();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  void guardarToken(){
    _pushNotificacionesProvider.guardarToken(_authProvider.obtenerUsuario().uid, 'Administrador');
  }

  void obtenerInfoAdministrador() {
    Stream<DocumentSnapshot> administradorStream = _administradorProvider.obtenerIdStream(_authProvider.obtenerUsuario().uid);
    _administradorInfoSuscription = administradorStream.listen((DocumentSnapshot document) {
      administrador = Administrador.fromJson(document.data());
      refresh();
    });
  }

  void abrirDrawer() {
    key.currentState.openDrawer();
  }

  void abrirEditar() {
    Navigator.pushNamed(context, 'administrador/editar');
  }

  void abrirHistorial() {
    Navigator.pushNamed(context, 'administrador/historial');
  }

  void showAlertDialog() {
    Widget btnSi = TextButton(
        onPressed: CerrarSesion,
        child: Text('Si',style: TextStyle(color: utils.Colors.Azul,fontWeight: FontWeight.bold))
    );
    Widget btnNo = TextButton(
        onPressed: ()  => Navigator.pop(context, 'No'),
        child: Text('No',style: TextStyle(color: utils.Colors.Rojo,fontWeight: FontWeight.bold))
    );
    AlertDialog alertDialog = AlertDialog(
      title: Text('Cerrar Sesión',style: TextStyle(color: utils.Colors.degradadoColor)),
      content: Text('¿Está seguro de cerrar sesión?',style: TextStyle(color: utils.Colors.degradadoColor)),
      actions: [
        btnNo,
        btnSi
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  void CerrarSesion() async {
    await _authProvider.cerrarSesion();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  void dispose() {
    _administradorInfoSuscription?.cancel();
    _taxisDisponiblesSuscription?.cancel();
  }


  void CentrarPosicion() {
    if (_posicion != null) {
      animarCamaraPosicion(_posicion.latitude, _posicion.longitude);
    } else {
      utils.Snackbar.showSnackbar(context, key, Colors.red, 'Activa el GPS para obtener la posición');
    }
  }


  void comprobarGPS() async {
    bool activoUbicacion = await Geolocator.isLocationServiceEnabled();
    if (activoUbicacion) {
      print('GPS ACTIVADO');
      actualizarUbicacion();
    } else {
      print('GPS DESACTIVADO');
      bool ubicacionGPS = await ubicacion.Location().requestService();
      if (ubicacionGPS) {
        actualizarUbicacion();
        print('ACTIVO EL GPS');
      }
    }
  }

  void actualizarUbicacion() async {
    try {
      await _determinarPosicion();
      _posicion = await Geolocator.getLastKnownPosition();//Obtener la ultima posicion de la ubicacion
      CentrarPosicion();
      obtenerTaxistasCercanos();
    } catch (error) {
      print('Error en la localizacion: $error');
    }
  }

  Future<Position> _determinarPosicion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void obtenerTaxistasCercanos() {//Dudas
    Stream<List<DocumentSnapshot>> taxistasStream = _geofireProvider.obtenerTaxistasCercanos(_posicion.latitude, _posicion.longitude, 5);
    _taxisDisponiblesSuscription = taxistasStream.listen((List<DocumentSnapshot> documentList) {

      for (DocumentSnapshot d in documentList) {
        print('DOCUMENT: $d');
      }
      for (MarkerId m in marcadores.keys) {
        bool retirar = true;

        for (DocumentSnapshot d in documentList) {
          if (m.value == d.id) {
            retirar = false;
          }
        }
        if (retirar) {
          marcadores.remove(m);
          refresh();
        }
      }
      for (DocumentSnapshot d in documentList) {
        GeoPoint point = d.data()['posicion']['geopoint'];
        rotacion = d.data()['rotacion'];
        agregarMarcador(d.id, point.latitude, point.longitude,marcadorTaxista);
      }
      refresh();
    });
  }

  void getTaxistaInfo(String idTaxista) async {
    taxista = await _taxistaProvider.obtenerId(idTaxista);
    refresh();
    openBottomSheet();
  }

  void openBottomSheet() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTaxistasInfo(
          imagenUrl: taxista?.imagen,
          nombreUsuario: taxista?.nombreUsuario,
          correo: taxista?.correo,
          placas: taxista?.placas,
          telefono: taxista?.telefono,
        )
    );
    //refresh();
  }

  Future<BitmapDescriptor> crearMarcadorImagen(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  Future animarCamaraPosicion(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 0, target: LatLng(latitude, longitude), zoom: 16.8)));
    }
  }

  void agregarMarcador(String marcadorId, double lat, double lng, BitmapDescriptor iconMarcador) {
    MarkerId id = MarkerId(marcadorId);
    Marker marcador = Marker(
        markerId: id,
        onTap: () =>  getTaxistaInfo(marcadorId),
        icon: iconMarcador,
        position: LatLng(lat, lng),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: rotacion);

    marcadores[id] = marcador;
  }
}
