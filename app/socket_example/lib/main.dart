// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(title: 'WebSocket Demo', home: WebSocketPage());
//   }
// }

// class WebSocketPage extends StatefulWidget {
//   @override
//   _WebSocketPageState createState() => _WebSocketPageState();
// }

// class _WebSocketPageState extends State<WebSocketPage> {
//   final TextEditingController _controller = TextEditingController();
//   late WebSocketChannel channel;
//   String response = '';

//   @override
//   void initState() {
//     super.initState();
//     // channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
//     channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:3000'));
//     channel.stream.listen((message) {
//       setState(() {
//         response = message;
//       });
//     });
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       channel.sink.add(_controller.text);
//     }
//   }

//   @override
//   void dispose() {
//     channel.sink.close();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('WebSocket Demo')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             TextField(controller: _controller, decoration: InputDecoration(labelText: 'Enter your name')),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _sendMessage, child: Text('Send')),
//             SizedBox(height: 20),
//             Text('Server says: $response'),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controller = TextEditingController();
  late WebSocketChannel _channel;
  String response = "";

  @override
  void initState() {
    // TODO: implement initState
    _channel = WebSocketChannel.connect(Uri.parse("ws://10.0.2.2:3000"));
    _channel.stream.listen((message) {
      setState(() {
        response = message;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 20,),
            TextField(controller: controller,),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: _sendMessage, child: Text("send")),
            Text(response)
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if(controller.text.isNotEmpty) {
      _channel.sink.add(controller.text);
    }
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    _channel.sink.close();
    controller.dispose();
    super.dispose();
  }
}