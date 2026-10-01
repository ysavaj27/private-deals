import 'dart:convert';

import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  List<String> get splitString {
    return split('|');
  }

  DateTime get showDateTime {
    return DateFormat('dd/MM/yyyy').parse(this);
  }

  String countryFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => match.group(0) == null
            ? ""
            : String.fromCharCode((match.group(0)!.codeUnitAt(0)) + 127397));
  }

  String toCountryFlag() {
    // if (length != 2) {
    //   throw ArgumentError('Country code must be exactly 2 characters.');
    // }

    final int firstChar = codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondChar = codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }

  String get fileName {
    String fileName = split('/').last;
    String newOne = fileName.split('\\').last;
    return newOne;
  }

  String get instrumentName {
    if (app.config.enumValues.instrumentType.equity == this) {
      return capitalFirst;
    } else {
      return toUpperCase();
    }
  }

  String get naString {
    if (isNotEmpty) {
      return this;
    } else {
      return "N/A";
    }
  }

  /// Encode the string to Base64.
  String toBase64() {
    final bytes = utf8.encode(this);
    return base64.encode(bytes);
  }

  /// Decode the Base64 string.
  String fromBase64() {
    final decodedBytes = base64.decode(this);
    return utf8.decode(decodedBytes);
  }

  // String get fileTypeImage {
  //   String fileName = split('/').last.split(".").last;
  //   // logger.d("File Name :$fileName");
  //   switch (fileName) {
  //     case "xlc":
  //       return AppAssets.xlsIc;
  //     case "xlsx":
  //       return AppAssets.xlsIc;
  //     case "doc":
  //       return AppAssets.docIc;
  //     case "image":
  //       return AppAssets.imageIc;
  //     case "pdf":
  //       return AppAssets.pdfIc;
  //     default:
  //       return AppAssets.docIc;
  //   }
  // }

  bool get isExcel {
    final ext = toLowerCase();
    return ext.endsWith(".xls") || ext.endsWith(".xlsx");
  }

  bool get isCSV {
    final ext = toLowerCase();
    return ext.endsWith(".csv");
  }

  String get capitalFirst {
    if (isNotEmpty) {
      return this[0].toUpperCase() + substring(1).toLowerCase();
    } else {
      return this;
    }
  }
}
