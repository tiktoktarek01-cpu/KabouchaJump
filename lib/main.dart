import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
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
    final outDir = await getTemporaryDirectory();
    final outPath = '${outDir.path}/jump_${DateTime.now().millisecondsSinceEpoch}.mp4';
    
    // سطر القفزة السحري: 6ث فيديو و 5.5ث صوت
    final cmd = '-i "${res.files.single.path}" -vf "trim=0:6,scale=1080:1920" -af "atrim=0:5.5,apad=pad_dur=0.5" -c:v h264_mediacodec -t 6 -y "$outPath"';
    
    await FFmpegKit.execute(cmd).then((session) async {
      if (await session.getReturnCode().isSuccess()) {
        await GallerySaver.saveVideo(outPath);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ القفزة واجدة في الغاليري!')));
      }
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.all(20)),
          onPressed: _loading ? null : _process,
          child: Text(_loading ? 'جاري الصنع...' : 'صنع قفزة كبوشة 🚀', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }
}
