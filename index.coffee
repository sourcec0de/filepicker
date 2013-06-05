# filepicker.js is a Node.js filepicker library with streaming
Filepicker = (apiKey) ->
  @apiKey = apiKey
  this
request = require("request")
fs = require("fs")
Stream = require("stream")
http = require("http")
BASE_URL = "https://www.filepicker.io"
endpoints = {}
endpoints.tempStorage = BASE_URL + "/api/path/storage/"

# read() - Retrieves a file as utf8 for now
# Arguments: full filepicker file url, options not used for now and callback of (err,data)
Filepicker::read = (url, options, callback) ->
  req_options =
    host: "www.filepicker.io"
    port: 80
    path: url.substring(BASE_URL.length)
    method: "GET"

  req = http.request(req_options, (res) ->
    
    # Set encoding
    res.setEncoding "utf8"
    body = ""
    res.on "data", (chunk) ->
      body += chunk.toString("utf8")

    res.on "end", ->
      callback null, body

  )
  req.on "error", (e) ->
    console.log "problem with request: " + e.message

  
  # write data to request body
  req.write "\n"
  req.end()


# stream() - Retrieves a file as utf8 for now
# Arguments: full filepicker file url, options not used for now and callback of (err,data)
Filepicker::stream = (url, options) ->
  stream = new Stream()
  stream.writeable = true
  stream.readable = true
  stream.write = (buffer) ->
    stream.emit "data", buffer

  stream.end = (buffer) ->
    stream.emit "end", buffer

  req_options =
    host: "www.filepicker.io"
    port: 80
    path: url.substring(BASE_URL.length)
    method: "GET"

  req = http.request(req_options, (res) ->
    res.pipe stream
  )
  req.on "error", (e) ->
    console.log "problem with request: " + e.message

  
  # write data to request body
  req.write "\n"
  req.end()
  stream


# store() - Stores a file to filepicker
# Arguments: fileconents string, options {persist:true} and callback of (err,data) also an encoding flag
Filepicker::store = (fileContents, options, callback, noencode) ->
  if typeof options is "function"
    noencode = !!callback
    callback = options
    options = {}
  else
    noencode = !!noencode
  options = {}  unless options
  options.filename = ""  unless options.filename
  callback = callback or ->

  unless fileContents
    callback new Error("Error: no contents given")
    return
  returnData = undefined
  fileContents = (if noencode then fileContents else new Buffer(fileContents).toString("base64"))
  request
    method: "POST"
    headers:
      Accept: "application/json"

    url: endpoints.tempStorage + options.filename
    form:
      fileContents: fileContents
      apikey: @apiKey
      persist: !!options.persist
  , (err, res, body) ->
    if err
      callback err
      return
    returnJson = undefined
    try
      returnJson = JSON.parse(body)
    catch e
      callback new Error("Unknown response"), null, body
      return
    if returnJson.result is "ok"
      returnData = returnJson.data
      callback null, returnData.url, returnData.data
    else if returnJson.result is "error"
      callback new Error(returnJson.msg)
    else
      callback new Error("Unknown response"), null, returnJson


Filepicker::getUrlFromBuffer = (buf, options, callback) ->
  if typeof options is "function"
    callback = options
    options = {}
  if not buf or (buf not instanceof Buffer)
    callback new Error("Error: must use a Buffer")
    return
  @getUrlFromData buf.toString("base64"), options, callback, true

Filepicker::getUrlFromUrl = (url, options, callback) ->
  self = this
  if typeof options is "function"
    callback = options
    options = {}
  unless url
    callback new Error("Error: no url given")
    return
  request
    url: url
    encoding: null
  , (err, res, buf) ->
    if err or not buf
      callback err
      return
    self.getUrlFromBuffer buf, options, callback, true


module.exports = Filepicker