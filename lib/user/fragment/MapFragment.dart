import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main/utils/Constants.dart';


class MapFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  MapFragmentState createState() => MapFragmentState();
}

class MapFragmentState extends State<MapFragment> {
  String selectedContent = "all";
  List<Marker> markers = [];
  MapController _mapController = MapController();
  TextEditingController searchController = TextEditingController();
  int totalVehicle = 0;
  int travelVehicle = 0;
  int idleVehicle = 0;
  int stopVehicle = 0;
  bool isLoading  = false;
  late final SuperclusterMutableController _superclusterController;


  static final _initialCenter = LatLng(5.2632, 100.4846);

  @override
  void initState() {
    super.initState();
    init();
    _superclusterController = SuperclusterMutableController();
    // Start the timer when the widget is initialized
    // _startTimer();
  }

  Future<void> init() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    // Fetch data based on selected content and update markers
    fetchDataAndUpdateMarkers();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _superclusterController.dispose();
  }

  void showDeviceDetails(BuildContext context, Map<String, dynamic> device) {
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
              if(device['status'] == '行驶') Text(
                'Moving',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              if(device['status'] == '静止' && device['engine'] == 'ON') Text(
                'Idle',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              if(device['status'] == '静止' && device['engine'] == 'OFF') Text(
                'Stopped',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              if(device['status'] == '离线' && device['engine'] == 'OFF') Text(
                'Offline',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          status: device['status'],
          engine: device['engine'],
        );
      },
    );
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

        print(filteredList);
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
          Image markerIcon;

          // Determine which icon to use based on the device status or type
          if (selectedContent == 'all') {
            // Add all markers regardless of status
            if (device['status'] == '行驶' && device['engine'] == 'ON') {
              markerIcon = await Image.network(mediaUrl + 'status/green_vehicle/' + device['plateNo'] + '.png');
              travelVehicle++;
            } else if (device['status'] == '静止' && device['engine'] == 'ON') {
              markerIcon = await Image.network(mediaUrl + 'status/blue_vehicle/' + device['plateNo'] + '.png');
              idleVehicle++;
            } else {
              markerIcon = await Image.network(mediaUrl + 'status/red_vehicle/' + device['plateNo'] + '.png');
              stopVehicle++;
            }
          } else if (selectedContent == 'travel') {
            markerIcon = await Image.network(mediaUrl + 'status/green_vehicle/' + device['plateNo'] + '.png');
            travelVehicle++;
          } else if (selectedContent == 'idle' &&
              device['status'] == '静止' && device['engine'] == 'ON') {
            markerIcon = await Image.network(mediaUrl + 'status/blue_vehicle/' + device['plateNo'] + '.png');
            idleVehicle++;
            print(device);
          } else if (selectedContent == 'stop' &&
              device['status'] != '行驶' && device['engine'] == 'OFF') {
            markerIcon = await Image.network(mediaUrl + 'status/red_vehicle/' + device['plateNo'] + '.png');
            stopVehicle++;
          } else {
            // If not matching any condition, continue to next device
            continue;
          }

          print(selectedContent);
          print(markerIcon);

          _superclusterController.replaceAll(markers);
          markers.add(
            Marker(
              builder: (context) => GestureDetector(
                onTap: () {
                  showDeviceDetails(context, device);
                },
                child: markerIcon,
              ),
              width: 80.0,
              height: 80.0,
              point: LatLng(
                double.parse(device['lat']),
                double.parse(device['lng']),
              ),
            ),
          );
        }

        setState(() {
          isLoading = false;
        });

        // Update markers on the map
        _mapController.move(
          LatLng(
            double.parse(filteredList[randomIndex]['lat']),
            double.parse(filteredList[randomIndex]['lng']),
          ),
          14.0,
        );
        // Update markers on the map
        setState(() {});
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error appropriately, such as showing a snackbar or retry button
    }
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
          Image markerIcon;

            final Image movingCarIcon = await Image.network(mediaUrl + 'status/green_vehicle/' + device['plateNo'] + '.png');
            final Image idleCarIcon = await Image.network(mediaUrl + 'status/blue_vehicle/' + device['plateNo'] + '.png');
            final Image stopCarIcon = await Image.network(mediaUrl + 'status/red_vehicle/' + device['plateNo'] + '.png');

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
              builder: (context) => markerIcon,
              width: 80.0,
              height: 80.0,
              point: LatLng(
                double.parse(device['lat']),
                double.parse(device['lng']),
              ),
            ),
          );

          if (!markerFound) {
            markerFound = true;
            _mapController.move(
              LatLng(double.parse(device['lat']), double.parse(device['lng'])),
              14.0,
            );
          }

        }
      }

      // Update markers on the map
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? Center(child: CircularProgressIndicator()):RefreshIndicator(
      onRefresh: () async {
        await init();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _initialCenter,
                zoom: 14,
                minZoom: 5,
                maxZoom: 18
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                SuperclusterLayer.mutable(
                  clusterWidgetSize: Size(40,40),// Replaces MarkerLayer
                  initialMarkers: markers,
                  indexBuilder: IndexBuilders.rootIsolate,
                  controller: _superclusterController,
                  builder: (context, position, markerCount, extraClusterData) =>
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: Text(
                            markerCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                ),
              ],
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
                        child: Text('All - $totalVehicle', style: TextStyle(fontSize: 11,color: selectedContent == 'all' || selectedContent == ' ' ? Colors.white : Colors.black),),
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
                          child: Text('Travel - $travelVehicle', style: TextStyle(fontSize: 11, color: selectedContent == 'travel' ? Colors.white : Colors.black),),
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
                          child: Text('Idle - $idleVehicle', style: TextStyle(fontSize: 11, color: selectedContent == 'idle' ? Colors.white : Colors.black),),
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
                          child: Text('Stop - $stopVehicle', style: TextStyle(fontSize: 11, color: selectedContent == 'stop' ? Colors.white : Colors.black),),
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




