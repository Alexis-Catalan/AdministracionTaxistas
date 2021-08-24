import 'dart:convert';

Administrador AdministradorFromJson(String str) => Administrador.fromJson(json.decode(str));

String administradorToJson(Administrador data) => json.encode(data.toJson());

class Administrador {
  String id;
  String nombreUsuario;
  String correo;
  String telefono;
  String token;
  String imagen;

  Administrador({this.id, this.nombreUsuario, this.correo, this.telefono, this.token, this.imagen});

  factory Administrador.fromJson(Map<String, dynamic> json) => Administrador(
      id: json["id"],
      nombreUsuario: json["nombreUsuario"],
      correo: json["correo"],
      telefono: json["telefono"],
      token: json["token"],
      imagen: json["imagen"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombreUsuario": nombreUsuario,
    "correo": correo,
    "telefono": telefono,
    "token": token,
    "imagen": imagen
  };
}
