package TCP_Client;

use warnings;
use strict;

use IO::Socket::INET;
use IO::Select;

my $select;
my $sock;

sub connect {

  my $host = shift;
  my $port = shift;

  $sock  = new IO::Socket::INET (
             PeerAddr    => $host,
             PeerPort    => $port,
             Proto       => 'tcp',
             Timeout     =>  1,
             Blocking    =>  0
         ) 
         or die "Could not connect";

  $select = new IO::Select;
  $select -> add($sock);

}


sub wait_answer {

  my $ret = '';
  my $answer_started = 0;

  while (not $answer_started and $sock->connected) {
    sleep 0.1;

    while ($sock->connected and $select -> can_read) {

      $answer_started = 1;

      my $buf;
      while ($sock->connected) {
        $sock -> recv($buf, 10);
        return $ret unless $buf;
        $ret .= $buf;
      }
    }
  }
}

sub send {

  my $text = shift;
  $sock -> send($text);

}

1;
