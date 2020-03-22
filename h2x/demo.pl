#!/usr/bin/perl -lw
# Save to text:
#  - fin aid - https://docs.google.com/document/d/1QaPGS90GRlmqh3CMMBfjCKdrlE6gr5oOjhwq1REUP2E/edit#
#  - horizontal - https://docs.google.com/document/d/1RcADfV9u4IID_XkEDuRj1x5HlPMLy29SxS4QDR2GFjg/edit#
# demo.pl *.txt

use URI::Escape;
use HTML::Entities;

my $num_finaid = 12;  # for attribution to NCAN/NASFAA

my $mdir = "demo/m";  # needs to exist
my $ddir = "demo/d";  # needs to exist

my @cases = @casenum = @casehasdata = @paths = @path = %seen = ();
my $case;
my $casenum = 0;
my %query = %children = ();

while (<>) {
  s/[\r\n]*$//;
  next if /^$/;
  # drop header
  next if /How to X - Financial Aid/ || /Please make a copy/ || /Format:/;

  if (/^(\d+\.) *(.*)/) {  # top level is use case
    if ($case) { printcase(); }
    $casenum = $1;
    $case = $2;
    $case =~ s/ \[.*?\]//g;
    push @cases, $case;
    push @casenum, $casenum;
    push @casehasdata, 0;
    %children = ();
    %query = ();
    @paths = ();
    %seen = ();
    @path = ($case);
    $query{$case} = lc $case;
  } elsif (/^( *)\* (.*?) *\/ *(.*)/) {  # Format:  * <label> / <query>
    my $depth = length($1) / 3;
    my $label = $2;
    my $query = $3;
    $#path = $depth;
    my $path = join(" > ", @path);
    push @paths, $path unless $seen{$path};
    print "push $path" unless $seen{$path};
    $seen{$path} = 1;
    push @{$children{$path}}, $label;
    my $subpath = $path." > ".$label;
    push @paths, $subpath unless $seen{$subpath};
    print "push sub $subpath" unless $seen{$subpath};
    $seen{$subpath} = 1;
    $query{$path . " > " . $label} = $query;
    push @path, $label;
    $casehasdata[$#casehasdata] = 1;
  }
}
if ($case) { printcase(); }

writeindex($mdir);
writeindex($ddir);

sub printcase {
  printonecase($ddir, "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.137 Safari/537.36");
  printonecase($mdir, "Mozilla/5.0 (Linux; Android 10; Pixel 2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.136 Mobile Safari/537.36");
}

sub printonecase($$) {
  my $dir = shift;
  my $ua = shift;

  my %file = ();
  my $pathnum = 0;
  foreach my $path (@paths) {
    $file{$path} = sprintf("%02d-%02d", $casenum, $pathnum);
    $pathnum++;
  }

  my $p = 0;
  foreach my $path (@paths) {
    print $path, " @ ", $file{$path}, " / ", $query{$path}, " ", $p;
    fetch_url($p, $dir, $file{$path}, $query{$path}, $ua);  # do not overwrite.

    open(F, "$dir/$file{$path}-orig.html") or die "$dir/$file{$path}-orig.html: $!";
    undef $/; $_ = <F>; $/ = "\n"; close F;

    my $top_stories = /\biows2d\b/;  # Whether it is the top stories module on the google SRP
    my $top_stories_style = $top_stories ? <<"EOF" : "";
      .box {
        padding-top: 0;
        margin-bottom: 0;
      }
      .title {
        display: none;
      }
      .expando {
        margin-top: -27px;
      }
      .chip, .toc {
        font-weight: normal;
      }
      \@media only screen and (max-width: 600px) {
        .box {
          margin-left: -8px;
        }
        .box, .bar {
          padding: 0;
        }
        .chiplink:first-child {
          margin-left: 16px;
        }
        .box {
          width: 34%;
        }
      }
EOF

    my $blue_style = 0 && !$top_stories ? <<"EOF" : "";
      .box {
        width: 200%;
        border: 1px solid #a8c8ff;
        background-color: #f0f6ff;
        margin-bottom: 8px;
      }
      .expando {
        margin-right: 50%;
      }
      .bar {
        margin-bottom: 8px;
      }
      .chip {
        border: 1px solid #a8c8ff;
      }
      \@media only screen and (max-width: 600px) {
        .expando {
          margin-right: 0;
        }
        .box {
          width: calc(100% - 31px);
          margin-bottom: 8px;
        }
      }
EOF

    s|^|
      <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css" />
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
      <style>
      #promos { display: none; }
      #taw { display: none; }
      #cnt { overflow-y: hidden; }
      .QmUzgb, .U5LfPc, .NFQFxe, .nChh6e { height: fit-content !important; }  /* shorten some divs */
      .kno-kp { background-color: white; }
      .box {
        width: 650px;
        font: initial;
        font-family: Roboto, sans-serif, arial;
        font-size: 15px;
        padding: 20px 20px 0 200px;
        margin: 8px 0 0 -200px;
        position: relative;
        margin-bottom: 8px;
      }
      .title {
        font-weight: bold;
        font-size: 16px;
        color: #222;
      }
      .bc {
        text-decoration: none;
      }
      .bc:active, .bc:visited, .bc:link {
        color: #222;
      }
      \@media (hover: hover) {
        .bc:hover {
          text-decoration: underline;
          color: #1a0dab;
        }
      }
      .nextlink {
        font-size: 14px;
        float: right;
        margin-right: 50%;
        margin-top: 4px;
      }
      .expando {
        float: right;
        margin-left: 8px;
        font-weight: bold;
      }
      .expando, .expando:link, .expando:active, .expando:visited {
        text-decoration: none;
        color: #222;
      }
      \@media (hover: hover) {
        .expando:hover {
          text-decoration: underline;
          color: #1a0dab;
        }
      }
      .toc {
        display: none;
        line-height: 20px;
        margin-top: 8px;
      }
      .bar {
        white-space: nowrap;
        overflow-x: auto;
        margin: 8px 0 0 0;
      }
      .bar::-webkit-scrollbar {
        display: none;
      }
      .chip {
        font-size: 15px;
        display: inline-block;
        border: 1px solid #ddd;
        border-radius: 24px;
        padding: 6px 12px;
        margin: 4px;
        cursor: pointer;
        color: #222;
      }
      \@media (hover: hover) {
        .chip:hover {
          text-decoration: underline;
          color: #1a0dab;
        }
      }
      .icon {
        margin: 0 4px -4px 0;
        fill: #3C4043;
      }
      .attrib {
        border-top: 1px solid #ddd;
        display: inline-block;
        padding: 6px 0;
        color: #70757a;
        font-size: 12px;
      }
      .attriblink:link,
      .attriblink:visited,
      .attriblink:hover,
      .attriblink:active {
        text-decoration: none;
        cursor: pointer;
        color: #70757a;
      }
      .attriblink:active {
        text-decoration: none;
      }

      \@media only screen and (max-width: 600px) {
        .box {
          padding: 12px 16px 4px;
          margin: 0 -1px 0 -1px;
          width: calc(100% - 31px);
        }
        .bar {
          margin: 8px -16px 0;
          padding: 0 16px;
        }
        .nextlink {
          margin-right: 0;
        }
        .expando {
          margin-right: 0;
        }
      }
      $blue_style
      $top_stories_style
      </style>
      <script>
        \$(document).ready(function() {
          \$('.expando').click(function() {
            if (\$('.toc').is(':hidden'))
              \$(this).text('Hide');
            else
              \$(this).text('See all');
            \$('.toc').slideToggle(150);
          });
        });
      </script>
      |s;
      # <base href="https://www.google.com/">
    s/â€Ž//gs;
    s/ Â//gs;
    s|"/(images\|logos)|"https://www.google.com/$1|g;

    my $stuff = "<div class=\"box\">";
    $stuff .= "<div class=\"expando\">See all</div>";
    $stuff .= "<div class=\"title\">";

    my $n = 0;
    my @parts = split / > /, $path;
    my $prefix = "";
    foreach my $part (@parts) {
      $prefix .= ($prefix eq "" ? "" : " > ") . $part;
      $stuff .= " &#x203A; " if $n;
      if ($n != $#parts) {
        my $target = $file{$prefix};
        $part = "<a class=\"bc\" href=\"$target.html\">$part</a>";
      }
      $stuff .= $part;
      $n++;
    }
    $stuff .= "</div>";

    $stuff .= "<div class=\"toc\">";
    my $i = 0;
    foreach my $t (@paths) {
      if ($i == 0) { $i++; next; }
      my $u = $t;
      $u =~ s/[^>]*> */>/g;
      $u =~ s/(^>*)(.*)/$2/;
      my $e = "&emsp;" x (length($1)*2);
      if ($i == $p) { $u = "<b>$u</b>" }
      $u = "$e<a class=\"bc\" href=\"$file{$t}.html\">$u</a>";
      $stuff .= $u;
      $stuff .= "<br>";
      $i++;
    }
    $stuff .= "</div>";

    $stuff .= "<div class=\"bar\">";
    foreach my $child (@{$children{$path}}) {
      my $target = $file{$path . " > " . $child};
      my $svg = '<svg class="icon" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M20.49 19l-5.73-5.73C15.53 12.2 16 10.91 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.41 0 2.7-.47 3.77-1.24L19 20.49 20.49 19zM5 9.5C5 7.01 7.01 5 9.5 5S14 7.01 14 9.5 11.99 14 9.5 14 5 11.99 5 9.5z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>';
      my $url = $target ? "$target.html" : search($query{$path . " > " . $child}, -1);
      $stuff .= "<a class=\"chiplink\" href=\"$url\"><div class=\"chip\">$svg$child</div></a>";
      print $child, " / ", $query{$path . " > " . $child};
      print "---> ".$target if $target;
    }
    if (scalar @{$children{$path}} == 0 && $p < scalar @paths - 1) {  # endpoint - add a next link
      my $n = $paths[$p+1];
      my $t = $paths[$p+1];
      $t =~ s/^.*> *//;
      $stuff .= "<a class=\"bc nextlink\" href=\"$file{$n}.html\">See next: $t &#xBB;</a>";
    }
    print "";
    $stuff .= "</div>";

    # attribution
    if ($casenum < $num_finaid) {  # rest are horizontal use cases.
      $stuff .= "<div class=\"attrib\">Source: <a class=\"attriblink\"
        href=\"https://www.ncan.org/page/About\">National College Attainment
        Network</a>, <a class=\"attriblink\" href=\"https://www.nasfaa.org/About_NASFAA\">National
        Association of Student Financial Aid Administrators</a></div>";
    }
    $stuff .= "</div>";

    #s/<div id="topstuff">/$&$stuff/;
    if (/\biows2d\b/) {
      s/<div class=.*?\biows2d\b.*?>Top stories/$&$stuff/;
    } else {
      s/<div id="(center_col|gsr)">/$&$stuff/;
    }

    open(F, ">$dir/$file{$path}.html") or die "$dir/$file{$path}.html: $!"; print F; close F;
    $p++;
  }
}

sub search($$) {
  my $query = lc(shift);
  my $pathnum = shift;
  return "https://www.google.com/search?q=" . uri_escape($query) . "&pws=0&gl=us&gws_rd=cr"
    . ($pathnum != 0 && $query =~ /^coronavirus\b/i ? "&tbm=nws" : "");
  # if $pathnum == 0, i.e. for the first page in each case, use the google srp top stories
  # for the rest, if it is the coronavirus use case, then use the news property with tbm=nws.
}

sub fetch_url($$$$$) {
  my $pathnum = shift;  # 0 for the first one page in this case, etc.
  my $dir = shift;
  my $file = shift;
  my $query = shift;
  my $ua = shift;
  unless (-s "$dir/$file-orig.html") {
    my $url = search($query, $pathnum);
    print("Fetching \"$url\"");
    system("wget -O \"$dir/$file-orig.html\" -U\"$ua\" \"$url\"");
  }
}

sub writeindex($) {
  my $dir = shift;
  open(F, ">$dir/index.html") or die "$dir/index.html: $!";
  print F<<"EOF";
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <title>How to X demos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width">
    <style>
    body {
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
      padding: 16px;
    }
    .text {
      margin: 16px 0;
    }
    li {
      margin-bottom: 8px;
    }
    #link:focus {
      outline: 0;
    }
    .treebox {
      display: none;
      border: 1px solid #82a5Ff;
      background-color: #dfefff;
      width: 300px;
      padding: 8px;
      margin: 8px;
    }
    .treebox li, .treebox ul {
      margin: 4px;
    }
    </style>
  </head>
  <body>
  <div class="header">
    <span class="title">How to X demos</span>
  </div>
  <div class="main">
  <div class="text">
  <b>How to X financial aid demos:</b>
  <ol>
EOF

  my $i = 0;
  foreach my $case (@cases) {
    if ($i == $num_finaid-1) {
      print F "</ol><b>How to X horizontal use case demos:</b><ol>";
    }
    if ($casehasdata[$i]) {
      my $this = sprintf("%02d-%02d.html", $casenum[$i], 0);
      print F "<li><a href=\"$this\">$case</a>";
    } else {
      print F "<li>$case (not ready)";
    }
    $i++;
  }
  print F "</ol>";
  print F "<b>Produced from these Google docs:</b>";
  print F "<ul>";
  print F "<li><a href=\"https://docs.google.com/document/d/1QaPGS90GRlmqh3CMMBfjCKdrlE6gr5oOjhwq1REUP2E/edit#\" target=_blank>How to X - Financial Aid</a>";
  print F "<li><a href=\"https://docs.google.com/document/d/1RcADfV9u4IID_XkEDuRj1x5HlPMLy29SxS4QDR2GFjg/edit#\" target=_blank>How to X - Horizontal</a>";
  print F "</ul>";

  print F "</div></div></body></html>";
  close F;
}

