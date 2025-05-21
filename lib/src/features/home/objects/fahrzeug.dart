import 'dart:io';

import 'package:objectbox/objectbox.dart';

import 'geodata.dart';

@Entity()
class Fahrzeug {
  @Id()
  int id = 0;

  final String? objektName;
  final String? caption;
  final String? name;
  final String? gpsTimeString;
  final String? versicherungsnummer;
  final String? telefonUnfall;
  final String? telefonPanne;
  final String? versicherung;
  final String? typ;
  final String? typNummer;

  final int? gpsTime;
  final int? course;
  final int? satInView;
  final int? overspeed;
  final int? fahrzeugId;
  final int? faultCodes;


  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? speedKnots;
  final double? rpm;
  final double? fuelLevel;
  final double? fuelRate;
  final double? externalPower;
  final double? mileage;
  final double? altitude;
  final double? coolantTemperature;
  final double? gasPedal;
  final double? motorLast;
  final double? xAcceleration;
  final double? zAcceleration;

  final bool? ignition;
  final dynamic schein;

  /// Pfad zum Bild statt `File` (File wird nicht unterstützt)
  String? imagePath;


  Fahrzeug({
    this.objektName,
    this.caption,
    this.name,
    this.gpsTimeString,
    this.versicherungsnummer,
    this.telefonUnfall,
    this.telefonPanne,
    this.versicherung,
    this.typ,
    this.typNummer,
    this.gpsTime,
    this.latitude,
    this.longitude,
    this.speed,
    this.speedKnots,
    this.course,
    this.rpm,
    this.fuelLevel,
    this.fuelRate,
    this.externalPower,
    this.mileage,
    this.altitude,
    this.coolantTemperature,
    this.gasPedal,
    this.motorLast,
    this.xAcceleration,
    this.zAcceleration,
    this.overspeed,
    this.satInView,
    this.fahrzeugId,
    this.ignition,
    this.faultCodes,
    this.schein,
  });

  factory Fahrzeug.fromJson(Map<String, dynamic> json) {
    T? parse<T>(dynamic value) {
      if (value == null || value == "null") return null;
      if (T == double) return (value as num).toDouble() as T;
      if (T == int) return (value as num).toInt() as T;
      if (T == bool) return (value == true || value == "true") as T;
      return value as T;
    }

    return Fahrzeug(
      objektName: parse<String>(json['OBJECTNAME']),
      caption: parse<String>(json['CAPTION']),
      name: parse<String>(json['NAME']),
      gpsTimeString: parse<String>(json['GPSTIME_STRING']),
      versicherungsnummer: parse<String>(json['Versicherungsnummer']),
      telefonUnfall: parse<String>(json['TelefonUnfall']),
      telefonPanne: parse<String>(json['TelefonPanne']),
      versicherung: parse<String>(json['Versicherung']),
      typ: parse<String>(json['TYP']),

      typNummer: parse<String>(json['TYP_NUMMER']),
      gpsTime: parse<int>(json['GPSTIME']),
      latitude: parse<double>(json['LATITUDE']),
      longitude: parse<double>(json['LONGITUDE']),
      speed: parse<double>(json['SPEED']),
      speedKnots: parse<double>(json['SPEED_KNOTS']),
      course: parse<int>(json['COURSE']),
      rpm: parse<double>(json['RPM']),
      fuelLevel: parse<double>(json['FUEL_LEVEL']),
      fuelRate: parse<double>(json['FUEL_RATE']),
      externalPower: parse<double>(json['EXTERNAL_POWER']),
      mileage: parse<double>(json['TOTAL_MILEAGE']),
      altitude: parse<double>(json['ALTITUDE']),
      coolantTemperature: parse<double>(json['COOLANT_TEMPERATURE']),
      gasPedal: parse<double>(json['GAS_PEDAL']),
      motorLast: parse<double>(json['MOTOR_LAST']),
      xAcceleration: parse<double>(json['X_ACCELERATION']),
      zAcceleration: parse<double>(json['Z_ACCELERATION']),
      overspeed: parse<int>(json['OVERSPEED']),
      satInView: parse<int>(json['SAT_IN_VIEW']),
      fahrzeugId: parse<int>(json['ID']),
      ignition: parse<bool>(json['IGNITION']),
      faultCodes: parse<int>(json['FAULT_CODES']),
      schein: json['SCHEIN'], // bleibt dynamisch
    );
  }

}