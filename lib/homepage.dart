
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:humble/checkout.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentLocationMessage;
  String? _backSlideLocationMessage;
  double _sliderPosition = 0.0;
  double _maxWidth = 0.0;
  bool _isSliderActive = false;
  Set<int> selectedIndices = {};
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());

  void _onSlide(double deltaX, double startPosition, double endPosition) {
    setState(() {
      _sliderPosition += deltaX;
      // Clamping slider position within the start and end bounds
      _sliderPosition = _sliderPosition.clamp(startPosition, endPosition);
    });
  }

  void _onSlideEnd(double startPosition, double endPosition) {
    setState(() {
      if (_sliderPosition > endPosition / 2) {
        // Lock slider at the end position
        _sliderPosition = endPosition;
        _isSliderActive = true;
        _fetchCurrentLocation();

        // Navigate to the next page when the slide is completed
      } else {
        // Reset slider to start position
        _sliderPosition = endPosition;
        _isSliderActive = false;
        _fetchBackSlideLocation();
        _navigateToNextPage();
      }
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocationMessage = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocationMessage = "Location permission denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationMessage =
              "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String currentTime = DateFormat('hh:mm a').format(DateTime.now());
        setState(() {
          _currentLocationMessage =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country} at $currentTime";
        });
      }
    } catch (e) {
      setState(() {
        _currentLocationMessage = "Error fetching location: $e";
      });
    }
  }

  Future<void> _fetchBackSlideLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _backSlideLocationMessage = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _backSlideLocationMessage = "Location permission denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _backSlideLocationMessage =
              "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String currentTime = DateFormat('hh:mm a').format(DateTime.now());
        setState(() {
          _backSlideLocationMessage =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country} at $currentTime";
        });
      }
    } catch (e) {
      setState(() {
        _backSlideLocationMessage = "Error fetching location: $e";
      });
    }
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmCheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildHeader(),
              const SizedBox(height: 24),
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildAttendanceSection(),
              const SizedBox(height: 24),
              _buildActivitySection(),
              SizedBox(
                height: 24,
              ),
              _buildSliderButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Athul Anil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Floor Manager',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Switch(
              value: false,
              onChanged: null,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isSelected = index == 3;
          return DateItem(
            day: (index + 3).toString().padLeft(2, '0'),
            weekDay: _getWeekDay(index),
            isSelected: isSelected,
          );
        },
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: AttendanceCard(
                title: 'Check In',
                time: '05:00 am',
                subtitle: 'In Time',
                icon: Icons.login,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AttendanceCard(
                title: 'Check Out',
                time: currentTime,
                subtitle: 'GoTime',
                icon: Icons.logout,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: AttendanceCard(
                title: 'Break Time',
                time: '00:45 min',
                subtitle: 'Avg Time',
                icon: Icons.timer,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AttendanceCard(
                title: 'Total Days',
                time: '28',
                subtitle: 'Working Days',
                icon: Icons.calendar_today,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          Column(
            children: [
              const ActivityItem(
                title: 'Check In',
                subtitle: 'June 2024',
                time: '05:00 am',
                status: 'On Time',
                icon: Icons.login,
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(Icons.add_location_alt_outlined),
              Text(
                _currentLocationMessage ?? 'Check In Location.',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          const ActivityItem(
            title: 'Check Out',
            subtitle: 'June 2024',
            time: '05:00 pm',
            status: 'On Time',
            icon: Icons.logout,
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(Icons.add_location_alt_outlined),
              Text(
                _backSlideLocationMessage ?? 'Check Out Location.',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth - 100;
        double startPosition = containerWidth * 0.02;
        double endPosition = containerWidth * 0.98;

        Color containerColor = _sliderPosition >= endPosition
            ? const Color.fromARGB(255, 255, 66, 66)
            : Colors.blue;

        String containerText = _sliderPosition >= endPosition
            ? 'Slide to Check Out'
            : 'Slide to Check In';

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
                    _isSliderActive ? 'Check Out' : 'Check In',
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

  String _getWeekDay(int index) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekDays[index % 7];
  }
}

class DateItem extends StatefulWidget {
  final String day;
  final String weekDay;
  final bool isSelected;

  const DateItem({
    Key? key,
    required this.day,
    required this.weekDay,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<DateItem> createState() => _DateItemState();
}

class _DateItemState extends State<DateItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: widget.isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.day,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.weekDay,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

 class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final String subtitle;
  final IconData icon;

  const AttendanceCard({
    Key? key,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final IconData icon;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


