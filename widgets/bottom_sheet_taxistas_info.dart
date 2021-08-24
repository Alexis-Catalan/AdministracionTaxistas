import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;

class BottomSheetTaxistasInfo extends StatefulWidget {
  String imagenUrl;
  String nombreUsuario;
  String correo;
  String placas;
  String telefono;

  BottomSheetTaxistasInfo({
    @required this.imagenUrl,
    @required this.nombreUsuario,
    @required this.correo,
    @required this.placas,
    @required this.telefono,
  });

  @override
  _BottomSheetTaxistasInfoState createState() =>
      _BottomSheetTaxistasInfoState();
}

class _BottomSheetTaxistasInfoState extends State<BottomSheetTaxistasInfo> {
  @override
  Widget build(BuildContext context) {
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
                  backgroundImage: widget.imagenUrl != null
                      ? NetworkImage(widget.imagenUrl)
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
                        widget.nombreUsuario ?? 'Nombre taxista',
                        style: TextStyle(
                          color: utils.Colors.temaColor
                        ),
                      ),
                      Text(widget.correo ?? 'correo@dominio.com',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey
                          )
                      ),
                      Text(widget.placas ?? 'AAA-123-A',
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
                    primary: utils.Colors.temaColor, // <-- Button color
                    onPrimary: Colors.white, // <-- Splash color
                  ),
                  child: Icon(Icons.phone),
                  onPressed: () async {
                    FlutterPhoneDirectCaller.callNumber(widget.telefono);
                  },
                ),
              ) // third widget
            ]
        )
    );
  }
}
