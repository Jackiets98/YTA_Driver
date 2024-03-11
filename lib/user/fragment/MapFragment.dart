import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';


class MapFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  MapFragmentState createState() => MapFragmentState();
}

class MapFragmentState extends State<MapFragment> {
  String selectedContent = "all";
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  List<Marker> markers = [];
  late Timer _timer;
  TextEditingController searchController = TextEditingController();
  int totalVehicle = 0;
  int travelVehicle = 0;
  int idleVehicle = 0;
  int stopVehicle = 0;
  bool isLoading  = false;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(	5.285153, 100.456238),
    zoom: 8.4746,
  );

  @override
  void initState() {
    super.initState();
    init();
    // Start the timer when the widget is initialized
    // _startTimer();
  }

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var obtainedID = sharedPreferences.getString('id');
    var deviceID = sharedPreferences.getString('androidID');

    setState(() {
      isLoading == true;
    });

    // Fetch data based on selected content and update markers
    fetchDataAndUpdateMarkers();
  }

  void searchVehicle(String searchText) async {
    // Clear previous markers
    markers.clear();


    var response = await http.get(Uri.parse(mBaseUrl + 'getDeviceList'));

    if (response.statusCode == 200) {
      List<dynamic> allMarkers = json.decode(response.body);
      bool markerFound = false;

      for (var device in allMarkers) {
        if (device['plateNo'].toLowerCase().contains(searchText.toLowerCase())) {
          final BitmapDescriptor movingCarIcon = await _createMarkerImageFromAsset('green_vehicle.png');
          final BitmapDescriptor idleCarIcon = await _createMarkerImageFromAsset('blue_vehicle.png');
          final BitmapDescriptor stopCarIcon = await _createMarkerImageFromAsset('red_vehicle.png');
          BitmapDescriptor markerIcon;

          if (device['status'] == '行驶' && device['engine'] == 'ON') {
            markerIcon = movingCarIcon;
            travelVehicle = travelVehicle;
          } else if (device['status'] == '静止' && device['engine'] == 'ON') {
            markerIcon = idleCarIcon;
            idleVehicle = idleVehicle;
          } else {
            markerIcon = stopCarIcon;
            stopVehicle = stopVehicle;
          }

          markers.add(
            Marker(
              markerId: MarkerId('${device['imei']}'),
              position: LatLng(double.parse(device['lat']), double.parse(device['lng'])),
              icon: markerIcon,
              rotation: device['course'].toDouble(),
              infoWindow: InfoWindow(
                title: '${device['plateNo']}',
                snippet: 'Please Click Here For More Details',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomInfoWindow(
                        title: '${device['plateNo']}',
                        speed: Text('Speed: ${device['speed']}km/h'),
                        course: Text('Course: ${device['course']}'),
                        battery: Text('Battery: ${device['battery']}V'),
                        statuses: Row(
                          children: [
                            Text('Status: '),
                            Text(
                              '${device['status']}',
                              style: TextStyle(
                                color: device['status'] == '行驶' && device['engine'] == 'ON' ? Colors.green :
                                device['status'] == '静止' && device['engine'] == 'ON' ? Colors.blue :
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        status: device['status'],
                        engine: device['engine'],
                      );
                    },
                  );
                },
              ),
            ),
          );

          // Move the camera to the position of the first matching marker
          if (!markerFound) {
            markerFound = true;
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(double.parse(device['lat']), double.parse(device['lng'])), 14.0));
          }
        }
      }

      // Update markers on the map
      setState(() {});
    }
  }


  // void _startTimer() {
  //   // Initialize the timer to call the fetchDataAndUpdateMarkers function every 10 seconds
  //   _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
  //     // Call the fetchDataAndUpdateMarkers function
  //     fetchDataAndUpdateMarkers();
  //   });
  // }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String assetName) async {
    final ByteData byteData = await rootBundle.load('assets/$assetName');
    final Uint8List byteList = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(byteList);
  }

  Future<void> fetchDataAndUpdateMarkers() async {
    try {
      // Make HTTP GET request
      var response = await http.get(Uri.parse(mBaseUrl + 'getDeviceList'));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response body
        List<dynamic> deviceList = json.decode(response.body);

        // Filter deviceList based on selected content
        List<dynamic> filteredList = [];
        if (selectedContent == 'all') {
          filteredList = deviceList;
        } else if (selectedContent == 'travel') {
          filteredList = deviceList.where((device) => device['status'] == '行驶' && device['engine'] == 'ON').toList();
        } else if (selectedContent == 'idle') {
          filteredList = deviceList.where((device) => device['status'] == '静止' && device['engine'] == 'ON').toList();
        } else if (selectedContent == 'stop') {
          filteredList = deviceList.where((device) => device['status'] != '行驶' || device['engine'] != 'ON').toList();
        }

        // Set randomIndex based on the length of the filtered list
        int randomIndex = Random().nextInt(filteredList.length);

        // Clear previous markers
        markers.clear();

        // Initialize counts to 0 if it's the first time
        if (selectedContent == 'all') {
          totalVehicle = deviceList.length;
          travelVehicle = 0;
          idleVehicle = 0;
          stopVehicle = 0;
        } // Reset counts based on selected content
        else if (selectedContent == 'travel') {
          travelVehicle = 0; // Reset travel vehicle count
        } else if (selectedContent == 'idle') {
          idleVehicle = 0; // Reset idle vehicle count
        } else if (selectedContent == 'stop') {
          stopVehicle = 0; // Reset stop vehicle count
        }

        // Add markers based on filteredList
        for (var device in filteredList) {
          // Load icon images for each marker type
          final BitmapDescriptor movingCarIcon = await _createMarkerImageFromAsset(
              'green_vehicle.png');
          final BitmapDescriptor idleCarIcon = await _createMarkerImageFromAsset(
              'blue_vehicle.png');
          final BitmapDescriptor stopCarIcon = await _createMarkerImageFromAsset(
              'red_vehicle.png');
          BitmapDescriptor markerIcon;

          // Determine which icon to use based on the device status or type
          if (selectedContent == 'all') {
            // Add all markers regardless of status
            if (device['status'] == '行驶' && device['engine'] == 'ON') {
              markerIcon = movingCarIcon;
              travelVehicle++;
            } else if (device['status'] == '静止' && device['engine'] == 'ON') {
              markerIcon = idleCarIcon;
              idleVehicle++;
            } else {
              markerIcon = stopCarIcon;
              stopVehicle++;
            }
          } else if (selectedContent == 'travel') {
            markerIcon = movingCarIcon;
            travelVehicle++;
          } else if (selectedContent == 'idle' &&
              device['status'] == '静止' && device['engine'] == 'ON') {
            markerIcon = idleCarIcon;
            idleVehicle++;
            print(device);
          } else if (selectedContent == 'stop' &&
              device['status'] != '行驶' && device['engine'] == 'OFF') {
            markerIcon = stopCarIcon;
            stopVehicle++;
            print(device);
          } else {
            // If not matching any condition, continue to next device
            continue;
          }

          markers.add(
            Marker(
              markerId: MarkerId('${device['imei']}'),
              position: LatLng(double.parse(device['lat']),
                  double.parse(device['lng'])),
              icon: markerIcon, // Use appropriate marker icon
              rotation: device['course'].toDouble(),
              infoWindow: InfoWindow(
                title: '${device['plateNo']}',
                snippet: 'Please Click Here For More Details',
                // Use custom info window widget
                // Here, we're passing the title and snippet to the custom info window widget
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomInfoWindow(
                        title: '${device['plateNo']}',
                        speed: Text('Speed: ${device['speed']}km/h'),
                        course: Text('Course: ${device['course']}'),
                        battery: Text('Battery: ${device['battery']}V'),
                        statuses: Row(
                          children: [
                            Text('Status: '),
                            Text(
                              '${device['status']}',
                              style: TextStyle(
                                color: device['status'] == '行驶' &&
                                    device['engine'] == 'ON'
                                    ? Colors.green
                                    : device['status'] == '静止' &&
                                    device['engine'] == 'ON'
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        status: device['status'],
                        engine: device['engine'],
                      );
                    },
                  );
                },
              ),
            ),
          );
        }

        setState(() {
          isLoading = false;
        });

        // Update markers on the map
        if (_controller.isCompleted) {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(double.parse(filteredList[randomIndex]['lat']),
                  double.parse(filteredList[randomIndex]['lng'])),
              14.0));
        }
        setState(() {});
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error appropriately, such as showing a snackbar or retry button
    }
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    // _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? CircularProgressIndicator():RefreshIndicator(
      onRefresh: () async {
        await init();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of(markers),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    color: Colors.white, // Set the background color
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by plate number...',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              String searchText = searchController.text;
                              // Call a method to handle search
                              searchVehicle(searchText);
                            },
                          ),
                        ),
                        onChanged: (String searchText) {
                          // Call search function whenever text changes
                          searchVehicle(searchText);
                        },
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedContent = 'all';
                            fetchDataAndUpdateMarkers();
                          });
                        },
                        child: Text('All - $totalVehicle', style: TextStyle(color: selectedContent == 'all' || selectedContent == ' ' ? Colors.white : Colors.black),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedContent == 'all' || selectedContent == ' ' ? Colors.amber : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(0.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(0.0),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Update the content based on the "Dashboard" button press
                              selectedContent = 'travel';
                              fetchDataAndUpdateMarkers();
                            });
                          },
                          child: Text('Travel - $travelVehicle', style: TextStyle(color: selectedContent == 'travel' ? Colors.white : Colors.black),),
                          style:ElevatedButton.styleFrom(backgroundColor: selectedContent == 'travel' ? Colors.green : Colors.white, elevation: 0,shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0), // Adjust as needed
                              topRight: Radius.circular(0.0), // Set to 0 for a sharp corner
                              bottomLeft: Radius.circular(0.0), // Set to 0 for a sharp corner
                              bottomRight: Radius.circular(0.0), // Adjust as needed
                            ),
                          ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Update the content based on the "Dashboard" button press
                              selectedContent = 'idle';
                              fetchDataAndUpdateMarkers();
                            });
                          },
                          child: Text('Idle - $idleVehicle', style: TextStyle(color: selectedContent == 'idle' ? Colors.white : Colors.black),),
                          style:ElevatedButton.styleFrom(backgroundColor: selectedContent == 'idle' ? Colors.blue : Colors.white, elevation: 0, shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0), // Adjust as needed
                              topRight: Radius.circular(0.0), // Set to 0 for a sharp corner
                              bottomLeft: Radius.circular(0.0), // Set to 0 for a sharp corner
                              bottomRight: Radius.circular(0.0), // Adjust as needed
                            ),
                          ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Update the content based on the "Dashboard" button press
                              selectedContent = 'stop';
                              fetchDataAndUpdateMarkers();
                            });
                          },
                          child: Text('Stop - $stopVehicle', style: TextStyle(color: selectedContent == 'stop' ? Colors.white : Colors.black),),
                          style:ElevatedButton.styleFrom(backgroundColor: selectedContent == 'stop' ? Colors.red : Colors.white, elevation: 0, shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0), // Adjust as needed
                              topRight: Radius.circular(8.0), // Set to 0 for a sharp corner
                              bottomLeft: Radius.circular(0.0), // Set to 0 for a sharp corner
                              bottomRight: Radius.circular(8.0), // Adjust as needed
                            ),
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define a custom info window widget
class CustomInfoWindow extends StatelessWidget {
  final String title;
  Widget speed;
  Widget course;
  Widget battery;
  Widget statuses;
  final String status;
  final String engine;

  CustomInfoWindow({required this.title, required this.speed,required this.course,required this.battery,required this.statuses, required this.status, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Adjust the width as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Container(
                  width: 100, // Adjust width as needed
                  height: 50, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: getColorFromStatusAndEngine(status, engine), // Set color based on status
                    borderRadius: BorderRadius.circular(10.0), // Set rounded corner radius
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            speed,
            course,
            battery,
            statuses
          ],
        ),
      ),
    );
  }
}

Color getColorFromStatusAndEngine(String status, String engine) {
  switch (status) {
    case '行驶':
      return Colors.green;
    case '静止':
      switch (engine) {
        case 'ON':
          return Colors.blue;
        case 'OFF':
          return Colors.red;
        default:
          return Colors.grey;
      }
    default:
      return Colors.grey;
  }
}