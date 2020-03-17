#!/usr/bin/perl -lw
# for i in a a2 z; do echo $i; cd $i; ../extract.pl *.txt ; cd ..; done

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
    }
    .next {
      float: right;
    }
    .next, .prev {
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
    next if $case =~ /buy a house/;  # skip this example.
    $case .= " [example]" if $case =~ /forgiveness/;
    push @cases, $case;
    @{$urls{$case}} = ();
    %{$data{$case}} = ();
  } elsif (/^   (\d+\.|\*|-) *(.*)/) {  # second level is url
    next if $case =~ /buy a house/;  # skip this example.
    $url = $2;
    push @{$urls{$case}}, $url;
    @{$data{$case}{$url}} = ();
    $cur = 0;
  } else {  # third+ levels are the taxonomy
    next if $case =~ /buy a house/;  # skip this example.
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
my $title = "Guided Search - Financial Aid";
print F<<"EOF";
<!DOCTYPE html>
<html lang="en">
<head>
  <title>$title</title>
  $htmlstuff
  <style>
  .main {
    padding: 16px;
  }
  .text {
    margin: 16px 0;
  }
  \@media (hover: hover) {
    .start:hover {
      text-decoration: underline;
    }
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
    margin-top: 8px;
  }
  #link:focus {
    outline: 0;
  }
  .is_mobile { display: none; }
  \@media only screen and (max-width: 600px) {
    .is_mobile { display: block; }
  }
  </style>
  <script>
    function resize() {
      var is_mobile = !\$('.is_mobile').is(':hidden');
      if (is_mobile) {
        \$('.demolink').each(function() {
          \$(this).attr('href', \$(this).attr('href').replace('/d/', '/m/'));
        });
      } else {
        \$('.demolink').each(function() {
          \$(this).attr('href', \$(this).attr('href').replace('/m/', '/d/'));
        });
      }
    }
    \$(document).ready(function() { resize(); });
    \$(window).resize(resize);
  </script>
</head>
<body onLoad="document.getElementById('link').focus();">
<div class="header">
  <span class="title">$title</span>
</div>
<div class="is_mobile"></div>
<div class="main">

<div class="text">
<h2>Journey curation tool instructions</h2>

Thank you for helping us work to improve the Search experience for journeys
such as "student loan forgiveness".  Below you will find more information about
this project, and instructions on how to help us deconstruct journeys.<p>

<h3>Background</h3>

For complex and important topics such as <b>[how to pay for college]</b> or
<b>[how to get student loan forgiveness]</b>, Google search results are
dependent on the student knowing what to search for, and results often show a
variety of articles on the topic, each one with a different perspective.  This
can be overwhelming for students and lead to them not getting the information
they need. (<a id="link"
href="https://www.google.com/search?q=how+to+get+student+loan+forgiveness&pws=0&gl=us&gws_rd=cr"
target=_blank>example search results</a>).<p>

Our goal is to guide the user (student) through these complex topics. To do
that, we need to <b>unpack these topics into a set of subtopics</b> (bite-sized
pieces). Sometimes these subtopics can be further unpacked to create a hierarchy of
subtopics. We want to focus on the following principles:<ul>
<li> Subtopics for exploration instead of prescriptive steps, and
<li> Understandable more than comprehensive.
</ul><p>

As part of guiding the user, we also want to provide a <b>well-chosen Google
search query</b> whose search results provide high-quality information on that
subtopic (articles, web answers, videos). Putting these subtopics and queries
together, the Search experience for student loan forgiveness could, for
example, look like <b><a class="demolink" href="../demo/d/01-00.html"
target=_blank>this demo</a></b>, which was built from <a href="../loan.png"
target=_blank>this hierarchy</a> of subtopics and search
queries.  Or for [how to buy a house], it could look like
<b><a class="demolink" href="../demo/d/14-00.html" target=_blank>this
demo</a></b>, built from  <a href="../house.png"
target=_blank>this
hierarchy</a>.<p>

We would like to ask you to <b>combine your domain expertise with information
from the top web results for each topic</b> to construct this hierarchy of
subtopics and the search queries. To make this easier, on the <a href="00.html" target=_blank>next few pages</a>,
we have collected the sections listed in the top results for the
query [how to get student loan forgiveness] and the other use cases.
Please use this as raw material for your subtopic hierarchies. For a
bird's-eye view, we have partially collapsed the information, but use
the "Expand" link on the top of each page (or the "&#xBB;" links) to see
more details.

<h3>Instructions</h3>
<ul>

<li> Make a copy of <a
href="https://docs.google.com/document/d/1QaPGS90GRlmqh3CMMBfjCKdrlE6gr5oOjhwq1REUP2E/edit?usp=sharing"
target=_blank>this Google doc</a> and share it with us (sitaram\@google.com).
This is where you will summarize your ideas at the end of the process.

<li> For each use case in this doc that you are familiar with, please go through
the following steps:<ol>

<li> First take a moment to think about how you would break it down into
subtopics to explain it to a user seeking advice.  Feel free to take scratch
notes on your notepad.

<li> Try grouping these points into a hierarchy similar to <a
href="../loan.png" target=_blank>the ones above</a> (ideally 2-3 levels deep,
3-5 subtopics in each list), which might resemble chapters and sections of a book on this topic.

<li> Then look over the <a href="00.html" target=_blank>raw material</a>
extracted from web results on these pages (hit "next" to go through all the use
cases).  Look for topics you might have missed, or different ways of organizing
these topics, and try to improve your hierarchy.

<li> Transcribe your hierarchy for this use case back into your copy of the
Google doc (if you did the work on a notepad).

<li> For each subtopic (at every level of the hierarchy), identify a
good search query, and <a href="../queries.png" target=_blank>add it after a
slash ("/")</a> after the subtopic.  Try Googling a few search queries that you
think are reasonable for that topic, and capture which one seems to have useful
information on the search results page. (You don\'t have to read the webpages).

<li> Proceed to the next use case.
</ol>

<li> Please make sure you shared the doc with sitaram\@google.com.
</ol></ul><p>

Thank you so much for your time and assistance!<P>

Best,<br>
Education team
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
      box-shadow: 1px 1px 1px #ccc;
      outline: 0;
      padding: 8px 8px 0 8px;
      width: 33%;
      vertical-align: top;
    }
    .linkbox {
      background-color: #dfefff;
      height: 16px;
      padding: 8px 16px;
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

    \@media only screen and (max-width: 600px) {
      td {
        display: table-row;
        box-shadow: none;
      }
      .header {
        height: 44px;
      }
      .main {
        top: 76px;
      }
      .title {
        display: inline-block;
        font-size: 20px;
        padding-top: 8px;
      }
      .next, .prev {
        padding: 0 8px;
      }
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
    print F "<div class=\"linkbox\"><a id=\"link\" href=\"$url\" target=_blank>$domain</a></div>";
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
