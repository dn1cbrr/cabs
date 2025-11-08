class Prediction {
  final String? description;
  final String? placeId;
  final String? reference;
  final List<dynamic>? types;
  final List<dynamic>? terms;
  final Map<String, dynamic>? structuredFormatting;

  Prediction({
    this.description,
    this.placeId,
    this.reference,
    this.types,
    this.terms,
    this.structuredFormatting,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
      reference: json['reference'],
      types: json['types'],
      terms: json['terms'],
      structuredFormatting: json['structured_formatting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'place_id': placeId,
      'reference': reference,
      'types': types,
      'terms': terms,
      'structured_formatting': structuredFormatting,
    };
  }
}
