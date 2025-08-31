class Cliente {
  final String mIdx;
  final String mName;
  final String mAlias;
  final String mTelefono;
  final String mEmail;
  final String mDireccion;
  final String mCreatedAt;
  final String mUpdatedAt;

  Cliente({
    required this.mIdx,
    required this.mName,
    required this.mAlias,
    required this.mTelefono,
    required this.mEmail,
    required this.mDireccion,
    required this.mCreatedAt,
    required this.mUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mIdx': mIdx,
      'mName': mName,
      'mAlias': mAlias,
      'mTelefono': mTelefono,
      'mEmail': mEmail,
      'mDireccion': mDireccion,
      'mCreatedAt': mCreatedAt,
      'mUpdatedAt': mUpdatedAt,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      mIdx: map['mIdx'] as String,
      mName: map['mName'] as String,
      mAlias: map['mAlias'] as String,
      mTelefono: map['mTelefono'] as String,
      mEmail: map['mEmail'] as String,
      mDireccion: map['mDireccion'] as String,
      mCreatedAt: map['mCreatedAt'] as String,
      mUpdatedAt: map['mUpdatedAt'] as String,
    );
  }

  Cliente copyWith({
    String? mIdx,
    String? mName,
    String? mAlias,
    String? mTelefono,
    String? mEmail,
    String? mDireccion,
    String? mCreatedAt,
    String? mUpdatedAt,
  }) {
    return Cliente(
      mIdx: mIdx ?? this.mIdx,
      mName: mName ?? this.mName,
      mAlias: mAlias ?? this.mAlias,
      mTelefono: mTelefono ?? this.mTelefono,
      mEmail: mEmail ?? this.mEmail,
      mDireccion: mDireccion ?? this.mDireccion,
      mCreatedAt: mCreatedAt ?? this.mCreatedAt,
      mUpdatedAt: mUpdatedAt ?? this.mUpdatedAt,
    );
  }
}

// import 'package:intl/intl.dart';

// class Cliente {
//   final int? mIdx; // Identificador único, opcional para nuevos clientes
//   final String mName;
//   final String mAlias;
//   final String mTelefono;
//   final String mEmail;
//   final String mDireccion;
//   final String mCreatedAt;
//   final String mUpdatedAt;

//   Cliente({
//     this.mIdx,
//     required this.mName,
//     required this.mAlias,
//     required this.mTelefono,
//     required this.mEmail,
//     required this.mDireccion,
//     String? mCreatedAt,
//     String? mUpdatedAt,
//   }) : mCreatedAt =
//            mCreatedAt ??
//            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
//        mUpdatedAt =
//            mUpdatedAt ??
//            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

//   // Convierte un Map (fila de la base de datos) en un objeto Cliente
//   factory Cliente.fromMap(Map<String, dynamic> map) {
//     return Cliente(
//       mIdx: map['mIdx'] as int,
//       mName: map['mName'] as String,
//       mAlias: map['mAlias'] as String,
//       mTelefono: map['mTelefono'] as String,
//       mEmail: map['mEmail'] as String,
//       mDireccion: map['mDireccion'] as String,
//       mCreatedAt: map['mCreatedAt'] as String,
//       mUpdatedAt: map['mUpdatedAt'] as String,
//     );
//   }

//   // Convierte un objeto Cliente en un Map para insertarlo en la base de datos
//   Map<String, dynamic> toMap() {
//     return {
//       'mIdx': mIdx,
//       'mName': mName,
//       'mAlias': mAlias,
//       'mTelefono': mTelefono,
//       'mEmail': mEmail,
//       'mDireccion': mDireccion,
//       'mCreatedAt': mCreatedAt,
//       'mUpdatedAt': mUpdatedAt,
//     };
//   }

