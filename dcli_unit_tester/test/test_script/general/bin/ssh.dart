#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

/// dcli script generated by:
/// dcli create run_echo.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

void main(List<String> args) {
  final fqdn = args[0];
  // ask( "FQDN of test target:");
  final password = args[1];
  //  ask( 'Password for target:', hidden: true);

  Remote().scp(
    fromHost: fqdn,
    from: ['/tmp/*.dart'],
    recursive: true,
    to: '/tmp',
  );

  Remote().exec(
    host: fqdn,
    command: 'ls  /home/bsutton/*',
    progress: Progress.print(),
  );

  // works except that it doesn't have permission to one dir so throws.
  // Remote.exec(
  //   host: fqdn,
  //   command: r'find  /home/bsutton -name "*.txt"',
  //   progress: Progress.print(),
  // );

  // the arg --name "*.txt" cause our glob parser to throw
  // needs further investigation but doesn't related to remote
  // Remote.exec(
  //   host: fqdn,
  //   command: r'find  /home/bsutton -type f  -name "*.txt" -exec shasum {}  \;',
  //   progress: Progress.print(),
  // );

  // works
  // Remote.exec(
  //     host: fqdn,
  //     password: password,
  //     command: r'find  /etc/openvpn -type f  -exec shasum {}  \;',
  //     progress: Progress.print(),
  //     sudo: true);

  // works
  Remote().scp(fromHost: fqdn, from: ['/etc/asterisk/sip.d/*'], to: '/tmp');

  Remote().scp(
      fromUser: "env['USER']", fromHost: fqdn, from: ['/tmp/*.log'], to: '.');

  Remote().scp(from: ['./*.dart'], toHost: fqdn, to: '/tmp', recursive: true);

  final result = which('copy_secure_dir');
  if (result.found) {
    final copySecureDir = result.path!;

    Remote().scp(from: [copySecureDir], to: '/tmp', toHost: fqdn);
  }

  // dart exe doesn't run on ubuntu 12.04
  // Remote.exec(
  //     host: fqdn,
  //     command: '/tmp/copy_secure_dir',
  //     sudo: true,
  //     password: password);

  Remote().scp(
      recursive: true,
      fromHost: fqdn,
      from: ['/tmp/slow.dart', '/tmp/parent.dart'],
      to: '/tmp');

  final command =
      "mkdir -p  /tmp/etc/openvpn; echo $password  | sudo -Sp '' cp -R /etc/openvpn/* /tmp/etc/openvpn; echo hi; ls -l /tmp/etc/openvpn; echo $password | sudo -Sp ''  rm -rf /tmp/etc/openvpn ; echo ho; ls /tmp";

  Remote().exec(
      host: fqdn,
      command: command,
      sudo: true,
      password: password,
      progress: Progress.print());

  Remote().execList(
      host: fqdn,
      commands: [
        'mkdir -p  /tmp/etc/openvpn',
        'rm -rf /tmp/etc/openvpn/*',
        'cp -R /etc/openvpn/* /tmp/etc/openvpn',
        'echo hi',
        'ls -l /tmp/etc/openvpn',
        'rm -rf /tmp/etc/openvpn',
        'echo ho',
        'ls /tmp'
      ],
      sudo: true,
      password: password,
      progress: Progress.print());

  touch('dcli.txt', create: true);
  Remote().scp(from: ['dcli.txt'], toHost: fqdn, to: '/tmp');

  //  "ssh -t bsutton@auditord.onepub.dev '/home/bsutton/git/auditor/backup.sh nowString.sql'"
  final now = DateTime.now();
  Remote().exec(
      host: 'bsutton@auditord.onepub.com.au',
      command: '/home/bsutton/git/auditor/backup.sh $now.sql');

  Remote().scp(
      fromHost: 'auditord.onepub.dev',
      from: ['/home/bsutton/git/auditor/$now.sql'],
      to: '.');

  // // command = 'pwd;ls *';
  // var cmdArgs = <String>[];
  // cmdArgs.clear();
  // cmdArgs.add(
  //     '-T'); // disable the psuedo terminal as we are echoing the password to sudo
  // // cmdArgs.add('-A');
  // cmdArgs.add(fqdn);
  // // cmdArgs.add('--');
  // cmdArgs.add("echo $password | sudo -Skp ''  $command");
  // var progress = Progress((line) => print(green('$line')),
  //     stderr: (line) => print(red(line)));
  // startFromArgs('ssh', cmdArgs, progress: progress, terminal: false);
}
