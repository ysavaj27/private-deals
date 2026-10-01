import 'package:private_deals/src/shared/functions/parse.dart';

class StartupOtherOneModel {
  int id;

  // int startupId;
  // int roundId;
  int numberOfFounders;
  String nameOfFounder;
  int age;
  String educationQualification;

  // String startupFailuresSuccessfulExits;
  String highlights;
  String idea;
  String keyInformation;
  String financialModel;

  // String founderEmailId;
  // int founderContactNumber;
  String ssaId;
  String ssaSignCoordinates;
  int offerId;
  String offerSignCoordinates;
  String equityOffered;
  double floor;
  double cap;

  // DateTime createdAt;
  // DateTime updatedAt;
  String workExp;
  String pitchdeck;

  StartupOtherOneModel({
    this.id = 0,
    // this.startupId = 0,
    // this.roundId = 0,
    this.numberOfFounders = 0,
    this.nameOfFounder = '',
    this.age = 0,
    this.educationQualification = '',
    // this.startupFailuresSuccessfulExits = '',
    this.highlights = '',
    this.idea = '',
    this.keyInformation = '',
    this.financialModel = '',
    // this.founderEmailId = '',
    // this.founderContactNumber = 0,
    this.ssaId = '',
    this.ssaSignCoordinates = '',
    this.offerId = 0,
    this.offerSignCoordinates = '',
    this.equityOffered = "",
    this.floor = 0,
    this.cap = 0,
    // required this.createdAt,
    // required this.updatedAt,
    this.workExp = '',
    this.pitchdeck = '',
  });

  factory StartupOtherOneModel.fromJson(Map<String, dynamic> json) =>
      StartupOtherOneModel(
        id: Parse.toInt(json["id"]),
        numberOfFounders: Parse.toInt(json["number_of_founders"]),
        nameOfFounder: Parse.toStrings(json["name_of_founder"]),
        age: Parse.toInt(json["age"]),
        educationQualification:
            Parse.toStrings(json["education_qualification"]),
        highlights: Parse.toStrings(json["highlights"]),
        idea: Parse.toStrings(json["idea"]),
        keyInformation: Parse.toStrings(json["key_information"]),
        financialModel: Parse.toStrings(json["financial_model"]),
        ssaId: Parse.toStrings(json["ssa_id"]),
        ssaSignCoordinates: Parse.toStrings(json["ssa_sign_coordinates"]),
        offerId: Parse.toInt(json["offer_id"]),
        offerSignCoordinates: Parse.toStrings(json["offer_sign_coordinates"]),
        equityOffered: Parse.toStrings(json["equity_offered"]),
        floor: Parse.toDouble(json["floor"]),
        cap: Parse.toDouble(json["cap"]),
        workExp: Parse.toStrings(json["work_exp"]),
        pitchdeck: Parse.parseUrl(json["pitchdeck"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        // "startup_id": startupId,
        // "round_id": roundId,
        "number_of_founders": numberOfFounders,
        "name_of_founder": nameOfFounder,
        "age": age,
        "education_qualification": educationQualification,
        // "startup_failures_successful_exits": startupFailuresSuccessfulExits,
        "highlights": highlights,
        "idea": idea,
        "key_information": keyInformation,
        "financial_model": financialModel,
        // "founder_email_id": founderEmailId,
        // "founder_contact_number": founderContactNumber,
        "ssa_id": ssaId,
        "ssa_sign_coordinates": ssaSignCoordinates,
        "offer_id": offerId,
        "offer_sign_coordinates": offerSignCoordinates,
        "equity_offered": equityOffered,
        "floor": floor,
        "cap": cap,
        // "created_at": createdAt.toIso8601String(),
        // "updated_at": updatedAt.toIso8601String(),
        "work_exp": workExp,
        "pitchdeck": pitchdeck.isNotEmpty ? pitchdeck : '',
      };
}
