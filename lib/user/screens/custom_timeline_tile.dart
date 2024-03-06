import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:yes_tracker/user/screens/ViewDeliveryDetails.dart';

import '../../main/utils/Colors.dart';

import '../../main/components/BodyCornerWidget.dart';

class CustomTimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String location;
  final String createdAt;
  final String id;

  CustomTimelineTile({
    Key? key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.location,
    required this.createdAt,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tileColor = (isPast && !isLast) ? colorPrimary : Colors.deepPurple; // Calculate the tile color

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 40,
        color: tileColor,
        iconStyle: IconStyle(
          iconData: Icons.done,
          color: (isPast && !isLast) ? Colors.white : tileColor, // Use tileColor for icon color
        ),
      ),
      beforeLineStyle: LineStyle(
        color: tileColor,
        thickness: 2,
      ),
      endChild: EventCard(
        isPast: isPast,
        location: location,
        createdAt: createdAt,
        id: id,
        tileColor: tileColor, // Pass the tileColor to the EventCard
      ),
    );
  }
}



class EventCard extends StatelessWidget {
  final bool isPast;
  final String location;
  final String createdAt;
  final String id;
  final Color tileColor;

  EventCard({
    Key? key,
    required this.isPast,
    required this.location,
    required this.createdAt,
    required this.id,
    required this.tileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible( // Wrap location with Flexible to allow it to take remaining space
            child: Text(_formatCreatedAt(createdAt), style: TextStyle(color: Colors.white)),
          ),
          8.height, // Add spacing
          Row( // Use Row to keep the icon and text on the same line
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 20), // Location icon
              8.width, // Add spacing between icon and text
              Flexible( // Wrap the text with Flexible to allow it to take remaining space
                child: Text(
                  location,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          8.height,
          Container( // Use a Container to handle any overflow
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewDeliveryDetails(id: id),
                  ),
                );
              },
              child: Text(
                "View Details >",
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(String createdAt) {
    final dateTime = DateTime.parse(createdAt);
    final formattedDate = DateFormat('hh:mma dd MMM yyyy').format(dateTime);
    return formattedDate;
  }
}


