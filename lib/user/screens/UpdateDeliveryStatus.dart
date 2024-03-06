import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:nb_utils/nb_utils.dart';
import '../../main/utils/Constants.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../user/screens/OrderDetailScreen.dart';

class UpdateDeliveryStatus extends StatefulWidget {
  final String shipmentId;
  final String driverId;
  final String status;

  final String? itemCode;
  final String? driverPhoneNum;
  final String? customerPhoneNum;
  final String? pickUpLocation;
  final String? dropOffLocation;
  final String? departedTime;
  final String? deliveredTime;
  final String? itemDesc;
  final int? amount;
  final String? remarks;
  final String? createdAt;

  UpdateDeliveryStatus({
    required this.shipmentId,
    required this.driverId,
    required this.status,

    required this.itemCode,
    required this.itemDesc,
    required this.driverPhoneNum,
    required this.customerPhoneNum,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.departedTime,
    required this.deliveredTime,
    required this.amount,
    required this.remarks,
    required this.createdAt,
  });

  @override
  _UpdateDeliveryStatusState createState() => _UpdateDeliveryStatusState();
}

class _UpdateDeliveryStatusState extends State<UpdateDeliveryStatus> {
  File? _selectedMedia;
  TextEditingController _descriptionController = TextEditingController();
  GoogleMapController? _mapController;
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 15,
  );
  Marker _userLocationMarker = Marker(markerId: MarkerId('user_location'), position: LatLng(4.2105, 101.9758));
  String _userAddress = 'Loading...';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _getInitialLocation(); // Get and set the user's current location
  }

  Future<void> _getInitialLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );

        _userLocationMarker = _userLocationMarker.copyWith(
          positionParam: LatLng(position.latitude, position.longitude),
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
      }
      await _updateUserAddress(position.latitude, position.longitude).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );

      _userLocationMarker = _userLocationMarker.copyWith(
        positionParam: LatLng(position.latitude, position.longitude),
      );
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
    }
    await _updateUserAddress(position.latitude, position.longitude);
  }

  Future<void> _updateUserAddress(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String fullAddress = '';

      // Extract various address components and concatenate them
      if (placemark.name != null) {
        fullAddress += placemark.name!;
      }
      // if (placemark.subThoroughfare != null) {
      //   fullAddress += ', ${placemark.subThoroughfare}';
      // }
      if (placemark.thoroughfare != null) {
        fullAddress += ', ${placemark.thoroughfare}';
      }
      if (placemark.subLocality != null) {
        fullAddress += ', ${placemark.subLocality}';
      }
      if (placemark.postalCode != null) {
        fullAddress += ', ${placemark.postalCode}';
      }
      if (placemark.locality != null) {
        fullAddress += ' ${placemark.locality}';
      }
      // if (placemark.subAdministrativeArea != null) {
      //   fullAddress += ', ${placemark.subAdministrativeArea}';
      // }
      // if (placemark.administrativeArea != null) {
      //   fullAddress += ', ${placemark.administrativeArea}';
      // }
      // if (placemark.country != null) {
      //   fullAddress += ', ${placemark.country}';
      // }

      setState(() {
        _userAddress = fullAddress;
      });
    } else {
      setState(() {
        _userAddress = 'Address not found';
      });
    }
  }


  void _onCameraMove(CameraPosition position) async {
    // Update the marker's position while the map is moved
    setState(() {
      _userLocationMarker = _userLocationMarker.copyWith(
        positionParam: position.target,
      );
    });
    await _updateUserAddress(position.target.latitude, position.target.longitude);
  }

  Future<void> _pickImageOrVideo(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    XFile? pickedMedia;

    if (isVideo) {
      pickedMedia = await picker.pickVideo(source: source);
    } else {
      pickedMedia = await picker.pickImage(source: source);
    }

    if (pickedMedia != null) {
      final File file = File(pickedMedia.path);

      final fileSize = await file.length();
      final allowedExtensions = isVideo ? ['mp4'] : ['jpg', 'jpeg'];

      final fileExtension = file.path.split('.').last.toLowerCase();
      if (fileSize > 10 * 1024 * 1024 || !allowedExtensions.contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid file. Please select a ${isVideo ? 'video (MP4)' : 'image (JPG or JPEG)'} within 10MB.',
            ),
          ),
        );
      } else {
        setState(() {
          _selectedMedia = file;
        });
      }
    }
  }


  Future<void> _uploadDeliveryDetails() async {
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

    final url = Uri.parse(mBaseUrl + 'uploadDeliveryDetails');
    final request = http.MultipartRequest('POST', url);

    final location = _userAddress;

    // Attach the image or video file
    if (_selectedMedia != null) {
      request.files.add(
        await http.MultipartFile.fromPath('media', _selectedMedia!.path),
      );
    }

    // Add other form data
    request.fields['description'] = _descriptionController.text;
    request.fields['location'] = location;
    request.fields['shipmentId'] = widget.shipmentId;
    request.fields['driverId'] = widget.driverId;
    request.fields['status'] = widget.status;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Successfully uploaded
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Delivery details uploaded successfully')),
        // );

        Fluttertoast.showToast(
          msg: "Successfully Uploaded",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
                orderId: widget.shipmentId,
                itemCode: widget.itemCode,
                itemDesc: widget.itemDesc,
                driverPhoneNum: widget.driverPhoneNum,
                customerPhoneNum: widget.customerPhoneNum,
                pickUpLocation: widget.pickUpLocation,
                dropOffLocation: widget.dropOffLocation,
                departedTime: widget.departedTime,
                deliveredTime: widget.deliveredTime,
                status: widget.status,
                amount: widget.amount,
                remarks: widget.remarks,
                createdAt: widget.createdAt,
                driverId: widget.driverId)
          ),
        );
      } else {
        // Handle the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed with status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
      backgroundColor: Color(0xFF253280),
      body: Center(
        child: SpinKitWanderingCubes(
          color: Colors.white,
        ),
      ),
    ): Scaffold(
      appBar: AppBar(
        title: Text('Update Delivery Status'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    if (_selectedMedia != null)
                      if (_selectedMedia!.path.toLowerCase().endsWith('.mp4'))
                        VideoPlayerWidget(videoFile: _selectedMedia!)
                      else
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(
                            height: 325,
                            width: double.infinity,
                          ),
                          child: Image.file(
                            _selectedMedia!,
                            fit: BoxFit.cover,
                          ),
                        ),
                    if (_selectedMedia != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMedia = null;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 16,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    if (_selectedMedia == null)
                      GestureDetector(
                        onTap: () {
                          showMediaOptions();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 40,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: Text(
                                'JPG, JPEG, or MP4 (10MB)',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description (Max: 500 words)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      markers: {_userLocationMarker}, // Add the user's location marker
                      onTap: (LatLng location) {
                        // Handle user interaction on the map, e.g., set their location
                      },
                      onCameraMove: _onCameraMove, // Update marker position while the map is moved
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: _getCurrentLocation, // Get and set the user's current location
                        child: Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity, // Make the button stretch to fit screen width
                  child: ElevatedButton(
                    onPressed: () {
                      _uploadDeliveryDetails();
                    },
                    child: Text('UPLOAD'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Capture Image'),
              onTap: () {
                _pickImageOrVideo(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Capture Video'),
              onTap: () {
                _pickImageOrVideo(ImageSource.camera, isVideo: true);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Select Image from Gallery'),
              onTap: () {
                _pickImageOrVideo(ImageSource.gallery, isVideo: false); // Specify that it's an image
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Select Video from Gallery'),
              onTap: () {
                _pickImageOrVideo(ImageSource.gallery, isVideo: true); // Specify that it's a video
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget({required this.videoFile});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 325,
      child: AspectRatio(
        aspectRatio: 16 / 9, // Set the aspect ratio to 16:9
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            VideoPlayer(_controller),
            if (!_controller.value.isInitialized)
              CircularProgressIndicator()
            else if (_controller.value.isPlaying)
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: () {
                  setState(() {
                    _controller.pause();
                  });
                },
              )
            else
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _controller.play();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
