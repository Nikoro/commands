import 'dart:io';

extension FileExtensions on File {
  String get name => path.split(Platform.pathSeparator).last;

  String get onlyName => name.replaceAll(RegExp(r'\.[^\.]+$'), '');
}

extension IterableExtensions<T> on Iterable<T> {
  Iterable<R> mapNotNull<R>(R? Function(T item) transform) sync* {
    for (final item in this) {
      final R? result = transform(item);
      if (result != null) yield result;
    }
  }

  Future<Iterable<R>> mapNotNullAsync<R>(Future<R?> Function(T item) transform) async =>
      (await Future.wait(map(transform))).whereType<R>();
}

extension ListStringExtensions on List<String> {
  bool containsAny(List<String> values) => values.any(contains);
  bool containsAnyCombo(List<List<String>> combos) => combos.any((combo) => combo.every(contains));
}

extension StringExtensions on String {
  bool containsAny(List<String> values) => values.any(contains);
}
