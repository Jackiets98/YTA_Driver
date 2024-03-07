import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String audioUri;

  VoiceMessagePlayer({required this.audioUri});

  @override
  _VoiceMessagePlayerState createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (!_isPlaying) {
      await _audioPlayer.play(UrlSource(widget.audioUri));
      setState(() {
        _isPlaying = true;
      });
    } else {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _isPlaying ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 32.0,
              color: _isPlaying ? Colors.blue : Colors.grey,
            ),
            SizedBox(width: 8.0),
            Text(
              '${_position.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_position.inSeconds.remainder(60)).toString().padLeft(2, '0')}/${_duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}