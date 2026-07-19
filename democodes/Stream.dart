import 'dart:async';

void main() async {
  print(' Single-Subscription Stream Demo ');
  await singleSubscriptionDemo();

  print('\n Broadcast Stream Demo ');
  await broadcastDemo();
}

Future<void> singleSubscriptionDemo() async {
  StreamController<int> streamController = StreamController<int>();

  // First (and only allowed) listener
  streamController.stream.listen(
    (int data) {
      print('Listener 1 received: $data');
    },
    onDone: () {
      print('Listener 1: stream is done.');
    },
  );

  streamController.add(1);
  streamController.add(2);

  // Trying to add a second listener throws immediately,
  // since single-subscription streams only ever allow one listener.
  try {
    streamController.stream.listen((data) {
      print('Listener 2 received: $data');
    });
  } catch (e) {
    print('Error: $e');
  }

  await streamController.close();

  // give the onDone callback a chance to fire before moving on
  await Future.delayed(Duration.zero);
}

Future<void> broadcastDemo() async {
  // asBroadcastStream() or StreamController.broadcast() both work
  StreamController<int> streamController = StreamController<int>.broadcast();

  // First listener
  streamController.stream.listen(
    (int data) {
      print('Listener 1 received: $data');
    },
    onDone: () {
      print('Listener 1: stream is done.');
    },
  );

  streamController.add(1);

  // Second listener joins mid-stream — no error, but it only gets
  // events emitted AFTER it starts listening (broadcast streams don't buffer).
  streamController.stream.listen(
    (int data) {
      print('Listener 2 received: $data');
    },
    onDone: () {
      print('Listener 2: stream is done.');
    },
  );

  streamController.add(2);

  await streamController.close();

  // give the onDone callbacks a chance to fire before moving on
  await Future.delayed(Duration.zero);
}
