import "package:meta/meta.dart";
import "package:test/test.dart";

import "package:fast_immutable_collections/fast_immutable_collections.dart";

void main() {
  test("Repeating elements doesn't include the copies in the set", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.iter, {james, sara, lucy});
  });

  test("FromIterableISetMixin.any()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.any((Student student) => student.name == "James"), isTrue);
    expect(students.any((Student student) => student.name == "John"), isFalse);
  });

  test("FromIterableISetMixin.cast()", () {
    final Students students = Students([Student("James")]);

    expect(students.cast<ProtoStudent>(), isA<ISet<ProtoStudent>>());
  });

  test("FromIterableISetMixin.contains()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.contains(const Student("James")), isTrue);
    expect(students.contains(const Student("John")), isFalse);
  });

  test("FromIterableISetMixin.elementAt()",
      () => expect(() => Students([]).elementAt(0), throwsUnsupportedError));

  test("FromIterableISetMixin.every()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.every((Student student) => student.name.length > 1), isTrue);
    expect(students.every((Student student) => student.name.length > 4), isFalse);
  });

  test("FromIterableISetMixin.expand()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.expand((Student student) => [student, student]),
        allOf(isA<ISet<Student>>(), <Student>{james, sara, lucy}.lock));
    expect(
        students.expand((Student student) => [student, Student(student.name + "2")]),
        allOf(
            isA<ISet<Student>>(),
            <Student>{
              james,
              sara,
              lucy,
              const Student("James2"),
              const Student("Sara2"),
              const Student("Lucy2")
            }.lock));
  });

  test("FromIterableISetMixin.length", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.length, 3);
  });

  test("FromIterableISetMixin.first", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.first, Student("James"));
  });

  test("FromISetMixin.last", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    // TODO: Marcelo, o último elemento não deveria ser Lucy? Não me parece claro o ordenamento.
    // Há algum `compareTo` implícito que eu não soube reconhecer?
    expect(students.last, Student("Lucy"));
  }, skip: true);

  test("FromIterableISetMixin.single", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(() => students.single, throwsStateError);
  });

  test("FromIterableISetMixin.firstWhere()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.firstWhere((Student student) => student.name.length == 5,
            orElse: () => const Student("John")),
        const Student("James"));
    expect(
        students.firstWhere((Student student) => student.name.length == 4,
            orElse: () => const Student("John")),
        const Student("Sara"));
    expect(
        students.firstWhere((Student student) => student == const Student("Bob"),
            orElse: () => const Student("John")),
        const Student("John"));
  });

  test("FromIterableISetMixin.fold()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.fold(
            Student("Class"),
            (Student previousStudent, Student currentStudent) =>
                Student(previousStudent.name + " : " + currentStudent.name)),
        const Student("Class : James : Sara : Lucy"));
  });

  test("FromIterableISetMixin.followedBy()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.followedBy([const Student("Bob")]).unlock,
        {james, sara, lucy, const Student("Bob")});
  });

  test("FromIterableISetMixin.forEach()", () {
    String concatenated = "";

    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    students.forEach((Student student) => concatenated += student.name + ", ");

    expect(concatenated, "James, Sara, Lucy, ");
  });

  test("FromIterableISetMixin.join()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.join(", "), "Student: James, Student: Sara, Student: Lucy");
    expect(Students([]).join(", "), "");
  });

  test("FromIterableISetMixin.lastWhere()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.lastWhere((Student student) => student.name.length == 5,
            orElse: () => const Student("John")),
        const Student("James"));
    expect(
        students.lastWhere((Student student) => student.name.length == 4,
            orElse: () => const Student("John")),
        const Student("Lucy"));
    expect(
        students.lastWhere((Student student) => student == const Student("Bob"),
            orElse: () => const Student("John")),
        const Student("John"));
  });

  test("FromIterableISetMixin.map()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    final Students students = Students([james, sara]);

    expect(students.map((Student student) => Student(student.name + student.name)),
        {const Student("JamesJames"), const Student("SaraSara")});
  });

  test("FromIterableISetMixin.reduce()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.reduce((Student currentStudent, Student nextStudent) =>
            Student(currentStudent.name + " " + nextStudent.name)),
        Student("James Sara Lucy"));
  });

  test("FromIterableISetMixin.singleWhere()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.singleWhere((Student student) => student.name == "Sara",
            orElse: () => Student("Bob")),
        const Student("Sara"));
    expect(
        students.singleWhere((Student student) => student.name == "Goat",
            orElse: () => Student("Bob")),
        const Student("Bob"));
  });

  test("FromIterableISetMixin.skip()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.skip(2), {const Student("Lucy")});
    expect(students.skip(10), <Student>{});
  });

  test("FromIterableISetMixin.skipWhile()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.skipWhile((Student student) => student.name.length > 4),
        {const Student("Sara"), const Student("Lucy")});
  });

  test("FromIterableISetMixin.take()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.take(0), <Student>{});
    expect(students.take(1), <Student>{const Student("James")});
    expect(students.take(2), <Student>{const Student("James"), const Student("Sara")});
    expect(students.take(3),
        <Student>{const Student("James"), const Student("Sara"), const Student("Lucy")});
    expect(students.take(10),
        <Student>{const Student("James"), const Student("Sara"), const Student("Lucy")});
  });

  test("FromIterableISetMixin.takeWhile()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.takeWhile((Student student) => student.name.length >= 5),
        {const Student("James")});
  });

  test("FromIterableISetMixin.where()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.where((Student student) => student.name.length == 5), {const Student("James")});
    expect(students.where((Student student) => student.name.length == 100), <Student>{});
  });

  test("FromIterableISetMixin.whereType()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(students.whereType<Student>(),
        {const Student("James"), const Student("Sara"), const Student("Lucy")});
    expect(students.whereType<String>(), <Student>{});
  });

  test("FromIterableISetMixin.isEmpty", () {
    expect(Students([]).isEmpty, isTrue);
    expect(Students([Student("James")]).isEmpty, isFalse);
  });

  test("FromIterableISetMixin.isNotEmpty", () {
    expect(Students([]).isNotEmpty, isFalse);
    expect(Students([Student("James")]).isNotEmpty, isTrue);
  });

  test("FromIterableISetMixin.iterator", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    final Iterator<Student> iterator = students.iterator;

    expect(iterator.current, isNull);
    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, james);
    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, sara);
    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, lucy);
    expect(iterator.moveNext(), isFalse);
    expect(iterator.current, isNull);
  });

  test("FromIterableISetMixin.toList()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.toList(), [const Student("James"), const Student("Sara"), const Student("Lucy")]);
  });

  test("FromIterableISetMixin.toSet()", () {
    const Student james = Student("James");
    const Student sara = Student("Sara");
    const Student lucy = Student("Lucy");
    final Students students = Students([james, sara, lucy, Student("James")]);

    expect(
        students.toSet(), {const Student("James"), const Student("Sara"), const Student("Lucy")});
  });
}

@immutable
class Ints with FromISetMixin<int, Ints> {
  final ISet<int> _ints;

  Ints([Iterable<int> ints]) : _ints = ISet(ints);

  @override
  Ints newInstance(ISet<int> iSet) => Ints(iSet);

  @override
  ISet<int> get iter => _ints;
}

@immutable
class Students with FromISetMixin<Student, Students> {
  final ISet<Student> _students;

  Students([Iterable<Student> students]) : _students = ISet(students);

  @override
  Students newInstance(ISet<Student> iSet) => Students(iSet);

  @override
  ISet<Student> get iter => _students;
}

@immutable
abstract class ProtoStudent {
  const ProtoStudent();
}

@immutable
class Student extends ProtoStudent {
  final String name;

  const Student(this.name);

  @override
  String toString() => "Student: $name";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}