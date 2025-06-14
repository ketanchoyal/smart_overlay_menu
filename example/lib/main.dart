import 'package:flutter/material.dart';
import 'package:smart_overlay_menu/smart_overlay_menu.dart';

void main() {
  runApp(const SmartOverlayMenuApp());
}

/// Main application widget demonstrating Smart Overlay Menu functionality
class SmartOverlayMenuApp extends StatelessWidget {
  const SmartOverlayMenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Overlay Menu Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SmartOverlayExamplesScreen(),
    );
  }
}

/// Main screen showcasing various Smart Overlay Menu configurations
class SmartOverlayExamplesScreen extends StatelessWidget {
  const SmartOverlayExamplesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Overlay Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntroductionSection(),
            SizedBox(height: 24),
            _BasicExamplesSection(),
            SizedBox(height: 32),
            _AlignmentExamplesSection(),
            SizedBox(height: 32),
            _InteractionExamplesSection(),
            SizedBox(height: 32),
            _RepositioningExamplesSection(),
            SizedBox(height: 32),
            _ControllerExampleSection(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Introduction section explaining the Smart Overlay Menu
class _IntroductionSection extends StatelessWidget {
  const _IntroductionSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Overlay Menu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'An intelligent overlay menu that automatically repositions itself '
              'to stay within screen boundaries. Long press any widget below to see it in action.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section demonstrating basic overlay configurations
class _BasicExamplesSection extends StatelessWidget {
  const _BasicExamplesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Basic Examples'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _TopWidgetExample()),
            SizedBox(width: 16),
            Expanded(child: _BottomWidgetExample()),
          ],
        ),
        const SizedBox(height: 16),
        const Center(child: _BothWidgetsExample()),
      ],
    );
  }
}

/// Section demonstrating alignment options
class _AlignmentExamplesSection extends StatelessWidget {
  const _AlignmentExamplesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Alignment Options'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _LeftAlignmentExample()),
            SizedBox(width: 12),
            Expanded(child: _CenterAlignmentExample()),
            SizedBox(width: 12),
            Expanded(child: _RightAlignmentExample()),
          ],
        ),
      ],
    );
  }
}

/// Section demonstrating different interaction styles
class _InteractionExamplesSection extends StatelessWidget {
  const _InteractionExamplesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Press Feedback'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _DefaultFeedbackExample()),
            SizedBox(width: 12),
            Expanded(child: _StrongFeedbackExample()),
            SizedBox(width: 12),
            Expanded(child: _SubtleFeedbackExample()),
          ],
        ),
      ],
    );
  }
}

/// Section demonstrating automatic repositioning
class _RepositioningExamplesSection extends StatelessWidget {
  const _RepositioningExamplesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Auto-Repositioning'),
        const SizedBox(height: 8),
        Text(
          'These examples show how overlays automatically reposition when they would exceed screen boundaries.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _TopRepositionExample()),
            SizedBox(width: 16),
            Expanded(child: _BottomRepositionExample()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _TallContainerExample()),
            const SizedBox(width: 8),
            Expanded(
                child: _TallContainerExample(
              scaleDownWhenTooLarge: true,
              repositionAnimationDuration: const Duration(milliseconds: 300),
            )),
          ],
        ),
      ],
    );
  }
}

/// Section demonstrating programmatic control
class _ControllerExampleSection extends StatelessWidget {
  const _ControllerExampleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Programmatic Control'),
        const SizedBox(height: 16),
        const _ControllerExample(),
      ],
    );
  }
}

/// Reusable section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

/// Example with only a top widget
class _TopWidgetExample extends StatelessWidget {
  const _TopWidgetExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      topWidget: _buildOverlayWidget(
        context,
        icon: Icons.keyboard_arrow_up,
        text: 'Top Widget',
        color: Colors.blue,
      ),
      child: _buildTriggerWidget(
        context,
        text: 'Top Only',
        color: Colors.green,
      ),
    );
  }
}

/// Example with only a bottom widget
class _BottomWidgetExample extends StatelessWidget {
  const _BottomWidgetExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      bottomWidget: _buildOverlayWidget(
        context,
        icon: Icons.keyboard_arrow_down,
        text: 'Bottom Widget',
        color: Colors.red,
      ),
      child: _buildTriggerWidget(
        context,
        text: 'Bottom Only',
        color: Colors.orange,
      ),
    );
  }
}

/// Example with both top and bottom widgets
class _BothWidgetsExample extends StatelessWidget {
  const _BothWidgetsExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      topWidget: _buildActionWidget(
        context,
        icon: Icons.favorite,
        text: 'Like',
        color: Colors.purple,
      ),
      bottomWidget: _buildActionWidget(
        context,
        icon: Icons.share,
        text: 'Share',
        color: Colors.teal,
      ),
      topWidgetPadding: const EdgeInsets.only(bottom: 8),
      bottomWidgetPadding: const EdgeInsets.only(top: 8),
      repositionAnimationDuration: const Duration(milliseconds: 400),
      child: _buildTriggerWidget(
        context,
        text: 'Both Widgets',
        color: Colors.indigo,
      ),
    );
  }
}

/// Example demonstrating left alignment
class _LeftAlignmentExample extends StatelessWidget {
  const _LeftAlignmentExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      topWidget: _buildOverlayWidget(
        context,
        icon: Icons.align_horizontal_left,
        text: 'Left',
        color: Colors.blue,
      ),
      topWidgetAlignment: Alignment.centerLeft,
      child: _buildTriggerWidget(
        context,
        text: 'Left\nAligned',
        color: Colors.grey.shade700,
        width: 120,
      ),
    );
  }
}

