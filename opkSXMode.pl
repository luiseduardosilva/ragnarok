################################################
##Openkore :: opkSXMode plugin
##This plugin is licensed under the GNU GPL
##See http://www.gnu.org/licenses/gpl.html for the full license
##Beta version 1.0 by Ninkoman
##For Openkore Ragnarok Online Bot
##Test on Openkore SVN 8448 07/06/13
################################################

package opkSXMode;

use strict;
use Plugins;
use Globals;

Plugins::register('opkSXMode', 'Openkore XKore Utilities', \&on_unload);

my $hooks = Plugins::addHooks(
   ['packet/actor_moved', \&on_parseActor],
   ['packet/actor_exists', \&on_parseActor],
   ['packet/actor_connected', \&on_parseActor],
   ['packet/character_status', \&on_parseActor],
);

sub on_unload {
   Plugins::delHooks($hooks);
}

sub on_parseActor {
   my (undef,$args) = @_;
   return if(!$config{'XKore'});
   my $switch = $args->{switch};

   if ($switch eq "07F7" || $switch eq "07F8" || $switch eq "07F9" || $switch eq "0856" || $switch eq "0857" || $switch eq "0858") {
      antiHideDisplay(\%{$args},5,13);
   }elsif($switch eq "0078" || $switch eq "0079" || $switch eq "007B" || $switch eq "007C" || $switch eq "022A" || $switch eq "022B" || $switch eq "022C" || $switch eq "02ED" || $switch eq "02EE"){
      antiHideDisplay(\%{$args},2,10);
   }elsif($switch eq "02EC"){
      antiHideDisplay(\%{$args},3,11);
   }elsif ($switch eq "0119" || $switch eq "0229"){
      my ($ID, $param2, $param3) = unpack("x2 a4 x2 S2",$args->{RAW_MSG});
      my $actor = Actor::get($ID);
      if ($ID eq $accountID && $param2 & 16) {
         $args->{RAW_MSG} = substr($args->{RAW_MSG},0,8).pack("S",$param2 - 16).substr($args->{RAW_MSG},10,$args->{RAW_MSG_SIZE}-10);
      }elsif(ref($actor)){
         antiHideDisplay(\%{$args},2,8);
      }
   }
}

sub antiHideDisplay {
   my $args = shift;
   my $msg = $args->{RAW_MSG};
   my $ID_ops = shift;
   my $param2_ops = shift;
   my $msg_size = length($msg);
   my $ID = unpack("x${ID_ops} a4", $msg);
   my ($param2, $param3) = unpack("x${param2_ops} S2", $msg);

   if ($ID ne $accountID && ($param3 & 2 || $param3 & 4 || $param3 & 64)) {
      my ($newmsg,$newp2,$newp3);
      if ($param2 & 2) {
         $newp2 = $param2;
      }else {
         $newp2 = $param2 + 2;
      }
      if ($param3 & 2) {
         $newp3 = $param3 - 2;
      }elsif($param3 & 4){
         $newp3 = $param3 - 4;
      }elsif($param3 & 64){
         $newp3 = $param3 - 64;
      }else {
         $newp3 = $param3;
      }
      $args->{RAW_MSG} = substr($msg,0,$param2_ops).pack("S2",$newp2,$newp3).substr($msg,$param2_ops + 4,$msg_size - ($param2_ops + 4));
   }
}

return 1;
