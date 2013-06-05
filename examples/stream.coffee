###
File Streaming Example
From Filepicker

Streaming is a NodeJS convention, its how it achieves
its extreme scalability.
###

# Load Dependencies
Stream = require 'stream'
Filepicker = require('../index')
filepicker = new Filepicker('YOUR_FILEPICKER_API_KEY')

# Create our own stream
# This way we can use nodes pipe to move the data
writeStream = new Stream()
writeStream.writable = true
writeStream.readable = true
###
Note pipe will send all data emited from filepicker.on 'data'
and send that buffered data to writeStream.write
###
writeStream.write = (buffer)->
	# We turn this into what ever format we need
	# using .toString(FORMAT)
	formattedData = buffer.toString('utf8')
	console.log formattedData
	###
	From here we can take our formatted data
	and either emit it again
	writeStream.emit('data',formattedData)

	Or we can do what ever we want with the data.
	OR we could even extend this example and add a
	callback to the params and send the data to a callback
	after its been formatted.
	###

writeStream.end = (buffer)->
	# formattedData = buffer.toString('utf8')
	# writeStream.emit('done',fomattedData)
	writeStream.readable = false
	writeStream.writable = false

# Start streaming
file_url = "YOUR_FILE_URL"
opts = {}
filepicker.stream(file_url,opts).pipe(writeStream)