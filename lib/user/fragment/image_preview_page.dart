import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewPage extends StatelessWidget {
  final XFile imageFile;
  final TextEditingController messageController;
  final void Function(XFile) sendMessage;

  const ImagePreviewPage({
    required this.imageFile,
    required this.messageController,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    print('Image Path: ${imageFile.path}'); // Print imagePath value
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                File(imageFile.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.white), // Set border side color to white
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.white), // Set border side color to white
                      ),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  onPressed: () => sendMessage(imageFile), // <-- Pass XFile to sendMessage
                  icon: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
