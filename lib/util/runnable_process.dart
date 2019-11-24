import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/util/waitForEx.dart';

import '../dshell.dart';
import 'dshell_exception.dart';
import 'log.dart';

typedef void LineAction(String line);
typedef bool CancelableLineAction(String line);

class RunnableProcess {
  Future<Process> fProcess;

  final String workingDirectory;

  ParsedCliCommand parsed;

  RunnableProcess(String cmdLine, {this.workingDirectory})
      : parsed = ParsedCliCommand(cmdLine);

  RunnableProcess.fromList(String command, List<String> args,
      {this.workingDirectory})
      : parsed = ParsedCliCommand.fromParsed(command, args);

  String get cmdLine => parsed.cmd + " " + parsed.args.join(" ");

  void start() {
    String workdir = workingDirectory;
    if (workdir == null) {
      workdir = Directory.current.path;
    }
    fProcess = Process.start(parsed.cmd, parsed.args,
        runInShell: false, workingDirectory: workdir);
  }

  void pipeTo(RunnableProcess stdin) {
    fProcess.then((stdoutProcess) {
      stdin.fProcess.then<void>(
          (stdInProcess) => stdoutProcess.stdout.pipe(stdInProcess.stdin));
    });
  }

  // Monitors the process until it exists.
  // If a LineAction exists we call
  // line action each time the process emmits a line.
  void processUntilExit(LineAction stdoutAction, [LineAction stderrAction]) {
    Completer<bool> done = Completer<bool>();

    fProcess.then((process) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (stdoutAction != null) {
          stdoutAction(line);
        }
      });

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (stderrAction != null) {
          stderrAction(line);
        } else {
          print(line);
        }
      });

      // trap the process finishing
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          done.completeError(RunException(exitCode,
              "The command [$cmdLine] failed with exitCode: ${exitCode}"));
        } else {
          done.complete(true);
        }
      });
    });
    waitForEx<bool>(done.future);
  }
}

class ParsedCliCommand {
  String cmd;
  List<String> args;

  ParsedCliCommand(String command) {
    parse(command);
  }

  ParsedCliCommand.fromParsed(this.cmd, this.args);

  void parse(String command) {
    List<String> parts = command.split(" ");

    cmd = parts[0];
    args = List();

    if (parts.length > 1) {
      args = parts.sublist(1);
    }

    if (Settings().debug_on) {
      Log.d("${Directory.current}");
      Log.d("cmd: $cmd args: $args");
    }
  }
}

class RunException extends DShellException {
  int exitCode;
  String reason;
  RunException(this.exitCode, this.reason) : super(reason);
}
