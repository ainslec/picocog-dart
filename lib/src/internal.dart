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

/// Internal Interface
abstract class PicoWriterItem {}


/// Used internally
class IndentedLine implements PicoWriterItem {
   String _line;
   int    indent; // Public (getter and setter not necessary from Dart 2.0, https://dart-lang.github.io/linter/lints/unnecessary_getters_setters.html)

   String get line   => _line   ;
   IndentedLine(line, indent){
     _line = line;
     this.indent = indent;
   }
   @override String toString() { return '$indent:$line'; }
}
