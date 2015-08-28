$|=1;
use LWP::Simple qw(get);
use Date::Simple ('date', 'today', 'ymd');

print "start...\n";
$url = 'http://www.vvl.be/vacatures/';
print "show vacancies of last ... days? ";
my $input = <STDIN>;
$count=0;
open(OUT, '>', "output.csv") or die "Could not open file '$filename' $!";
$content = get $url;
my @lines = split /\n/, $content;
my $hash = {};
print "start checking vacancies\n";
foreach my $line (@lines) {
  if($line =~ m/<a href=\"(.*)\">Bekijk(.*)/) {
    $gemeente = $1;
    print "$gemeente\n";
    $str = (split (/\//, $gemeente))[-1];
    $content = get $1;
    my @vac_lines = split /\n/, $content;
    my $v=0;
    my $date=0;
    foreach my $vac_line (@vac_lines) {
      if($vac_line =~ m/<label>(.*)<\/label>/) {
        $v=1;
        $date = $1;
      }
      if($vac_line =~ m/<h3><a href=\"(.*)\">(.*)<\/a><\/h3>/ && $v==1) {
        my $vacature = {
          url => $1,
          date => $date,
          name => $2
        };
        push @{$hash->{$gemeente}}, $vacature;
        $v=0;
      }
    }
  }
}

foreach my $key (keys %{$hash}) {
  $keystr = (split (/\//, $key))[-1];
  foreach my $value (@{$hash->{$key}}) {
    my $day = (split(/\//,$value->{date}))[0];
    my $month = (split(/\//,$value->{date}))[1];
    my $year = (split(/\//,$value->{date}))[2];
    my $diff = abs(today() - ymd($year,$month,$day));
    if($diff<$input) {
      $count++;
      print OUT "$keystr;".$value->{name}.";".$value->{date}.";".$value->{url}."\n";
    }
  }
}
print "$count vacancies found\n";
print "end!\n";
my $input = <STDIN>;
