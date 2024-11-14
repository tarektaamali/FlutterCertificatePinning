import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart'; // Import the ApiService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dio
  await ApiService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dio Proxy & Certificate Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dio Proxy & Certificate Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _apiResponse = "Press the button to fetch data";

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
      _apiResponse = 'Fetching data...';
    });

    try {
      // Use the global Dio instance
      Response response = await ApiService.instance.dio.get('/posts/$_counter');
      setState(() {
        _apiResponse = 'Response data: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error making API call: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Added const for optimization
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pressed the button $_counter times:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10), // Added const for optimization
              Text(
                '$_apiResponse',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Fetch Data',
        child: const Icon(Icons.add),
      ),
    );
  }
}
