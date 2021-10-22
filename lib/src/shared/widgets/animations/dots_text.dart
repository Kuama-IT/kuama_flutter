import 'package:flutter/material.dart';

/// Displays a series of dots [text] multiplying at each [interval] starting from [min] and
/// reaching a [max] value
///
/// https://drive.google.com/file/d/1xn2Mk-v5OKffb5zkCYc5n6sK0pMEooDC
class DotsText extends StatefulWidget {
  /// Time interval between one dot and another
  final Duration interval;

  /// Maximum number of dots
  final int max;

  /// Minimum number of dots
  final int min;

  /// [Text.style]
  final TextStyle? style;

  /// [Text.textAlign]
  final TextAlign? textAlign;

  /// The dot, you can replace it with any other test
  final String text;

  const DotsText({
    Key? key,
    this.interval = const Duration(milliseconds: 300),
    this.max = 3,
    this.min = 1,
    this.style,
    this.textAlign,
    this.text = '.',
  })  : assert(max > 0 && max > min,
            'The maximum($max) must be greater than zero and the minimum($min)'),
        assert(min >= 0, 'The minimum($min) cannot be negative'),
        super(key: key);

  @override
  State<DotsText> createState() => _DotsTextState();
}

class _DotsTextState extends State<DotsText> {
  late int _i;

  @override
  void initState() {
    super.initState();
    _i = widget.min;
    _animate();
  }

  void _animate() async {
    await Future.delayed(widget.interval);
    if (!mounted) return;

    final i = _i + 1;
    setState(() {
      _i = i > widget.max ? widget.min : i;
    });
    _animate();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text * _i,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
