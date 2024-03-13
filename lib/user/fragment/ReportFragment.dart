import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:video_player/video_player.dart';
import 'package:yes_tracker/main/components/VoiceMessagePlayer.dart';
import '../../main/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';

import '../components/VideoPlayerScreen.dart';
import '../components/VideoPlayerWidget.dart';
import 'image_preview_page.dart';

String? userID;
String? userName;
String? androidID;
XFile? _selectedMedia; // Declare _selectedMedia variable

class ReportFragment extends StatefulWidget {
  @override
  _ReportFragmentState createState() => _ReportFragmentState();
}

class _ReportFragmentState extends State<ReportFragment> with WidgetsBindingObserver {
  bool _isDriverSelected = true;
  List<dynamic> _adminReports = [];
  List<dynamic> driverReports = [];
  int _currentPage = 1; // Keep track of the current page number
  int _driverCUrrentPage = 1;
  bool _isLoading = false; // Flag to indicate if data is being loaded
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isTyping = false; // Flag to indicate if the user is typing
  bool _isRecording = false;
  bool _cancelRecording = false;
  bool _isDelivering = true;
  String _cancelText = "";
  double _keyboardPadding = 50.0; // Initial padding value
  bool isRecorderReady = false;
  bool isPlaying = false;
  final _recorder = FlutterSoundRecorder();
  late String _recordFilePath;
  final _player = FlutterSoundPlayer();
  Timer? _timer;
  int _elapsedSeconds = 0;
  // Define a debounce Duration (adjust the duration as needed)
  Duration _debounceDuration = Duration(milliseconds: 300);
  // Define a Timer variable to control debounce
  Timer? _debounceTimer;
  List<XFile>? _pickedFiles;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  Future initRecorder() async{
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Micrphone Permission Is Not Granted';
    }

