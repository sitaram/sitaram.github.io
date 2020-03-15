#!/usr/bin/perl -lw
# (echo a; cd a; ../x.pl Algorithmic\ extraction_clustering\ candidates_depth\=1.txt ; echo z; cd ../z; ../x.pl candidates.txt)

my $htmlstuff = <<EOF;
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width">
    <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <style>
    body, pre {
      font-family: Roboto, sans-serif, arial;
      margin: 0;
    }
    .header {
      background-color: #dfefff;
      position: fixed;
      height: 28px;
      padding: 16px;
      width: calc(100% - 32px);
      border-bottom: 1px solid #ccc;
      box-shadow: 0px 3px 3px #ddd;
    }
    .prev {
      float: left;
      padding: 0 16px;
    }
    .next {
      float: right;
      padding: 0 16px;
    }
    .title {
      display: flex;
      justify-content: center;
      font-weight: bold;
      font-size: 24px;
    }
    body {
      position: relative;
    }
    .main {
      position: fixed;
      overflow: auto;
      top: 60px;
      bottom:0;
      max-height: 100%;
    }
    </style>
EOF


my @cases = %urls = %data = ();
my $case;
my $url;
my $cur = 0;  # current depth
my $maxdepth = 1;

while (<>) {
  s/[\r\n]*$//;
  next if /^$/;

  # drop header
  next if /Algorithmic extraction.clustering candidates/ ||
    /make a copy of this doc to collect your set of candidates/ ||
    /either add the candidate decompositions under each query directly/;

  if (/^(\d+\.|\*|-) *(.*)/) {  # top level is use case
    $case = $2;
    next if $case =~ /buy a house$/;  # skip this example.
    #$case .= " [example]" if $case =~ /buy a house$/;
    push @cases, $case;
    @{$urls{$case}} = ();
    %{$data{$case}} = ();
  } elsif (/^   (\d+\.|\*|-) *(.*)/) {  # second level is url
    next if $case =~ /buy a house$/;  # skip this example.
    $url = $2;
    push @{$urls{$case}}, $url;
    @{$data{$case}{$url}} = ();
    $cur = 0;
  } else {  # third+ levels are the taxonomy
    next if $case =~ /buy a house$/;  # skip this example.
    s/^      //;
    next if /^         /;  # remove stuff too deep

    s/^( *)(.*)/$2/;
    my $depth = length($1) / 3;
    for (; $cur > $depth; $cur--) {
      push @{$data{$case}{$url}}, "</ul>";
    }
    for (; $cur < $depth; $cur++) {
      push @{$data{$case}{$url}},
           $cur >= $maxdepth ? "<span class=\"expando chevron\">&#xBB;</span><ul class=\"collapsed\">" : "<ul>";
    }
    s/^( *)[-\*] /$1/g;
    s/ ([,?!\)\.])/$1/g;  # " , " -> ", " etc.
    s/\( /\(/g;
    s/\.$//;
    push @{$data{$case}{$url}}, "<li>" . ucfirst($_);
  }
}
for (; $cur > 0; $cur--) {
  push @{$data{$case}{$url}}, "</ul>";
}

open(F, ">index.html") or die $!;
my $title = "How to X - Financial Aid";
print F<<"EOF";
<!DOCTYPE html>
<html lang="en">
<head>
  <title>$title</title>
  $htmlstuff
  <style>
  .main {
    margin: 16px;
  }
  .text {
    margin: 16px 0;
  }
  .start:hover {
    text-decoration: underline;
  }
  .start {
    display: inline-block;
    background-color: #4285F4;
    color: white;
    font-size: 18px;
    padding: 12px 18px;
    border-radius: 24px;
  }
  li {
    margin-bottom: 12px;
  }
  </style>
</head>
<body onLoad="document.getElementById('link').focus();">
<div class="header">
  <span class="title">$title</span>
</div>
<div class="main">

<div class="text">
Hello focus group participant,
<ol>
<li> For complex and important topics like the ones listed below, for example
<b>how to get student loan forgiveness</b>, often Google search results are
slightly overwhelming and not too useful today. They show a number of different
articles on the topic, but often each one brings in a different perspective -
and a different number of options for how to proceed, from 5, 8, to 80
different ways in this case.  Digesting these articles to form a mental model
and a course of action takes time and experience, which many users (in this
case mostly students) lack.  <a
id="link" href="https://www.google.com/search?q=how+to+get+student+loan+forgiveness&pws=0&gl=us&gws_rd=cr"
target=_blank>Check out this search page</a>.

<li> We would like to guide the user through these complex topics. For that, we
want to <b>unpack such topics into a set of subtopics</b> for the user to digest
in bite-sized pieces.  Some of these topics are themselves complex, and can be
further decomposed to create a hierarchy of subtopics.  These subtopics may be key questions
to think about, or a breakdown of options,
or the standard steps to follow, or a combination
of all of these.
They need
to be subtopics to explore rather than prescriptive instructions.
They need to be understandable rather than comprehensive: a
hierarchy of depth 2 or 3, with 4-5 subtopics per level would be ideal.  There may
not be one right way to break down a topic, and that is okay.
For example, for
student loan forgiveness, there are broadly three paths: repayment-plan based options,
career-based options, and extraordinary circumstances.  There are also common
questions such as "do I qualify" and "where to sign up". Career-based options
further break down into programs for nurses, teachers, military, etc. <a
href="" target=_blank>See this example
hierarchy</a>.

<li> In addition to showing users the hierarchy of subtopics, for each
subtopic, we would like to guide the user to a <b>well-chosen Google search query</b>
whose search results provide high-quality information on that subtopic.  We would ask you
to try out a few different queries until the search page (including results, the answer panel, etc.) collectively contain
useful information.  In our experience we have found that the choice of words matters a lot.
For
example, for the option "career-based", a search query that brings up a useful
search result page is <a
href="https://www.google.com/search?q=career-based+student+loan+forgiveness+programs&pws=0&gl=us&gws_rd=cr"
target=_blank>career-based student loan forgiveness programs</a>.

<li> That way, we
can enable the user to go deeper if they want to into each subtopic, by using the ability
of Search to return a diverse set of high-quality articles, videos, and
other Search features for each query, rather than send the user to a single article for
all the subtopics.  Putting these subtopics and queries together, the Search
experience for student loan forgiveness could now look like <a href="../demo/"
target=_blank>this demo</a>, for example.

<li> We would like to leverage a combination of your domain expertise and a
synthesis of information from the top web results, to construct this hierarchy of
subtopics and choose the search queries. On the next page, we have collected
the sections listed in the top 20 results for the query "how to get student
loan forgiveness".  For easy viewing we have partially collapsed the information, but
use the "Expand" link on the top of each page (or the equivalent
"&#xBB;" links) to see more details.  <a href="00.html" target=_blank>See this page for raw material</a>.

<li> We would like to ask you to make a copy of <a
href="https://docs.google.com/document/d/1QaPGS90GRlmqh3CMMBfjCKdrlE6gr5oOjhwq1REUP2E/edit?usp=sharing"
target=_blank>this Google doc</a>, and share it with us
(aliciasab\@google.com).  For each use case listed in the doc, please look at
the raw material from web results, then step back and think about how you would
explain it to a student seeking advice. Then try to formulate a hierarchical breakdown of
subtopics.  For each subtopic, please try out a few search queries that you think are
reasonable, and try to find one that returns the most useful information. We have
done the first one as an example, but please feel free to replace or improve
that one as well, in addition to the others.
</ol>

Thank you,<br>
Education team, Google.
</div>

<a class="startlink" href="00.html"><div class="start">Start &gt;&gt;</div></a>
<div class="text">
<b>Or jump to a specific use case:</b>
<ol>
EOF
my $num = 0;
foreach my $case (@cases) {
  my $this = (sprintf "%02d", $num) . ".html";
  print F "<li><a href=\"$this\">$case</a>";
  $num++;
}
print F "</ol></div></body></html>";
close F;

$num = 0;
foreach my $case (@cases) {
  my $this = (sprintf "%02d", $num) . ".html";
  print $this;
  open(F, ">$this") or die $!;
  my $next = (sprintf "%02d", (($num + 1) % scalar(@cases))). ".html";
  my $prev = (sprintf "%02d", (($num - 1 + scalar(@cases)) % scalar(@cases))). ".html";
  $num++;

  print F<<"EOF";
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <title>$num. $case</title>
    $htmlstuff
    <style>
    table {
      table-layout: fixed;
      width: 100%;
    }
    td {
      border: 1px solid #ccc;
      outline: 0;
      padding: 8px 8px 0 8px;
      width: 33%;
      vertical-align: top;
    }
    #link {
      font-weight: bold;
    }
    #link:focus {
      outline: 0;
    }
    .collapsed {
      display: none;
    }
    .expando {
      width: 60px;
    }
    </style>

    <script>
      \$(document).ready(function() {
        \$('.expando').each(function() {
          if (\$('.collapsed').get().length == 0) {
            \$(this).css('visibility', 'hidden');
          }
        });

        \$('.expando').click(function() {
          \$('.collapsed').each(function() {
            if (\$(this).is(':hidden')) \$(this).slideDown(200);
            else \$(this).slideUp(200);
          });
          \$('.expando').each(function() {
            \$(this).text(\$(this).text() == "Expand" ? "Collapse" :
                          \$(this).text() == "Collapse" ? "Expand" :
                          \$(this).text() == "\\u00bb" ? "\\u00ab" :
                          \$(this).text() == "\\u00ab" ? "\\u00bb" : "");
          });
        });
      });
    </script>
  </head>
  <body onLoad="document.getElementById('link').focus();">
  <div class="header">
    <a class="prev" href="$prev">&lt; Previous</a>
    <a class="prev" href="index.html">Main page</a>
    <a class="next" href="$next">Next &gt;</a>
    <a class="next expando" href="javascript:void(0);">Expand</a>
    <span class="title">$num.&nbsp;&nbsp;$case</span>
  </div>
  <div class="main">
  <table>
EOF

  my $cols = 3;
  my $n = 0;
  foreach my $url (@{$urls{$case}}) {
    next unless scalar(@{$data{$case}{$url}});
    if ($n % $cols == 0) {
      print F "<tr>";
    }
    print F "<td>";
    my $domain = $url;
    my $more = "";
    $domain =~ s|http.*?://||;
    $domain =~ s|/.*||;
    $more = $& if $domain =~ s|\.\w\w$||;
    $more = $& . $more if $domain =~ s|\.\w\w\w?$||;
    $domain =~ s|.*\.||;
    $domain = ucfirst $domain.$more;
    print F "<a id=\"link\" href=\"$url\" target=_blank>$domain</a>";
    print F "<ul>";
    foreach my $line (@{$data{$case}{$url}}) {
      print F $line;
    }
    print F "</ul></td>";
    if ($n % $cols == $cols - 1) {
      print F "</tr>";
    }
    $n++;
  }
  print F "</table></div></body></html>";
  close F;
}
