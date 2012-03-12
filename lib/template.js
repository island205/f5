(function() {
  exports.templates = {
    qunit: {
      html: "<link rel=\"stylesheet\" href=\"http://code.jquery.com/qunit/qunit-git.css\" type=\"text/css\"></link>\n<script type=\"text/javascript\" src=\"http://code.jquery.com/qunit/qunit-git.js\"></script>\n<script type=\"text/javascript\" src=\"#jsFilePath#\"></script>\n<h1 id=\"qunit-header\">#title#</h1>\n<h2 id=\"qunit-banner\"></h2>\n<div id=\"qunit-testrunner-toolbar\"></div>\n<h2 id=\"qunit-userAgent\"></h2>\n<ol id=\"qunit-tests\"></ol>\n<div id=\"qunit-fixture\">test markup, will be hidden</div>\n<script type=\"text/javascript\" src=\"#testJsFilePath#\"></script>",
      js: "test(\"Don't let me alone\",function(){\n	ok(false,\"Will you?\");\n});"
    }
  };
}).call(this);