/// Example demonstrating center alignment
class _CenterAlignmentExample extends StatelessWidget {
  const _CenterAlignmentExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      topWidget: _buildOverlayWidget(
        context,
        icon: Icons.align_horizontal_center,
        text: 'Center',
        color: Colors.green,
      ),
      topWidgetAlignment: Alignment.center,
      child: _buildTriggerWidget(
        context,
        text: 'Center\nAligned',
        color: Colors.grey.shade700,
        width: 120,
      ),
    );
  }
}

/// Example demonstrating right alignment
class _RightAlignmentExample extends StatelessWidget {
  const _RightAlignmentExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      topWidget: _buildOverlayWidget(
        context,
        icon: Icons.align_horizontal_right,
        text: 'Right',
        color: Colors.orange,
      ),
      topWidgetAlignment: Alignment.centerRight,
      child: _buildTriggerWidget(
        context,
        text: 'Right\nAligned',
        color: Colors.grey.shade700,
        width: 120,
      ),
    );
  }
}

/// Example with default press feedback
class _DefaultFeedbackExample extends StatelessWidget {
  const _DefaultFeedbackExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      bottomWidget: _buildOverlayWidget(
        context,
        icon: Icons.touch_app,
        text: 'Default\n(0.95 scale)',
        color: Colors.green,
      ),
      child: _buildTriggerWidget(
        context,
        text: 'Default\nFeedback',
        color: Colors.blue,
        width: 110,
      ),
    );
  }
}

/// Example with strong press feedback
class _StrongFeedbackExample extends StatelessWidget {
  const _StrongFeedbackExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      pressFeedbackScale: 0.9,
      pressFeedbackDuration: const Duration(milliseconds: 200),
      bottomWidget: _buildOverlayWidget(
        context,
        icon: Icons.touch_app,
        text: 'Strong\n(0.9 scale)',
        color: Colors.orange,
      ),
      child: _buildTriggerWidget(
        context,
        text: 'Strong\nFeedback',
        color: Colors.deepOrange,
        width: 110,
      ),
    );
  }
}

/// Example with subtle press feedback
class _SubtleFeedbackExample extends StatelessWidget {
  const _SubtleFeedbackExample();

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      pressFeedbackScale: 0.98,
      pressFeedbackDuration: const Duration(milliseconds: 100),
      bottomWidget: _buildOverlayWidget(
        context,
        icon: Icons.touch_app,
        text: 'Subtle\n(0.98 scale)',
        color: Colors.purple,
      ),
      child: _buildTriggerWidget(
        context,
        text: 'Subtle\nFeedback',
        color: Colors.deepPurple,
        width: 110,
      ),
    );
  }
}

/// Example that repositions when near top of screen
class _TopRepositionExample extends StatelessWidget {
  const _TopRepositionExample();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SmartOverlayMenu(
        topWidget: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 30),
              SizedBox(height: 8),
              Text(
                'Large widget that would\noverflow the top',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
        child: _buildTriggerWidget(
          context,
          text: 'Near Top\n(repositions)',
          color: Colors.pink,
        ),
      ),
    );
  }
}

/// Example that repositions when near bottom of screen
class _BottomRepositionExample extends StatelessWidget {
  const _BottomRepositionExample();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SmartOverlayMenu(
        bottomWidget: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 30),
              SizedBox(height: 8),
              Text(
                'Large widget that would\noverflow the bottom',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
        child: _buildTriggerWidget(
          context,
          text: 'Near Bottom\n(repositions)',
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}

/// Example with container taller than screen
class _TallContainerExample extends StatelessWidget {
  const _TallContainerExample({this.scaleDownWhenTooLarge = false, this.repositionAnimationDuration});
  final bool scaleDownWhenTooLarge;
  final Duration? repositionAnimationDuration;

  @override
  Widget build(BuildContext context) {
    return SmartOverlayMenu(
      scaleDownWhenTooLarge: scaleDownWhenTooLarge,
      repositionAnimationDuration: repositionAnimationDuration,
      topWidget: _buildActionWidget(
        context,
        icon: Icons.favorite,
        text: 'Like',
        color: Colors.purple,
      ),
      bottomWidget: _buildActionWidget(
        context,
        icon: Icons.share,
        text: 'Share',
        color: Colors.teal,
      ),
      topWidgetPadding: const EdgeInsets.only(bottom: 8),
      bottomWidgetPadding: const EdgeInsets.only(top: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 1.5,
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scaleDownWhenTooLarge ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          scaleDownWhenTooLarge
              ? 'Extra Tall Container\n(scaled down when too large)'
              : 'Extra Tall Container\n(auto-positions at top)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Example demonstrating programmatic control
class _ControllerExample extends StatefulWidget {
  const _ControllerExample();

  @override
  State<_ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<_ControllerExample> {
  final SmartOverlayMenuController _controller = SmartOverlayMenuController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _controller.open,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Overlay Programmatically'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SmartOverlayMenu(
              controller: _controller,
              bottomWidget: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.control_camera, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Opened programmatically!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Controlled Widget\n(use button above)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to build consistent overlay widgets
Widget _buildOverlayWidget(
  BuildContext context, {
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// Helper function to build action widgets (like/share)
Widget _buildActionWidget(
  BuildContext context, {
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// Helper function to build consistent trigger widgets
Widget _buildTriggerWidget(
  BuildContext context, {
  required String text,
  required Color color,
  double? width,
}) {
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