//   // Crea una copia del objeto, útil para actualizaciones
//   Cliente copyWith({
//     int? mIdx,
//     String? mName,
//     String? mAlias,
//     String? mTelefono,
//     String? mEmail,
//     String? mDireccion,
//     String? mCreatedAt,
//     String? mUpdatedAt,
//   }) {
//     return Cliente(
//       mIdx: mIdx ?? this.mIdx,
//       mName: mName ?? this.mName,
//       mAlias: mAlias ?? this.mAlias,
//       mTelefono: mTelefono ?? this.mTelefono,
//       mEmail: mEmail ?? this.mEmail,
//       mDireccion: mDireccion ?? this.mDireccion,
//       mCreatedAt: mCreatedAt ?? this.mCreatedAt,
//       mUpdatedAt: mUpdatedAt ?? this.mUpdatedAt,
//     );
//   }
// }

// // import 'dart:convert';

// // class Clientes {
// //   List<Cliente> items = [];

// //   Clientes();

// //   // Clientes.fromJsonList(List<dynamic>? jsonList) {
// //   //   if (jsonList == null) {
// //   //     return;
// //   //   } else {
// //   //     for (var item in jsonList) {
// //   //       final mCountry = Cliente.fromJsonMap(item);
// //   //       items.add(mCountry);
// //   //     }
// //   //   }
// //   // }

// //   String toArrayJson() {
// //     String jsonArray = '';
// //     for (var i = 0; i < items.length; i++) {
// //       jsonArray += items[i].toJson();

// //       if ((i + 1) < items.length) {
// //         jsonArray += ", ";
// //       }
// //     }

// //     return jsonArray = '[$jsonArray]';
// //   }
// // }

// // class Cliente {
// //   String mIdx;
// //   String mName;
// //   String mAlias;
// //   String mTelefono;
// //   String mEmail;
// //   String mDireccion;
// //   DateTime mCreatedAt;
// //   DateTime mUpdatedAt;

// //   Cliente({
// //     mIdx,
// //     mName,
// //     mAlias,
// //     mTelefono,
// //     mEmail,
// //     mDireccion,
// //     mCreatedAt,
// //     mUpdatedAt,
// //   });

// //   // Cliente.fromJsonMap(Map<String, dynamic> json) {
// //   //   mIdx = json['idx'];
// //   //   mName = json['name'];
// //   //   mAlias = json['alias'];
// //   //   mTelefono = json['telefono'];
// //   //   mEmail = json['email'];
// //   //   mDireccion = json['direccion'];
// //   //   mCreatedAt =
// //   //       json['created_at'] == null ? null : DateTime.parse(json['created_at']);
// //   //   mUpdatedAt =
// //   //       json['updated_at'] == null ? null : DateTime.parse(json['updated_at']);
// //   // }

// //   String toJson() {
// //     return jsonEncode(_toJsonMap());
// //   }

// //   Map<String, dynamic> _toJsonMap() => {
// //     'idx': mIdx,
// //     'name': mName,
// //     'alias': mAlias,
// //     'telefono': mTelefono,
// //     'email': mEmail,
// //     'direccion': mDireccion,
// //     'created_at': mCreatedAt,
// //     'updated_at': mUpdatedAt,
// //   };

// //   // Convierte un Map (fila de la base de datos) en un objeto Cliente
// //   factory Cliente.fromMap(Map<String, dynamic> map) {
// //     return Cliente(
// //       mIdx: map['mIdx'] as int,
// //       mName: map['mName'] as String,
// //       mAlias: map['mAlias'] as String,
// //       mTelefono: map['mTelefono'] as String,
// //       mEmail: map['mEmail'] as String,
// //       mDireccion: map['mDireccion'] as String,
// //       mCreatedAt: map['mCreatedAt'] as String,
// //       mUpdatedAt: map['mUpdatedAt'] as String,
// //     );
// //   }

// //   // Convierte un objeto Cliente en un Map para insertarlo en la base de datos
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'mIdx': mIdx,
// //       'mName': mName,
// //       'mAlias': mAlias,
// //       'mTelefono': mTelefono,
// //       'mEmail': mEmail,
// //       'mDireccion': mDireccion,
// //       'mCreatedAt': mCreatedAt,
// //       'mUpdatedAt': mUpdatedAt,
// //     };
// //   }
// // }
