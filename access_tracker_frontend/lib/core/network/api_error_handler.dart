import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "The server took too long to respond.";
        case DioExceptionType.connectionError:
          return "Please check your internet connection.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 401:
              return "Invalid email or password.";
            case 403:
              return "Your account is not authorized.";
            case 404:
              return "Server endpoint not found.";
            case 409:
              return "The email is already registered.";
            case 422:
              final data = error.response?.data;
              if (data is Map && data.containsKey('detail')) {
                return data['detail'].toString();
              }
              return "Invalid request data.";
            case 500:
              return "Something went wrong on the server.";
            default:
              return "An unexpected error occurred.";
          }
        default:
          return "An unexpected error occurred.";
      }
    }
    return "An unexpected error occurred.";
  }
}
