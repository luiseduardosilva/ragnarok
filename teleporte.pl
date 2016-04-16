# Ragnarok, plugin teleporte.
package ChangeState;

# Perl includes
use strict;
use Data::Dumper;
use Time::HiRes;
use List::Util;
use Storable;
use Log qw(message);

# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
use Actor;
use Misc;

Plugins::register("cts", "ChangeState", \&on_unload, \&on_reload);

my $hook = Plugins::addHook("target_died", \&update, undef);

sub on_unload {
	Plugins::delHook("target_died", $hook);
}

sub on_reload {
	Plugins::delHook("target_died", $hook);
}

sub update {
	message "Working.\n";
	my $tenpercentsp = (($char->{sp_max})*0,1);
	my $ninetypercentsp = (($char->{sp_max})*0,9);
	if (($char->{sp} <= $tenpercentsp) && $char->{skills}{AL_TELEPORT} && ($config{'route_randomWalk'}) == 0) {
		message "Changing current state to: walking.\n";
		configModify("route_randomWalk", 1);
		configModify("teleportAuto_idle", 0);
		configModify("teleportAuto_search", 0);
		configModify("teleportAuto_useSkill", 1);

	} elsif (($char->{sp} >= $ninetypercentsp) && $char->{skills}{AL_TELEPORT} && ($config{'route_randomWalk'}) == 1) {
		message "Changing current state to: teleporting.\n";
		configModify("route_randomWalk", 0);
		configModify("teleportAuto_idle", 1);
		configModify("teleportAuto_search", 1);
		configModify("teleportAuto_useSkill", 1);
	} elsif ($char->{skills}{AL_TELEPORT} && ($config{'route_randomWalk'}) == 0) {
		message "Keep teleporting.\n";
	} elsif ($char->{skills}{AL_TELEPORT} && ($config{'route_randomWalk'}) == 1) {
		message "Keep walking.\n";
	}
}
1;
