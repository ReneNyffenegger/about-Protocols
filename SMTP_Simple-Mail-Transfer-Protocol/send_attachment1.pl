use warnings;
use strict;

use MIME::Base64;
use File::Slurp;

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

TCP_Client::wait_answer();

TCP_Client::send("ehlo $mailserver\n");
TCP_Client::wait_answer();

TCP_Client::send("auth login\n"); # Note: answer base 64 decoded
TCP_Client::wait_answer();

TCP_Client::send("$username_64"); # Note: base 64 encoding already added newline
TCP_Client::wait_answer();

TCP_Client::send("$password_64");
TCP_Client::wait_answer();

TCP_Client::send("mail from: <$from_mailaddress>\n");
TCP_Client::wait_answer();

TCP_Client::send("rcpt to: <$to_mailaddress>\n");
TCP_Client::wait_answer();

TCP_Client::send("data\n");
TCP_Client::wait_answer();

my $seperator = '###This#is#the#seperator###';

my $date = scalar(localtime);



TCP_Client::send(<<HEADER);
From: "From Name" <$from_mailaddress>
To: "To Name" <$to_mailaddress>
Date: $date
Subject: Test with Attachment
Content-Type: text/html

HEADER

TCP_Client::send(<<HTML_TEXT);
<html><head><title>Some Title</title>
<style type='text/css'>
  * { font-family: Garamond; }
  body {background-color: #eeeeff}
</style>
</head>
<body>
<h1>This is a test</h1>
And here's some text
HTML_TEXT




TCP_Client::send(".\n");
TCP_Client::wait_answer();
TCP_Client::send("quit\n");
TCP_Client::wait_answer();