    await _recorder.openRecorder();
    isRecorderReady = true;
    _recorder.setSubscriptionDuration(const Duration(microseconds: 500));
  }

  Future record() async{
    if (!isRecorderReady) return;

    // Get the external storage directory
    final directory = await getExternalStorageDirectory();
    _recordFilePath = '${directory!.path}/audio.aac';

    _startTimer();

    await _recorder.startRecorder(toFile: _recordFilePath);
  }

  Future stop() async{
    if (!isRecorderReady) return;

    final path = await _recorder.stopRecorder();
    final audioFile = File(path!);

    _stopTimer();
    _saveRecordingToBackend(path);

    print('Recorded audio: $path');
  }

  void cancelRecording() async {
    if (!isRecorderReady) return;

    // Stop recording
    await _recorder.stopRecorder();
    _stopTimer();

    // Delete the recording file
    if (_recordFilePath != null) {
      final audioFile = File(_recordFilePath!);
      if (audioFile.existsSync()) {
        await audioFile.delete();
      }
    }

    print('Recording canceled');
  }

  Future<void> play() async {
    print('Play function called');
    if (!await File(_recordFilePath).exists()) {
      print('No recorded file found');
      return;
    }

    try {
      print('Opening player');
      await _player.openPlayer().whenComplete(() {
        isPlaying = true;
      });
      await _player.startPlayer(fromURI: _recordFilePath).whenComplete(() {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      print('Failed to play recording: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.pausePlayer();
    } catch (e) {
      print('Failed to stop playback: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    fetchAdminReports();
    fetchDriverReports();
    getID().then((_) {
      // Once the data is retrieved, you can use it here
      print('User ID: $userID');
      print('User Name: $userName');
      print('Android ID: $androidID');
    });
    initRecorder();

    setState(() {
      _currentPage = 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _scrollController.dispose();
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
          _refreshDriverReports();
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

  void _sendMessageWithMedia(List<XFile> mediaFiles) async {
    final String message = _messageController.text;
    final url = Uri.parse(mBaseUrl + 'driverMessageMedia');
    final request = http.MultipartRequest('POST', url);

    // Attach the media files
    for (var mediaFile in mediaFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('media[]', mediaFile.path),
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

        // Parse the response JSON
        final jsonResponse = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = json.decode(jsonResponse);

        // Extract the message and uploaded images from the response
        String message = responseData['message'];
        List<dynamic> uploadedMedia = responseData['media'];

        // Display the message (optional)
        print(message);
        print(uploadedMedia);

        // Clear the message input field
        _messageController.clear();
        _refreshDriverReports();
        // Navigate back
        Navigator.pop(context);
      } else {
        // Handle the error
        print('Failed with status code: ${response.statusCode}');
        String errorMessage = await response.stream.bytesToString();
        print('Error message: $errorMessage');
      }
    } catch (e) {
      print('Error: $e');
      // Handle exceptions
    }
  }




  void _selectImageFromGallery() async {
    List<XFile>? pickedFiles = await ImagePicker().pickMultipleMedia(
      maxWidth: 800,
      maxHeight: 600,
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Selected Media',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pickedFiles.length,
                    itemBuilder: (context, index) {
                      XFile file = pickedFiles[index];
                      if (file.path.toLowerCase().endsWith('.mp4')) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                              ),
                              child: VideoPlayerWidget(file.path),
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Image.file(
                            File(file.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        _sendMessageWithMedia(pickedFiles!);
                        setState(() {
                          _pickedFiles = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

  }

  void _takeMediaOnSpot() async {
    final ImagePicker _picker = ImagePicker();

    // Prompt the user to choose between image or video
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select An Option',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Close the modal bottom sheet
                      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        _handleMediaPicked(pickedFile, isImage: true);
                      }
                    },
                    icon: Icon(Icons.image),
                    label: Text('Select Image'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Close the modal bottom sheet
                      final pickedVideo = await _picker.pickVideo(source: ImageSource.camera, maxDuration: Duration(seconds: 5));
                      if (pickedVideo != null) {
                        _handleMediaPicked(pickedVideo, isImage: false);
                      }
                    },
                    icon: Icon(Icons.videocam),
                    label: Text('Record Video'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMediaPicked(XFile file, {required bool isImage}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                isImage ? 'Captured Image' : 'Captured Video',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Display the captured image or video
              isImage
                  ? Image.file(
                File(file.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
                  : Padding(
                padding: EdgeInsets.only(right: 8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: VideoPlayerWidget(file.path),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      _sendMessageWithMedia([file]);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Action To Complete',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the modal bottom sheet
                      _selectImageFromGallery(); // Open gallery to select images
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the modal bottom sheet
                      _takeMediaOnSpot(); // Open camera to take a photo
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        // Fetch driver reports after successful upload
        _refreshDriverReports();
        // Clear the message input field
        // _messageController.clear();
        // // Navigate back
        // Navigator.pop(context);
      } else {
        // Handle the error
        print('Failed with status code: ${response.statusCode}');
        // Print out the response body for more information
        print(await response.stream.bytesToString());
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
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Dialog(
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
          ),
        );
      },
    );
  }

  Future getID() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userID = sharedPreferences.getString('id');
    userName = sharedPreferences.getString('name');
    androidID = sharedPreferences.getString('androidID');
  }

  Future<void> fetchDriverReports({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse(mBaseUrl + 'getDriverReports/$userID?page=$page')); // Replace 'your_backend_url_here' with your actual backend URL

      if (response.statusCode == 200) {
        // If the request is successful (status code 200), parse the response body
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> _driverReports = responseData['driverReports']['data'];
        _isDelivering = responseData['isDelivering'];

        setState(() {
          if (page == 1) {
            // If it's the first page, replace the current list with new data
            driverReports = _driverReports;
          } else {
            // If it's not the first page, append the new data to the existing list
            driverReports.addAll(_driverReports);
          }

          // Sort the entire list based on the created_at field
          driverReports.sort((a, b) {
            // Parse the created_at strings into DateTime objects
            DateTime createdAtA = DateTime.parse(a['created_at']);
            DateTime createdAtB = DateTime.parse(b['created_at']);

            // Compare the DateTime objects
            return createdAtA.compareTo(createdAtB); // Sorting in ascending order, oldest first
          });
        });
        print(_driverReports);
      } else {
        // If the request fails, print an error message
        print('Failed to load driver reports: ${response.statusCode}');
      }
    } catch (e) {
      // If an exception occurs, print the error
      print('Exception occurred: $e');
    }
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

// Method to handle debounced loading of more reports
  void handleLoadMoreDriverReports() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      // If a previous debounce timer is running, cancel it
      _debounceTimer!.cancel();
    }

    // Start a new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      loadMoreDriverReports(); // Load more reports
      print(_currentPage);
    });
  }
  // Method to load more reports when the user scrolls to the end
  Future<void> loadMoreReports() async {
    _currentPage++; // Increment the page number
    await fetchAdminReports(page: _currentPage);
    print(_currentPage);
  }

  // Method to load more reports when the user scrolls to the end
  Future<void> loadMoreDriverReports() async {
    _currentPage++; // Increment the page number
    await fetchDriverReports(page: _currentPage);
    print(_currentPage);
  }

  Future<void> _refreshReports() async {
    _currentPage = 1;
    await fetchAdminReports();
  }

  Future<void> _refreshDriverReports() async {
    _driverCUrrentPage = 1;
    await fetchDriverReports();

    // Scroll to the top after refreshing
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500), // Adjust duration as needed
      curve: Curves.easeInOut, // Adjust curve as needed
    );
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
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading && scrollInfo.metrics.atEdge && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          // If not already loading and user has scrolled to the bottom
                          handleLoadMoreDriverReports(); // Load more reports
                          return true;
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Reverse the list view
                        itemCount: driverReports.length,
                        itemBuilder: (context, index) {
                          final reversedIndex = driverReports.length - 1 - index; // Calculate the reversed index
                          final driverImage = driverReports[reversedIndex]['driver_image']; // Get the driver image URL
                          final dynamic media = driverReports[reversedIndex]['media'];
                          String createdAt = DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.parse(driverReports[index]['created_at']));
                          List<dynamic>? mediaList;

                          if (media != null && !media.endsWith('.aac')) {
                            mediaList = json.decode(media);
                          }
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green, // Use the textColor variable here
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(Icons.local_shipping, size: 36, color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50, top: 0, right: 5, bottom: 0),
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${driverReports[reversedIndex]['plate_no']}',
                                                style: TextStyle(fontWeight: FontWeight.bold),),
                                              FittedBox( // Use FittedBox to fit the child within available space
                                                child: Text(
                                                  '${driverReports[reversedIndex]['created_at']}', // Use the createdAt time here
                                                  style: TextStyle(
                                                    color: Colors.grey, // Adjust text color as needed
                                                    fontSize: 12, // Adjust font size as needed
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('${driverReports[reversedIndex]['driver_surname']}'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${driverReports[reversedIndex]['message'] ?? ''}',
                                  ),
                                  SizedBox(height: 16),
                                  if (media != null) ...[
                                    if (mediaList != null && mediaList.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GridView.count(
                                          physics: NeverScrollableScrollPhysics(),
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          children: mediaList.take(2).map<Widget>((media) {
                                            if (media is String && media.endsWith('.jpg')) {
                                              // Display image
                                              String imageUrl = driverMediaURL + media;
                                              return Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showImageDialog(context, mediaList!.map<String>((media) => driverMediaURL + media).toList(), imageUrl);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black, // Border color
                                                        width: 0.2, // Border width
                                                      ),
                                                    ),
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else if (media is String && media.endsWith('.mp4')) {
                                              // Play video
                                              return GestureDetector(
                                                onTap: () {
                                                  // Play video
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => VideoPlayerScreen(videoUrl: driverMediaURL + media),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Colors.black, // Placeholder color for video thumbnail
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.play_circle_fill,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Handle other media types or unknown types
                                              return Container(); // Return empty container or handle accordingly
                                            }
                                          }).toList()..add(
                                            // Show +X if more than 3 media items
                                            mediaList.length > 2
                                                ? GestureDetector(
                                              onTap: () {
                                                String imageUrl = driverMediaURL + driverReports[reversedIndex]['media'];
                                                _showImageDialog(
                                                  context,
                                                  (jsonDecode(driverReports[reversedIndex]['media']) as List)
                                                      .map<String>((media) => driverMediaURL + media)
                                                      .toList(),
                                                  imageUrl,
                                                );
                                              },
                                              child: Container(
                                                color: Colors.black54,
                                                width: 200,
                                                height: 200,
                                                child: Center(
                                                  child: Text(
                                                    '+${mediaList.length - 2}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                                : SizedBox(),
                                          ),
                                        ),
                                      ),
                                    if (media.endsWith('.aac'))
                                    SizedBox(
                                          height: 50, // Provide a height constraint
                                          width: 200, // Provide a width constraint
                                          child: VoiceMessagePlayer(
                                          audioUri: '$DOMAIN_URL/public/audio/$media',
                                        ),
                                      )
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _isDelivering
                  ? _isRecording
                      ? Column(
                    children: [
                      Center(
                          child: Column(
                            children: [
                              Center(
                                  child: Column(
                                    children: [
                                      Center(
                                        child: GestureDetector(
                                          onLongPressStart: (_) async {
                                            // Start recording when long press starts
                                            await record();
                                            setState(() {
                                              // Set recording state to true
                                              _isRecording = true;
                                              _cancelText = "Swipe up to cancel"; // Set cancellation text
                                            });
                                          },
                                          onLongPressEnd: (_) async {
                                            if (!_cancelRecording) { // Only stop recording if not canceled
                                              // Stop recording when long press ends
                                              await stop();
                                            }
                                            setState(() {
                                              // Reset recording and cancellation states
                                              // _isRecording = false;
                                              _cancelRecording = false;
                                              _cancelText = ""; // Reset cancellation text
                                            });
                                          },
                                          onLongPressMoveUpdate: (details) {
                                            final RenderBox buttonBox = context.findRenderObject() as RenderBox;
                                            final buttonSize = buttonBox.size;

                                            // Get the position of the long press relative to the button
                                            final pressPosition = details.localPosition;

                                            // Define a margin for the button to account for partial swipes
                                            final double margin = 20.0;

                                            // Check if the press position is outside the button area with margin
                                            if (pressPosition.dx < -margin ||
                                                pressPosition.dx > buttonSize.width + margin ||
                                                pressPosition.dy < -margin ||
                                                pressPosition.dy > buttonSize.height + margin) {
                                              setState(() {
                                                // Set cancellation flag
                                                _cancelRecording = true;
                                                _cancelText = ""; // Reset cancellation text
                                              });
                                              // Cancel recording
                                              cancelRecording();
                                            }
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _cancelText.isNotEmpty ?
                                              Text(
                                                _cancelText,
                                                style: TextStyle(color: Colors.red), // Apply red color to cancellation text
                                              ) :
                                              SizedBox(height: 2.0),
                                              Text(
                                                '${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                                                style: TextStyle(color: Colors.black), // Example styling for the timer text
                                              ),
                                              // SizedBox(height: 10,),
                                              ElevatedButton(
                                                child: Icon(
                                                  _recorder.isRecording ? Icons.stop : Icons.mic,
                                                  size: 80,
                                                ),
                                                onPressed: () {
                                                  // This will be triggered when the button is tapped
                                                  // We handle long press actions separately with GestureDetector
                                                },
                                              ),
                                              SizedBox(height: 16.0), // Display cancel text if not empty
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.0),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            // Clear the recording state when the close button is pressed
                                            _isRecording = false;
                                            _cancelText = ""; // Reset cancellation text
                                          });
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
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
                            if (_isTyping) {
                              _sendMessage(); // Send message if user is typing
                            } else {
                              setState(() {
                                _isRecording = true; // Start recording if user is not typing
                              });
                              // Show toast message
                              Fluttertoast.showToast(
                                msg: "Hold and Release to Send",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black.withOpacity(0.8),
                                textColor: Colors.white,
                              );
                            }
                          },
                          icon: _isTyping ? Icon(Icons.send) : Icon(Icons.mic),
                        ),

                      ],
                    ),
                  )
                      : Column(),
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
                      final dynamic media = _adminReports[index]['media'];
                      List<dynamic>? mediaList;

                      if (media != null) {
                        mediaList = json.decode(media);
                      }
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
                                          child: Text(
                                            DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.parse(_adminReports[index]['created_at'])),
                                            style: TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        )],
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
                              if (mediaList != null && mediaList.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    children: mediaList.take(2).map<Widget>((media) {
                                      if (media is String && (media.endsWith('.jpg')||media.endsWith('.png') )) {
                                        // Display image
                                        String imageUrl = mediaUrl + media;
                                        return Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              _showImageDialog(context, mediaList!.map<String>((media) => mediaUrl + media).toList(), imageUrl);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black, // Border color
                                                  width: 0.2, // Border width
                                                ),
                                              ),
                                              child: Image.network(
                                                imageUrl,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (media is String && media.endsWith('.mp4')) {
                                        // Play video
                                        return GestureDetector(
                                          onTap: () {
                                            // Play video
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideoPlayerScreen(videoUrl: mediaUrl + media),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.black, // Placeholder color for video thumbnail
                                            child: Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Handle other media types or unknown types
                                        return Container(); // Return empty container or handle accordingly
                                      }
                                    }).toList()..add(
                                      // Show +X if more than 3 media items
                                      mediaList.length > 2
                                          ? GestureDetector(
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
                                          color: Colors.black54,
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              '+${mediaList.length - 2}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          : SizedBox(),
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
