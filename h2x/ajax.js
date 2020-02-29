  /*
  GET https://www.googleapis.com/customsearch/v1?key=INSERT_YOUR_API_KEY&cx=017576662512468239146:omuauf_lfve&q=lectures
    function hndlr(response) {
      for (var i = 0; i < response.items.length; i++) {
        var item = response.items[i];
        // in production code, item.htmlTitle should have the HTML entities escaped.
        document.getElementById("content").innerHTML += "<br>" + item.htmlTitle;
      }
    }
  script src="https://www.googleapis.com/customsearch/v1?key=YOUR-KEY&cx=017576662512468239146:omuauf_lfve&q=cars&callback=hndlr"
  */

  /*
  $.ajax({
      url: "http://www.google.com/search?q=foo",
      dataType: "jsonp",
      type: "POST",
      contentType: "application/json; charset=utf-8",
      jsonpCallback: 'processJSONPResponse', // add this property

      success: function (result, status, xhr) {
          alert(result);
      },
      error: function (xhr, status, error) {
          alert("Error")
      }
  });
  */


