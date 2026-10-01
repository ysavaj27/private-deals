/// BASE MODEL
class BaseModel<T> {
  int s;
  String m;
  T? r;

  BaseModel({this.s = 0, this.m = "", this.r});

  bool get isSuccess => s == 1;

  // factory BaseModel.fromJson(Map<String, dynamic> json, createModel(data)) =>
  //     BaseModel<T>(
  //       s: json["s"] ?? 0,
  //       m: json["m"] ?? "",
  //       r: createModel(json["r"]),
  //     );

  factory BaseModel.fromJson(
          Map<String, dynamic> json, Function(Map<String, dynamic>) data) =>
      BaseModel<T>(
        s: json["status"] ?? 0,
        m: json["message"] ?? "",
        r: json["status"] == 1 && json["data"] is Map<String, dynamic> ? data(json["data"]) : null,
      );

  factory BaseModel.fromInt(Map<String, dynamic> json, Function(int) data) =>
      BaseModel<T>(
        s: json["status"] ?? 0,
        m: json["message"] ?? "",
        r: json["data"] != null ? data(int.tryParse(json["data"]) ?? 0) : null,
      );

  factory BaseModel.fromListJson(
          Map<String, dynamic> json, Function(List<dynamic>) create) =>
      BaseModel<T>(
        s: json["status"] ?? 0,
        m: json["message"] ?? "",
        r: json["status"] == 1
            ? json["data"] != null
                ? create(json["data"])
                : null
            : null,
      );

  factory BaseModel.fromEmpty() => BaseModel<T>(
        r: null,
        m: "",
        s: 0,
      );

  factory BaseModel.fromMessage(Map<String, dynamic> json) => BaseModel<T>(
        s: json["status"] ?? 0,
        m: json["message"] ?? "",
      );

  factory BaseModel.fromError(String err) => BaseModel<T>(
        s: 0,
        m: err,
        r: null,
      );

  Map<String, dynamic> toJson() => {
        "status": s,
        "message": m,
        "data": r,
      };
}
