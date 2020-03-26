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

sub arrow_back_svg { '<svg class="' . $_[0] . '" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>'; }
sub search_svg { '<svg class="' . $_[0] . '" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M20.49 19l-5.73-5.73C15.53 12.2 16 10.91 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.41 0 2.7-.47 3.77-1.24L19 20.49 20.49 19zM5 9.5C5 7.01 7.01 5 9.5 5S14 7.01 14 9.5 11.99 14 9.5 14 5 11.99 5 9.5z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>'; }
sub keyboard_arrow_right_svg { '<svg class="' . $_[0] . '" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M9.71 18.71l-1.42-1.42 5.3-5.29-5.3-5.29 1.42-1.42 6.7 6.71z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>'; }
sub keyboard_arrow_down_svg { '<svg class="' . $_[0] . '" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M12 16.41l-6.71-6.7 1.42-1.42 5.29 5.3 5.29-5.3 1.42 1.42z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>'; }
sub keyboard_arrow_up_svg { '<svg class="' . $_[0] . '" xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 0 24 24" width="18px"><path d="M17.29 15.71L12 10.41l-5.29 5.3-1.42-1.42L12 7.59l6.71 6.7z"/><path d="M0 0h24v24H0V0z" fill="none"/></svg>'; }
sub color_circle_icon { '<img class="' . $_[0] . '" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyMCAyMCI+PGNpcmNsZSBmaWxsPSIjZmZmIiBjeD0iMTAiIGN5PSIxMCIgcj0iMTAiLz48cGF0aCBmaWxsPSIjMzRBODUzIiBkPSJNMTAgMThjLTIuMTQgMC00LjE1LS44My01LjY2LTIuMzRsMi4xMi0yLjEyQzcuNDEgMTQuNDggOC42NiAxNSAxMCAxNXMyLjU5LS41MiAzLjU0LTEuNDZsMi4xMiAyLjEyQTcuOTQ5IDcuOTQ5IDAgMCAxIDEwIDE4eiIvPjxwYXRoIGZpbGw9IiNFQTQzMzUiIGQ9Ik0xMy41NCA2LjQ2QzEyLjU5IDUuNTIgMTEuMzQgNSAxMCA1cy0yLjU5LjUyLTMuNTQgMS40Nkw0LjM0IDQuMzRDNS44NSAyLjgzIDcuODYgMiAxMCAyczQuMTUuODMgNS42NiAyLjM0bC0yLjEyIDIuMTJ6Ii8+PHBhdGggZmlsbD0iI0ZCQkMwNSIgZD0iTTQuMzQgMTUuNjZDMi44MyAxNC4xNSAyIDEyLjE0IDIgMTBzLjgzLTQuMTUgMi4zNC01LjY2bDIuMTIgMi4xMkM1LjUyIDcuNDEgNSA4LjY2IDUgMTBzLjUyIDIuNTkgMS40NiAzLjU0bC0yLjEyIDIuMTJ6Ii8+PHBhdGggZmlsbD0iIzQyODVGNCIgZD0iTTE1LjY2IDE1LjY2bC0yLjEyLTIuMTJjLjk0LS45NSAxLjQ2LTIuMiAxLjQ2LTMuNTRzLS41Mi0yLjU5LTEuNDYtMy41NGwyLjEyLTIuMTJDMTcuMTcgNS44NSAxOCA3Ljg2IDE4IDEwcy0uODMgNC4xNS0yLjM0IDUuNjZ6Ii8+PC9zdmc+Cg==" class="K8Ci1" alt="" data-atf="1" height="20" width="20">'; }

