import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math;

enum CircularStrokeCap { butt, round, square }

class CircularPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double radius;

  ///Width of the line of the Circle
  final double lineWidth;

  ///Color of the background of the circle , default = transparent
  final Color fillColor;

  ///First color applied to the complete circle
  final Color backgroundColor;
  final Color progressColor;

  ///true if you want the circle to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the top of the circle
  final Widget? header;

  ///widget at the bottom of the circle
  final Widget? footer;

  ///widget inside the circle
  final Widget? center;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, square
  final CircularStrokeCap? circularStrokeCap;

  ///the angle which the circle will start the progress (in degrees, eg: 0.0, 45.0, 90.0)
  final double startAngle;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  CircularPercentIndicator({
    Key? key,
    this.percent = 0.0,
    this.lineWidth = 5.0,
    this.startAngle = 0.0,
    required this.radius,
    this.fillColor = Colors.transparent,
    this.backgroundColor = const Color(0xFFB8C7CB),
    this.progressColor = Colors.red,
    this.animation = false,
    this.animationDuration = 500,
    this.header,
    this.footer,
    this.center,
    this.circularStrokeCap,
    this.animateFromLastPercent = false,
  }) : super(key: key) {
    assert(startAngle >= 0.0);
    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }
  }

  @override
  _CircularPercentIndicatorState createState() =>
      _CircularPercentIndicatorState();
}

class _CircularPercentIndicatorState extends State<CircularPercentIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation =
          Tween(begin: 0.0, end: widget.percent).animate(_animationController!)
            ..addListener(() {
              setState(() {
                _percent = _animation?.value;
              });
            });
      _animationController?.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(CircularPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent ||
        oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animation = Tween(
                begin: widget.animateFromLastPercent &&
                        oldWidget.percent < widget.percent
                    ? oldWidget.percent
                    : 0.0,
                end: widget.percent)
            .animate(_animationController!);
        _animationController?.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (widget.header != null) {
      items.add(widget.header!);
    }
    items.add(
      Container(
        height: widget.radius + widget.lineWidth,
        width: widget.radius,
        child: CustomPaint(
          painter: CirclePainter(
            progress: _percent * 360,
            progressColor: widget.progressColor,
            backgroundColor: widget.backgroundColor,
            startAngle: widget.startAngle,
            circularStrokeCap: widget.circularStrokeCap,
            radius: (widget.radius / 2) - widget.lineWidth / 2,
            lineWidth: widget.lineWidth,
          ),
          child: (widget.center != null)
              ? Center(child: widget.center)
              : Container(),
        ),
      ),
    );

    if (widget.footer != null) {
      items.add(widget.footer!);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: items,
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final lineWidth;
  final progress;
  final radius;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap? circularStrokeCap;
  final double startAngle;

  CirclePainter(
      {this.lineWidth,
      this.progress,
      required this.radius,
      required this.progressColor,
      required this.backgroundColor,
      this.startAngle = 0.0,
      this.circularStrokeCap = CircularStrokeCap.round}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = lineWidth;

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, _paintBackground);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.radians(-90.0 + startAngle),
        math.radians(progress),
        false,
        _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
