import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:radio_taxi_alfa_app/src/pages/administrador/historial_detalle/administrador_historial_detalle_controlador.dart';
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;
import 'package:radio_taxi_alfa_app/src/widgets/button_app.dart';

class AdministradorHistorialDetallePage extends StatefulWidget {
  @override
  _AdministradorHistorialDetallePageState createState() => _AdministradorHistorialDetallePageState();
}

class _AdministradorHistorialDetallePageState extends State<AdministradorHistorialDetallePage> {

  AdministradorHistorialDetalleControlador _con = new AdministradorHistorialDetalleControlador();

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
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        centerTitle: true,
        title: Text('Detalle del historial'),
      ),
      body: SingleChildScrollView(
        child: Column(
         children: [
           SizedBox(height: 5),
           _listaInfo('Origen: ', _con.historialViaje?.origen, Icons.my_location, utils.Colors.origen),
           _listaInfo('Destino: ', _con.historialViaje?.destino, Icons.location_on, utils.Colors.destino),
           _infoViaje(),
           _listaInfoCalificacion('Calificación al cliente:', _con.historialViaje?.calificacionCliente ?? 0, Icons.stars, Colors.amber),
           _listaInfoUserInfo(_con.cliente?.imagen, _con.cliente?.nombreUsuario, _con.cliente?.correo, '', _con.cliente?.telefono, Colors.amber),
           _listaInfoCalificacion('Calificación al taxista:', _con.historialViaje?.calificacionTaxista ?? 0, Icons.stars, utils.Colors.taxi),
           _listaInfoUserInfo(_con.taxista?.imagen, _con.taxista?.nombreUsuario, _con.taxista?.correo, _con.taxista?.placas, _con.taxista?.telefono,utils.Colors.taxi),
           _listaInfo('Fecha de finalización del viaje: ', _con.fecha ?? 'Fecha Viaje', Icons.event, utils.Colors.fecha),
         ],
        ),
      ),
    );
  }


  Widget _listaInfo(String titulo, String info, IconData icono, Color iconColor) {
    return ListTile(
      title: Text(
          titulo,
        style: TextStyle(
        fontWeight: FontWeight.bold,)
      ),
      subtitle: Text(info ?? 'Dirección'),
      leading: Icon(icono,color: iconColor,),
    );
  }

  Widget _infoViaje(){
    return Container(
        height: 40,
        margin: EdgeInsets.only(left: 70,right: 30, bottom: 15),
        child: ButtonApp(
          onPressed: _con.Informacion,
          text: 'Ver Ruta',
          icon: Icons.alt_route,
        )
    );
  }

  Widget _listaInfoUserInfo(String imagen, String nombre,String correo, String info, String telefono, Color color) {
    return Container(
          height: 100,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    backgroundImage:  imagen != null
                        ? NetworkImage(imagen)
                        : AssetImage('assets/img/profile.jpg'),
                  ),
                ), // first widget
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nombre ?? 'Nombre Cliente',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(correo ?? 'correo@dominio.com',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey
                            )
                        ),
                        Text(info ?? 'Placas',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey
                            )
                        )
                      ],
                    ),
                  ),
                ), // second widget
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      primary: color, // <-- Button color
                      onPrimary: Colors.white, // <-- Splash color
                    ),
                    child: Icon(Icons.phone),
                    onPressed: () async {
                      FlutterPhoneDirectCaller.callNumber(telefono);
                    },
                  ),
                ) // third widget
              ]
          )
    );
  }

  Widget _listaInfoCalificacion(String titulo, double info, IconData icono, Color iconColor) {
    return ListTile(
      title: Text(
          titulo ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,),
      ),
      subtitle: Container(
        child: Row(
          children: [
            Text('$info',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,)),
            RatingBar.builder(
              initialRating: info ?? 0,
              itemCount: 5,
              allowHalfRating: true,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.5),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
      leading: Icon(icono, color: iconColor),
    );
  }

  void refresh() {
    setState(() {

    });
  }
}
