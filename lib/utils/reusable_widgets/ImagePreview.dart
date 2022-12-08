import 'package:flutter/material.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl;

  ImagePreview(this.imageUrl);

//  AssetImage("assets/large-image.jpg")
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appThemeColor,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
          child: PhotoViewGallery(
              backgroundDecoration: BoxDecoration(color: Colors.black87),
              pageOptions: <PhotoViewGalleryPageOptions>[
                PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrl),
                  initialScale: PhotoViewComputedScale.contained * 0.98,
                  heroAttributes: PhotoViewHeroAttributes(tag: "tag1"),
                ),
              ]),
        ));
  }
}
