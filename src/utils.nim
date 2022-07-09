import std/[
  terminal, 
  httpcore,
  
  strutils
]

type 
  LogType* = enum
    Info = "info",
    Error = "error",
    Warn = "warning",
    Debug = "debug"

proc log*(logType: LogType = Info, message: string) =
  case logType:
  of Info:
    stdout.styledWrite fgBlue, "INFO ", fgDefault
  of Error:
    stdout.styledWrite fgRed, "ERR  ", fgDefault
  of Warn:
    stdout.styledWrite fgYellow, "WARN ", fgDefault
  of Debug:
    stdout.styledWrite fgMagenta, "DBG  ", fgDefault
  stdout.writeLine message

proc logHeaders*(headers: HttpHeaders) =
  for key, val in headers:
    stdout.styledWriteLine "| ", fgMagenta, key, fgWhite, ": ", val

proc logBody*(body: string) =
  for line in body.split("\n"):
    stdout.styledWriteLine "| ", fgMagenta, "[body] ", fgWhite, line