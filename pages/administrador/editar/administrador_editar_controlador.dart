import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:radio_taxi_alfa_app/src/models/administrador.dart';
import 'package:radio_taxi_alfa_app/src/providers/administrador_provider.dart';
import 'package:radio_taxi_alfa_app/src/providers/auth_provider.dart';
import 'package:radio_taxi_alfa_app/src/utils/snackbar.dart' as utils;
import 'package:radio_taxi_alfa_app/src/utils/my_progress_dialog.dart';
import 'package:radio_taxi_alfa_app/src/providers/storage_provider.dart';

class AdministradorEditarControlador {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController nombreUsuarioControlador = new TextEditingController();
  TextEditingController telefonoControlador = new TextEditingController();

  AuthProvider _authProvider;
  AdministradorProvider _administradorProvider;
  StorageProvider _storageProvider;
  ProgressDialog _progressDialog;

  PickedFile eleccionFile;
  File imagenFile;

  Administrador administrador;

  Future init (BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;

    _authProvider = new AuthProvider();
    _administradorProvider = new AdministradorProvider();
    _storageProvider = new StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');

    obtenerInfoUsuario();
  }

  void obtenerInfoUsuario() async {
    administrador = await _administradorProvider.obtenerId(_authProvider.obtenerUsuario().uid);
    nombreUsuarioControlador.text = administrador.nombreUsuario;
    telefonoControlador.text = administrador.telefono;
    if(administrador?.imagen == null){
      imagenFile = null;
    } else {
      imagenFile = File(administrador?.imagen);
    }
    refresh();
  }

  void showAlertDialog() {

    Widget btnGaleria = TextButton(
        onPressed: () {
          obtenerImagen(ImageSource.gallery);
        },
        child: Text('GALERIA')
    );

    Widget btnCamara = TextButton(
        onPressed: () {
          obtenerImagen(ImageSource.camera);
        },
        child: Text('CAMARA')
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [
        btnGaleria,
        btnCamara
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );

  }

  Future obtenerImagen(ImageSource imageSource) async {
    eleccionFile = await ImagePicker().getImage(source: imageSource);
    if (eleccionFile != null) {
      imagenFile = File(eleccionFile.path);
    }
    else {
      print('No selecciono ninguna imagen');
    }
    Navigator.pop(context);
    refresh();
  }

  void actualizar() async {
    String nombreUsuario = nombreUsuarioControlador.text;
    String telefono = telefonoControlador.text.trim();

    if (nombreUsuario.isEmpty || telefono.isEmpty) {
      utils.Snackbar.showSnackbar(context, key, Colors.red, 'Debes rellenar todos los campos.');
      return;
    }

    if(telefono.length < 10){
      utils.Snackbar.showSnackbar(context, key, Colors.red, 'El número de teléfono debe tener 10 digitos.');
      return;
    }

    if (eleccionFile == null) {
      Map<String, dynamic> data = {
        'imagen': administrador?.imagen ?? null,
        'nombreUsuario': nombreUsuario,
        'telefono': telefono
      };

      await _administradorProvider.actualizar(data, _authProvider.obtenerUsuario().uid);
    } else {
      _progressDialog.show();
      TaskSnapshot snapshot = await _storageProvider.subirArchivo(eleccionFile,administrador.id);
      String imagenUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> data = {
        'imagen': imagenUrl,
        'nombreUsuario': nombreUsuario,
        'telefono': telefono
      };

      await _administradorProvider.actualizar(data, _authProvider.obtenerUsuario().uid);
      _progressDialog.hide();
    }
    utils.Snackbar.showSnackbar(context, key, Colors.cyan, 'Los datos se actualizaron');
  }

}