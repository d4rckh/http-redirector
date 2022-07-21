# http redirector

this is a lightweight http server that redirects requests to another http server.

![image](https://user-images.githubusercontent.com/35298550/178099525-8cf116a4-c2d5-49ed-b67e-9bb7baf584bc.png)

## building
1. install nim using [dom96/choosenim](https://github.com/dom96/choosenim)
2. clone the repo
3. run `nimble install argparse`
4. run `nim -d:ssl c src/main.nim`

## options and flags
```
Usage:
   [options]

Options:
  -h, --help
  -p, --port=PORT            The port to listen on. (default: 0)
  -u, --url=URL              The base URL to which to forward requests.
  -H, --hostheader=HOSTHEADER
                             The value for the host header. (default: )
  -P, --printheaders         Print request & response headers.
  -b, --printbody            Print request & response body.
  -t, --transparent          Be transparent about client's original IP address (X-Forwarded-For).
```
## examples
`--port 8080 --url http://localhost:8000`: listen for htp requests on port 8080 and forward every request to localhost:8000.

`--port 8080 --url http://localhost:8000 -t`: same as above example but now the original client IP address is sent via the headers (`X-Forwarded-For`)
