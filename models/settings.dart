import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

//global func
XSettings settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return XSettings.jsonMapConvrtToSettingsObj(jsonData);
}

String settingsObjectToJsonString(XSettings data) {
  final dyn = data.convertToJsonMap();
  //print("settingsToJson data.settingsId: ${data.settingsId}");
  print("settingsToJson data.settingsId: ");
  return json.encode(dyn);
}

class XSettings {
  String settingsId;

 
  XSettings({  //cunstructur
    this.settingsId,
  });

  factory XSettings.jsonMapConvrtToSettingsObj(Map<String, dynamic> json) => new XSettings(
        settingsId: json["settingsId"],
      );

  Map<String, dynamic> convertToJsonMap() => {
        "settingsId": settingsId,
      };

    factory XSettings.docConvertToSettingClassObj(DocumentSnapshot doc) { 
      return XSettings.jsonMapConvrtToSettingsObj(doc.data);
    }
}
