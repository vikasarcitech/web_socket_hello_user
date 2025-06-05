// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: HomePage());
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   TextEditingController _controller = TextEditingController();
//   late WebSocketChannel _channel;
//   String response = "";

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _channel = WebSocketChannel.connect(Uri.parse("ws://10.0.2.2:3000"));
//   }
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//     _channel.sink.close();
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       _channel.sink.add(_controller.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("websocket apps")),
//       body: Column(
//         children: [
//           SizedBox(height: 10),
//           TextField(controller: _controller),
//           SizedBox(height: 10),
//           ElevatedButton(onPressed: _sendMessage, child: Text("send message")),
//           Expanded(
//             child: StreamBuilder(
//               stream: _channel.stream,
//               builder: (context, snapshot) {
//                 print(snapshot.data ?? "");
//                 return Text("Result ${snapshot.data}");
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: JoinPage());
  }
}

class JoinPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join Chat")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: roomController, decoration: InputDecoration(labelText: 'Room')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChatPage(
                    username: usernameController.text,
                    room: roomController.text,
                  ),
                ));
              },
              child: Text("Join Chat"),
            )
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String room;
  const ChatPage({required this.username, required this.room});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel _channel;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:3000'));
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

    // Send join event
    _channel.sink.add(jsonEncode({
      "type": "join",
      "username": widget.username,
      "room": widget.room
    }));

    // Listen to messages
    _channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      if (decoded['type'] == 'message') {
        setState(() {
          _messages.add(decoded);
        });
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose(); 
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final msg = {
        "type": "message",
        "text": _controller.text,
      };
      _channel.sink.add(jsonEncode(msg));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room: ${widget.room}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return ListTile(
                  title: Text("${msg['username']} • ${msg['timestamp'].substring(11, 19)}"),
                  subtitle: Text(msg['text']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "Type message"))),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';

// void main() {
//   // runApp(MyApp());
//   runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Hello")))));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GeminiLiveChat(),
//     );
//   }
// }

// class GeminiLiveChat extends StatefulWidget {
//   @override
//   _GeminiLiveChatState createState() => _GeminiLiveChatState();
// }

// class _GeminiLiveChatState extends State<GeminiLiveChat> {
//   late IOWebSocketChannel channel;
//   final TextEditingController _controller = TextEditingController();
//   final List<String> _messages = [];

//   @override
//   void initState() {
//     super.initState();

//     final uri = Uri.parse(
//       'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
//     );

//     channel = IOWebSocketChannel.connect(
//       uri,
//       headers: {
//         'Authorization': 'Bearer ', // Replace with your Gemini API key
//       },
//     );

//     // Listen for messages from Gemini
//     channel.stream.listen((message) {
//       setState(() {
//         _messages.add('Gemini: $message');
//       });
//     });

//     // Send session config
//     final sessionConfig = {
//       "session_config": {
//         "model": "models/gemini-1.5-pro", // Replace with desired model
//         "generation_config": {
//           "temperature": 0.7,
//           "top_p": 1.0,
//           "top_k": 40
//         },
//         "response_modality": "TEXT"
//       }
//     };

//     channel.sink.add(jsonEncode(sessionConfig));
//   }

//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       final userMessage = {
//         "message": {"text": _controller.text}
//       };
//       channel.sink.add(jsonEncode(userMessage));
//       setState(() {
//         _messages.add('You: ${_controller.text}');
//         _controller.clear();
//       });
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
//         appBar: AppBar(title: Text('Gemini Live Chat')),
//         body: Column(children: [
//           Expanded(
//               child: ListView.builder(
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(title: Text(_messages[index]));
//                   })),
//           Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(children: [
//                 Expanded(
//                     child: TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(hintText: 'Enter message'),
//                 )),
//                 IconButton(
//                     icon: Icon(Icons.send), onPressed: _sendMessage)
//               ]))
//         ]));
//   }
// }
