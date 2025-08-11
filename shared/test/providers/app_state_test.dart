import 'package:flutter_test/flutter_test.dart';
import 'package:shared/providers/app_state.dart';

void main() {
  group('AppState', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('initial state has isSearching set to false', () {
      expect(appState.isSearching, isFalse);
    });

    test(
      'setSearchState(true) updates isSearching to true and notifies listeners',
      () {
        // Arrange
        var listenerCallCount = 0;
        appState.addListener(() {
          listenerCallCount++;
        });

        // Act
        appState.setSearchState(true);

        // Assert
        expect(appState.isSearching, isTrue);
        expect(listenerCallCount, 1);
      },
    );

    test(
      'setSearchState(false) does not notify listeners when state is already false',
      () {
        // Arrange
        var listenerCallCount = 0;
        appState.addListener(() {
          listenerCallCount++;
        });

        // Act
        appState.setSearchState(false);

        // Assert
        expect(appState.isSearching, isFalse);
        expect(listenerCallCount, 0);
      },
    );

    test(
      'setSearchState(false) updates isSearching to false and notifies listeners when state was true',
      () {
        // Arrange: first set the state to true
        appState.setSearchState(true);

        var listenerCallCount = 0;
        appState.addListener(() {
          listenerCallCount++;
        });

        // Act: now toggle it back to false
        appState.setSearchState(false);

        // Assert
        expect(appState.isSearching, isFalse);
        expect(listenerCallCount, 1);
      },
    );

    test(
      'setSearchState(true) does not notify listeners when state is already true',
      () {
        // Arrange: first set the state to true
        appState.setSearchState(true);

        var listenerCallCount = 0;
        appState.addListener(() {
          listenerCallCount++;
        });

        // Act: call it again with the same value
        appState.setSearchState(true);

        // Assert
        expect(appState.isSearching, isTrue);
        expect(listenerCallCount, 0);
      },
    );
  });
}
