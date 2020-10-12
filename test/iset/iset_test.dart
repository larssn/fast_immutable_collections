import 'package:test/test.dart';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

void main() {
  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("Creating immutable sets |", () {
    final ISet iSet1 = ISet(), iSet2 = ISet({});
    final iSet3 = ISet<String>({}),
        iSet4 = ISet([1]),
        iSet5 = ISet.empty<int>(),
        iSet6 = <int>{}.lock;

    test("Runtime Type", () {
      expect(iSet1, isA<ISet>());
      expect(iSet2, isA<ISet>());
      expect(iSet3, isA<ISet<String>>());
      expect(iSet4, isA<ISet<int>>());
      expect(iSet5, isA<ISet<int>>());
      expect(iSet6, isA<ISet>());
    });

    test("Emptiness Properties", () {
      expect(iSet1.isEmpty, isTrue);
      expect(iSet2.isEmpty, isTrue);
      expect(iSet3.isEmpty, isTrue);
      expect(iSet4.isEmpty, isFalse);
      expect(iSet5.isEmpty, isTrue);
      expect(iSet6.isEmpty, isTrue);

      expect(iSet1.isNotEmpty, isFalse);
      expect(iSet2.isNotEmpty, isFalse);
      expect(iSet3.isNotEmpty, isFalse);
      expect(iSet4.isNotEmpty, isTrue);
      expect(iSet5.isNotEmpty, isFalse);
      expect(iSet6.isNotEmpty, isFalse);
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("Ensuring Immutability |", () {
    group("ISet.add method |", () {
      test("Changing the passed mutable list doesn't change the IList", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, original);

        original.add(3);
        original.add(4);

        expect(original, <int>{1, 2, 3, 4});
        expect(iSet, <int>{1, 2});
      });

      test("Changing the ISet also doesn't change the original set", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, original);

        final ISet<int> iSetNew = iSet.add(3);

        expect(original, <int>{1, 2});
        expect(iSet, <int>{1, 2});
        expect(iSetNew, <int>{1, 2, 3});
      });

      test("If the item being passed is a variable, a pointer to it shouldn't exist inside ISet",
          () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, original);

        int willChange = 4;
        final ISet<int> iSetNew = iSet.add(willChange);

        willChange = 5;

        expect(original, <int>{1, 2});
        expect(iSet, <int>{1, 2});
        expect(willChange, 5);
        expect(iSetNew, <int>{1, 2, 4});
      });
    });

    group("ISet.addAll method", () {
      test("Changing the passed mutable list doesn't change the ISet", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, <int>{1, 2});

        original.addAll(<int>{2, 3, 4});

        expect(original, <int>{1, 2, 3, 4});
        expect(iSet, <int>{1, 2});
      });

      test("Changing the passed immutable set doesn't change the ISet", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, <int>{1, 2});

        final ISet<int> iSetNew = iSet.addAll(<int>{2, 3, 4});

        expect(original, <int>{1, 2});
        expect(iSet, <int>{1, 2});
        expect(iSetNew, <int>{1, 2, 3, 4});
      });

      test(
          "If the items being passed are from a variable, "
          "it shouldn't have a pointer to the variable", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet1 = original.lock;
        final ISet<int> iSet2 = original.lock;

        expect(iSet1, original);
        expect(iSet2, original);

        final ISet<int> iSetNew = iSet1.addAll(iSet2.addAll({3, 4}));
        original.add(3);

        expect(original, <int>{1, 2, 3});
        expect(iSet1, <int>{1, 2});
        expect(iSet2, <int>{1, 2});
        expect(iSetNew, <int>{1, 2, 3, 4});
      });
    });

    group("ISet.remove method |", () {
      test("Changing the passed mutable set doesn't change the ISet", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, {1, 2});

        original.remove(2);

        expect(original, <int>{1});
        expect(iSet, <int>{1, 2});
      });

      test("Removing from the original ISet doesn't change it", () {
        final Set<int> original = {1, 2};
        final ISet<int> iSet = original.lock;

        expect(iSet, <int>{1, 2});

        final ISet<int> iSetNew = iSet.remove(1);

        expect(original, <int>{1, 2});
        expect(iSet, <int>{1, 2});
        expect(iSetNew, <int>{2});
      });
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO: Equals
  group("Equals and Other Comparisons |", () {
    group("Equals Operator |", () {
      test("ISet with identity-equals compares the set instance, not the items.", () {
        final ISet<int> mySet = ISet({1, 2}).withIdentityEquals;
        expect(mySet == mySet, isTrue);
        expect(mySet == ISet({1, 2}).withIdentityEquals, isFalse);
        expect(mySet == {1, 2}.lock, isFalse);
        expect(mySet == ISet({1, 2, 3}).withIdentityEquals, isFalse);
      });

      test("ISet with deep-equals compares the items, not necessarily the list instance", () {
        final ISet<int> mySet = ISet({1, 2});
        expect(mySet == mySet, isTrue);
        expect(mySet == ISet({1, 2}), isTrue);
        expect(mySet == {1, 2}.lock.withDeepEquals, isTrue);
        expect(mySet == ISet({1, 2, 3}), isFalse);
      });

      test("ISet with deep-equals is always different from iSet with identity-equals", () {
        expect(ISet({1, 2}).withDeepEquals == ISet({1, 2}).withIdentityEquals, isFalse);
        expect(ISet({1, 2}).withIdentityEquals == ISet({1, 2}).withDeepEquals, isFalse);
        expect(ISet({1, 2}).withDeepEquals == ISet({1, 2}), isTrue);
        expect(ISet({1, 2}) == ISet({1, 2}).withDeepEquals, isTrue);
      });
    });

    group("Other Comparisons |", () {
      test("ISet.isIdentityEquals and ISet.isDeepEquals properties", () {
        final ISet<int> iSet1 = ISet({1, 2}), iSet2 = ISet({1, 2}).withIdentityEquals;
        expect(iSet1.isIdentityEquals, isFalse);
        expect(iSet1.isDeepEquals, isTrue);
        expect(iSet2.isIdentityEquals, isTrue);
        expect(iSet2.isDeepEquals, isFalse);
      });

      // TODO: Marcelo, por favor, revise.
      test("ISet.same method", () {
        final ISet<int> iSet1 = ISet({1, 2}),
            iSet2 = ISet({1, 2}),
            iSet3 = ISet({1}),
            iSet4 = ISet({1, 2}).withIdentityEquals;
        expect(iSet1.same(iSet1), isTrue);
        expect(iSet1.same(iSet2), isFalse);
        expect(iSet1.same(iSet3), isFalse);
        expect(iSet1.same(iSet4), isFalse);
      });

      test("ISet.equals method", () {
        final ISet<int> iSet1 = ISet({1, 2}),
            iSet2 = ISet({1, 2}),
            iSet3 = ISet({1}),
            iSet4 = ISet({1, 2}).withIdentityEquals;
        expect(iSet1.equals(iSet1), isTrue);
        expect(iSet1.equals(iSet2), isTrue);
        expect(iSet1.equals(iSet3), isFalse);
        expect(iSet1.equals(iSet4), isFalse);
      });
    });

    test("ISet.hashCode method", () {
      final ISet<int> iSet = ISet({1, 2});
      expect(iSet.hashCode, 884763);
    });

    test("ISet.config method", () {
      final ISet<int> iSet = ISet({1, 2});

      expect(iSet.isDeepEquals, isTrue);
      expect(iSet.config.autoSort, isTrue);

      final ISet<int> iSetWithCompare = iSet.withConfig(
        iSet.config.copyWith(autoSort: false),
      );

      expect(iSetWithCompare.isDeepEquals, isTrue);
      expect(iSetWithCompare.config.autoSort, isFalse);
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("Creating immutable sets with extension |", () {
    test("From an empty set", () {
      final ISet iList = <int>{}.lock;

      expect(iList, isA<ISet>());
      expect(iList.isEmpty, isTrue);
      expect(iList.isNotEmpty, isFalse);
    });

    test("From a set with one int item", () {
      final ISet iSet = {1}.lock;

      expect(iSet, isA<ISet<int>>());
      expect(iSet.isEmpty, isFalse);
      expect(iSet.isNotEmpty, isTrue);
    });

    test("From a set with one null string", () {
      final String text = null;
      final ISet<String> typedList = {text}.lock;

      expect(typedList, isA<ISet<String>>());
    });

    test("From an empty set typed with String", () {
      final typedList = <String>{}.lock;

      expect(typedList, isA<ISet<String>>());
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("Creating native mutable sets from immutable sets |", () {
    final Set<int> exampleSet = {1, 2, 3};

    test("From the default factory constructor", () {
      final ISet<int> iSet = ISet(exampleSet);

      expect(iSet.unlock, exampleSet);
      expect(identical(iSet.unlock, exampleSet), isFalse);
    });

    test("From lock", () {
      final ISet<int> iSet = exampleSet.lock;

      expect(iSet.unlock, exampleSet);
      expect(identical(iSet.unlock, exampleSet), isFalse);
    });
  });

  test("ISet.flush method", () {
    final ISet<int> iSet = {1, 2, 3}.lock.add(4).addAll({5, 6}).add(7).addAll({}).addAll({8, 9});

    expect(iSet.isFlushed, isFalse);

    iSet.flush;

    expect(iSet.isFlushed, isTrue);
    expect(iSet.unlock, {1, 2, 3, 4, 5, 6, 7, 8, 9});
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("Adding Elements", () {
    final ISet<int> baseSet = ISet<int>([1]);

    test("ISet.add method", () {
      ISet<int> iSet = baseSet.add(2);

      expect(iSet.unlock, <int>{1, 2});
    });

    test("ISet.add method with a repeated element", () {
      ISet<int> iSet = baseSet.add(1);

      expect(iSet.unlock, <int>{1});
    });

    test("ISet.add and ISet.addAll methods", () {
      final ISet<int> iSet1 = {1, 2, 3}.lock;
      final ISet<int> iSet2 = iSet1.add(4);
      final ISet<int> iSet3 = iSet2.addAll({5, 6});

      expect(iSet1.unlock, {1, 2, 3});
      expect(iSet2.unlock, {1, 2, 3, 4});
      expect(iSet3.unlock, {1, 2, 3, 4, 5, 6});

      // Methods are chainable.
      expect(iSet1.add(10).addAll({20, 30}).unlock, {1, 2, 3, 10, 20, 30});
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////

    group("Adding repeated elements |", () {
      final ISet<int> baseSet = ISet<int>({1, 2, 3});

      test("adding a repeated element", () {
        final ISet<int> iSet = baseSet.add(1);

        expect(iSet.length, 3);
        expect(iSet.unlock, {1, 2, 3});
      });

      test("adding multiple repeated elements", () {
        final ISet<int> iSet = baseSet.addAll({1, 2});

        expect(iSet.length, 3);
        expect(iSet.unlock, {1, 2, 3});
      });

      test("adding some repeated elements and another, new one", () {
        final ISet<int> iSet = baseSet.addAll({1, 2, 5, 7});

        expect(iSet.length, 5);
        expect(iSet.unlock, {1, 2, 3, 5, 7});
      });

      test("adding some repeated elements and new ones", () {
        final ISet<int> iSet = baseSet.addAll({1, 2, 5, 7, 11, 13});

        expect(iSet.length, 7);
        expect(iSet.unlock, {1, 2, 3, 5, 7, 11, 13});
      });
    });
  });

  test("ISet.remove method", () {
    final ISet<int> iSet1 = {1, 2, 3}.lock;

    final ISet<int> iSet2 = iSet1.remove(2);
    expect(iSet2.unlock, {1, 3});

    final ISet<int> iSet3 = iSet2.remove(5);
    expect(iSet3.unlock, {1, 3});

    final ISet<int> iSet4 = iSet3.remove(1);
    expect(iSet4.unlock, {3});

    final ISet<int> iSet5 = iSet4.remove(3);
    expect(iSet5.unlock, <int>{});

    final ISet<int> iSet6 = iSet5.remove(7);
    expect(iSet6.unlock, <int>{});

    expect(identical(iSet1, iSet2), false);
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("ISet methods from Iterable |", () {
    final ISet<int> iSet = {1, 2, 3}.lock.add(4).addAll({5, 6});

    test("ISet.any method", () {
      expect(iSet.any((int v) => v == 4), isTrue);
      expect(iSet.any((int v) => v == 100), isFalse);
    });

    test("ISet.cast method", () => expect(iSet.cast<num>(), isA<ISet<num>>()));

    test("ISet.contains method", () {
      expect(iSet.contains(2), isTrue);
      expect(iSet.contains(4), isTrue);
      expect(iSet.contains(5), isTrue);
      expect(iSet.contains(100), isFalse);
    });

    test("ISet.every method", () {
      expect(iSet.every((int v) => v > 0), isTrue);
      expect(iSet.every((int v) => v < 0), isFalse);
      expect(iSet.every((int v) => v != 4), isFalse);
    });

    test("ISet.expand method", () {
      expect(iSet.expand((int v) => {v, v}),
          // ignore: equal_elements_in_set
          {1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6});
      expect(iSet.expand((int v) => <int>{}), <int>{});
    });

    test("ISet.length", () => expect(iSet.length, 6));

    test("ISet.first method", () => expect(iSet.first, 1));

    test("ISet.last method", () => expect(iSet.last, 6));

    //////////////////////////////////////////////////////////////////////////////////////////////////

    group("ISet.single method |", () {
      test("State exception", () => expect(() => iSet.single, throwsStateError));

      test("Access", () => expect({10}.lock.single, 10));
    });

    test("ISet.firstWhere method", () {
      expect(iSet.firstWhere((int v) => v > 1, orElse: () => 100), 2);
      expect(iSet.firstWhere((int v) => v > 4, orElse: () => 100), 5);
      expect(iSet.firstWhere((int v) => v > 5, orElse: () => 100), 6);
      expect(iSet.firstWhere((int v) => v > 6, orElse: () => 100), 100);
    });

    test("ISet.fold method", () => expect(iSet.fold(100, (int p, int e) => p * (1 + e)), 504000));

    test("ISet.followedBy method", () {
      expect(iSet.followedBy({7, 8}).unlock, {1, 2, 3, 4, 5, 6, 7, 8});
      expect(
          iSet.followedBy(<int>{}.lock.add(7).addAll({8, 9})).unlock, {1, 2, 3, 4, 5, 6, 7, 8, 9});
    });

    test("ISet.forEach method", () {
      int result = 100;
      iSet.forEach((int v) => result *= 1 + v);
      expect(result, 504000);
    });

    test("ISet.join method", () {
      expect(iSet.join(","), "1,2,3,4,5,6");
      expect(<int>{}.lock.join(","), "");
    });

    test("ISet.lastWhere method", () {
      expect(iSet.lastWhere((int v) => v < 2, orElse: () => 100), 1);
      expect(iSet.lastWhere((int v) => v < 5, orElse: () => 100), 4);
      expect(iSet.lastWhere((int v) => v < 6, orElse: () => 100), 5);
      expect(iSet.lastWhere((int v) => v < 7, orElse: () => 100), 6);
      expect(iSet.lastWhere((int v) => v < 50, orElse: () => 100), 6);
      expect(iSet.lastWhere((int v) => v < 1, orElse: () => 100), 100);
    });

    test("ISet.map method", () {
      expect({1, 2, 3}.lock.map((int v) => v + 1).unlock, {2, 3, 4});
      expect(iSet.map((int v) => v + 1).unlock, {2, 3, 4, 5, 6, 7});
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////

    group("ISet.reduce method |", () {
      test("Regular usage", () {
        expect(iSet.reduce((int p, int e) => p * (1 + e)), 2520);
        expect({5}.lock.reduce((int p, int e) => p * (1 + e)), 5);
      });

      test(
          "State exception",
          () => expect(() => ISet().reduce((dynamic p, dynamic e) => p * (1 + (e as num))),
              throwsStateError));
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////

    group("ISet.singleWhere method |", () {
      test("Regular usage", () {
        expect(iSet.singleWhere((int v) => v == 4, orElse: () => 100), 4);
        expect(iSet.singleWhere((int v) => v == 50, orElse: () => 100), 100);
      });

      test(
          "State exception",
          () => expect(
              () => iSet.singleWhere((int v) => v < 4, orElse: () => 100), throwsStateError));
    });

    test("ISet.skip method", () {
      expect(iSet.skip(1).unlock, {2, 3, 4, 5, 6});
      expect(iSet.skip(3).unlock, {4, 5, 6});
      expect(iSet.skip(5).unlock, {6});
      expect(iSet.skip(10).unlock, <int>{});
    });

    test("ISet.skipWhile method", () {
      expect(iSet.skipWhile((int v) => v < 3).unlock, {3, 4, 5, 6});
      expect(iSet.skipWhile((int v) => v < 5).unlock, {5, 6});
      expect(iSet.skipWhile((int v) => v < 6).unlock, {6});
      expect(iSet.skipWhile((int v) => v < 100).unlock, <int>{});
    });

    test("ISet.take method", () {
      expect(iSet.take(0).unlock, <int>{});
      expect(iSet.take(1).unlock, {1});
      expect(iSet.take(3).unlock, {1, 2, 3});
      expect(iSet.take(5).unlock, {1, 2, 3, 4, 5});
      expect(iSet.take(10).unlock, {1, 2, 3, 4, 5, 6});
    });

    test("ISet.takeWhile method", () {
      expect(iSet.takeWhile((int v) => v < 3).unlock, {1, 2});
      expect(iSet.takeWhile((int v) => v < 5).unlock, {1, 2, 3, 4});
      expect(iSet.takeWhile((int v) => v < 6).unlock, {1, 2, 3, 4, 5});
      expect(iSet.takeWhile((int v) => v < 100).unlock, {1, 2, 3, 4, 5, 6});
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////

    group("ISet.toList method |", () {
      test("Regular usage", () {
        expect(iSet.toList()..add(7), [1, 2, 3, 4, 5, 6, 7]);
        expect(iSet.unlock, [1, 2, 3, 4, 5, 6]);
      });

      test("Unsupported exception",
          () => expect(() => iSet.toList(growable: false)..add(7), throwsUnsupportedError));
    });

    test("Iset.toIList method", () => expect(iSet.toIList(), IList([1, 2, 3, 4, 5, 6])));

    test("ISet.toSet method", () {
      expect(iSet.toSet()..add(7), {1, 2, 3, 4, 5, 6, 7});
      expect(iSet.unlock, [1, 2, 3, 4, 5, 6]);
    });

    test("ISet.where method", () {
      expect(iSet.where((int v) => v < 0).unlock, <int>{});
      expect(iSet.where((int v) => v < 3).unlock, {1, 2});
      expect(iSet.where((int v) => v < 5).unlock, {1, 2, 3, 4});
      expect(iSet.where((int v) => v < 100).unlock, {1, 2, 3, 4, 5, 6});
    });

    test("ISet.whereType method",
        () => expect((<num>{1, 2, 1.5}.lock.whereType<double>()).unlock, {1.5}));

    test("ISet.toString method", () => expect(iSet.toString(), "{1, 2, 3, 4, 5, 6}"));

    test("ISet.iterator getter", () {
      final Iterator<int> iterator = iSet.iterator;

      int count = 0;
      final Set<int> result = {};
      while (iterator.moveNext()) {
        count++;
        result.add(iterator.current); 
      }
      expect(count, iSet.length);
      expect(result, iSet);
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////

  group("ISet of MapEntry gets special treatment |", () {
    test("Equals", () {
      final ISet<MapEntry<String, int>> iSet1 = ISet([MapEntry("a", 1)]).withDeepEquals,
          iSet2 = ISet([MapEntry("a", 1)]).withDeepEquals;

      expect(iSet1, iSet2);
    });
  });

  //////////////////////////////////////////////////////////////////////////////////////////////////
}
