import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/images/image_policy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';

class ProductGalleryScreen extends StatefulWidget {
  const ProductGalleryScreen({
    required this.images,
    required this.title,
    required this.initialPage,
    super.key,
  });
  final List<String> images;
  final String title;
  final int initialPage;
  @override
  State<ProductGalleryScreen> createState() => _ProductGalleryScreenState();
}

class _ProductGalleryScreenState extends State<ProductGalleryScreen> {
  late final PageController _controller;
  late int _page;
  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.gallery),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpace.page),
          child: Center(
            child: Semantics(
              label: context.l10n.imagePosition(
                _page + 1,
                widget.images.length,
              ),
              child: ExcludeSemantics(
                child: Text(
                  '${_page + 1} / ${widget.images.length}',
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => PhotoViewGallery.builder(
        pageController: _controller,
        onPageChanged: (index) => setState(() => _page = index),
        itemCount: widget.images.length,
        backgroundDecoration: const BoxDecoration(color: AppColors.canvas),
        builder: (_, index) => PhotoViewGalleryPageOptions.customChild(
          childSize: constraints.biggest,
          initialScale: 1.0,
          minScale: 1.0,
          maxScale: ImagePolicy.galleryMaxZoom,
          child: AppNetworkImage(
            url: widget.images[index],
            label: widget.title,
            resolutionScale: ImagePolicy.galleryScale,
          ),
        ),
      ),
    ),
  );
}
