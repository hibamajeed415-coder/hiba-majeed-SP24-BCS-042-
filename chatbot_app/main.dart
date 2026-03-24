import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

ValueNotifier<bool> isDarkMode = ValueNotifier(false);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: value ? ThemeData.dark() : ThemeData.light(),
          home: StartScreen(),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// 🌸 START SCREEN WITH OPTIONS
////////////////////////////////////////////////////////////
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF1F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 80, color: Colors.pink),

            SizedBox(height: 20),

            Text("AI Chatbot",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),

            SizedBox(height: 40),

            /// ▶ START CHAT
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen()));
              },
              child: Text("Start Chat"),
            ),

            SizedBox(height: 15),

            /// ℹ ABOUT
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("About App"),
                    content: Text("This is an AI Chatbot built using Flutter and API."),
                  ),
                );
              },
              child: Text("About"),
            ),

            SizedBox(height: 15),

            /// ⚙ SETTINGS
            ElevatedButton(
              onPressed: () {
                isDarkMode.value = !isDarkMode.value;
              },
              child: Text("Toggle Theme"),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 💬 CHAT SCREEN
////////////////////////////////////////////////////////////
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isTyping = false;
  String mode = "friendly";

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({"role": "user", "text": message});
      isTyping = true;
    });

    String apiKey = "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";

    String systemPrompt =
    mode == "friendly"
        ? "You are a friendly chatbot."
        : "You are a professional assistant.";

    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://yourapp.com",
          "X-Title": "Flutter Chatbot"
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": message}
          ]
        }),
      );

      setState(() => isTyping = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply =
        data["choices"][0]["message"]["content"];

        setState(() {
          messages.add({"role": "bot", "text": reply});
        });
      } else {
        setState(() {
          messages.add({"role": "bot", "text": "API Error"});
        });
      }
    } catch (e) {
      setState(() {
        isTyping = false;
        messages.add({"role": "bot", "text": "Connection error"});
      });
    }

    controller.clear();
  }

  void showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Clear Chat"),
              onTap: () {
                setState(() => messages.clear());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Toggle Theme"),
              onTap: () {
                isDarkMode.value = !isDarkMode.value;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Switch to Friendly"),
              onTap: () {
                setState(() => mode = "friendly");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Switch to Formal"),
              onTap: () {
                setState(() => mode = "formal");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildMessage(String text, bool isUser) {
    return Align(
      alignment:
      isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.pink[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Assistant"),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: showOptions,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  bool isUser =
                      messages[index]["role"] == "user";
                  return buildMessage(
                      messages[index]["text"]!, isUser);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Typing..."),
                  );
                }
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                  InputDecoration(hintText: "Type message..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    sendMessage(controller.text);
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
