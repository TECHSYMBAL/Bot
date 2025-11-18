import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'analytics.dart';

class DiagonalLinePainter extends CustomPainter {
  final List<double>? dataPoints; // Optional: for real data later

  DiagonalLinePainter({this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = const Color(0xFFE4E4E4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Use real data if provided, otherwise use sample points
    final points = dataPoints ?? _getSamplePoints(size);

    if (points.isEmpty) return;

    // Start the path
    path.moveTo(0, size.height - (points[0] * size.height));

    // Create smooth curve through all points using cubic bezier
    for (int i = 1; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);

      if (i == 1) {
        // First segment: use quadratic curve
        final controlX = x * 0.5;
        final controlY = size.height -
            (points[0] * size.height) * 0.7 -
            (points[i] * size.height) * 0.3;
        path.quadraticBezierTo(controlX, controlY, x, y);
      } else {
        // Subsequent segments: use cubic bezier for smooth transitions
        final prevX = ((i - 1) / (points.length - 1)) * size.width;
        final prevY = size.height - (points[i - 1] * size.height);

        // Control points for smooth curve
        final cp1X = prevX + (x - prevX) * 0.3;
        final cp1Y = prevY;
        final cp2X = prevX + (x - prevX) * 0.7;
        final cp2Y = y;

        path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  // Sample data points for demonstration (normalized 0.0 to 1.0)
  List<double> _getSamplePoints(Size size) {
    return [
      0.1, // Start low
      0.6, // First peak
      0.3, // First valley
      0.2, // Deep dip
      0.7, // Second peak
      0.5, // Descent
      0.9, // Final ascent
    ];
  }

  @override
  bool shouldRepaint(DiagonalLinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Vercel Analytics after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VercelAnalytics.init();
      // Track initial page view
      VercelAnalytics.trackPageView(path: '/', title: 'Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Mini App',
      // Use default theme without Material fonts to avoid loading errors
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Aeroport',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          bodyMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          bodySmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displayLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displayMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          displaySmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          headlineSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          titleSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelLarge: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelMedium: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          labelSmall: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
          hintStyle: TextStyle(
              fontFamily: 'Aeroport',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  bool _isFocused = false;
  bool _isTappingSuggestion = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      // If we're tapping a suggestion, don't update _isFocused state
      // This prevents the UI from hiding suggestions when focus temporarily changes
      if (_isTappingSuggestion) {
        return;
      }
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _controller.addListener(() {
      // Check if text contains newline (Enter was pressed)
      if (_controller.text.contains('\n')) {
        print('Newline detected in text field'); // Debug
        // Remove the newline
        final textWithoutNewline = _controller.text.replaceAll('\n', '');
        _controller.value = TextEditingValue(
          text: textWithoutNewline,
          selection: TextSelection.collapsed(offset: textWithoutNewline.length),
        );
        // Trigger navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToNewPage();
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToNewPage() {
    final text = _controller.text.trim();
    print('_navigateToNewPage called with text: "$text"'); // Debug
    if (text.isNotEmpty) {
      print('Navigating to NewPage with title: "$text"'); // Debug

      // Track question submission event
      VercelAnalytics.trackEvent('question_submitted', properties: {
        'question_length': text.length.toString(),
      });

      // Track page view for response page
      VercelAnalytics.trackPageView(path: '/response', title: 'Response');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPage(title: text),
        ),
      ).then((_) {
        // Clear the text field after navigation
        _controller.clear();
        // Track return to home page
        VercelAnalytics.trackPageView(path: '/', title: 'Home');
      });
    } else {
      print('Text is empty, not navigating'); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            // padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 30, bottom: 15, left: 15, right: 15),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 30,
                    height: 30,
                  ),
                ),
                if (_isFocused)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Listener(
                            onPointerDown: (event) {
                              print('Suggestion 1 pointer down'); // Debug
                              // Set flag immediately to prevent unfocus
                              _isTappingSuggestion = true;
                              // Request focus immediately
                              FocusScope.of(context).requestFocus(_focusNode);
                              // Set text and navigate
                              _controller.text =
                                  'What is my all wallet\'s last month profit';
                              print(
                                  'Text set to: ${_controller.text}'); // Debug
                              // Navigate after a short delay
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (mounted) {
                                  _isTappingSuggestion = false;
                                  _navigateToNewPage();
                                }
                              });
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                child: Text(
                                  'What is my all wallet\'s last month profit',
                                  style: TextStyle(
                                    fontFamily: 'Aeroport',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Listener(
                            onPointerDown: (event) {
                              print('Suggestion 2 pointer down'); // Debug
                              // Set flag immediately to prevent unfocus
                              _isTappingSuggestion = true;
                              // Request focus immediately
                              FocusScope.of(context).requestFocus(_focusNode);
                              // Set text and navigate
                              _controller.text = 'Advise me a token to buy';
                              print(
                                  'Text set to: ${_controller.text}'); // Debug
                              // Navigate after a short delay
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (mounted) {
                                  _isTappingSuggestion = false;
                                  _navigateToNewPage();
                                }
                              });
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                child: Text(
                                  'Advise me a token to buy',
                                  style: TextStyle(
                                    fontFamily: 'Aeroport',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_isFocused)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  const Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('ton/usdt',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Color(0xFF818181),
                                                fontSize: 20,
                                              )),
                                          SizedBox.shrink(),
                                          Text(
                                            '+300.70%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("d"),
                                          SizedBox(width: 15),
                                          Text("h"),
                                          SizedBox(width: 15),
                                          Text("q"),
                                          SizedBox(width: 15),
                                          Text(
                                            "m",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'FDV',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '\$3.1K',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LIQ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '\$1.1K',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'VOL',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '\$3.1K',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'TXNS',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '\$7K',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '1 H',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '+208.13%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '6 H',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '+208.13%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF818181),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: SizedBox.expand(
                                                  child: CustomPaint(
                                                    painter:
                                                        DiagonalLinePainter(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "12.37",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF818181)),
                                                  ),
                                                  Text("14.40",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xFF818181))),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "0.05678",
                                              style: TextStyle(
                                                  color: Color(0xFF818181),
                                                  fontSize: 10),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "0.03678",
                                                  style: TextStyle(
                                                    color: Color(0xFF818181),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 0, left: 15, right: 15),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Sell',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF818181),
                                      fontSize: 20,
                                    )),
                                SizedBox(
                                  height: 20,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Image.asset('assets/sample/1.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/2.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/3.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/4.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/5.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Color(0xFFE4E4E4),
                                    )),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/sample/usdt.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain),
                                    const SizedBox(width: 8),
                                    const Text('usdt',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFFE4E4E4),
                                          fontSize: 20,
                                        )),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icons/select.svg',
                                      width: 5,
                                      height: 10,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFFE4E4E4),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r'$1',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFF818181),
                                      )),
                                  Text('On TON',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFF818181),
                                      )),
                                ]),
                          ]),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                          child: SvgPicture.asset(
                            'assets/icons/rotate.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                              top: 0, bottom: 0, left: 15, right: 15),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Buy',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF818181),
                                      fontSize: 20,
                                    )),
                                SizedBox(
                                  height: 20,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Image.asset('assets/sample/1.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/2.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/3.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/4.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 5),
                                        Image.asset('assets/sample/5.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Color(0xFFE4E4E4),
                                    )),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/sample/ton.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain),
                                    const SizedBox(width: 8),
                                    const Text('ton',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFFE4E4E4),
                                          fontSize: 20,
                                        )),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icons/select.svg',
                                      width: 5,
                                      height: 10,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFFE4E4E4),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r'$1',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFF818181),
                                      )),
                                  Text('On TON',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFF818181),
                                      )),
                                ]),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 0, left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/connect.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFE4E4E4),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const SizedBox(
                                        height: 20,
                                        child: Center(
                                          child: Text(
                                            'Connect',
                                            style: TextStyle(
                                              color: Color(0xFFE4E4E4),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/create.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFE4E4E4),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const SizedBox(
                                        height: 20,
                                        child: Center(
                                          child: Text(
                                            'Create',
                                            style: TextStyle(
                                              color: Color(0xFFE4E4E4),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/import.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFE4E4E4),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const SizedBox(
                                        height: 20,
                                        child: Center(
                                          child: Text(
                                            'Import',
                                            style: TextStyle(
                                              color: Color(0xFFE4E4E4),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Center(
                                child: Text(
                                  'wallet',
                                  style: TextStyle(
                                    color: Color(0xFF818181),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 30, left: 15, right: 15),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 30),
                          child: _controller.text.isEmpty
                              ? SizedBox(
                                  height: 30,
                                  child: TextField(
                                    key: _textFieldKey,
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    enabled: true,
                                    readOnly: false,
                                    cursorColor: const Color(0xFFE4E4E4),
                                    cursorHeight: 15,
                                    maxLines: 11,
                                    minLines: 1,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                        fontFamily: 'Aeroport',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 2.0,
                                        color: Color(0xFFE4E4E4)),
                                    onSubmitted: (value) {
                                      print(
                                          'TextField onSubmitted called with: "$value"'); // Debug
                                      _navigateToNewPage();
                                    },
                                    onChanged: (value) {
                                      print(
                                          'TextField onChanged called with: "$value"'); // Debug
                                    },
                                    decoration: InputDecoration(
                                      hintText: (_isFocused ||
                                              _controller.text.isNotEmpty)
                                          ? null
                                          : 'Ask anything',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFFE4E4E4),
                                          fontFamily: 'Aeroport',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          height: 2.0),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: !_isFocused
                                          ? const EdgeInsets.only(
                                              left: 0,
                                              right: 0,
                                              top: 5,
                                              bottom: 5)
                                          : const EdgeInsets.only(right: 0),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextField(
                                    key: _textFieldKey,
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    enabled: true,
                                    readOnly: false,
                                    cursorColor: const Color(0xFFE4E4E4),
                                    cursorHeight: 15,
                                    maxLines: 11,
                                    minLines: 1,
                                    textAlignVertical:
                                        _controller.text.split('\n').length == 1
                                            ? TextAlignVertical.center
                                            : TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontFamily: 'Aeroport',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 2,
                                        color: Color(0xFFE4E4E4)),
                                    onSubmitted: (value) {
                                      print(
                                          'TextField onSubmitted called with: "$value"'); // Debug
                                      _navigateToNewPage();
                                    },
                                    onChanged: (value) {
                                      print(
                                          'TextField onChanged called with: "$value"'); // Debug
                                    },
                                    decoration: InputDecoration(
                                      hintText: (_isFocused ||
                                              _controller.text.isNotEmpty)
                                          ? null
                                          : 'Ask anything',
                                      hintStyle: const TextStyle(
                                          color: Color(0xFFE4E4E4),
                                          fontFamily: 'Aeroport',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          height: 2),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          _controller.text.split('\n').length >
                                                  1
                                              ? const EdgeInsets.only(
                                                  left: 0, right: 0, top: 11)
                                              : const EdgeInsets.only(right: 0),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          print('Apply button tapped'); // Debug
                          _navigateToNewPage();
                        },
                        child: SvgPicture.asset(
                          'assets/icons/apply.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewPage extends StatefulWidget {
  final String title;

  const NewPage({super.key, required this.title});

  @override
  State<NewPage> createState() => _NewPageState();
}

class QAPair {
  final String question;
  String? response;
  bool isLoading;
  String? error;
  AnimationController? dotsController;

  QAPair({
    required this.question,
    this.response,
    this.isLoading = true,
    this.error,
    this.dotsController,
  });
}

class _NewPageState extends State<NewPage> with TickerProviderStateMixin {
  // List to store all Q&A pairs
  final List<QAPair> _qaPairs = [];
  final String _apiUrl = 'https://xp7k-production.up.railway.app';
  late AnimationController _dotsController;

  // Input field controllers
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final GlobalKey _inputTextFieldKey = GlobalKey();
  bool _isInputFocused = false;

  // Scroll controller for auto-scrolling to new responses
  final ScrollController _scrollController = ScrollController();

  // Track if auto-scrolling is enabled (disabled when user manually scrolls)
  bool _autoScrollEnabled = true;

  // Scroll progress for custom scrollbar
  double _scrollProgress = 0.0;
  double _scrollIndicatorHeight = 1.0;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    // Listen to scroll changes to detect manual scrolling and update scrollbar
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        final maxScroll = position.maxScrollExtent;
        final currentScroll = position.pixels;
        final viewportHeight = position.viewportDimension;
        final totalHeight = viewportHeight + maxScroll;

        // Update scrollbar
        if (maxScroll > 0 && totalHeight > 0) {
          final indicatorHeight =
              (viewportHeight / totalHeight).clamp(0.0, 1.0);
          final scrollPosition = (currentScroll / maxScroll).clamp(0.0, 1.0);
          setState(() {
            _scrollIndicatorHeight = indicatorHeight;
            _scrollProgress = scrollPosition;
          });
        } else {
          setState(() {
            _scrollProgress = 0.0;
            _scrollIndicatorHeight = 1.0;
          });
        }

        // If user is near the bottom (within 50px), re-enable auto-scroll
        // Otherwise, disable auto-scroll if user scrolled up
        if (maxScroll > 0) {
          final distanceFromBottom = maxScroll - currentScroll;
          if (distanceFromBottom < 50) {
            // User is near bottom, enable auto-scroll
            // Also check if any response is still loading/streaming
            final hasLoadingContent = _qaPairs.any((pair) => pair.isLoading);
            if (!_autoScrollEnabled || hasLoadingContent) {
              setState(() {
                _autoScrollEnabled = true;
              });
              // If content is still streaming and user is at bottom, scroll immediately
              if (hasLoadingContent) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    final currentMaxScroll =
                        _scrollController.position.maxScrollExtent;
                    if (currentMaxScroll > 0) {
                      _scrollController.animateTo(
                        currentMaxScroll,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                });
              }
            }
          } else if (distanceFromBottom > 100) {
            // User scrolled up significantly, disable auto-scroll
            if (_autoScrollEnabled) {
              setState(() {
                _autoScrollEnabled = false;
              });
            }
          }
        }
      }
    });

    _inputController.addListener(() {
      // Check if text contains newline (Enter was pressed)
      if (_inputController.text.contains('\n')) {
        final textWithoutNewline = _inputController.text.replaceAll('\n', '');
        _inputController.value = TextEditingValue(
          text: textWithoutNewline,
          selection: TextSelection.collapsed(offset: textWithoutNewline.length),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _askNewQuestion();
        });
      }
      setState(() {});
    });
    // Add initial Q&A pair with the title
    setState(() {
      _qaPairs.add(QAPair(
        question: widget.title,
        isLoading: true,
        dotsController: _dotsController,
      ));
    });
    // Fetch response after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _qaPairs.isNotEmpty) {
        _fetchAIResponse(_qaPairs.last);
      }
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    // Dispose all animation controllers
    for (var pair in _qaPairs) {
      pair.dotsController?.dispose();
    }
    super.dispose();
  }

  void _askNewQuestion() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      // Clear input
      _inputController.clear();

      // Create new animation controller for this Q&A pair
      final newDotsController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat();

      // Add new Q&A pair at the end (bottom of the list)
      final newPair = QAPair(
        question: text,
        isLoading: true,
        dotsController: newDotsController,
      );
      setState(() {
        _qaPairs.add(newPair);
      });

      // Fetch AI response for the new question
      _fetchAIResponse(newPair);

      // Scroll to bottom after a short delay, only if auto-scroll is enabled
      if (_autoScrollEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            if (maxScroll > 0) {
              _scrollController.animateTo(
                maxScroll,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        });
      }
    }
  }

  Future<void> _fetchAIResponse(QAPair pair) async {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_apiUrl/api/chat'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'message': pair.question});

      final client = http.Client();
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        String accumulatedResponse = '';
        String? finalResponse;
        String buffer = ''; // Buffer for incomplete lines

        // Process the stream line by line as it arrives
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;
          final lines = buffer.split('\n');

          // Keep the last incomplete line in buffer
          if (lines.isNotEmpty) {
            buffer = lines.removeLast();
          } else {
            buffer = '';
          }

          for (final line in lines) {
            if (line.trim().isEmpty) continue;
            try {
              final data = jsonDecode(line);

              // Check for final complete response
              if (data['response'] != null && data['done'] == true) {
                finalResponse = data['response'] as String;
                // Update with final complete response
                if (mounted) {
                  setState(() {
                    pair.response = finalResponse;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                }
              }
              // Process tokens as they arrive (for streaming effect)
              else if (data['token'] != null) {
                accumulatedResponse += data['token'] as String;
                // Update UI immediately with each token (streaming effect)
                if (mounted && finalResponse == null) {
                  setState(() {
                    pair.response = accumulatedResponse;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                  // Auto-scroll to bottom as response streams in, only if auto-scroll is enabled
                  if (_autoScrollEnabled) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        final maxScroll =
                            _scrollController.position.maxScrollExtent;
                        if (maxScroll > 0) {
                          _scrollController.animateTo(
                            maxScroll,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                    });
                  }
                }
              }
              // Check for errors
              else if (data['error'] != null) {
                if (mounted) {
                  setState(() {
                    pair.error = data['error'] as String;
                    pair.isLoading = false;
                    pair.dotsController?.stop();
                  });
                }
                client.close();
                return;
              }
            } catch (e) {
              // Skip invalid JSON lines (might be partial chunks)
              continue;
            }
          }
        }

        // Process any remaining buffer content
        if (buffer.trim().isNotEmpty) {
          try {
            final data = jsonDecode(buffer);
            if (data['response'] != null && data['done'] == true) {
              finalResponse = data['response'] as String;
            } else if (data['token'] != null) {
              accumulatedResponse += data['token'] as String;
            }
          } catch (e) {
            // Ignore parse errors for buffer
          }
        }

        // Use final response if available, otherwise use accumulated
        if (mounted && finalResponse != null) {
          setState(() {
            pair.response = finalResponse;
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
          // Scroll to bottom when response is complete, only if auto-scroll is enabled
          if (_autoScrollEnabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                if (maxScroll > 0) {
                  _scrollController.animateTo(
                    maxScroll,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          }
        } else if (mounted &&
            accumulatedResponse.isNotEmpty &&
            pair.response == null) {
          setState(() {
            pair.response = accumulatedResponse;
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
          // Scroll to bottom when response is complete, only if auto-scroll is enabled
          if (_autoScrollEnabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                if (maxScroll > 0) {
                  _scrollController.animateTo(
                    maxScroll,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          }
        }

        client.close();
      } else {
        if (mounted) {
          setState(() {
            pair.error = 'Error: ${streamedResponse.statusCode}';
            pair.isLoading = false;
            pair.dotsController?.stop();
          });
        }
        client.close();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          pair.error = 'Failed to connect: $e';
          pair.isLoading = false;
          pair.dotsController?.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(0.0),
          thumbVisibility: WidgetStateProperty.all(false),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              //padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            reverse: false,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: _qaPairs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final pair = entry.value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Question
                                      Text(
                                        pair.question,
                                        style: const TextStyle(
                                          fontFamily: 'Aeroport',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFE4E4E4),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 16),
                                      // Response (loading, error, or content)
                                      if (pair.isLoading &&
                                          pair.dotsController != null)
                                        AnimatedBuilder(
                                          animation: pair.dotsController!,
                                          builder: (context, child) {
                                            final progress =
                                                pair.dotsController!.value;
                                            int dotCount = 1;
                                            if (progress < 0.33) {
                                              dotCount = 1;
                                            } else if (progress < 0.66) {
                                              dotCount = 2;
                                            } else {
                                              dotCount = 3;
                                            }
                                            return Text(
                                              '·' * dotCount,
                                              style: const TextStyle(
                                                fontFamily: 'Aeroport',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFE4E4E4),
                                              ),
                                              textAlign: TextAlign.left,
                                            );
                                          },
                                        )
                                      else if (pair.error != null)
                                        Text(
                                          pair.error!,
                                          style: const TextStyle(
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red,
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      else if (pair.response != null)
                                        Text(
                                          pair.response!,
                                          style: const TextStyle(
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFE4E4E4),
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      else
                                        const Text(
                                          'No response received',
                                          style: TextStyle(
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFE4E4E4),
                                          ),
                                        ),
                                      // Add spacing between Q&A pairs (except for the last one in reversed list)
                                      if (index < _qaPairs.length - 1)
                                        const SizedBox(height: 32),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Custom scrollbar - always visible on mobile
                        // Position it as a separate row item to ensure it's always in viewport
                        SizedBox(
                          width: 1.0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Check for valid constraints and scroll controller
                              if (!_scrollController.hasClients ||
                                  constraints.maxHeight == double.infinity ||
                                  constraints.maxHeight <= 0) {
                                return const SizedBox.shrink();
                              }

                              try {
                                final maxScroll =
                                    _scrollController.position.maxScrollExtent;
                                if (maxScroll <= 0) {
                                  return const SizedBox.shrink();
                                }

                                final containerHeight = constraints.maxHeight;
                                final indicatorHeight =
                                    (containerHeight * _scrollIndicatorHeight)
                                        .clamp(0.0, containerHeight);
                                final availableSpace =
                                    (containerHeight - indicatorHeight)
                                        .clamp(0.0, containerHeight);
                                final topPosition =
                                    (_scrollProgress * availableSpace)
                                        .clamp(0.0, containerHeight);

                                // Only show white thumb, no grey track background
                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: topPosition),
                                    child: Container(
                                      width: 1.0,
                                      height: indicatorHeight.clamp(
                                          0.0, containerHeight),
                                      color: const Color(0xFFE4E4E4),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Return empty widget if any error occurs
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 30),
                            child: _inputController.text.isEmpty
                                ? SizedBox(
                                    height: 30,
                                    child: TextField(
                                      key: _inputTextFieldKey,
                                      controller: _inputController,
                                      focusNode: _inputFocusNode,
                                      cursorColor: const Color(0xFFE4E4E4),
                                      cursorHeight: 15,
                                      maxLines: 11,
                                      minLines: 1,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: const TextStyle(
                                          fontFamily: 'Aeroport',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          height: 2.0,
                                          color: Color(0xFFE4E4E4)),
                                      onSubmitted: (value) {
                                        _askNewQuestion();
                                      },
                                      decoration: InputDecoration(
                                        hintText: (_isInputFocused ||
                                                _inputController
                                                    .text.isNotEmpty)
                                            ? null
                                            : 'Ask anything',
                                        hintStyle: const TextStyle(
                                            color: Color(0xFFE4E4E4),
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            height: 2.0),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: !_isInputFocused
                                            ? const EdgeInsets.only(
                                                left: 0,
                                                right: 0,
                                                top: 5,
                                                bottom: 5)
                                            : const EdgeInsets.only(right: 0),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: TextField(
                                      key: _inputTextFieldKey,
                                      controller: _inputController,
                                      focusNode: _inputFocusNode,
                                      cursorColor: const Color(0xFFE4E4E4),
                                      cursorHeight: 15,
                                      maxLines: 11,
                                      minLines: 1,
                                      textAlignVertical: _inputController.text
                                                  .split('\n')
                                                  .length ==
                                              1
                                          ? TextAlignVertical.center
                                          : TextAlignVertical.bottom,
                                      style: const TextStyle(
                                          fontFamily: 'Aeroport',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          height: 2,
                                          color: Color(0xFFE4E4E4)),
                                      onSubmitted: (value) {
                                        _askNewQuestion();
                                      },
                                      decoration: InputDecoration(
                                        hintText: (_isInputFocused ||
                                                _inputController
                                                    .text.isNotEmpty)
                                            ? null
                                            : 'Ask anything',
                                        hintStyle: const TextStyle(
                                            color: Color(0xFFE4E4E4),
                                            fontFamily: 'Aeroport',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            height: 2),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: _inputController.text
                                                    .split('\n')
                                                    .length >
                                                1
                                            ? const EdgeInsets.only(
                                                left: 0, right: 0, top: 11)
                                            : const EdgeInsets.only(right: 0),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            _askNewQuestion();
                          },
                          child: SvgPicture.asset(
                            'assets/icons/apply.svg',
                            width: 30,
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFE4E4E4),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
