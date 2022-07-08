
type
  App* = ref object
    httpPort*: int
    hostHeader*: string
    baseUrl*: string

    printHeaders*: bool
    printBody*: bool
    transparent*: bool