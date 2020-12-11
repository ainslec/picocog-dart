// Copyright 2017 - 2020, Chris Ainsley

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:picocog_dart/picocog_dart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    PicoWriter w;

    setUp(() {
      w = PicoWriter();
    });

    test('First Test', () {
      w.writeln_r('One {');
      w.writeln_r('Two {');
      w.writeln_r('Three {');
      w.writeln('// A Comment here');
      w.writeln_l('}');
      w.writeln_l('}');
      w.writeln_l('}');
      expect(w.toString(), 'One {\n   Two {\n      Three {\n         // A Comment here\n      }\n   }\n   }\n');
    });
  });
}
