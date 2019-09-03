var debug_cm = null;
CodeMirror.defineInitHook( (cm) => {

  if (!cm.getTextArea || !cm.getTextArea().classList.contains('fill-in')) {
    return
  }
  debug_cm = cm;

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

  function getRangeValue({from, to}) {
      return cm.getRange(from, to)
  }
  function getEditableRangeValue({from, to}) {
      return getRangeValue({from: from.find().to, to: to.find().from})
  }
  function getStringContent() {
    var i = 0;
    var str = "";
    while (true) {
      if (!frozenRanges[i]) {
        return str;
      }
      str += getRangeValue(frozenRanges[i].find())
      if (!editableRanges[i]) {
        return str;
      }
      str += "{%" + getEditableRangeValue(editableRanges[i]) + "%}"
      i = i + 1
    }
  }
  cm.getStringContent = getStringContent;
  cm.getValue = function () {
    return getStringContent()
  }
  cm.save = function () {
    cm.getTextArea().value = getStringContent()
  }

})

function studio_init_template_code_fill(well, pid, problem)
{
    studio_init_template_code(well, pid, problem);
}

function load_input_code_fill(submissionid, key, input)
{
    if(key in input) {
        codeEditors[key].toTextArea();
        var elem = $('textarea[name="'+key+'"]')
        if (input[key].template == elem.attr('data-x-template')) {
            elem[0].value = input[key].input;
        } else {
            elem[0].value = elem.attr('data-x-template')
        }
        registerCodeEditor(elem[0], elem.attr('data-x-language'), elem.attr('data-x-lines'));
    } else {
        // TODO: console.log("No idea what to do here")
    }
}
