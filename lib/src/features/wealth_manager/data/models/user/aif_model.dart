import 'package:private_deals/src/features/wealth_manager/data/models/document/document_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class AifModel {
  int id;
  int investorId;
  int status;
  String notes;
  int ppmSigned;
  int caSigned;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  String currentStatus;
  String nextStep;
  DocumentModel aadharFront;
  DocumentModel aadharBack;
  DocumentModel panCard;
  DocumentModel cheque;
  DocumentModel cml;

  bool get isRejected => status == 1;

  String get message {
    if (ppmSigned == 0 && caSigned == 0) {
      return "Please sign the PPM and CA document to complete registration process";
    } else if (caSigned == 0) {
      return "Please sign the CA document to complete registration process";
    } else if (ppmSigned == 0) {
      return "Please sign the PPM document to complete registration process";
    } else {
      return 'Please wait for admin approval';
    }
  }

  AifModel({
    this.id = 0,
    this.investorId = 0,
    this.status = 0,
    this.notes = '',
    this.ppmSigned = 0,
    this.caSigned = 0,
    this.createdBy = 0,
    this.updatedBy = 0,
    required this.createdAt,
    required this.updatedAt,
    this.currentStatus = '',
    this.nextStep = '',
    required this.aadharFront,
    required this.aadharBack,
    required this.panCard,
    required this.cheque,
    required this.cml,
  });

  factory AifModel.fromJson(Map<String, dynamic> json) => AifModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        status: Parse.toInt(json["status"]),
        notes: Parse.toStrings(json["notes"]),
        ppmSigned: Parse.toInt(json["ppm_signed"]),
        caSigned: Parse.toInt(json["ca_signed"]),
        createdBy: Parse.toInt(json["created_by"]),
        updatedBy: Parse.toInt(json["updated_by"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        currentStatus: Parse.toStrings(json["current_status"]),
        nextStep: Parse.toStrings(json["next_step"]),
        aadharFront: DocumentModel.fromJson(json["aadhar_front"] ?? {}),
        aadharBack: DocumentModel.fromJson(json["aadhar_back"] ?? {}),
        panCard: DocumentModel.fromJson(json["pan_card"] ?? {}),
        cheque: DocumentModel.fromJson(json["cheque"] ?? {}),
        cml: DocumentModel.fromJson(json["cml"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "status": status,
        "notes": notes,
        "ppm_signed": ppmSigned,
        "ca_signed": caSigned,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "current_status": currentStatus,
        "next_step": nextStep,
        "aadhar_front": aadharFront.toJson(),
        "aadhar_back": aadharBack.toJson(),
        "pan_card": panCard.toJson(),
        "cheque": cheque.toJson(),
        "cml": cml.toJson(),
      };
}
