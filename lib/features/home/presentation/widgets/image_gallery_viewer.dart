import 'package:flutter/material.dart';

class ImageGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const ImageGalleryViewer({super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${_index + 1}/${widget.imageUrls.length}', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, i) {
              final url = widget.imageUrls[i];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
