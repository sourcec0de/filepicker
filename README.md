filepicker.js
===============

A Node.js Filepicker Library, with streaming

Installation
-------------

``` bash
$ npm install filepicker.js
```

#### Instantiation

``` javascript
var Filepicker = require('filepicker.js');
var filepicker = new Filepicker('YOUR_API_KEY');
```

#### Methods

1. `store`
	* Stores a file into filepicker and passes the url in the response

	``` javascript
	filepicker.store("test", {persist:true}, function(err, url) {
		console.log(url);
	});
	```

2. `read`
	* Reads a file from filepicker and passes the contents in the callback
        * For now uses utf8

	``` javascript
        filepicker.read(url, {}, function(err,data){
          console.log(data);
        });
	```

3. `stream`
	* see examples/stream.coffe
	* see examples/stream.js