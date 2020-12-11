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

import 'internal.dart';

/// Can be used by dependency injectors
abstract class SourceCodeContributor {
   void contribute(PicoWriter m);
}

class PicoWriter implements PicoWriterItem {

    static final String SEP = '\n';
    static final String DI  = '   ';

    int                      _indents                    = -1;
    int                      _numLines                   = 0;
    bool                     _generateIfEmpty            = true;
    bool                     _generate                   = true;
    bool                     _normalizeAdjacentBlankRows = false;
    bool                     _isDirty                    = false;

    // Used for aligning columns in the multi string writeln method.
    final List<List<String>>       _rows                       = []; 
    final List<PicoWriterItem>     _content                    = [];
    final StringBuffer             _sb                         = StringBuffer ();
    String                         _ic  /* Indent chars*/      = DI;

    PicoWriter () {
        _indents = 0;
    }

    PicoWriter.customIndex (String indentText) {
        _indents = 0;
        _ic      = indentText ?? DI ;
    }

    PicoWriter.customIndentCustomText (int initialIndent, String indentText) {
        _indents = initialIndent < 0 ? 0 : initialIndent;
        _ic      = indentText ?? DI;
    }

    void indentRight() {
        _indents++;
    }
    
    void indentLeft() {
        _indents--;
        if (_indents < 0) {
          throw Exception('Local indent cannot be less than zero');
        }
    }

    PicoWriter createDeferredWriter() {
        if (_sb.length > 0) {
          _flush();
          _numLines++;
        }
        var inner = PicoWriter.customIndentCustomText(_indents, _ic);
        _content.add(inner);
        _numLines++;
        return inner;
    }
    
    PicoWriter writeln_inner(PicoWriter inner) {
        if (_sb.length > 0) {
          _flush();
          _numLines++;
        }
        _adjustIndents(inner, _indents, _ic);
        _content.add(inner);
        _numLines++;
        return this;
    }
    

    PicoWriter writeln_r(String string) {
        writeln(string);
        indentRight();
        return this;
    }
    
    PicoWriter writeln_l(String string) {
        flushRows();
        indentLeft();
        writeln(string);
        return this;
    }
    
    PicoWriter writeln_lr(String string) {
        flushRows();
        indentLeft();
        writeln(string);
        indentRight();
        return this;
    }
    
    PicoWriter writeln(String string) {
        _numLines++;
        _sb.write(string);
        _flush();
        return this;
    }
    
    PicoWriter writeln_row(List<String> strings) {
        _rows.add(strings);
        _isDirty = true;
        _numLines++;
        return this;
    }
    
    bool isEmpty() {
        return _numLines == 0;
    }
    
    void write(String string)  {
        _numLines++;
        _isDirty = true;
        _sb.write(string);
    }
    
    static void _writeIndentedLine(final StringBuffer sb, final int indentBase, final String indentText, final String line) {
        for (var indentIndex = 0; indentIndex < indentBase; indentIndex++) {
          sb.write(indentText);
        }
        sb.write(line);
        sb.write(SEP);
    }

    void _adjustIndents(PicoWriter inner, int indents, String ic) {
        if (inner != null) {
          inner._content.forEach((item) {
              if (item is PicoWriter) {
                _adjustIndents(item, indents, ic);
              } else if (item is IndentedLine) {
                item.indent = item.indent + indents;
              }
          });
          inner._ic = ic;
        }
    }
    
    bool _render(StringBuffer sb, int indentBase, bool normalizeAdjacentBlankRows, bool lastRowWasBlank) {
        
        if (_isDirty) {
          _flush();
        }
        
        // Some methods are flagged not to be generated if there is no body text inside the method, we don't add these to the class narrative
        if ((!isGenerate()) || ((!isGenerateIfEmpty()) && isMethodBodyEmpty())) {
          return lastRowWasBlank;
        }

        _content.forEach((item) {
          if (item is IndentedLine) {
              var lineText        = item.line;
              var indentLevelHere = indentBase + item.indent;
              var thisRowIsBlank  = lineText.isEmpty;

              if (normalizeAdjacentBlankRows && lastRowWasBlank && thisRowIsBlank) {
                // Don't write the line if we already had a blank line
              } else {
                _writeIndentedLine(sb, indentLevelHere, _ic, lineText);
              }
              
              lastRowWasBlank = thisRowIsBlank;
          } else if (item is PicoWriter) {
              lastRowWasBlank = item._render(sb, indentBase, normalizeAdjacentBlankRows, lastRowWasBlank);
          } else {
              sb.write(item.toString());
          }

        });


        
        return lastRowWasBlank;
    }

    bool isMethodBodyEmpty() {
        return _content.isEmpty && _sb.length == 0;
    }
    
    bool isGenerateIfEmpty() {
        return _generateIfEmpty;
    }
    
    void setGenerateIfEmpty(bool generateIfEmpty) {
        _generateIfEmpty  = generateIfEmpty;
    }
    
    bool isGenerate() {
        return _generate;
    }
    
    void setGenerate(bool generate) {
        _generate = generate;
    }
    
    void _flush() {
        flushRows();
        _content.add(IndentedLine(_sb.toString(), _indents));
        _sb.clear();
        _isDirty = false;
    }
    
    void flushRows() {
        if (_rows.isNotEmpty) {

          var maxWidth = <int>[];

          _rows.forEach((columns) {
              var numColumns = columns.length;
              for (var i=0; i < numColumns; i++) {
                var currentColumnStringValue = columns[i];
                var currentColumnStringValueLength = currentColumnStringValue == null ? 0 : currentColumnStringValue.length;
                if (maxWidth.length < i + 1) {
                    maxWidth.add(currentColumnStringValueLength);
                } else {
                    if (maxWidth[i] < currentColumnStringValueLength) {
                      maxWidth.insert(i, currentColumnStringValueLength);
                    }
                }
              }
          });

          var rowSB = StringBuffer();
          
          _rows.forEach((columns) {
              var numColumns = columns.length;
              for (var i=0; i < numColumns; i++) {
                var currentColumnStringValue = columns[i];
                var currentItemWidth = currentColumnStringValue == null ? 0 : currentColumnStringValue.length;
                var maxWidth1 = maxWidth[i];
                rowSB.write(currentColumnStringValue ?? '');
                
                if (currentItemWidth < maxWidth1) {
                    for (var j=currentItemWidth; j < maxWidth1; j++) {
                      rowSB.write(' '); // right pad
                    }
                }
              }
              _content.add(IndentedLine(rowSB.toString(), _indents));
              rowSB.clear();
          });

          _rows.clear();
        }
    }
    

    void setNormalizeAdjacentBlankRows(bool normalizeAdjacentBlankRows) {
        _normalizeAdjacentBlankRows = normalizeAdjacentBlankRows;
    }
    
    String toStringWithIndents(int indentBase) {
        var sb = StringBuffer();
        _render(sb, indentBase, _normalizeAdjacentBlankRows, false /* lastRowWasBlank */);
        return sb.toString();
    }
    
    @override
    String toString() {
        return toStringWithIndents(0);
    }

}