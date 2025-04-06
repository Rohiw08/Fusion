class WidgetModel {
  final int? height;
  final int? width;
  final String? backgroundImage;
  final String? name;
  final String? logo;

  WidgetModel({
    this.height,
    this.width,
    this.backgroundImage,
    this.name,
    this.logo,
  });

  // Factory method to create a WidgetModel from a JSON (Map<String, dynamic>)
  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    return WidgetModel(
      height: json['height'] as int?,
      width: json['width'] as int?,
      backgroundImage:
          json['backgroung Image'] as String?, // Note the typo in the schema
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );
  }

  // Method to convert a WidgetModel to a JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'width': width,
      'backgroung Image':
          backgroundImage, // Keeping the typo for consistency with the schema
      'name': name,
      'logo': logo,
    };
  }
}
