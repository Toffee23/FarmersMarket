class Response {
  final String? message;
  final String? statusMessage;
  final ResponseStatus status;
  final dynamic data;

  Response({
    this.message,
    this.statusMessage,
    required this.status,
    this.data,
  });

  factory Response.fromJson(Map<String, dynamic> data) {
    return Response(
      message: data['message'],
      statusMessage: data['status'],
      status: ResponseStatus.pending,
      data: data['data'],
    );
  }

  Response copyWith({
    String? message,
    String? statusMessage,
    ResponseStatus? status,
    dynamic data,
  }) {
    return Response(
      message: message ?? this.message,
      statusMessage: statusMessage ?? this.statusMessage,
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }
}

enum ResponseStatus {
  pending,
  success,
  failed,
  connectionError,
  unknownError,
}
