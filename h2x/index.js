var tree;
let state = { path: [], demo: false };

function showDemo(node, children) {
  $('#panel').show().animate({left: 0}, 200);
  $('.placeholder-for-query').text(node);
  $('.placeholder-for-query-input').val(node.toLowerCase());

  $('.main').parent().find('.chipsbox').remove();
  if (children.length > 0) {
    var chipsbar, chipsbox = $('<div/>', { 'class': 'chipsbox' }).append(
        $('<div/>', { 'class': 'chipstitle' }).text(node),  // "How to" variant?
        chipsbar = $('<div/>', { 'class': 'chipsbar' }));
    for (var i in children) {
      chipsbar.append('<div class=chip>' + children[i][0] + '</div>');
    }
    $('.chip').click(function() {
      location.href = 'https://www.google.com/search?q=' + escape($(this).text().toLowerCase());
    });
    $('.main').prepend(chipsbox);
  }

  $('#demo').hide();
  $('#demo-close').show();
}

function showList(children) {
  $('#list').html('');
  if (!$('#panel').is(':hidden')) {
    $('#panel').animate({left: '100%'}, 200, function() { $(this).hide(); });
  }
  $('#demo-close').hide();

  for (var i in children) {
    addItem(children[i][0], children[i][1]);
  }

  $("#list")
    .sortable({ handle: '.drag-icon', axis: 'y' })
    .on("sortupdate", updateFn);
  document.getSelection().removeAllRanges();
  $("#list").disableSelection();
}

function updateFn(e) {
  e.stopPropagation();

  // Find our place (based on state) in the tree.
  var node = root;
  var children = tree;
  for (var p in state.path) {
    node = state.path[p];
    var found = false;
    for (var i in children) {
      if (children[i][0] == node) {
        children = children[i][1];
        found = true;
        break;
      }
    }
    if (!found) break;  // Url malformed, break infinite loop.
  }
  console.log('update.node:', node);
  console.log('      .children:', children);

  children.splice(0, children.length);
  $('#list').children().each(function(i, li) {
    var item = $(li).find(".item");
    children.push([item.text(), item.data('children') || []]);
  });
  // Persist.
  if (typeof(Storage) == "function") {
    localStorage.h2xTree = JSON.stringify(tree);
    console.log('      .store', localStorage.h2xTree.substr(0,50));
  }
}

// List editing.
function editFn() {
  var item = $(this).parent().find('.item');
  var text = item.text();
  item.html('');
  item.val(text);
  $("#list").enableSelection();

  var input = $('<input/>')
    .bind("click", function(e) { e.stopPropagation(); })
    .bind("keyup", function (e) {
      if (e.keyCode == 13) $(this).trigger("blur");
      else if (e.keyCode == 27) $(this).trigger("blur", "escape");
    })
    .appendTo(item)
    .focus()
    .blur(function (e, key) {
      var me = $(this).parent().find('input').remove().end();
      var newVal = $(this).val().trim();
      me.text(key == "escape" ? me.val() : newVal);
      // If value is empty then delete the item.
      if (me.text() == "") me.parent().remove();
      if (key != "escape") updateFn(e);
      document.getSelection().removeAllRanges();
      $("#list").disableSelection();
    })
    .val(text)
    .scrollLeft(10000);
  // Don't end up with a new input below the phone keyboard.
  $('html, body').scrollTop(input.offset().top - 16);
}

function addItem(node, children) {
  var dragSVG = '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#555"><path d="M11 18c0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2 2 .9 2 2zm-2-8c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0-6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm6 4c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>';
  var editSVG = '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#555"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/><path d="M0 0h24v24H0z" fill="none"/></svg>';

  var editElement;
  $('#list').append(
    $('<li/>', { "class": "row ui-state-default ui-sortable-handle" }).append(
      $('<span/>', { "class": "drag-icon" }).append(dragSVG),
      $('<span/>', { "class": "item" })
        .text(node)
        .data('children', children)
        .click(function() {
           state.path.push($(this).text());
           window.history.pushState(state, null, "");
           render(state);
         }),
      editElement = $('<span/>', { "class": "edit-icon" })
        .append(editSVG).click(editFn)));
  return editElement;
}

function getTree() {
  var tree;
  if (typeof(Storage) != "function" || localStorage.h2xTree == null) {
    // Replace "string" by ["string", []]
    function decompressTree(tree) {
      for (var i in tree) {
        if (typeof(tree[i]) == "string") {
          tree[i] = [tree[i], []];
        } else if (typeof(tree[i]) == "object" && tree[i][1] != null) {
          decompressTree(tree[i][1]);
        }
      }
    }
    tree = baseTree;
    decompressTree(tree);
    localStorage.h2xTree = JSON.stringify(tree);
    console.log('bootstrap', localStorage.h2xTree.substr(0,50));
  } else if (tree == null) {
    tree = JSON.parse(localStorage.h2xTree);
    // function compress(tree) { return tree.map(x => x[1].length > 0 ? [x[0], compress(x[1])] : x[0]); }
    // console.log(JSON.stringify(compress(tree), null, 2));
    console.log('parse', localStorage.h2xTree.substr(0,50));
  }
  return tree;
}

function render(state) {
  console.log('render.state:', JSON.stringify(state));

  // Find our place (based on state) in the tree.
  var node = root;
  var children = tree;
  for (var p in state.path) {
    node = state.path[p];
    var found = false;
    for (var i in children) {
      if (children[i][0] == node) {
        children = children[i][1];
        found = true;
        break;
      }
    }
    if (!found) break;  // Url malformed, break infinite loop.
  }
  console.log('      .node:', node);
  console.log('      .children:', children);

  // Title.
  $('#title').text(node);
  $("#titlebar").disableSelection();
  if (node == root) { $('#back').hide(); $('#demo').hide(); $('#title').css('margin-left', '0'); }
  else { $('#back').show(); $('#demo').show(); $('#title').css('margin-left', '34px'); }

  if (state.demo) {
    showDemo(node, children);
  } else {
    showList(children);
  }
}

$(document).ready(function() {
  // Bootstrap from storage.
  tree = getTree();

  // Back button.
  window.onpopstate = function (event) {
    if (event.state) { state = event.state; }
    render(state);
  };

  // Demo.
  $("#demo").click(function() {
    state.demo = true;
    window.history.pushState(state, null, "");
    render(state);
  });

  // Back.
  $("#back").click(function() { history.back(); });
  $("#demo-close").click(function() { history.back(); });

  // Add.
  $("#add").click(function() { addItem("").trigger("click"); });

  // Reset.
  $("#reset").click(function() {
    if (confirm("Lose all edits and reset to original state?")) {
      delete localStorage.h2xTree;
      location.reload();
    }
  });

  // Initial.
  window.history.replaceState(state, null, "");
  render(state);
});
