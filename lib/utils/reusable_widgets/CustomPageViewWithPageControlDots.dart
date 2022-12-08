import 'package:flutter/material.dart';

class CustomPageViewWithPageControlDots extends StatefulWidget {
  final List<Widget> pageContent;
  final double? pageControlDotSize;
  final BoxShape? pageControlDotShape;
  final double? spacing;
  final Color? pageControlDotColorSelected;
  final Color? pageControlDotColorUnSelected;
  final Function(double? pageOffset)? onPageChanged;

  const CustomPageViewWithPageControlDots({
    Key? key,
    required this.pageContent,
    this.pageControlDotSize,
    this.pageControlDotShape,
    this.spacing,
    this.pageControlDotColorSelected,
    this.pageControlDotColorUnSelected,
    this.onPageChanged,
  }) : super(key: key);

  @override
  _CustomPageViewWithPageControlDotsState createState() =>
      _CustomPageViewWithPageControlDotsState();
}

class _CustomPageViewWithPageControlDotsState
    extends State<CustomPageViewWithPageControlDots>
    with TickerProviderStateMixin {
  // CONTROLLERS
  PageController? _pageController;

  // UI PROPERTIES
  double? _pageOffset;
  double? _pageControlDotSize;
  double? _spacing;
  late int _itemCount;
  BoxShape? _pageControlDotShape;
  Color? _pageControlDotColor;

  // METHODS

  /// SETS UI PROPERTIES TO DEFAULTS
  void _setDefaults() {
    _pageOffset = 0.0;
    _pageControlDotSize = widget.pageControlDotSize ?? 12.0;
    _spacing = widget.spacing ?? 5.0;
    _itemCount = widget.pageContent.length;
    _pageControlDotShape = widget.pageControlDotShape ?? BoxShape.rectangle;
    _pageControlDotColor = widget.pageControlDotColorSelected ?? Colors.black;
  }

  // OVERRIDDEN METHODS
  @override
  void initState() {
    _setDefaults();
    _pageController = PageController();
    _pageController?.addListener(() {
      setState(() {
        _pageOffset = _pageController?.page;
      });
      (widget.onPageChanged ?? () {})(_pageOffset);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView.builder(
          itemCount: _itemCount,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: widget.pageContent[index],
            );
          },
        ),
        Container(
          alignment: Alignment.bottomCenter,
          width: (_itemCount * (_pageControlDotSize ?? 0.0)) +
              (_itemCount * (_spacing ?? 0.0)),
          child: _itemCount > 1
              ? Wrap(
                  spacing: 2.0,
                  children: <Widget>[]..addAll(
                      List<Widget>.generate(
                        _itemCount,
                        (int index) {
                          //todo Check What To Return
                          return Container();
                        },
                      ),
                    ),
                )
              : null,
        ),
      ],
    );
  }
}
