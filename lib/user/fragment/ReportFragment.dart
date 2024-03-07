import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import '../../main/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

import 'image_preview_page.dart';

String? userID;
String? userName;
String? androidID;
XFile? _selectedMedia; // Declare _selectedMedia variable
bool _isRecording = false;


class ReportFragment extends StatefulWidget {
  @override
  _ReportFragmentState createState() => _ReportFragmentState();
}

class _ReportFragmentState extends State<ReportFragment> with WidgetsBindingObserver {
  bool _isDriverSelected = true;
  List<dynamic> _adminReports = [];
  int _currentPage = 1; // Keep track of the current page number
  bool _isLoading = false; // Flag to indicate if data is being loaded
  TextEditingController _messageController = TextEditingController();
  bool _isTyping = false; // Flag to indicate if the user is typing
  double _keyboardPadding = 50.0; // Initial padding value

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    fetchAdminReports();
    getID().then((_) {
      // Once the data is retrieved, you can use it here
      print('User ID: $userID');
      print('User Name: $userName');
      print('Android ID: $androidID');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _keyboardPadding = bottomInset > 0 ? 10.0 : 50.0;
    });
  }

  void _handleMessageInputChange(String input) {
    setState(() {
      _isTyping = input.isNotEmpty;
    });
  }

  void _sendMessage() async {
    final String message = _messageController.text;
    if (message.isNotEmpty) {
      // Send the message to the backend
      try {
        final Uri url = Uri.parse(mBaseUrl + 'driverMessage');
        final response = await http.post(
          url,
          body: {
            'message': message,
            'userId': userID ?? '', // Pass the user ID obtained from SharedPreferences
          },
        );

        if (response.statusCode == 200) {
          // Message saved successfully
          print('Message saved successfully');
          // Clear the message input field
          _messageController.clear();
          // Reset the typing state
          _handleMessageInputChange(''); // Reset _isTyping to false
          // Refresh the admin reports
          _refreshReports();
        } else {
          // Error saving message
          print('Error saving message: ${response.body}');
        }
      } catch (e) {
        print('Exception occurred: $e');
      }
    }
  }

  void _sendMessageWithMedia(XFile imageFile) async {
    final String message = _messageController.text;
      final url = Uri.parse(mBaseUrl + 'driverMessageMedia');
      final request = http.MultipartRequest('POST', url);

      // Attach the image file
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', imageFile.path),
        );
      }

      // Add other form data
      request.fields['message'] = message ?? '';
      request.fields['userId'] = userID ?? '';

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          // Successfully uploaded
          print('Media uploaded successfully');
          // Clear the message input field
          _messageController.clear();
          // Navigate back
          Navigator.pop(context);
        } else {
          // Handle the error
          print('Failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
        // Handle exceptions
      }
  }



  void _selectImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Navigate to the image preview page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(
            imageFile: pickedFile,
            messageController: _messageController,
            sendMessage: (XFile imageFile) => _sendMessageWithMedia(imageFile),
            // Pass imageFile to _sendMessageWithMedia
          ),
        ),
      );
    }
  }

  void _takePictureOnSpot() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Navigate to the image preview page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(
            imageFile: pickedFile,
            messageController: _messageController,
            sendMessage: (XFile imageFile) => _sendMessageWithMedia(imageFile),
            // Pass imageFile to _sendMessageWithMedia
          ),
        ),
      );
    }
  }




  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose Image from Gallery'),
                  onTap: () {
                    // Handle selecting image from gallery
                    _selectImageFromGallery();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Picture on the Spot'),
                  onTap: () {
                    // Handle taking picture on the spot
                    _takePictureOnSpot();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveRecordingToBackend(String audioFilePath) async {
    final url = Uri.parse(mBaseUrl + 'driverMessageRecording');
    final request = http.MultipartRequest('POST', url);

    // Attach the audio file
    if (audioFilePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFilePath),
      );
    }

    // Add other form data
    request.fields['userId'] = userID ?? '';

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Successfully uploaded
        print('Recording uploaded successfully');
        // Clear the message input field
        // _messageController.clear();
        // // Navigate back
        // Navigator.pop(context);
      } else {
        // Handle the error
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle exceptions
    }
  }


  void _showImageDialog(BuildContext context, List<String> images, String imageUrl) {
    int initialPageIndex = images.indexOf(imageUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    controller: PageController(initialPage: initialPageIndex),
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                images[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadMedia() async {
    if (_selectedMedia == null) {
      // Show a toast if no media is attached
      Fluttertoast.showToast(
        msg: "Please include a media",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final url = Uri.parse(mBaseUrl + 'driverMessageMedia');
    final request = http.MultipartRequest('POST', url);

    // Attach the image file
    if (_selectedMedia != null) {
      request.files.add(
        await http.MultipartFile.fromPath('media', _selectedMedia!.path),
      );
    }

    // Add other form data
    request.fields['message'] = _messageController.text;
    request.fields['userId'] = userID ?? '';

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Successfully uploaded
        print('Media uploaded successfully');
        // Reset media selection
        setState(() {
          _selectedMedia = null;
        });
      } else {
        // Handle the error
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle exceptions
    }
  }


  Future getID() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userID = sharedPreferences.getString('id');
    userName = sharedPreferences.getString('name');
    androidID = sharedPreferences.getString('androidID');
  }

  Future<void> fetchAdminReports({int page = 1}) async {
    if (_isLoading) return; // If already loading, do not fetch again
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(mBaseUrl + 'CAdminReports?page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> adminReports = responseData['adminReports']['data'];

      setState(() {
        if (page == 1) {
          _adminReports = adminReports;
        } else {
          _adminReports.addAll(adminReports);
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // throw Exception('Failed to load admin reports');
      print(response.statusCode);
    }
  }

  // Method to load more reports when the user scrolls to the end
  Future<void> loadMoreReports() async {
    _currentPage++; // Increment the page number
    await fetchAdminReports(page: _currentPage);
    print(_currentPage);
  }

  Future<void> _refreshReports() async {
    _currentPage = 1;
    await fetchAdminReports();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isDriverSelected = true;
                    });
                  },
                  icon: Icon(Icons.directions_car),
                  label: Text('Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDriverSelected ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isDriverSelected = false;
                    });
                  },
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text('Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isDriverSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _isDriverSelected
              ? Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: _keyboardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Driver Report',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.purple, // Specify the color of the divider
                          thickness: 1.0, // Specify the thickness of the divider
                        ),
                      ],
                    ),
                  ),
                  _isRecording
                      ? Column(
                    children: [
                      SocialMediaRecorder(
                        startRecording: () {
                          // setState(() {
                          //   _isRecording = true;
                          // });
                        },
                        stopRecording: (_time) {
                          // setState(() {
                          //   _isRecording = false;
                          // });
                        },
                        sendRequestFunction: (soundFile, _time) {
                          _saveRecordingToBackend(soundFile.path);
                        },
                        encode: AudioEncoderType.AAC,
                      ),
                      SizedBox(height: 16.0),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isRecording = false;
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  )
                      : Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 40.0,
                            child: TextField(
                              controller: _messageController,
                              onChanged: _handleMessageInputChange,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: TextStyle(fontSize: 14.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.attach_file),
                                  onPressed: _showAttachmentOptions,
                                ),
                              ),
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isRecording = true;
                            });
                          },
                          icon: _isTyping ? Icon(Icons.send) : Icon(Icons.mic),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              : _adminReports.isEmpty
              ? Expanded(
            child: Center(
              child: Text(
                'No Admin Reports Currently',
                style: TextStyle(fontSize: 24),
              ),
            ),
          )
              : Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshReports,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isLoading &&
                        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      // If not already loading and user has scrolled to the bottom
                      loadMoreReports(); // Load more reports
                      return true;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: _adminReports.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://t4.ftcdn.net/jpg/02/27/45/09/360_F_227450952_KQCMShHPOPebUXklULsKsROk5AvN6H1H.jpg'),
                                  ),
                                  SizedBox(width: 8), // Add some spacing between avatar and text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                          child: Text(_adminReports[index]['created_at']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 15, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_adminReports[index]['text']),
                                  ],
                                ),
                              ),
                              // Display media
                              if (_adminReports[index]['media'] != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    children: (jsonDecode(_adminReports[index]['media']) as List)
                                        .take(2)
                                        .map<Widget>((media) {
                                      String imageUrl = mediaUrl + media;
                                      return Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            _showImageDialog(
                                              context,
                                              (jsonDecode(_adminReports[index]['media']) as List)
                                                  .map<String>((media) => mediaUrl + media)
                                                  .toList(),
                                              imageUrl,
                                            );
                                          },
                                          child: Image.network(
                                            imageUrl,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                      ..addAll(
                                        // Show +X if more than 3 images
                                        ((jsonDecode(_adminReports[index]['media']) as List).length > 2)
                                            ? [
                                          GestureDetector(
                                            onTap: () {
                                              String imageUrl = mediaUrl + _adminReports[index]['media'];
                                              _showImageDialog(
                                                context,
                                                (jsonDecode(_adminReports[index]['media']) as List)
                                                    .map<String>((media) => mediaUrl + media)
                                                    .toList(),
                                                imageUrl,
                                              );
                                            },
                                            child: Container(
                                              color: Colors.black54.withOpacity(0.5),
                                              width: 200,
                                              height: 200,
                                              child: Center(
                                                child: Text(
                                                  '+${(jsonDecode(_adminReports[index]['media']) as List).length - 2}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                            : [],
                                      ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
