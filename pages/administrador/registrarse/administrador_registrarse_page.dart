import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radio_taxi_alfa_app/src/widgets/button_app.dart';
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:radio_taxi_alfa_app/src/pages/administrador/registrarse/administrador_registrase_controlador.dart';

class AdministradorRegistrarsePage extends StatefulWidget {
  @override
  _AdministradorRegistrarsePageState createState() => _AdministradorRegistrarsePageState();
}

class _AdministradorRegistrarsePageState extends State<AdministradorRegistrarsePage> {
  AdministradorRegistrarseControlador _con = new AdministradorRegistrarseControlador();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.key,
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 0,
          centerTitle: true,
          title: Text('Registro Administrador'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _appEncabezado(),
              _txtRegistro(),
              _edtCampoNombreUsuario(),
              _edtCampoCorreo(),
              _edtCampoTelefono(),
              _edtCampoPassword(),
              _edtCampoCofirmarPassword(),
              _btnRegistrase()
            ],
          ),
        ));
  }

  Widget _appEncabezado() {
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
          color: utils.Colors.temaColor,
          height: MediaQuery.of(context).size.height * 0.22,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'assets/img/logo_app.png',
                    width: 150,
                    height: 115,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text('UN SERVICIO',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text('RÁPIDO, SEGURO',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('CONFIABLE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                ],
              )
            ],
          )
      )
    );
  }

  Widget _txtRegistro() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(
        'Registro',
        style: TextStyle(
            color: utils.Colors.degradadoColor, fontWeight: FontWeight.bold, fontSize: 25),
      ),
    );
  }

  Widget _edtCampoNombreUsuario() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.nombreUsuarioControlador,
        cursorColor: utils.Colors.temaColor,
        decoration: InputDecoration(
            hintText: 'Nombre(s) Apellidos',
            labelText: 'Nombre de usuario:',
            suffixIcon: Icon(
              Icons.person,
              color: utils.Colors.temaColor,
            )),
      ),
    );
  }

  Widget _edtCampoCorreo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.correoControlador,
        cursorColor: utils.Colors.temaColor,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'correo@dominio.com',
            labelText: 'Correo electrónico:',
            suffixIcon: Icon(
              Icons.email,
              color: utils.Colors.temaColor,
            )),
      ),
    );
  }

  Widget _edtCampoTelefono() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.telefonoControlador,
        cursorColor: utils.Colors.temaColor,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        decoration: InputDecoration(
            hintText: 'Teléfono',
            labelText: 'Número de teléfono:',
            suffixIcon: Icon(
              Icons.phone,
              color: utils.Colors.temaColor,
            )),
      ),
    );
  }

  Widget _edtCampoPassword() {
    return Container(
      margin: EdgeInsets.only(left: 30,right: 30,bottom: 10),
      child: TextField(
        controller: _con.passwordControlador,
        cursorColor: utils.Colors.temaColor,
        obscureText: _con.isPassword,
        decoration: InputDecoration(
            labelText: 'Contraseña:',
            suffixIcon: IconButton(
              icon: _con.isPassword? Icon(Icons.visibility_off) : Icon(Icons.visibility),
              color: utils.Colors.temaColor,
              onPressed: _con.Ocultar,
            )),
      ),
    );
  }

  Widget _edtCampoCofirmarPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: TextField(
        controller: _con.confirmarPasswordControlador,
        cursorColor: utils.Colors.temaColor,
        obscureText: _con.isPasswordConfirm,
        decoration: InputDecoration(
            labelText: 'Confirmar contraseña:',
            suffixIcon: IconButton(
              icon: _con.isPasswordConfirm? Icon(Icons.visibility_off) : Icon(Icons.visibility),
              color: utils.Colors.temaColor,
              onPressed: _con.OcultarConfirmar,
            )),
      ),
    );
  }

  Widget _btnRegistrase() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        child: ButtonApp(
          onPressed: _con.Registrarse,
          text: 'Registrarse ahora',
          icon: Icons.person_add_alt_1_outlined,
        ));
  }

  void refresh() {
    setState(() {});
  }
}
