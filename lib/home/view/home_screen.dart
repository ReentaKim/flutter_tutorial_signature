import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? signature;
  final controller = SignatureController(
    penColor: Colors.white,
    penStrokeWidth: 3,
    exportPenColor: Colors.red,
    exportBackgroundColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Signature Package Flutter',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Signature(
              controller: controller,
              width: double.infinity,
              height: 200,
              backgroundColor: Colors.black,
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    controller.undo();
                  },
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    controller.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    controller.redo();
                  },
                  icon: const Icon(Icons.redo),
                  label: const Text('Redo'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    signature = await controller.toPngBytes();
                    setState(() {});
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    signature = await controller.toPngBytes();
                    setState(() {});
                    if (signature != null) {
                      // 웹과 모바일을 구분하여 처리
                      if (kIsWeb) {
                        final blob = html.Blob([signature!]);
                        final url = html.Url.createObjectUrlFromBlob(blob);
                        final anchor = html.AnchorElement(href: url)
                          ..setAttribute("download", "signature.png")
                          ..click();
                        html.Url.revokeObjectUrl(url);
                      } else {
                        final status = await Permission.storage.status;
                        if (!status.isGranted || status.isDenied || status.isPermanentlyDenied) {
                          await Permission.storage.request();
                        }
                        final time = DateTime.now().toIso8601String().replaceAll('.', ':');
                        final result = await ImageGallerySaver.saveImage(signature!, name: 'signature_$time');
                        debugPrint(result.toString());
                        if (result['isSuccess']) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Signature saved',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                          controller.clear();
                        }
                      }
                    }
                  },
                  child: const Text('Export in Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (signature != null) Image.memory(signature!, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
