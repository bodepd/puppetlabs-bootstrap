# Define: puppetlabs::account
#
#   This defined resource type manages user accounts.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define puppetlabs::account(
  $homedir=false,
  $uid,
  $gid,
  $password='!!',
  $groups=[ "wheel", "adm" ],
  $email=false,
  $comment="")
{
  $module = "puppetlabs"
  $source = "puppet:///modules/${module}"
  $name_real = $name
  $email_real = $email ? {
    false => "${name_real}@puppetlabs.com",
    default => $email,
  }
  $homedir_real = $homedir ? {
    false => "/home/${name_real}",
    default => $homedir,
  }
  $uid_real = $uid ? { false => undef, default => $uid }
  $gid_real = $gid ? { false => undef, default => $gid }
  $password_real = $password
  $groups_real = $groups
####
  File {
    owner => $uid_real,
    group => $gid_real,
    mode => "0644",
    replace => false,
  }
####
  puppetlabs::rcfiles {
    "$name_real":
      user    => "$name_real",
      group   => "$gid_real",
      homedir => "$homedir_real";
  }
  group {
    "${name_real}":
      ensure => "present",
      gid    => $gid_real,
  }
  user {
    "${name_real}":
      ensure   => "present",
      home     => $homedir_real,
      password => $password_real,
      uid      => $uid_real,
      gid      => $gid_real,
      groups   => $groups_real,
      require  => [ Group["${name_real}"], ],
  }
  file {
    "${homedir_real}":
      ensure  => directory,
      require => [ User["$name_real"], Group["$name_real"] ];
    "${homedir_real}/.ssh":
      ensure => directory,
      mode   => "0700";
    "${homedir_real}/.ssh/authorized_keys":
      source => [ "${source}/authorized_keys.${name_real}",
                  "${source}/authorized_keys", ];
  }
}
#
