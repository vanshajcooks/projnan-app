class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value)? toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null && toJsonT != null)
        'data': toJsonT(data as T)
      else if (data != null)
        'data': data,
    };
  }
}
