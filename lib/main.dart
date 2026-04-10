import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: KabouchaJump(), debugShowCheckedModeBanner: false));

class KabouchaJump extends StatefulWidget {
  @override
  _KabouchaJumpState createState() => _KabouchaJumpState();
}

class _KabouchaJumpState extends State<KabouchaJump> {
  bool _loading = false;

  Future<void> _process() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res == null) return;
    
    setState(() => _loading = true);
    
    try {
      final outDir = await getTemporaryDirectory();
      final outPath = '${outDir.path}/jump_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      final cmd = '-i "${res.files.single.path}" -vf "trim=0:6,scale=1080:1920" -af "atrim=0:5.5,apad=pad_dur=0.5" -c:v h264_mediacodec -t 6 -y "$outPath"';
      
      await FFmpegKit.execute(cmd).then((session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          await GallerySaver.saveVideo(outPath);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video Saved to Gallery!')));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Processing Video')));
          }
        }
        if (mounted) setState(() => _loading = false);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _loading 
          ? CircularProgressIndicator(color: Colors.orange)
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, 
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20)
              ),
              onPressed: _process,
              child: Text('CREATE JUMP 🚀', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
      ),
    );
  }
}
