import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<XFile> imageFiles;
  final TextEditingController messageController;
  final void Function(List<XFile>) sendMessage;

  const ImagePreviewPage({
    required this.imageFiles,
    required this.messageController,
    required this.sendMessage,
  });

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Swiper(
              itemCount: widget.imageFiles.length,
              index: _currentIndex,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Image.file(
                      File(widget.imageFiles[index].path),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              layout: SwiperLayout.DEFAULT,
              scrollDirection: Axis.horizontal,
              loop: false, // Disable infinite looping
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    widget.sendMessage(widget.imageFiles);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
