// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;

// /// True when the failure looks like "no connection" rather than a real bug.
// /// Each HTTP client wraps the socket error differently, so we check all
// /// the ones the app uses: Supabase -> http.ClientException,
// /// Dio -> DioException, raw dart:io -> SocketException.
// bool isNetworkError(Object error) {
//   return error is SocketException ||
//       error is http.ClientException ||
//       (error is DioException &&
//           (error.type == DioExceptionType.connectionError ||
//               error.type == DioExceptionType.connectionTimeout));
// }