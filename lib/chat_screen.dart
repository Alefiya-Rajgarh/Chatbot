import 'dart:convert';
import 'dart:io';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:flutter/material.dart';
import 'package:chatbot/message.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:intl/intl.dart';
import 'package:chatbot/key.env';

// ChatScreen widget to display a chatbot interface
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controllers for text input and scrolling
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  // List to store chat messages
  List<Message> msgs = [];

  // Tracks if the bot is typing
  bool isTyping = false;
  final ImagePicker picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        // Add image message to the list
        msgs.insert(
          0,
          Message(true, "describe it", DateTime.now(), imageFile: File(pickedFile.path)),
        );
        // Optionally, you could immediately send a placeholder or upload the image
        // For now, we just display it locally.
      });
      scrollController.animateTo(
        0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to send a message and get a response from OpenAI API
  void sendMsg({File? imageFile}) async {
    String text = controller.text;
    String apiKey = My_API_KEY;
    controller.clear();

    if (text.isNotEmpty) {
      // Add user message to the list and show typing indicator
      setState(() {
        msgs.insert(0, Message(true, text, DateTime.now()));
        isTyping = true;
      });
    } else if (imageFile != null) {
    } else {
      return;
    }
    // Scroll to the top of the chat
    scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
    if (text.isNotEmpty) {
      try {
        // Send the message to OpenAI API
        var response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": "gpt-4o-mini",
            "messages": [
              {"role": "user", "content": text},
            ],
          }),
        );

        print(response.body);

        // Handle API response
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          setState(() {
            isTyping = false;
            msgs.insert(
              0,
              Message(
                false,
                json["choices"][0]["message"]["content"].toString().trimLeft(),
                DateTime.now(),
              ),
            );
          });

          // Scroll to the top of the chat
          scrollController.animateTo(
            0.0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
          );
        } else {
          print("API Error: ${response.statusCode} ${response.body}");
          setState(() {
            isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error from API: ${response.reasonPhrase ?? 'Unknown error'}",
              ),
            ),
          );
        }
      } catch (e) {
        print("Exception during API call: $e");
        if (mounted) {
          setState(() {
            isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Some error occurred, please try again!"),
            ),
          );
        }
      }
    } else {
      // If only an image was "sent" (added to UI), no API call for text needed.
      setState(() {
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Alefiya's Chat Bot",
          style: const TextStyle(
            color: Color(0xFF9575CD),
            fontWeight: FontWeight.w900,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.purple.shade50,
        elevation: 1.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Chat messages list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  final message = msgs[index];
                  final bool isSender = message.isSender;

                  // Widget to display for the current message
                  Widget messageWidget;

                  if (message.imageFile != null) {
                    messageWidget = BubbleNormalImage(
                      id: 'image_$index', // Unique ID for the bubble
                      image: Image.file(message.imageFile!),
                      color: isSender
                          ? Colors.deepPurple.shade100
                          : Colors.grey.shade100,
                      tail: true,
                      isSender: isSender,
                      delivered:
                          isSender, // Example, you might want actual delivery status
                    );
                  } else {
                    messageWidget = BubbleNormal(
                      text: message.msg ?? "", // Handle null text
                      isSender: isSender,
                      color: isSender
                          ? Colors.deepPurple.shade100
                          : Colors.deepPurple.shade200,
                      tail: true,
                      textStyle: TextStyle(
                        color: isSender ? Colors.black87 : Colors.black87,
                        fontSize: 18,
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        messageWidget,
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 2.0,
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Text(
                            DateFormat(
                              'hh:mm a',
                            ).format(message.timestamp), // Format timestamp
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Bot is typing...",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -1),
                    blurRadius: 1,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ],
              ),

              child: Row(
                children: [
                  // Image Picker Button
                  IconButton(
                    icon: Icon(
                      Icons.image_outlined,
                      color: Colors.deepPurple.shade300,
                    ),
                    onPressed: _pickImage,
                    tooltip: "Pick image",
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  Material(
                    // Using Material for InkWell splash effect
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          sendMsg();
                        }
                        // You might also want to send if an image was just picked but no text
                        // This depends on your desired UX.
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(
                          10.0,
                        ), // Adjust padding for button size
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20, // Adjust icon size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

//                     return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: isTyping && index == 0
//                         ? Column(
//                       children: [
//                         BubbleNormal(
//                           text: msgs[0].msg,
//                           isSender: true,
//                           color: Colors.blue.shade100,
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.only(left: 16, top: 4),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text("Typing..."),
//                           ),
//                         )
//                       ],
//                     )
//                         : BubbleNormal(
//                       text: msgs[index].msg,
//                       isSender: msgs[index].isSender,
//                       color: msgs[index].isSender
//                           ? Colors.blue.shade100
//                           : Colors.grey.shade200,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // Input field and send button
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       width: double.infinity,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: TextField(
//                           controller: controller,
//                           textCapitalization: TextCapitalization.sentences,
//                           onSubmitted: (value) {
//                             sendMsg();
//                           },
//                           textInputAction: TextInputAction.send,
//                           showCursor: true,
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Enter text",
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     sendMsg();
//                   },
//                   child: Container(
//                     height: 40,
//                     width: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Icon(
//                       Icons.send,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
