use warnings;
use strict;

use MIME::Base64;

use lib '..';
use TCP_Client;


my $mailserver        = shift;
my $port              = shift;
my $username          = shift;
my $password          = shift;
my $from_mailaddress  = shift;
my $to_mailaddress    = shift;

my $username_64 = encode_base64($username);
my $password_64 = encode_base64($password);

TCP_Client::connect($mailserver, $port);

sleep 0.1;


print_answer();

print_and_send("ehlo $mailserver\n");
print_answer();

print_and_send("auth login\n"); # Note: answer base 64 decoded
print_answer();

print_and_send("$username_64"); # Note: base 64 encoding already added newline
print_answer();

print_and_send("$password_64");
print_answer();

print_and_send("mail from: <$from_mailaddress>\n");
print_answer();

print_and_send("rcpt to: <$to_mailaddress>\n");
print_answer();

print_and_send("data\n");
print_answer();

print_and_send("From: \"From Name\" <$from_mailaddress>\n");
print_and_send("To: \"To Name\" <$to_mailaddress>\n");
print_and_send("Date: " . scalar(localtime) . "\n");
print_and_send("Subject: Test\n");
print_and_send("\n");
print_and_send("Hello\n");
print_and_send("This is a test\n");
print_and_send(".\n");
print_answer();
print_and_send("quit\n");
print_answer();

sub print_and_send {
  my $text = shift;


 (my $text_out = $text) =~ s/^/> /gm;

  print "\n";
  print $text_out;
  print "\n";

  TCP_Client::send($text);
}

sub print_answer {

  my $answer = TCP_Client::wait_answer();

  $answer =~ s/334 ([^\x0d\x0a]*)/"334 $1" . ' [' . decode_base64($1) . ']'/e;

  $answer =~ s/^/< /gm;

  print "\n";
  print $answer;
  print "\n";
}
