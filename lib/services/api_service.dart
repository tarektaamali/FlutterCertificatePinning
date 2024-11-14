import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/adapter.dart';

class ApiService {
  // Private constructor
  ApiService._privateConstructor();

  // The single instance of ApiService
  static final ApiService instance = ApiService._privateConstructor();

  // Dio instance
  late final Dio dio;

  // Initialize Dio with configurations
  Future<void> initialize() async {
    try {
      // Load the CA certificate from assets
      final sslCert = await rootBundle.load('assets/certificates/jmeter_cert.crt');

      // Create a SecurityContext and set the trusted certificates
      SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
      securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

      // Create a custom HttpClient that uses the SecurityContext
      HttpClient httpClient = HttpClient(context: securityContext);

      // Set connection timeout
      httpClient.connectionTimeout = const Duration(seconds: 10);

      // Configure the proxy
      httpClient.findProxy = (Uri uri) {
        return "PROXY  10.1.15.221:8080;";
      };

      // Create Dio instance
      dio = Dio();

      // Configure Dio's HttpClientAdapter
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        return httpClient;
      };

      // Optionally, set a base URL
      dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';

      // Optionally, add interceptors for logging
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

      // You can add more configurations here (e.g., interceptors, headers)
    } catch (e) {
      throw Exception('Failed to initialize Dio: $e');
    }
  }
}
