import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// -----------------------------------------------------------------------
/// The InheritedWidget itself.
///
/// It just carries a `count` and a `increment` callback down the tree.
/// The two static helpers (`of` / `maybeOf`) are the standard convention
/// Flutter itself uses (see Theme.of, MediaQuery.of, etc.) — they hide
/// `dependOnInheritedWidgetOfExactType` behind a friendly API.
/// -----------------------------------------------------------------------
class CounterProvider extends InheritedWidget {
  const CounterProvider({
    super.key,
    required this.count,
    required this.increment,
    required super.child,
  });

  final int count;
  final VoidCallback increment;

  /// Walks *up* the tree from [context] looking for the nearest
  /// CounterProvider — no matter how many widgets sit in between.
  static CounterProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>();
  }

  static CounterProvider of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No CounterProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CounterProvider oldWidget) {
    // Only rebuild dependents when the count actually changes.
    return count != oldWidget.count;
  }
}

/// -----------------------------------------------------------------------
/// Root widget: owns the counter state and is the only place that ever
/// calls setState. Everything below just reads from CounterProvider.
/// -----------------------------------------------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: CounterProvider(
        count: _count,
        increment: _increment,
        // Parent sits directly under the provider...
        child: const ParentWidget(),
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// PARENT — a direct child of CounterProvider.
/// -----------------------------------------------------------------------
class ParentWidget extends StatelessWidget {
  const ParentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Direct access: ParentWidget is an immediate child of CounterProvider.
    final counter = CounterProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InheritedWidget: parent vs grandparent'),
        actions: [
          IconButton(
            tooltip: 'See the broken example',
            icon: const Icon(Icons.warning_amber_rounded),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BrokenPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Box(
              label: 'ParentWidget (direct child of CounterProvider)',
              count: counter.count,
              color: Colors.indigo.shade100,
            ),
            const SizedBox(height: 24),
            // GrandchildWidget is nested two levels below CounterProvider
            // (Parent -> Padding -> Grandchild), yet it will reach the
            // exact same provider with the exact same call.
            const Padding(
              padding: EdgeInsets.all(16),
              child: GrandchildWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// GRANDCHILD — several widgets below CounterProvider, with ParentWidget
/// in between. The lookup still finds CounterProvider directly, because
/// dependOnInheritedWidgetOfExactType walks up the element tree until it
/// finds a match — it doesn't care how many "generations" separate them.
/// -----------------------------------------------------------------------
class GrandchildWidget extends StatelessWidget {
  const GrandchildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Grandparent access: CounterProvider is two levels up from here,
    // but the call looks identical to the one in ParentWidget.
    final counter = CounterProvider.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Box(
          label: 'GrandchildWidget (reads straight past ParentWidget)',
          count: counter.count,
          color: Colors.teal.shade100,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: counter.increment,
          icon: const Icon(Icons.add),
          label: const Text('Increment (updates both boxes above)'),
        ),
      ],
    );
  }
}

/// -----------------------------------------------------------------------
/// BROKEN EXAMPLE — this is the mistake called out in the Flutter docs:
/// "context must be a descendant of the InheritedWidget".
///
/// Here, `BrokenPage.build`'s own `context` is the context CounterProvider
/// is about to be *inserted at* — it is the provider's own ancestor
/// context, not a descendant of it. Reading `CounterProvider.of(context)`
/// with that outer context walks up the tree from *above* the provider
/// and never finds it, so the assertion inside `of` fails.
///
/// Notice the Builder below: its `innerContext` genuinely is a descendant
/// of CounterProvider, and swapping to it would fix this instantly — but
/// this widget deliberately keeps using the outer `context` to show the
/// failure live.
/// -----------------------------------------------------------------------
class BrokenPage extends StatelessWidget {
  const BrokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broken: wrong context')),
      body: CounterProvider(
        count: 0,
        increment: () {},
        child: Builder(
          builder: (BuildContext innerContext) {
            // WRONG on purpose: `context` here is BrokenPage's own context,
            // which sits *above* CounterProvider, not below it.
            // Using `innerContext` instead would work fine.
            final counter = CounterProvider.of(context); // <-- assertion fails
            return Center(child: Text('${counter.count}'));
          },
        ),
      ),
    );
  }
}

/// Small reusable display box so the two reads above look identical
/// and the point of the demo — same call, different depth — is obvious.
class _Box extends StatelessWidget {
  const _Box({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('$count', style: Theme.of(context).textTheme.displayMedium),
        ],
      ),
    );
  }
}
