#!/usr/bin/perl -lw
# Save to text: https://docs.google.com/document/d/1QaPGS90GRlmqh3CMMBfjCKdrlE6gr5oOjhwq1REUP2E/edit#
# demo.pl "How to X - Financial Aid.txt"

use URI::Escape;
use HTML::Entities;

my $dir = "demo";  # needs to exist

my @cases = @paths = @path = %seen = ();
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
    $case =~ s/ \[demo\]//;
    push @cases, $case;
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
  }
}
if ($case) { printcase(); }

sub printcase {
  my %file = ();
  my $pathnum = 0;
  foreach my $path (@paths) {
    $file{$path} = sprintf("%02d-%02d", $casenum, $pathnum);
    $pathnum++;
  }

  my $p = 0;
  foreach my $path (@paths) {
    print $path, " @ ", $file{$path}, " / ", $query{$path}, " ", $p;
    fetch_url($file{$path}, $query{$path});  # do not overwrite.

    open(F, "$dir/$file{$path}-orig.html") or die "$dir/$file{$path}-orig.html: $!";
    undef $/; $_ = <F>; $/ = "\n"; close F;

    s|^|
      <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css" />
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
      <style>
      #promos { display: none; }
      #taw { display: none; }
      .box {
        border: 1px solid #a8c8ff;
        background-color: #f0f6ff;
        padding: 20px 20px 0 200px;
        margin: 8px 0 18px -200px;
        width: 200%;
      }
      .title {
        font-weight: bold;
        font-size: 16px;
        color: #222;
      }
      .bc {
        text-decoration: none;
      }
      .bc:active, .bc:visited, .bc:hover, .bc:link {
        color: #222;
      }
      .bc:hover {
        text-decoration: underline;
        color: #1a0dab;
      }
      .expando {
        position: absolute;
        left: 120%;
        top: 20px;
        width: 60px;
        font-weight: bold;
      }
      .toc {
        display: none;
        line-height: 20px;
        margin-top: 8px;
      }
      .bar {
        white-space: nowrap;
        overflow-x: auto;
        margin: 9px 0px;
      }
      .bar::-webkit-scrollbar {
        display: none;
      }
      .chip {
        font-size: 15px;
        display: inline-block;
        border: 1px solid #a8c8ff;
        border-radius: 24px;
        padding: 8px 16px;
        margin: 4px;
        cursor: pointer;
        color: #222;
      }
      .chip:hover {
        text-decoration: underline;
        color: #1a0dab;
      }
      .icon {
        margin: 0 4px -4px 0;
        fill: #3C4043;
      }
      .attrib {
        border-top: 1px solid #ddd;
        display: inline-block;
        padding: 6px;
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
      </style>
      <script>
        \$(document).ready(function() {
          \$('.expando').click(function() {
            if (\$('.toc').is(':hidden'))
              \$(this).text('Collapse');
            else
              \$(this).text('View all');
            \$('.toc').slideToggle(150);
          });
        });
      </script>
      |s;
      # <base href="https://www.google.com/">
    s/â€Ž//gs;
    s/ Â//gs;
    s|"/images|"https://www.google.com/images|g;

    my $stuff = "<div class=\"box\">";
    $stuff .= "<div class=\"title\">";

    my $n = 0;
    my @parts = split / > /, $path;
    my $prefix = "";
    foreach my $part (@parts) {
      $prefix .= ($prefix eq "" ? "" : " > ") . $part;
      $stuff .= " &#x203A; " if $n;
      $part = $n == 0 ? $part : lc $part;
      if ($n != $#parts) {
        my $target = $file{$prefix};
        $part = "<a class=\"bc\" href=\"$target.html\">$part</a>";
      }
      $stuff .= $part;
      $n++;
    }
    $stuff .= "</div>";

    $stuff .= "<div class=\"expando\">View all</div>";
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
      
      my $url = $target ? "../$dir/$target.html" : search($query{$path . " > " . $child});
      $stuff .= "<a href=\"$url\"><div class=\"chip\">$svg$child</div></a>";

      print $child, " / ", $query{$path . " > " . $child};
      print "---> ".$target if $target;
    }
    print "";
    $stuff .= "</div>";

    # attribution
    if ($casenum < 12) {  # 12+ are miscellaneous use cases.
      $stuff .= "<div class=\"attrib\">Source: <a class=\"attriblink\"
        href=\"https://www.ncan.org/page/About\">National College Attainment
        Network</a>, <a class=\"attriblink\" href=\"https://www.nasfaa.org/About_NASFAA\">National
        Association of Student Financial Aid Administrators</a></div>";
    }
    $stuff .= "</div>";

    #s|<div id="topstuff">|$&$stuff|;
    s|<div id="center_col">|$&$stuff|;

    open(F, ">$dir/$file{$path}.html") or die "$dir/$file{$path}.html: $!"; print F; close F;
    $p++;
  }
}


sub search($) {
  my $query = shift;
  return "https://www.google.com/search?q=" . uri_escape($query) . "&pws=0&gl=us&gws_rd=cr";
}

sub fetch_url($$) {
  my $file = shift;
  my $query = shift;
  unless (-s "$dir/$file-orig.html") {
    my $url = search($query);
    print("Fetching \"$url\"");
    my $ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.137 Safari/537.36";
    system("wget -O \"$dir/$file-orig.html\" -U\"$ua\" \"$url\"");
  }
}
