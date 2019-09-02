
CodeMirror.defineInitHook( (cm) => {

  if (!cm.getTextArea || !cm.getTextArea().classList.contains('fill-in')) {
    return
  }

  var editableRanges = new Array();
  var frozenRanges = new Array();
  var texts = cm.getValue().split(/{%([^]+?)%}/);
  cm.setValue("")

  function getLastPos(cm) {
    var line = CodeMirror.Pos(cm.lastLine()).line;
    return {
      line: line,
      ch: cm.getLine(line).length
    }
  }


  var oldMark;
  texts.forEach((s, i) => {
    var from = getLastPos(cm);
    cm.replaceRange(s, CodeMirror.Pos(cm.lastLine()));
    var to = getLastPos(cm);

    if (i % 2 == 0) {
      // mark range frozen
      var mark = cm.markText(from, to, {
        className: 'read-only',
        readOnly: true,
        inclusiveLeft: i == 0,
        inclusiveRight: i == texts.length,
      })
      frozenRanges.push(mark)
      var lastRange = editableRanges[editableRanges.length - 1];
      if (lastRange && !lastRange.to) {
        lastRange.to = mark;
      }
      oldMark = mark;
    } else {
      editableRanges.push({
        from: oldMark,
        to: null,
        text: s,
        inline: from.line == to.line,
      })
    }
  })
  var inlineRanges = editableRanges.filter(r => r.inline);


  function overlaps(pos) {
    return inlineRanges.some(range => {
      var from = range.from.find().to;
      var to = range.to.find().from;
      var hasOverlap =
        pos.line == from.line &&
        pos.ch >= from.ch &&
        pos.line == to.line &&
        pos.ch <= to.ch;
      return hasOverlap;
    })
  }

  cm.on("beforeChange", (cm, change) => {
    if (change.update && overlaps(change.from)) {
      change.update(null, null, [change.text.join("")])
    }
  })

  cm.getValue = function () {
      var i = 0;
      var str = "";

      if (!frozenRanges[i]) {
          return str;
      }
      
      str += frozenRanges[i].getValue()

      if (!editableRanges[i]) {
          return str;
      }

      str += "{%" + editableRanges[i].getValue() + "%}"

      i = i + 1
  }

  /* This does not work because it blocks history in an infinite loop
  cm.on("changes", (cm, changes) => {
    // check that all fillable fields are non-empty.
    // Otherwise, re-add the todo.
    cm.operation(() => {
      editableRanges.forEach( r => {
        var from = r.from.find().to
        var to = r.to.find().from
        var val = cm.getRange(from, to)
        console.log([val])
        if (val == "") {
          if (r.inline) {
            cm.replaceRange(" ", to, to);
          } else {
            cm.setCursor(from)
            cm.execCommand("newlineAndIndent")
          }
        }
      })
    })
  })
  */
})
