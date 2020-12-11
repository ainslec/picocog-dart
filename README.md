# Picocog

A tiny code generation (templating) library, ported to Dart from Java (by the original author of Picocog).

More information on the [pub.dev page](https://pub.dev/packages/picocog_dart).

## Installing

Add the following to your pubspec.yaml file:

```yaml
dependencies:
  picocog_dart: ^1.0.6
```
For dart, run:

```
$ pub get
```

For Flutter, run:

```
$ flutter pub get
```

To import into your Dart/Flutter code:

```dart
import 'package:picocog_dart/picocog_dart.dart';
```

## Usage

A simple usage example:

```dart
import 'package:picocog_dart/picocog_dart.dart';

main() {
  PicoWriter w = PicoWriter();
  w.writeln('int foo = calcFoo();');
  w.writeln('');
  w.writeln('// We shall dance here');
  w.writeln_r('if (foo == 0) {');
  w.writeln('sayHello();');
  w.writeln_lr('} else if (foo < 100) {');
  w.writeln('sayGoodbye();');
  w.writeln_lr('} else {');
  w.writeln('sayAnything();');
  w.writeln_l('}');
  print(w.toString());
}
```

One of the core features of Picocog is the ability to write to multiple locations in the same output document at the same time.

An example of use of a deferred writer is shown below based on the article here ( https://dzone.com/articles/introducing-picocog-a-lightweight-code-generation ):

```dart
import 'package:picocog_dart/picocog.dart';

/// MODEL BUILDER START --------------------------------------

const typeChar     = 'char';
const typeInteger  = 'integer';
const typeDateTime = 'datetime';


class Document {
   List<Table> tables= [];
}

class Table {
   String id;
   List<Field> fields = [];

   Table(id){
     this.id = id;
   }
}

class Field {
   String id;
   String type;
   int length;

   Field({id, type, length}){
     this.id = id;
     this.type = type;
     this.length = length;
   }
}

Document setupModel() {
  var document = Document();

  // Add The Customer Table Data ( https://dzone.com/articles/introducing-picocog-a-lightweight-code-generation )
  // Would usually load this from a data store, or JSON, or YAML, or XML, or RION file.
  {
    var table = Table('customer');
    var fields = table.fields;
    fields.add(Field(id: 'id', type: typeChar, length: 40));
    fields.add(Field(id: 'address1', type: typeChar));
    fields.add(Field(id: 'address2', type: typeChar));
    fields.add(Field(id: 'address3', type: typeChar));
    fields.add(Field(id: 'zipcode', type: typeChar));
    fields.add(Field(id: 'country', type: typeChar));
    document.tables.add(table);
  }

  // Would usually load this from a data store, or JSON, or YAML, or XML, or RION file.
  {
    var table = Table('order');
    var fields = table.fields;
    fields.add(Field(id: 'id', type: typeInteger));
    fields.add(Field(id: 'customer_id', type: typeChar));
    fields.add(Field(id: 'date_of_purchase', type: typeDateTime));
    document.tables.add(table);
  }

  return document;
}

/// MODEL BUILDER END --------------------------------------


// TEXT ENCODERS START --------------------------------------

// NOTE:: These text conversion methods are for naive and rapidly written for demo purposes and should not be trusted.

String toFirstCap(String input, bool capFirst) {
  var length  = input.length;
  var sb = StringBuffer();
  
  var insideWord = false;
  
  for (var i = 0; i < length; i++) {
      var c = input.codeUnitAt(i);
      // Only from the 2nd char of a word onwards ... 
      if (insideWord) {
        if (c >= 65 && c <= 90 /* is Upper case */) {
            // To lowercase
            sb.write(String.fromCharCode(c + 32));
        } else if (c >= 97 && c <= 122 /* is Lower case */) {
            sb.write(String.fromCharCode(c)); // Do nothing
        } else {
            insideWord = false;
            sb.write(String.fromCharCode(c));
        }
      } else {
        if (c >= 97 && c <= 122 /* is Lower case */) {
            // To Uppercase
            sb.write(capFirst ? String.fromCharCode(c - 32) : String.fromCharCode(c));
            insideWord = true;
        } else if (c >= 65 && c <= 90 /* is Upper case */) {
            sb.write(String.fromCharCode(c)); // Do nothing
            insideWord = true;
        } else {
            sb.write(String.fromCharCode(c));
        }
      }
  }
  return sb.toString();
}

// NOTE:: These text conversion methods are for naive and rapidly written for demo purposes and should not be trusted.
String toCamelCase(String input, bool capFirst) {
  if (input == null) {
      return null;
  }
  var split = input.split('_');
  
  if (split.isNotEmpty) {
      var sb = StringBuffer();
      var isFirst = true;

      split.forEach((element) {
        sb.write(toFirstCap(element, isFirst ? capFirst : true));
        isFirst = false;
      });
      return sb.toString();
  } else {
      return '';
  }
  
}

/// TEXT ENCODERS END --------------------------------------

void main() {
  var document = setupModel();

  var packageName = 'com.myjava.package';
  document.tables.forEach((table) {

    var outer = PicoWriter();
    var camelCaseTableId = toCamelCase(table.id, true /* capFirst */);
    outer.writeln('');
    outer.writeln('// $camelCaseTableId.java');
    outer.writeln('');
    outer.writeln('package $packageName;');
    outer.writeln('');
    outer.writeln_r('public class $camelCaseTableId {');
    var inner = outer.createDeferredWriter();
    outer.writeln('');

    table.fields.forEach((field) {
       var ccFieldId    = toCamelCase(field.id, false /* capFirst */);
       var ccFieldIdCap = toCamelCase(field.id, true /* capFirst */);
       var fieldType    = field.type;

       switch (fieldType) {
         case typeChar: {

            // Create the field
            inner.writeln('private String $ccFieldId;');

            // Create the setter
            outer.writeln_r('public void set$ccFieldIdCap(String $ccFieldId) {');
            outer.writeln('this.$ccFieldId = $ccFieldId;');
            outer.writeln_l('}');

            // Create the setter
            outer.writeln_r('public String get$ccFieldIdCap() {');
            outer.writeln('return $ccFieldId;');
            outer.writeln_l('}');

         }
         break;
         case typeInteger: {
            // Create the field
            inner.writeln('private int $ccFieldId;');

            // Create the setter
            outer.writeln_r('public void set$ccFieldIdCap(int $ccFieldId) {');
            outer.writeln('this.$ccFieldId = $ccFieldId;');
            outer.writeln_l('}');

            // Create the setter
            outer.writeln_r('public int get$ccFieldIdCap() {');
            outer.writeln('return $ccFieldId;');
            outer.writeln_l('}');
         }
         break;
         case typeDateTime: {
            // Create the field
            inner.writeln('private java.util.Date $ccFieldId;');

            // Create the setter
            outer.writeln_r('public void set$ccFieldIdCap(java.util.Date $ccFieldId) {');
            outer.writeln('this.$ccFieldId = $ccFieldId;');
            outer.writeln_l('}');

            // Create the setter
            outer.writeln_r('public java.util.Date get$ccFieldIdCap() {');
            outer.writeln('return $ccFieldId;');
            outer.writeln_l('}');
         }
         break;
         default: {
           // Ignore
         }
       }
    });


    outer.writeln_l('}');
    print(outer.toString());

  });

}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ainslec/picocog-dart/issues

## Tips / Tricks

* It helps to create a bunch of deferrals straight away.
* Always match indents at point of writing. Never wait to match an indent.
* Always generate distinctive comments in your generated source - these act as anchors for debugging your source code generator.
* Always use the writeln_lr for '} else if (…​) {' lines.
* Be aware of the escaping requirements of the language for which you are generating sourcecode.
* Store commonly use strings in member variables and/or constants.
* If you have access to the API at code generation time for which you are generating source for, make use of the YourApiClass.class.getName() method call. This will make sure that your code generator will automatically cope with class name refactoring.
* If you are nice to other people, they tend to act nicer towards you.

## License

Picocog Dart is available under the Apache Version 2.0 license. See the LICENSE file for the full license.

## Java Version

The original Java version of Picocog is available [here](https://github.com/ainslec/picocog).

## Dart Library Boilerplate

Non-code boilerplate for the dart library was created from a template made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Author

Picocog, and Picocog-Dart are written by Chris Ainsley.

## Keywords

Code Generation, Code Generation, Template Library, Lightweight, Tiny, Model Based Development, Model Driven Development.