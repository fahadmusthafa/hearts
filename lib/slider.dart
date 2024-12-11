import 'package:flutter/material.dart';

class SliderButton extends StatefulWidget {
  final String checkInText;
  final String checkOutText;
  final Function(bool) onSlideComplete;

  const SliderButton({
    required this.checkInText,
    required this.checkOutText,
    required this.onSlideComplete,
    Key? key,
  }) : super(key: key);

  @override
  _SliderButtonState createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  double _sliderPosition = 0;
  bool _isSliderActive = false;

  void _onSlide(double delta, double startPosition, double endPosition) {
    setState(() {
      _sliderPosition += delta;
      if (_sliderPosition < startPosition) {
        _sliderPosition = startPosition;
      } else if (_sliderPosition > endPosition) {
        _sliderPosition = endPosition;
      }
    });
  }

  void _onSlideEnd(double startPosition, double endPosition) {
    if (_sliderPosition >= endPosition) {
      setState(() {
        _isSliderActive = true;
      });
      widget.onSlideComplete(true);
    } else {
      setState(() {
        _sliderPosition = startPosition;
        _isSliderActive = false;
      });
      widget.onSlideComplete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth - 100;
        double startPosition = containerWidth * 0.02;
        double endPosition = containerWidth * 0.98;

        Color containerColor = _sliderPosition >= endPosition
            ? const Color.fromARGB(255, 255, 66, 66)
            : Colors.blue;

        String containerText = _sliderPosition >= endPosition
            ? widget.checkOutText
            : widget.checkInText;

        return Stack(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  containerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              left: _sliderPosition >= startPosition
                  ? (_sliderPosition <= endPosition
                      ? _sliderPosition
                      : endPosition)
                  : startPosition,
              top: 5,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  _onSlide(
                      details.primaryDelta ?? 0, startPosition, endPosition);
                },
                onHorizontalDragEnd: (_) {
                  _onSlideEnd(startPosition, endPosition);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isSliderActive ? widget.checkOutText : widget.checkInText,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SliderButtonExample extends StatelessWidget {
  const SliderButtonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider Buttons')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SliderButton(
              checkInText: 'Slide to Check In',
              checkOutText: 'Slide to Check Out',
              onSlideComplete: (isCheckedOut) {
                debugPrint(
                    'First button is ${isCheckedOut ? "Checked Out" : "Checked In"}');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SliderButton(
              checkInText: 'Slide to Start Task',
              checkOutText: 'Slide to End Task',
              onSlideComplete: (isCheckedOut) {
                debugPrint(
                    'Second button is ${isCheckedOut ? "Ended" : "Started"}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
