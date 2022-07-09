import std/[
  asynchttpserver, 
  asyncdispatch,
  httpclient,

  strutils,
  strformat
]

import argparse

import types, utils

proc main {.async.} =

  let p = newParser:
    option("-p", "--port", help="The port to listen on.", default=some("0"))
    option("-u", "--url", help="The base URL to which to forward requests.", required=true)
    option("-H", "--hostheader", help="The value for the host header.", default=some(""))
    flag("-P", "--printheaders", help="Print request & response headers.")
    flag("-b", "--printbody", help="Print request & response body.")
    flag("-t", "--transparent", help="Be transparent about client's original IP address (X-Forwarded-For).")

  let app = App()

  try:
    let options = p.parse(commandLineParams())
    app.httpPort = parseInt options.port
    app.hostHeader = options.hostheader
    app.printHeaders = options.printheaders
    app.printBody = options.printbody
    app.transparent = options.transparent
    if $options.url[^1] == "/":
      app.baseUrl = options.url[0..^2]
    else:
      app.baseUrl = options.url
  except ShortCircuit as e:
    if e.flag == "argparse_help":
      echo p.help
      quit QuitSuccess

  var server = newAsyncHttpServer()

  server.listen(Port(app.httpPort))
 
  let port = server.getPort

  log Info, fmt"Will redirect http requests to {app.baseUrl}"  
  log Info, fmt"Redirector handling requests on port {port.uint32}"

  proc cb(req: Request) {.async.} =

    var client = newAsyncHttpClient(maxRedirects=5)
    let proxyReqHeaders = req.headers
    if app.hostHeader != "":
      proxyReqHeaders.del("host")
      proxyReqHeaders["host"] = @[app.hostHeader]
    if app.transparent:
      proxyReqHeaders["X-Forwarded-For"] = @[req.hostname]
    echo req.url
    log Info, fmt"REQ {req.reqMethod} {req.hostname} -> redirector -> {app.baseUrl}{req.url.path}?{req.url.query}" 
    if app.printHeaders: logHeaders proxyReqHeaders
    if app.printBody: logBody req.body

    let response = await client.request(
      app.baseUrl & req.url.path & "?" & req.url.query,
      httpMethod=req.reqMethod,
      headers=proxyReqHeaders,
      body=req.body
    )

    log Debug, fmt"Got {response.status}, reading body"

    
    var proxyResponseBody: string
    if response.code == Http304:
      proxyResponseBody = ""
    else:
      proxyResponseBody = await response.body
    # proxyResponseBody = proxyResponseBody.replace("https://example.org", "http://localhost:1234")
    
    log Info, fmt"RES {req.hostname} <- redirector <- {app.baseUrl}{req.url.path} ({response.status})" 
    if app.printHeaders: logHeaders response.headers
    if app.printBody: logBody proxyResponseBody 

    await req.respond(
      code response,
      proxyResponseBody, 
      response.headers
    )
    
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      await sleepAsync(0)

waitFor main()