while (<>) {
  s/[\r\n]*$//;
  next if /^$/;
  # drop header
  next if /How to X - / || /^\[.*\]/;

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
  } elsif (/^( *)\* (.*?) *(\/ *(.*))?/) {  # Format:  * <label> / <query>
    my $depth = length($1) / 3;
    my $label = $2;
    my $query = $4 || $2;
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
      .iows2d {
        display: block !important;  /* no flex */
      }
      .box {
        padding-top: 0;
        margin-bottom: 0;
      }
      .title {
        display: none;
      }
      .subtitle {
        display: none;
      }
      .expando {
        margin-top: -32px;
      }
      .chip, .toc {
        font-weight: normal;
      }
      \@media only screen and (max-width: 600px) {
        .box {
          margin: -8px -16px 0px -8px;
          width: 100%;
        }
        .expando {
          margin-top: -30px;
        }
        .bar {
          margin-top: 4px;
          margin-bottom: 8px;
        }
        .box, .bar {
          padding: 0 16px 0 8px;
        }
        .subtitle {
          margin: -4px 0 8px 16px;
        }
        .chiplink:first-child {
          margin-left: 16px;
        }
      }
EOF

    my $blue_style = 1 && !$top_stories ? <<"EOF" : "";
      \@media only screen and (max-width: 600px) {
        /* move above \@media if desktop needs to be blue */
        .box {
          width: 200%;
          border-bottom: 1px solid #85C2FF;
          box-shadow: inset 0px 4px 10px 0 #DAEDFF;
          background: radial-gradient(farthest-side circle at 108px 34px, #EDF6FF, #DAEDFF 86%);
          margin-bottom: 8px;
          margin-top: -8px;
          padding-top: 20px;
          padding-bottom: 20px;
        }
        .expando {
          margin-right: 50%;
          background-color: white;
          border: 1px solid #85C2FF;
        }
        /* this part stays here for mobile */
        .box {
          margin-top: 0;
          width: calc(100% - 31px);
          margin-bottom: 8px;
        }
        .expando {
          margin-right: 0;
        }
        .nextlink {
          margin-right: 16px;
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
        padding: 0 20px 0 200px;
        margin: 8px 0 0 -200px;
        position: relative;
        margin-bottom: 8px;
      }
      .title {
        font-weight: bold;
        font-size: 18px;
        color: #222;
      }
      .subtitle {
        font-size: 14px;
        margin-top: 8px;
      }
      .subtitle-icon {
        vertical-align: -30%;
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
        margin-top: 4px;
      }
      .expando {
        float: right;
        font-weight: normal;
        margin-left: 8px;
        margin-top: -3px;
      }
      .expando, .expando:link, .expando:active, .expando:visited {
        text-decoration: none;
        color: #222;
      }
      .expando-hide {
        display: none;
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
      .toc-title {
        display: none;
      }
      .outerbar {
        position: relative;
      }
      .bar {
        white-space: nowrap;
        overflow-x: auto;
        margin: 8px 0 8px 0;
      }
      .bar::-webkit-scrollbar {
        display: none;
      }
      .scrollright {
        display: none;
        position: absolute;
        right: -12px;
        z-index: 1000;
        border: 1px solid #ddd;
        box-shadow: 0 0 0 1px rgba(0,0,0,0.04), 0 4px 8px 0 rgba(0,0,0,0.20);
        border-radius: 32px;
        background-color: white;
        padding: 4px;
        top: 50%;
        transform: translateY(-50%);
      }
      .scrollright-svg {
        fill: #3C4043;
      }
      .chip {
        font-size: 14px;
        line-height: 14px;
        display: inline-block;
        border: 1px solid #ddd;
        border-radius: 24px;
        padding: 6px 12px;
        cursor: pointer;
        color: #222;
      }
      .chip2 {
        margin: 4px;
      }
      \@media (hover: hover) {
        .chip:hover {
          text-decoration: underline;
          color: #1a0dab;
        }
      }
      .icon {
        display: inline;
        margin: 0 4px -4px 0;
        fill: #3C4043;
      }
      .expando-right-icon {
        display: none;
      }
      .expando-down-icon, .expando-up-icon {
        display: inline;
        margin: 0 0 -4px 0;
        fill: #3C4043;
      }
      .expando-up-icon {
        display: inline;
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
      .is_mobile { display: none; }

      \@media only screen and (max-width: 600px) {
        .is_mobile { display: block; }
        .attrib {
          padding: 6px 16px 12px;
        }
        .box {
          padding: 12px 16px 4px;
          margin: 0;
          width: calc(100% - 31px);
        }
        .bar {
          margin: 8px -16px 8px;
          padding: 0 16px;
        }
        .scrollright {
          display: none;
        }
        .toc {
          padding-top: 56px;
          position: fixed;
          overflow: scroll;
          width: 100%;
          height: 100%;
          top: 0;
          left: 100%;  /* off screen */
          right: 0;
          bottom: 0;
          background-color: white;
          z-index: 10000000;
        }
        .toc-back {
          padding: 16px;
          margin: -16px;
        }
        .toc-title {
          position: fixed;
          left: 100%;  /* off screen */
          right: 0;
          top: 0;
          background: white;
          display: block;
          font-size: 18px;
          color: #222;
          line-height: 18px;
          margin-bottom: 16px;
          padding: 12px;
          padding-top: 16px;
          border-bottom: 1px solid #ccc;
          box-shadow: 0 3px 3px #ddd;
        }
        .toc-line {
          line-height: 32px;
        }
        .toc-title-text {
          vertical-align: 33%;
          margin-left: 12px;
        }
        .nextlink {
          margin-right: 0;
          margin-bottom: 8px;
        }
        .expando {
          margin-right: 0;
        }
        .expando-right-icon {
          display: inline;
          margin: 0 0 -4px 0;
          fill: #3C4043;
        }
        .expando-down-icon {
          display: none;
        }
        .chiplink:first-child {
          margin-left: 8px;
        }
      }
      $blue_style
      $top_stories_style
      </style>
      <script>
        function update_scrollbutton() {
          var lastChip = \$('.chip2').last();
          var is_mobile = !\$('.is_mobile').is(':hidden');
          if (!is_mobile && lastChip.get().length &&
              lastChip.offset().left + lastChip.outerWidth() > \$('.outerbar').offset().left + \$('.outerbar').outerWidth()) {
            \$('.scrollright').show();
          } else {
            \$('.scrollright').hide();
          }
        }
        \$(document).ready(function() {
          update_scrollbutton();
          \$('.scrollright').click(function() {
                                   console.log(\$('.bar').scrollLeft());
            \$('.bar').animate({scrollLeft: \$('.bar').scrollLeft() + 300}, 200,
                               update_scrollbutton);
          });

          \$('.expando').click(function() {
            var is_mobile = !\$('.is_mobile').is(':hidden');
            if (is_mobile) {
              \$('.toc').show().animate({left: 0}, 200);
              \$('.toc-title').show().animate({left: 0}, 200);
              window.history.pushState('forward', null, '');
              \$(window).on('popstate', function() {
                \$('.toc').animate({left: '100%'}, 200);
                \$('.toc-title').animate({left: '100%'}, 200);
              });
            } else {
              if (\$('.toc').is(':hidden')) {
                \$(this).data('text', \$(this).html());
                \$(this).html(\$('.expando-hide').html());
              } else {
                \$(this).html(\$(this).data('text'));
              }
              \$('.toc').slideToggle(150);
            }
          });
          \$('.toc-back').click(function() {
            \$('.toc').animate({left: '100%'}, 200);
            \$('.toc-title').animate({left: '100%'}, 200);
          });

        });

      </script>
      |s;
      # <base href="https://www.google.com/">
    s/â€Ž//gs;
    s/ Â//gs;
    s|"/(images\|logos)|"https://www.google.com/$1|g;

    my $stuff = "<div class=\"is_mobile\"></div>";
    $stuff .= "<div class=\"box\">";
    my $keyboard_arrow_up_svg = keyboard_arrow_up_svg("expando-up-icon");
    my $keyboard_arrow_down_svg = keyboard_arrow_down_svg("expando-down-icon");
    my $keyboard_arrow_right_svg = keyboard_arrow_right_svg("expando-right-icon");
    $stuff .= "<div class=\"chip expando\">${keyboard_arrow_down_svg} All topics${keyboard_arrow_right_svg}</div>";
    $stuff .= "<div class=\"expando-hide\">${keyboard_arrow_up_svg}Hide</div>";
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

    my $color_circle_icon = color_circle_icon("subtitle-icon");
    $stuff .= "<div class=\"subtitle\">${color_circle_icon} &nbsp;Explore this topic &nbsp;&middot; &nbsp;<a class=\"bc\" href=\"javascript:void(0);\">Learn more</a></div>";

    $stuff .= "<div class=\"toc\">";
    my $arrow_back_svg = arrow_back_svg("icon toc-back");
    $stuff .= "<div class=\"toc-title\">${arrow_back_svg} <span class=\"toc-title-text\">Related topics</span></div>";
    my $i = 0;
    foreach my $t (@paths) {
      if ($i == 0) { $i++; next; }
      my $u = $t;
      $u =~ s/[^>]*> */>/g;
      $u =~ s/(^>*)(.*)/$2/;
      my $e = "&emsp;" x (length($1)*2);
      if ($i == $p) { $u = "<b>$u</b>" }
      $u = "$e<a class=\"bc toc-line\" href=\"$file{$t}.html\">$u</a>";
      $stuff .= $u;
      $stuff .= "<br>";
      $i++;
    }
    $stuff .= "</div>";

    $stuff .= "</div>";

    $stuff .= "<div class=\"outerbar\">";
    $stuff .= "<div class=\"bar\">";
    foreach my $child (@{$children{$path}}) {
      my $target = $file{$path . " > " . $child};
      my $url = $target ? "$target.html" : search($query{$path . " > " . $child}, -1);
      my $search_svg = search_svg("icon");
      $stuff .= "<a class=\"chiplink\" href=\"$url\"><div class=\"chip chip2\">$search_svg$child</div></a>";
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
    $stuff .= "</div>";  # bar

    $stuff .= "<div class=\"scrollright\">" . keyboard_arrow_right_svg("scrollright-svg") . "</div>";
    $stuff .= "</div>";  # outerbar

    # attribution
    if ($casenum < $num_finaid) {  # rest are horizontal use cases.
      $stuff .= "<div class=\"attrib\">Source: <a class=\"attriblink\"
        href=\"https://www.ncan.org/page/About\">National College Attainment
        Network</a>, <a class=\"attriblink\" href=\"https://www.nasfaa.org/About_NASFAA\">National
        Association of Student Financial Aid Administrators</a></div>";
    }

    #s/<div id="topstuff">/$&$stuff/;
    if (/\biows2d\b/) {
      s/<div class=.*?\biows2d\b.*?><div.*?>Top stories<\/div>/$&$stuff/;
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

