var tree;
let state = { path: [], demo: false };
let is_mobile = true, was_mobile = true;

function showDemo(node, children) {
  if (is_mobile) $('#panel').show().animate({left: 0}, 200);
  else $('#panel').show().css('left', '400px');

  $('#panel').css('top', $('#titlebar').outerHeight());

  $('.placeholder-for-query').text(node);
  $('.placeholder-for-query-input').val(node.toLowerCase());

  $('.main').parent().find('.chipsbox').remove();
  if (children.length > 0) {
    var chipsbar, chipsbox = $('<div/>', { 'class': 'chipsbox' }).append(
        $('<div/>', { 'class': 'chipstitle' }).text(node),  // "How to" variant?
        chipsbar = $('<div/>', { 'class': 'chipsbar' }),
        $('<a/>', { 'class': 'chips-attribution',
        'href': 'https://www.nasfaa.org/About_NASFAA' })
          .append('Source: National Association of Student Financial Aid Administrators'));
    for (var i in children) {
      var searchSVG = '<svg class="chip-icon-svg" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M20.49 19l-5.73-5.73C15.53 12.2 16 10.91 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.41 0 2.7-.47 3.77-1.24L19 20.49 20.49 19zM5 9.5C5 7.01 7.01 5 9.5 5S14 7.01 14 9.5 11.99 14 9.5 14 5 11.99 5 9.5z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>';
      chipsbar.append($('<div/>', {class: 'chip'}).click(function() {
        window.open('https://www.google.com/search?q=' + escape($(this).text().toLowerCase()));
      }).append(searchSVG, children[i].query));
    }
    $('.main').prepend(chipsbox);
  }

  $('#demo').hide();
  if (is_mobile) $('#demo-close').show();
}

function positionAddButton() {
  var top = $('#list').offset().top + $('#list').height() + 8;
  var maxTop = $(window).height() - 100;
  if (top > maxTop) top = maxTop;
  $('#add').css('top', top).css('bottom', 'initial').show();
}

function showList(children) {
  $('#listbox').css('top', $('#titlebar').outerHeight());
  $('#list').html('');

  if (is_mobile) {
    if (!$('#panel').is(':hidden'))
      $('#panel').animate({left: '100%'}, 200, function() { $(this).hide(); });
  } else $('#panel').show().css('left', '400px');
  $('#demo-close').hide();

  for (var i in children) {
    addItem(children[i].query, children[i].subtopics);
  }

  $("#list")
    .sortable({ handle: '.drag-icon', axis: 'y' })
    .on("sortupdate", updateFn);
  document.getSelection().removeAllRanges();
  $("#list").disableSelection();

  positionAddButton();
}

function updateFn(e) {
  e.stopPropagation();

  // Find our place (based on state) in the tree.
  var node = root;
  var parent = children = tree;
  var found_i = -1;
  for (var p in state.path) {
    node = state.path[p];
    var found = false;
    for (var i in children) {
      if (children[i].query == node) {
        parent = children;
        children = children[i].subtopics;
        found = true;
        found_i = i;
        break;
      }
    }
    if (!found) break;  // Url malformed, break infinite loop.
  }

  var children = [];
  $('#list').children().each(function(i, li) {
    var item = $(li).find(".item");
    var child = { query: item.text() };
    if (item.data('children')) child.subtopics = item.data('children');
    children.push(child);
  });
  if (found) parent[found_i].subtopics = children;
  else tree = children;
  console.log('update.node:', node);
  // console.log('      .children:', children);
  // Persist.
  if (typeof(Storage) == "function") {
    localStorage.h2xTree = JSON.stringify(tree);
  }

  if (!is_mobile) showDemo(node, children);
}

// List editing.
function editFn() {
  var li = $(this).parent();
  var item = li.find('.item');

  // move text to val.
  var text = item.text();
  item.text('');
  item.val(text);

  var deleteSVG = '<svg class="trash-icon-svg" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#000000"><path d="M15 4V3H9v1H4v2h1v13c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V6h1V4h-5zm2 15H7V6h10v13zM9 8h2v9H9zm4 0h2v9h-2z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>';
  li.append($(deleteSVG).mousedown(function(e) {
    var input = $(this).parent().find('input');
    if (confirm("Delete this topic '" + input.val() + "' and all its subtopics?")) {
      input.val('').trigger('blur');
    }
  }));

  var input = $('<input/>')
    .bind("click", function(e) { e.stopPropagation(); })
    .bind("keyup", function (e) {
      if (e.keyCode == 13) $(this).trigger("blur");
      else if (e.keyCode == 27) $(this).trigger("blur", "escape");
    })
    .appendTo(item)
    .focus()
    .blur(function (e, key) {
      var input = $(this);
      var item = input.parent();
      var li = item.parent();
      item.text(key == "escape" ? item.val() : input.val().trim());
      // If value is empty then delete the list item.
      if (item.text() == "") li.remove();
      input.remove();
      li.find('.trash-icon-svg').remove();
      if (key != "escape") updateFn(e);
      document.getSelection().removeAllRanges();
      $("#list").disableSelection();
      positionAddButton();
    })
    .val(text)
    .scrollLeft(10000);

  // Don't end up with a new input below the phone keyboard.
  $('#listbox').scrollTop(10000000);
  $("#list").enableSelection();
}

function addItem(node, children) {
  var dragSVG = '<svg class="icon-svg" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#555"><path d="M11 18c0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2 2 .9 2 2zm-2-8c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0-6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm6 4c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>';
  var editSVG = '<svg class="icon-svg" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#555"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/><path d="M0 0h24v24H0z" fill="none"/></svg>';

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
  if (typeof(Storage) != "function" || localStorage.h2xTree == null ||
      localStorage.h2xTreeVersion != baseTreeVersion) {
    tree = baseTree;
    localStorage.h2xTree = JSON.stringify(tree);
    localStorage.h2xTreeVersion = baseTreeVersion;
    console.log('bootstrap', localStorage.h2xTree.substr(0,50));
  } else if (tree == null) {
    tree = JSON.parse(localStorage.h2xTree);
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
      if (children[i].query == node) {
        children = children[i].subtopics;
        found = true;
        break;
      }
    }
    if (!found) break;  // Url malformed, break infinite loop.
  }
  if (children == null) children = [];
  // console.log('      .node:', node);
  // console.log('      .children:', children);

  // Title.
  $('#title').text(node);
  $('#breadcrumbs').text(state.path.length > 1 ?
      state.path.slice(0, state.path.length-1).join(' > ') + ' >': '');
  $("#titlebar").disableSelection();
  if (node == root) { $('#back').hide(); $('#menu').show(); $('#demo').hide(); }
  else { $('#back').show(); $('#menu').hide(); if (is_mobile) $('#demo').show(); }

  if (!is_mobile || state.demo) showDemo(node, children);
  if (!is_mobile || !state.demo) showList(children);
  positionAddButton();
}

$(document).ready(function() {
  $(window).resize(function() {
    is_mobile = $('#is_mobile').is(':visible');
    if (!is_mobile) state.demo = false;
    if (was_mobile != is_mobile) {
      was_mobile = is_mobile;
      render(state);
    }
    positionAddButton();
  });
  $(window).trigger("resize");

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
  $("#add").click(function() {
    addItem("").trigger("click");
    positionAddButton();
  });

  // Reset.
  $("#reset").click(function() {
    if (confirm("Lose all edits and reset to original state?")) {
      delete localStorage.h2xTree;
      delete localStorage.h2xTreeVersion;
      location.reload();
    }
  });

  // Initial.
  window.history.replaceState(state, null, "");
  render(state);
});
