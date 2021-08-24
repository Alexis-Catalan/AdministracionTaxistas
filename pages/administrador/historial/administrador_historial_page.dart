import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radio_taxi_alfa_app/src/pages/administrador/historial/administrador_historial_controlador.dart';
import 'package:radio_taxi_alfa_app/src/utils/colors.dart' as utils;
import 'package:radio_taxi_alfa_app/src/models/historial_viaje.dart';
import 'package:radio_taxi_alfa_app/src/utils/relative_time_util.dart';

class AdministradorHistorialPage extends StatefulWidget {
  @override
  _AdministradorHistorialPageState createState() => _AdministradorHistorialPageState();
}

class _AdministradorHistorialPageState extends State<AdministradorHistorialPage> {

  AdministradorHistorialControlador _con = new AdministradorHistorialControlador();

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
        title: Text('Historial de viajes'),
      ),
      body: FutureBuilder(
        future: _con.obtenerHistorial(),
        builder: (context, AsyncSnapshot<List<HistorialViaje>> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (_, index) {
              return _cardHistorialInfo(
                snapshot.data[index].origen,
                snapshot.data[index].destino,
                RelativeTimeUtil.getRelativeTime(snapshot.data[index].timestamp ?? 0),
                snapshot.data[index].id,
              );
            }
          );
        },
      )
    );
  }

  Widget _cardHistorialInfo(
    String origen,
    String destino,
    String timestamp,
    String idHistorialViaje,
  ) {
    return GestureDetector(
      onTap: () {
        _con.abrirHistorialDetalle(idHistorialViaje);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(
              color: utils.Colors.temaColor,
              width: 1,
            )
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5),
                Icon(Icons.my_location,color: utils.Colors.origen,),
                SizedBox(width: 5),
                Text(
                    'Origen: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    origen ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 5),
                Icon(Icons.location_on,color: utils.Colors.destino,),
                SizedBox(width: 5),
                Text(
                  'Destino: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    destino ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 5),
                Icon(Icons.event,color: utils.Colors.fecha,),
                SizedBox(width: 5),
                Text(
                  'Fecha: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    timestamp ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    setState(() {
    });
  }
}
