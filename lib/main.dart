import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/billings/counter_sales.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the window manager
  await windowManager.ensureInitialized();

  // Set up window options
  WindowOptions windowOptions = WindowOptions(
    center: true, // Center the window on the screen
    title: "FoxCare",
    titleBarStyle: TitleBarStyle.normal, // Retain the title bar
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
// Get the screen bounds
    final Rect screenBounds = await windowManager.getBounds();

    // Adjust bounds to avoid overlapping the taskbar
    const double taskbarHeight =
        40; // Approximate taskbar height (can vary per OS)
    final Rect usableBounds = Rect.fromLTWH(
      screenBounds.left,
      screenBounds.top,
      screenBounds.width,
      screenBounds.height - taskbarHeight,
    );
    // Set the window bounds
    await windowManager.setBounds(usableBounds);
    await windowManager.maximize();
    await windowManager.setResizable(false); // Disable resizing
    await windowManager.setMaximizable(false); // Disable maximize button
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoxCare Lite',
      home: CounterSales(),
    );
  }
}
