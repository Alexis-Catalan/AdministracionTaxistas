import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:radio_taxi_alfa_app/src/models/administrador.dart';
import 'package:radio_taxi_alfa_app/src/providers/administrador_provider.dart';
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;
import 'package:radio_taxi_alfa_app/src/providers/auth_provider.dart';
import 'package:radio_taxi_alfa_app/src/utils/snackbar.dart' as utils;
import 'package:radio_taxi_alfa_app/src/utils/my_progress_dialog.dart';

class AdministradorRegistrarseControlador {
  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController nombreUsuarioControlador = new TextEditingController();
  TextEditingController correoControlador = new TextEditingController();
  TextEditingController telefonoControlador = new TextEditingController();
  TextEditingController passwordControlador = new TextEditingController();
  TextEditingController confirmarPasswordControlador = new TextEditingController();

  AuthProvider _authProvider;
  AdministradorProvider _administradorProvider;
  ProgressDialog _progressDialog;

  bool isPassword = true;
  bool isPasswordConfirm = true;

  Future init(BuildContext context, Function refresh) {
    print('Se Inicio Administrador Registrarse Controlador');
    this.context = context;
    this.refresh = refresh;
    _authProvider = new AuthProvider();
    _administradorProvider = new AdministradorProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
  }

  void Ocultar(){
    isPassword = !isPassword;
    refresh();
  }

  void OcultarConfirmar(){
    isPasswordConfirm = !isPasswordConfirm;
    refresh();
  }

  void Registrarse() async {
    String nombreUsuario = nombreUsuarioControlador.text;
    String correo = correoControlador.text.trim();
    String telefono = telefonoControlador.text.trim();
    String password = passwordControlador.text.trim();
    String confirmarPassword = confirmarPasswordControlador.text.trim();

    if (nombreUsuario.isEmpty || correo.isEmpty || telefono.isEmpty || password.isEmpty || confirmarPassword.isEmpty) {
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'Debes rellenar todos los campos.');
      return;
    }

    bool correoValido = RegExp(r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$").hasMatch(correo);

    if (!correoValido) {
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'El correo electrónico no es válido.');
      return;
    }

    if(telefono.length < 10){
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'El número de teléfono debe tener 10 digitos.');
      return;
    }

    if (password.length < 6) {
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (confirmarPassword != password) {
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'Las contraseñas no coinciden.');
      return;
    }

    try {
      _progressDialog.show();
      bool registrado = await _authProvider.registrarUsuario(correo, password);

      if (registrado) {
        Administrador administrador = new Administrador(
            id: _authProvider.obtenerUsuario().uid,
            nombreUsuario: nombreUsuario,
            correo: _authProvider.obtenerUsuario().email,
            telefono: telefono);

        await _administradorProvider.crearAdministrador(administrador);

        _progressDialog.hide();
        utils.Snackbar.showSnackbar(context, key, utils.Colors.Azul, 'El administrador se registro correctamente.');
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushNamedAndRemoveUntil(context, 'administrador/mapa', (route) => false);
        });
      } else {
        _progressDialog.hide();
        utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'La dirección de correo electrónico ya está siendo utilizada por otra cuenta.');
      }
    } catch (error) {
      _progressDialog.hide();
      utils.Snackbar.showSnackbar(context, key, utils.Colors.Rojo, 'Error $error');
    }
  }
}
