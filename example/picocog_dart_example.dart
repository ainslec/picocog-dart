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

// NOTE:: These text conversion methods are for naive and rapidly written for demo purposes and  SHOULD NOT BE TRUSTED.

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

// NOTE:: These text conversion methods are for naive and rapidly written for demo purposes and SHOULD NOT BE TRUSTED.
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


// void main() {
//   var w = PicoWriter();
//   w.writeln_r('One {');
//   w.writeln_r('Two {');
//   w.writeln_r('Three {');
//   w.writeln('// A Comment here');
//   w.writeln_l('}');
//   w.writeln_l('}');
//   w.writeln_l('}');
//   print(w.toString());
// }