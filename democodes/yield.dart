import 'dart:async';

// Define an asynchronous generator function
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    // Yield each value asynchronously
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

void main() {
  // Create a stream using the asynchronous generator function
  Stream<int> stream = countStream(6);

  // Subscribe to the stream
  stream.listen(
    (value) {
      print('Received: $value');
    },
    onDone: () {
      print('Stream is done');
    },
  );
}
