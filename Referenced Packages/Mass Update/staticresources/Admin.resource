var crmc;(function () { if (!crmc || !crmc.requirejs) {
if (!crmc) { crmc = {}; } else { require = crmc; }
/**
 * @license almond 0.2.9 Copyright (c) 2011-2014, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {
    var main, req, makeMap, handlers,
        defined = {},
        waiting = {},
        config = {},
        defining = {},
        hasOwn = Object.prototype.hasOwnProperty,
        aps = [].slice,
        jsSuffixRegExp = /\.js$/;

    function hasProp(obj, prop) {
        return hasOwn.call(obj, prop);
    }

    /**
     * Given a relative module name, like ./something, normalize it to
     * a real name that can be mapped to a path.
     * @param {String} name the relative name
     * @param {String} baseName a real name that the name arg is relative
     * to.
     * @returns {String} normalized name
     */
    function normalize(name, baseName) {
        var nameParts, nameSegment, mapValue, foundMap, lastIndex,
            foundI, foundStarMap, starI, i, j, part,
            baseParts = baseName && baseName.split("/"),
            map = config.map,
            starMap = (map && map['*']) || {};

        //Adjust any relative paths.
        if (name && name.charAt(0) === ".") {
            //If have a base name, try to normalize against it,
            //otherwise, assume it is a top-level require that will
            //be relative to baseUrl in the end.
            if (baseName) {
                //Convert baseName to array, and lop off the last part,
                //so that . matches that "directory" and not name of the baseName's
                //module. For instance, baseName of "one/two/three", maps to
                //"one/two/three.js", but we want the directory, "one/two" for
                //this normalization.
                baseParts = baseParts.slice(0, baseParts.length - 1);
                name = name.split('/');
                lastIndex = name.length - 1;

                // Node .js allowance:
                if (config.nodeIdCompat && jsSuffixRegExp.test(name[lastIndex])) {
                    name[lastIndex] = name[lastIndex].replace(jsSuffixRegExp, '');
                }

                name = baseParts.concat(name);

                //start trimDots
                for (i = 0; i < name.length; i += 1) {
                    part = name[i];
                    if (part === ".") {
                        name.splice(i, 1);
                        i -= 1;
                    } else if (part === "..") {
                        if (i === 1 && (name[2] === '..' || name[0] === '..')) {
                            //End of the line. Keep at least one non-dot
                            //path segment at the front so it can be mapped
                            //correctly to disk. Otherwise, there is likely
                            //no path mapping for a path starting with '..'.
                            //This can still fail, but catches the most reasonable
                            //uses of ..
                            break;
                        } else if (i > 0) {
                            name.splice(i - 1, 2);
                            i -= 2;
                        }
                    }
                }
                //end trimDots

                name = name.join("/");
            } else if (name.indexOf('./') === 0) {
                // No baseName, so this is ID is resolved relative
                // to baseUrl, pull off the leading dot.
                name = name.substring(2);
            }
        }

        //Apply map config if available.
        if ((baseParts || starMap) && map) {
            nameParts = name.split('/');

            for (i = nameParts.length; i > 0; i -= 1) {
                nameSegment = nameParts.slice(0, i).join("/");

                if (baseParts) {
                    //Find the longest baseName segment match in the config.
                    //So, do joins on the biggest to smallest lengths of baseParts.
                    for (j = baseParts.length; j > 0; j -= 1) {
                        mapValue = map[baseParts.slice(0, j).join('/')];

                        //baseName segment has  config, find if it has one for
                        //this name.
                        if (mapValue) {
                            mapValue = mapValue[nameSegment];
                            if (mapValue) {
                                //Match, update name to the new value.
                                foundMap = mapValue;
                                foundI = i;
                                break;
                            }
                        }
                    }
                }

                if (foundMap) {
                    break;
                }

                //Check for a star map match, but just hold on to it,
                //if there is a shorter segment match later in a matching
                //config, then favor over this star map.
                if (!foundStarMap && starMap && starMap[nameSegment]) {
                    foundStarMap = starMap[nameSegment];
                    starI = i;
                }
            }

            if (!foundMap && foundStarMap) {
                foundMap = foundStarMap;
                foundI = starI;
            }

            if (foundMap) {
                nameParts.splice(0, foundI, foundMap);
                name = nameParts.join('/');
            }
        }

        return name;
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
        };
    }

    function makeNormalize(relName) {
        return function (name) {
            return normalize(name, relName);
        };
    }

    function makeLoad(depName) {
        return function (value) {
            defined[depName] = value;
        };
    }

    function callDep(name) {
        if (hasProp(waiting, name)) {
            var args = waiting[name];
            delete waiting[name];
            defining[name] = true;
            main.apply(undef, args);
        }

        if (!hasProp(defined, name) && !hasProp(defining, name)) {
            throw new Error('No ' + name);
        }
        return defined[name];
    }

    //Turns a plugin!resource to [plugin, resource]
    //with the plugin being undefined if the name
    //did not have a plugin prefix.
    function splitPrefix(name) {
        var prefix,
            index = name ? name.indexOf('!') : -1;
        if (index > -1) {
            prefix = name.substring(0, index);
            name = name.substring(index + 1, name.length);
        }
        return [prefix, name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    makeMap = function (name, relName) {
        var plugin,
            parts = splitPrefix(name),
            prefix = parts[0];

        name = parts[1];

        if (prefix) {
            prefix = normalize(prefix, relName);
            plugin = callDep(prefix);
        }

        //Normalize according
        if (prefix) {
            if (plugin && plugin.normalize) {
                name = plugin.normalize(name, makeNormalize(relName));
            } else {
                name = normalize(name, relName);
            }
        } else {
            name = normalize(name, relName);
            parts = splitPrefix(name);
            prefix = parts[0];
            name = parts[1];
            if (prefix) {
                plugin = callDep(prefix);
            }
        }

        //Using ridiculous property names for space reasons
        return {
            f: prefix ? prefix + '!' + name : name, //fullName
            n: name,
            pr: prefix,
            p: plugin
        };
    };

    function makeConfig(name) {
        return function () {
            return (config && config.config && config.config[name]) || {};
        };
    }

    handlers = {
        require: function (name) {
            return makeRequire(name);
        },
        exports: function (name) {
            var e = defined[name];
            if (typeof e !== 'undefined') {
                return e;
            } else {
                return (defined[name] = {});
            }
        },
        module: function (name) {
            return {
                id: name,
                uri: '',
                exports: defined[name],
                config: makeConfig(name)
            };
        }
    };

    main = function (name, deps, callback, relName) {
        var cjsModule, depName, ret, map, i,
            args = [],
            callbackType = typeof callback,
            usingExports;

        //Use name if no relName
        relName = relName || name;

        //Call the callback to define the module, if necessary.
        if (callbackType === 'undefined' || callbackType === 'function') {
            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            //Default to [require, exports, module] if no deps
            deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
            for (i = 0; i < deps.length; i += 1) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = handlers.require(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = handlers.exports(name);
                    usingExports = true;
                } else if (depName === "module") {
                    //CommonJS module spec 1.1
                    cjsModule = args[i] = handlers.module(name);
                } else if (hasProp(defined, depName) ||
                           hasProp(waiting, depName) ||
                           hasProp(defining, depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = defined[depName];
                } else {
                    throw new Error(name + ' missing ' + depName);
                }
            }

            ret = callback ? callback.apply(defined[name], args) : undefined;

            if (name) {
                //If setting exports via "module" is in play,
                //favor that over return value and exports. After that,
                //favor a non-undefined return value over exports use.
                if (cjsModule && cjsModule.exports !== undef &&
                        cjsModule.exports !== defined[name]) {
                    defined[name] = cjsModule.exports;
                } else if (ret !== undef || !usingExports) {
                    //Use the return value from the function.
                    defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            defined[name] = callback;
        }
    };

    requirejs = require = req = function (deps, callback, relName, forceSync, alt) {
        if (typeof deps === "string") {
            if (handlers[deps]) {
                //callback in this case is really relName
                return handlers[deps](callback);
            }
            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            config = deps;
            if (config.deps) {
                req(config.deps, config.callback);
            }
            if (!callback) {
                return;
            }

            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = relName;
                relName = null;
            } else {
                deps = undef;
            }
        }

        //Support require(['a'])
        callback = callback || function () {};

        //If relName is a function, it is an errback handler,
        //so remove it.
        if (typeof relName === 'function') {
            relName = forceSync;
            forceSync = alt;
        }

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            //Using a non-zero value because of concern for what old browsers
            //do, and latest browsers "upgrade" to 4 if lower value is used:
            //http://www.whatwg.org/specs/web-apps/current-work/multipage/timers.html#dom-windowtimers-settimeout:
            //If want a value immediately, use require('id') instead -- something
            //that works in almond on the global level, but not guaranteed and
            //unlikely to work in other AMD implementations.
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 4);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function (cfg) {
        return req(cfg);
    };

    /**
     * Expose module registry for debugging and tooling
     */
    requirejs._defined = defined;

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        if (!hasProp(defined, name) && !hasProp(waiting, name)) {
            waiting[name] = [name, deps, callback];
        }
    };

    define.amd = {
        jQuery: true
    };
}());

crmc.requirejs = requirejs;crmc.require = require;crmc.define = define;
}
}());
crmc.define("../Util/almond", function(){});

crmc.define('ajax',[], function() {
	/* Namespace for Ajax XMLHttpRequext wrapper, 
	encapsulates low level http communcations */
	var Ajax = {
		REQ_TIMEOUT_MS: 30000,

		createRequest: function(url, username, password) {
			// Event handlers
			var ret = {};

			// Validate URL is http
			// if (url.search(/^https?:\/\/.*/i) < 0) {
			// 	// Append http on to beginning
			// 	url = "http://" + url;
			// }

			ret.handleEvent = function(callback, ajaxReq) {
				if (typeof callback === "function") {
					callback(ajaxReq);
				}
			};

			var http_request = new XMLHttpRequest();
			http_request.onreadystatechange = function() {
				switch (http_request.readyState) {
					case 1:
						/* Open */
						// if (typeof username === "string") {
						// 	http_request.withCredentials = "true";
						// }
						// if (typeof ret.onopen === "function") {
						// 	/* For setting additional request headers */
						// 	ret.onopen(http_request);
						// }
						break;
					case 2:
						/* Sent */
						break;
					case 3:
						/* Loading */
						break;
					case 4:
						/* Finished */
						clearInterval(ret.timeout);
						if (http_request.status === 200) {
							ret.handleEvent(ret.onsuccess, http_request);
						}
						else {
							ret.handleEvent(ret.onfail, http_request);
						}
						ret.handleEvent(ret.oncomplete, http_request);
						break;
				}
			};
			ret.request = http_request;

			var timedout = function() {
				http_request.abort();
				clearInterval(ret.timeout);
				ret.handleEvent(ret.onfail, "Request timed out.");
			};
			
			ret.request.onprogress = function(status) {
				// We are making progress, so reset timeout interval.
				clearInterval(ret.timeout);
				ret.timeout = setInterval(timedout, Ajax.REQ_TIMEOUT_MS);
			};

			// Request send methods
			ret.get = function() {
				http_request.open("GET", url, true, username, password);
				ret.timeout = setInterval(timedout, Ajax.REQ_TIMEOUT_MS);
				http_request.send();
			};

			ret.post = function(data, contentType, encoding) {
				if (typeof data === "string") {
					http_request.open('POST', url, true, username, password);
					if (typeof contentType === "string") {
						http_request.setRequestHeader("Content-Type", contentType);
					}
					ret.onopen(http_request);
					ret.timeout = setInterval(timedout, Ajax.REQ_TIMEOUT_MS);
					http_request.send(data);
				}
				else {
					ret.get();
				}
			};

			return ret;
		}
	};

	return Ajax;
});

// These are extensions on existing javascript objects and prototypes
// Many of them are influenced by LINQ and are for personal comfort.
// No module is returned by design
crmc.define('extensions',[], function() {
	// Add create method to Object from prototype because we hate the 'new' keyword
	if (typeof Object.create !== 'function') {
		Object.create = function(o) {
			var F = function(){};
			F.prototype = o;
			return new F();
		};
	}

	// Add each method to Object prototype to perform map operations
	// There is by default an Array.map but this is nice for objects
	if (typeof Object.each !== 'function') {
		Object.each = function(o, fn) {
			for (var name in o) {
				if (o.hasOwnProperty(name)) {
					fn(o[name], name);
				}
			}
		};
	}

	// Return first item in an object or array that evaluates true with passed in function
	if (typeof Object.first !== 'function') {
		Object.first = function(o, fn) {
			for (var name in o) {
				if (o.hasOwnProperty(name) && fn(o[name])) {
					return o[name];
				}
			}
		};
	}

	// Sort an array of objects by object member
	if (typeof Array.orderBy !== 'function') {
		Array.orderBy = function(arr, fn) {
			return arr.sort(function(a,b) {
				return fn(a) < fn(b) ? -1 : fn(a) > fn(b) ? 1 : 0;
			});
		};
	}

	// Insert parameters in to a string with {N} markers
	if (typeof String.format !== 'function') {
		String.format = function(str) {
			var match = str.match(/{\d+}/g);
			for (var i=0; i<match.length; i++) {
				var argNum = parseInt(match[i].replace(/[{}]/, ""));
				str = str.replace(match[i], arguments[argNum+1]);
			}
			return str;
		};
	}
});

crmc.define('soap',['ajax', 'extensions'], function(Ajax) {
	/* Namespace for Soap Requests. Encapsulates any simple Soap request. */
	/* Depends on globals: */
	var Soap = {
		createRequest: function(url, soapAction, username, password) {
			var ret = Ajax.createRequest(url, username, password);

			// SoapAction should get sent as a header
			var setReqHeaders = function(req) {
				req.setRequestHeader('SoapAction', soapAction);
			};
			ret.onopen = setReqHeaders;

			// OnSuccess should get called with response xml
			var base = ret.handleEvent;
			ret.handleEvent = function(callback, soapReq) {
				if (soapReq.readyState === 4 && soapReq.status === 200 && typeof callback === "function") {
					//console.log(soapReq.responseText);
					if (soapReq.responseXML !== undefined && soapReq.responseXML.length > 0) {
						callback(soapReq.responseXML);
					}
					else {
					  	var parser = new DOMParser();
  						var xmlDoc = parser.parseFromString(soapReq.responseText, "text/xml");
						callback(xmlDoc);
					}
				}
				else {
					base(callback, soapReq);
				}
			};

			ret.execute = function(xml) {
				//console.log(xml);
				ret.post(xml, "text/xml");
			};

			return ret;
		},
		
		/* Returns an object from a SOAP response, 
		warning Array wont be returned as such when there is only one object
		*/
		objectFromXml:function(xmlDoc) {
			var ret = {};

			// Add other objects to the object model
			if (xmlDoc.childNodes && xmlDoc.childNodes.length > 0) {
				for (var i = 0; i < xmlDoc.childNodes.length; i++) {
					if (xmlDoc.childNodes[i].nodeName === "#text") {
						if (xmlDoc.childNodes[i].nodeValue.match(/^\s*$/)) {
							continue;
						}
						ret = Soap.objectFromXml(xmlDoc.childNodes[i]);
					}
					else {
						var key = xmlDoc.childNodes[i].nodeName;
						if (ret[key]) {
							if (typeof ret[key].push !== "function") {
								ret[key] = [ret[key]];
							}
							ret[key].push(Soap.objectFromXml(xmlDoc.childNodes[i]));
						}
						else {
							ret[key] = Soap.objectFromXml(xmlDoc.childNodes[i]);
						}
					}
				}
			}
			else {
				// No children in this node, just add the node value to the object
				if (xmlDoc !== undefined && xmlDoc.nodeValue !== null) {
					ret = xmlDoc.nodeValue;
				}
			}

			// Add any attributes as scalar values to the object model
			if (xmlDoc.attributes && xmlDoc.attributes.length > 0) {
				for (var j = 0; j < xmlDoc.attributes.length; j++) {
					ret[xmlDoc.attributes[j].name] = xmlDoc.attributes[j].value;
				}
			}

			return ret;
		},
		
		/* Returns a xml string of an objects properties, recursively
		*/
		objectToXml: function(obj, namespace) {
			var ret = "";
			if (typeof obj === "object")
			{
				Object.each(obj, function(prop, name) {
					var openNode = name;
					if (typeof(obj.xmlns) === "string") {
						openNode += " xmlns=\"" + obj.xmlns + "\"";
					}
					if (typeof(prop['xsi:type']) === "string") {
						openNode += " xsi:type=\"" + prop['xsi:type'] + "\"";
					}
					if (name !== "xmlns" && name !== "xsi:type") {
						if (prop instanceof Array) {
							Object.each(prop, function(i) {
								ret += "<" + openNode + ">" + Soap.objectToXml(i) + "</" + name + ">\n";
							});
						}
						else {
							ret += "<" + openNode + ">" + Soap.objectToXml(prop) + "</" + name + ">\n";
						}
					}
				});
			}
			else
			{
				ret = Soap.htmlSpecialChars(obj.toString());
			}
			return ret;
		},
		htmlSpecialChars: function (unsafe) {
			return unsafe
			.replace(/&/g, "&amp;")
			.replace(/</g, "&lt;")
			.replace(/>/g, "&gt;")
			.replace(/"/g, "&quot;");
		}
	};

	return Soap;
});
crmc.define('KendoPopup',[],function () {
  return {

    /**
     * Popup
     * @param {string} title
     * @param {string|html} content
     */
    popup: function (title, content, confirmText, confirmFn) {
      //var title = "Popup Title!";
      //var content = "This is the message!";
      var unique = new Date().getTime();
      var popup = kendo.template("<div id='KendoPopupBox#=uniqueid#' style='display:none;'><p>#= val #</p><div style='float:right;'><span id='closeWindow#=uniqueid#' class='k-button'>Dismiss</span>&nbsp;#if (confirmText) {#<span id='confirmWindow#=uniqueid#' class='k-button'>#=confirmText#</span># } #</div></div>");
      var data = { 
        val: content,
        uniqueid: unique,
        confirmText: confirmText,
      }; //A value in JavaScript/JSON
      var result = popup(data); //Pass the data to the compiled template
      $("body").append(result);

      var closeWindow = $("#closeWindow" + unique);
      var box = $("#KendoPopupBox" + unique);

      closeWindow.bind("click", function () {
        box.data("kendoWindow").close();
      });

      if (confirmText && typeof(confirmFn) === "function") {
        var confirmButton = $("#confirmWindow" + unique);
        confirmButton.bind("click", function() {
          box.data("kendoWindow").close();
          confirmFn();
        });
      }

      if (!box.data("kendoWindow")) {
        box.kendoWindow({
          draggable: true,
          modal: true,
          resizable: false,
          actions: ["Close"],
          title: title
        });
      }

      box.data("kendoWindow").center().open();
    }
  };
});				
crmc.define('metadata',['soap', 'KendoPopup'], function(Soap, alert) {

	var SoapData = {
		soapHeader: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:cmd=\"http://soap.sforce.com/2006/04/metadata\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><soap:Header>",
		soapHeaderEnd: "</soap:Header><soap:Body>",
		soapFooter: "</soap:Body></soap:Envelope>"
	};

	var metaService = {
		delegate: {
			onError: function() {},
		},
		sessionId: "",
		endpoint: "https://login.salesforce.com/services/Soap/c/31.0",
		apiVersion: 31.0,
		xmlns: "http://soap.sforce.com/2006/04/metadata",
		makeRequestObject: function(soapAction, innerObject) {
			var ret = {
				xmlns: this.xmlns
			};
			ret[soapAction] = innerObject;
			return ret;
		},
		// Login necessary if no existing sessionId, otherwise set sessionId before request
		login: function(username, password, fnCallback) {
			var req = {
				username: username,
				password: password,
			};
			var that = this;
			this.xmlns = "urn:enterprise.soap.sforce.com";
			this.beginMetadataRequest("login", req, "result", function(response) {
				// Successful login sets metadata endpoint and sessionid for further calls
				that.sessionId = response.sessionId;
				that.endpoint = response.metadataServerUrl;
				that.xmlns = "http://soap.sforce.com/2006/04/metadata";
				fnCallback(response);
			});
		},
		listMetadata: function(folder, type, fnCallback) {
			var req = {
				queries:
				{
					folder: folder,
					type: type,
				},
				asOfVersion: this.apiVersion,
			};
			this.beginMetadataRequest("listMetadata", req, "listMetadataResponse", fnCallback);
		},
		describeMetadata: function(fnCallback) {
			var req = {
				asOfVersion: this.apiVersion,
			};
			this.beginMetadataRequest("describeMetadata", req, "result", fnCallback);
		},
		updateMetadata: function(type, currentName, metaData, fnCallback) {
			var req = {
				
				//currentName: currentName,
				metadata: metaData
			};
			this.beginMetadataRequest("updateMetadata", req, "result", fnCallback);
		},
		createMetadata: function(type, currentName, metaData, fnCallback) {
			var req = {
				
				//currentName: currentName,
				metadata: metaData
			};
			this.beginMetadataRequest("createMetadata", req, "result", fnCallback);
		},
		readMetadata: function(type, fullNames, fnCallback) {
			var req = {
				type: type,
				fullNames: fullNames,
			};
			this.beginMetadataRequest("readMetadata", req, "result", fnCallback);
		},
		beginMetadataRequest: function(soapAction, requestObject, responseType, resultFn) {
			// Create request handlers
			var request = Soap.createRequest(this.endpoint, soapAction);
			request.onsuccess = function(xml) {
				// Get responseType element from response body
				xml = xml.getElementsByTagName(responseType)[0];
				resultFn(Soap.objectFromXml(xml));
			};
			request.onfail = function(r) {
				// Handle error responses
				console.log(r.responseText); 
				if (this.delegate && typeof(this.delegate.onError) === "function") {
					this.delegate.onError(r.responseText, r);
				}
			};

			// Concat soap xml body
			var data = this.makeRequestObject(soapAction, requestObject);
			// Serialize request data to xml
			var innerXml = Soap.objectToXml(data);
			var soapHeader = SoapData.soapHeader + 
				// Include session id in soap header (not included in login requests)
				(this.sessionId.length > 0 ? "<cmd:SessionHeader><cmd:sessionId>" + this.sessionId + "</cmd:sessionId></cmd:SessionHeader>" : "") + 
				SoapData.soapHeaderEnd;
			var xmlData = soapHeader + innerXml + SoapData.soapFooter;
			// Submit soap body to endpoint
			request.execute(xmlData);
		},
		/**
	     * Create a button
	     * @param {string} objectName
	     * @param {string} buttonName
	     * @param {string} buttonLabel
	     * @param {string} url
 	     * @param {function} callback
	     */
	    createButton: function (objectName, buttonName, buttonLabel, url,callback) {
	      var webLink = {
	        "xsi:type": "WebLink",
	        fullName: objectName + '.' + buttonName, 
	        availability: 'online',
	        displayType: 'massActionButton',
	        linkType: 'javascript',
	        masterLabel: buttonLabel,
	        openType: 'onClickJavaScript',
	        requireRowSelection: true,
	        url: url
	      };
	      this.createMetadata('webLink', objectName + '.' + buttonName, webLink, function (response) {
	        if (typeof(callback) === "function")
	          callback(response);
	      });
	    },
	    /**
	     * Gets a custom object by tablename
	     * @param {string} tableName
	     * @param {string} buttonName
	     * @param {string} prefix
	     * @param {function} callback
	     */
	    getCustomObject: function (tableName, buttonName, prefix, callback) {
	      // TODO: should table name be required?
	      //if(tableName || tableName.length == 0){
	      //  throw new Error('Table is required..?')
	      //}
	    	var customObject = {
	    		hasButton: false,
	    		hasSearchResults: false,
	    		hasListView: false,
	    		custObj: null
	    	};
	      this.readMetadata('CustomObject', tableName, function (response) {
	        customObject.custObj = response.records;
	        var buttons = customObject.custObj.webLinks;
	        //TODO: Should be able to just say if(!buttons)
	        if (buttons != undefined) {
	          if (buttons.length == undefined) {
	            buttons = [buttons];
	          }
	          for (var i in buttons) {
	            if (buttons[i].fullName == buttonName || buttons[i].fullName == prefix + buttonName) {
	              customObject.hasButton = true;
	              break;
	            }
	          }
	        }

	        if (customObject.custObj.searchLayouts != undefined) {
	          var searchResults = customObject.custObj.searchLayouts.searchResultsCustomButtons;
	          var listViews = customObject.custObj.searchLayouts.listViewButtons;

	          if (searchResults != undefined) {
	            if (typeof searchResults == 'string') {
	              searchResults = [searchResults];
	            }
	            for (var i in searchResults) {
	              if (searchResults[i] == buttonName || searchResults[i] == prefix + buttonName) {
	                customObject.hasSearchResults = true;
	                break;
	              }
	            }
	          }
	          if (listViews != undefined) {
	            if (typeof listViews == 'string') {
	              listViews = [listViews];
	            }
	            for (var i in listViews) {
	              if (listViews[i] == buttonName || listViews[i] == prefix + buttonName) {
	                customObject.hasListView = true;
	                break;
	              }
	            }
	          }
	        }

	        if (typeof(callback) == "function")
	          callback(customObject);
	      });
	    },
	    /**
	     * Add to Search results
	     * @param custObj
	     * @param {string} buttonName
	     * @param {function} callback
	     */
	    addToSearchResult: function (custObj, buttonName, callback) {
	      if (!custObj.searchLayouts) {
	        alert.popup("Unsupported", custObj.fullName + " does not support search layouts");
	      }
	      else {
	        if (!custObj.searchLayouts.searchResultsCustomButtons) {
	          custObj.searchLayouts.searchResultsCustomButtons = [];
	        }
	        else if (typeof(custObj.searchLayouts.searchResultsCustomButtons) === 'string') {
	          custObj.searchLayouts.searchResultsCustomButtons = [custObj.searchLayouts.searchResultsCustomButtons];
	        }
	        custObj.searchLayouts.searchResultsCustomButtons.push(buttonName);
	        var minObj = { fullName: custObj.fullName, "xsi:type": custObj["xsi:type"], searchLayouts: custObj.searchLayouts };
	        if (custObj.pluralLabel != undefined)
	        {
	        	for(var i in custObj)
				{
				  if (i != 'webLinks')
				  {    
				      minObj[i] = custObj[i];
				  }
				}
	        }
	        this.updateMetadata('customObject', custObj.fullName, minObj, function (response) {
	          if (typeof(callback) === "function")
	            callback(response);
	        });

	      }
    	},
    	/**
	     * Add to list view button
	     * @param custObj	     
	     * @param {string} buttonName
	     * @param {function} callback
	     */
	    addToListViewButtons: function (custObj, buttonName, callback) {
	      if (custObj.searchLayouts.listViewButtons == undefined) {
	        custObj.searchLayouts.listViewButtons = [];
	      }
	      else if (typeof(custObj.searchLayouts.listViewButtons) === 'string')
	        custObj.searchLayouts.listViewButtons = [custObj.searchLayouts.listViewButtons];
	      custObj.searchLayouts.listViewButtons.push(buttonName);
	      var minObj = { fullName: custObj.fullName, "xsi:type": custObj["xsi:type"], searchLayouts: custObj.searchLayouts };
		  if (custObj.pluralLabel != undefined)
	        {
	        	for(var i in custObj)
				{
				  if (i != 'webLinks')
				  {    
				      minObj[i] = custObj[i];
				  }
				}
	        }
	      this.updateMetadata('customObject', custObj.fullName, minObj, function (response) {
	        if (typeof(callback) === "function")
	          callback(response);
	      });
	    },
	};

	return metaService;
});
crmc.define('admin',['metadata', 'KendoPopup'], function (metadata, alert) {

  var adminService = {
    prefix: "CRMC_MassUpdate__",
    buttonName: "crmc_Mass_Update",
    buttonLabel: 'Mass Update',
    listName: "crmc_Mass_Update",
    custObj: {},
    hasButton: false,
    hasSearchResults: false,
    hasListView: false,

    /**
     * Initialize with a session
     * @param {string} sessionId
     */
    init: function (sessionId) {
      // TODO: should sessionId required?

      metadata.endpoint = "/services/Soap/m/30.0/";
      metadata.sessionId = sessionId;
      metadata.delegate = {
        onError: function(message) {
          alert.popup("Metadata API Error", message);
        }
      };
    },

    /**
     * Gets a custom object by tablename
     * @param {string} tableName
     * @param {function} callback
     */
    getCustomObject: function (tableName, callback) {
      // TODO: should table name be required?
      //if(tableName || tableName.length == 0){
      //  throw new Error('Table is required..?')
      //}
      metadata.getCustomObject(tableName, adminService.buttonName, adminService.prefix, callback);
    },

    /**
     * Create button function. This is template code to be put in ListView button
     * @param objectName
     * @param selectedIds
     */
    createButtonFunction: function (selectedIds, retUrl) {
      // Including script with namespace ensures sessionid is setup with GET before needing to POST
      var head = document.getElementsByTagName('HEAD').item(0);
      var script = document.createElement("script");
      script.type = "text/javascript";
      head.appendChild(script);
      script.onload = function () {
        //var selectedIds = {!GETRECORDIDS( $ObjectType.Contact )};
        MassUpdate.massUpdate(selectedIds, retUrl);
      };
      script.src = "/resource/CRMC_MassUpdate__MassUpdate?ts=" + new Date().getTime();
    },

    /**
     * Create a button
     * @param {string} objectName
     * @param {function} callback
     */
    createButton: function (objectName, callback) {
      metadata.createButton(objectName, adminService.buttonName, adminService.buttonLabel, 
        String.format('({0}({!GETRECORDIDS( $ObjectType.{1})},window.location.href));', this.createButtonFunction.toString(), objectName),
        callback);
    },

    /**
     * Add to Search results
     * @param {string} objectName     
     * @param {function} callback
     */
    addToSearchResult: function (custObj, callback) {
      metadata.addToSearchResult(custObj, adminService.buttonName, callback);
    },

    /**
     * Add to list view button
     * @param {function} callback
     */
    addToListViewButtons: function (custObj, callback) {
      metadata.addToListViewButtons(custObj, adminService.buttonName, callback);
    },
  };
  return adminService;
});
crmc.define('sfdc',['extensions'], function() {
	return {
		// Return entire query string as js object
		parseAsObject: function() {
			var queryArgs = location.search.slice(1).split('&');
			var queryObj = {};
			for (var i=0; i<queryArgs.length; i++) {
				var keyVal = queryArgs[i].split('=');
				if (keyVal.length === 2) {
					queryObj[unescape(keyVal[0].toLowerCase())] = unescape(keyVal[1]);
				}
			}
			return queryObj;
		},
		// Return a comma delimited query parameter as js array
		parseAsArray: function(argName) {
			var ret = [];
			var queryObj = this.parseAsObject();
			if (queryObj[argName] !== undefined) {
				var items = queryObj[argName].split(',');
				for (var i=0; i<items.length; i++) {
					if (items[i] != "") ret.push(items[i]);
				}
			}
			return ret;
		},
		// Navigate to a visualforce page with specified namespace prefix and GET query parameters
		navigateToVFPage: function(namespace, pageName, parameters) {
			// var domains = window.location.hostname.split(".");
			// if (domains.length == 3) {
			// 	instance = domains[0];
			// }
			// else {
			// 	instance = domains[1];
			// } 
			var params = [];
			Object.each(parameters, function(value, name) {
					params.push(name + '=' + escape(value));
				}
			);
			namespace = namespace.replace('_', '-');
			// Return URL should return to native instance
			// params.push("retURL=" + 
			// 	String.format("{0}//{1}.salesforce.com{2}", 
			// 		location.protocol, instance, escape(window.location.pathname + window.location.search)));
			// var pageUrl = String.format("{0}//{1}.{2}.visual.force.com/apex/{3}?{4}", location.protocol, namespace, instance, pageName, params.join('&')); 
			var pageUrl = String.format("/apex/{0}__{1}?{2}", namespace, pageName, params.join('&')); 
			var mywin = window.open(pageUrl, "_top"); 
			mywin.focus(); 
		},
		postToVFPage: function(namespace, pageName, parameters, data) {
			var prefix = '';
			var domains = window.location.hostname.split(".");
			if (domains.length == 5){
			  instance = domains[1];
			  var prefixes = domains[0].split('--');
			  if (prefixes.length == 2)
			    prefix = prefixes[0] + '--';
			}			
			else if (domains.length == 3) {
				instance = domains[0];
			}
			else {
				instance = domains[1];
			} 
			var params = [];
			Object.each(parameters, function(value, name) {
					params.push(name + '=' + escape(value));
				}
			);
			namespace = namespace.replace('_', '-');
			var path = String.format("{0}//{1}{2}.{3}.visual.force.com/apex/{4}?{5}", location.protocol, prefix, namespace, instance, pageName, params.join('&')); 			// var path = String.format("/apex/{0}__{1}?{2}", namespace, pageName, params.join('&')); 
			var form = document.createElement('form'); 
			form.method = "post";
			form.action = path;
			Object.each(data, function(value, name) {
				var input = document.createElement("input");
				input.type = "hidden";
				if (typeof(value) === "object" && value.name !== undefined && value.value !== undefined) {
					input.name = value.name;
					input.value = value.value;
				}
				else {
					input.name = name;
					input.value = value;
				}
				form.appendChild(input);
			});
			document.body.appendChild(form);
			form.submit();
		},
		// Used to navigate to non-VF SFDC pages
		navigateToPage: function(relativeUrl, parameters) {
			// var domains = window.location.hostname.split(".");
			// if (domains.length == 3) {
			// 	instance = domains[0];
			// }
			// else {
			// 	instance = domains[1];
			// } 
			var params = [];
			Object.each(parameters, function(value, name) {
					params.push(name + '=' + escape(value));
				}
			);
			// Return url should be relative
			//params.push("retURL=" + escape(window.location.pathname + window.location.search));
			var pageUrl = String.format("/{0}?{1}", relativeUrl, params.join('&')); 
			var mywin = window.open(pageUrl, "_top"); 
			mywin.focus(); 
		},
		/* Retrieves sObject describe from REST API
		* @param objectName
		* returns {*}
		*/
		getSObjectDescribe: function(objectName) {
			var describe = sforce.connection.describeSObject(objectName);
			return describe;
		},
		/* Returns the name field from an sobject describe
		* @param describe
		* returns string name
		*/
		getSObjectNameField: function(describe) {
			var name = Object.first(describe.fields, function(x) {
				return x.getBoolean("nameField");
			});
			return name ? name.name : undefined;
		},
		/* Use AJAX toolkit API to run SOQL query 
			Requires sessionid be set with VF mergetag:
			sforce.connection.sessionId = "{!$Api.Session_ID}";
		*/
		query: function(soql) {
			if (arguments.length > 1) {
				// If more than a single argument apply string.format to soql
				soql = String.format.apply(String, arguments);
			}
			if (window.isDebug) console.log(soql);
			try {
				var result = sforce.connection.queryAll(soql);
				return result.getArray("records");
			}
			catch (e) {
				console.log(e.faultstring);
				throw e;
			}
		},
		/*
			Select columns from object where FK IDs IN passed list, batch query if needed
		*/
		batchQueryIn: function(objectName, selectCols, whereFk, inIdList) {
			var results = [];
			var QUERY = "select {0} from {1} where {2} in ({3})";
			if (selectCols instanceof Array) selectCols = selectCols.join();
			// Ids are 18 characters long so split up queries to avoice 2000 character limit
			var limit = 85; // 85 x 18 = 1530 leaving room for query syntax
			var slices = parseInt(inIdList.length / limit);
			if (slices < 1) slices = 1;
			for (var i=0; i<slices; i++) {
				var sliceIds = inIdList.slice(i * limit, (i + 1) * limit);
				// Synchronous, could probably be more performant async
				var subresults = this.query(QUERY, selectCols, objectName, whereFk, sliceIds.join());
				results = results.concat(subresults);
			}
			return results;
		},
		update: function(sObject, fnSuccess, fnError) {
			sforce.connection.update([sObject], {
				onSuccess: function(results) {
					var result = results[0];
					var success = result.getBoolean("success");
					if (success) {
						fnSuccess(result);
					}
					else {
						fnError(result.errors.message);
					}
				},
				onFailure: function(error) {
					fnError(error.message);
				},
			});
		},
		insert: function(sObject, fnSuccess, fnError) {
			sforce.connection.create([sObject], {
				onSuccess: function(results) {
					var result = results[0];
					var success = result.getBoolean("success");
					if (success) {
						fnSuccess(result);
					}
					else {
						if (result && result.errors && result.errors.message) {
							fnError(result.errors.message.faultstring);
						}
					}
				},
				onFailure: fnError,
			});
		},
		getUserInfo: function() {
			if (this.userInfo=== undefined) {
				if (window.isDebug) {
					// Return debug data
					this.userInfo = {
						userLocale: "en_US",
						userTimeZone: "America/Los_Angeles",
						currencySymbol: "$",
					};
				}
				else {
					this.userInfo = sforce.connection.getUserInfo();
				}	
			}
			return this.userInfo;
		}
	};
});
// Module to manage everything needed to bind a grid to remote data
crmc.define('GridDataProvider',['KendoPopup', 'sfdc', 'extensions'], function (alert, sfdc) {

  //TODO: rename to pascal cased as it's an instance variable
  var GridDataProvider = {

    // Instance of kendo dataSource object
    dataSource: undefined,
    // Info that is used during data request to indicate paging and other context
    pageInfo: {},
    // Delegate handles events
    delegate: {
      onDataSourceReady: function(dataSource) {},
      onReadFieldMetadata: function(fieldMeta) {},
    },
    init: function (settings) {
      settings = settings || {};
      // Construnct a new data provider object to return
      var newDS = Object.create(this);
      newDS.pageInfo = settings.pageInfo;
      newDS.settings = settings;
      return newDS;
    },

    /**
     * Create a new instance of dataSource that can be used to init a grid
     * @param settings
     * @param delegate
     */
    create: function (settings, delegate) {
      settings = settings || {};
      
      var newDS = this.init(settings);
      newDS.delegate = delegate || {};

      // Get metadata necessary to setup dataSource schema
      Visualforce.remoting.Manager.invokeAction(
        settings.remoteActions.getFieldMetaAction,
        settings.pageInfo.objectName,
        settings.pageInfo.columns,
        function (fieldMeta, e) {
          if (e.status) {
            newDS.fieldMeta = fieldMeta;
            newDS.dataSource = newDS.createDataSource();
            // Return dataSource object to callback
            if (typeof(newDS.delegate.onDataSourceReady) === "function") {
              newDS.delegate.onDataSourceReady(newDS.dataSource, newDS.fieldMeta);
            }
          }
        });
    },

    /**
     * Create data source
     * @returns {DataSource}
     */
    createDataSource: function () {
      // Create datasource object for grid
      var provider = this;
      var schema = this.createSchema(this.fieldMeta);
      var dataSource = new kendo.data.DataSource({
        serverPaging: !window.isDebug,
        serverSorting: !window.isDebug,
        serverFiltering: !window.isDebug,
        pageSize: 100,
        aggregate: [],
        error: function (e) {
          console.log(e);
          if (e.status && typeof(e.status.message) === "string") {
            alert.popup("Data Error", e.status.message);
          }
        },
        transport: {
          update: function (o) {
            // Create new sObject to be updated
            var sObject = new sforce.SObject(provider.pageInfo.objectName);
            sObject.Id = o.data.Id;
            // Copy dirty databound values to sobject
            Object.each(o.data.dirtyFields, function (value, key) {
              sObject[key] = o.data[key];
            });
            // Update in sfdc
            sfdc.update(sObject, o.success,
              function (error) {
                var status = { message: error };
                o.error(o.data, status);
              });
          },
          // Use remote action to populate data
          read: function (pg) {
            // Pass through paging and sorting info
            provider.pageInfo.takeCount = pg.data.take;
            provider.pageInfo.skipCount = pg.data.skip;
            provider.pageInfo.sorts = pg.data.sort;
            provider.pageInfo.groups = pg.data.group;
            provider.pageInfo.filter = pg.data.filter;
            // Don't pass restore column metadata to remote action
            delete provider.pageInfo.displayColumns;
            if (!provider.pageInfo.filterId) {
              if (!provider.pageInfo.sorts ||
                provider.pageInfo.sorts.length === 0) {
                var nameField = sfdc.getSObjectNameField(provider.settings.metadata);
                if (nameField) {
                  // Set a default sort on Name field
                  provider.pageInfo.sorts = [{
                    field: nameField,
                    dir: "asc",
                  }];
                }
              }
            }
            if (provider.settings.baseFilter !== undefined) {
              // If any base filter (i.e. Related List) then add to filter
              if (provider.pageInfo.filter === undefined) provider.pageInfo.filter = { logic: 'and' };
              if (provider.pageInfo.filter.filters === undefined) provider.pageInfo.filter.filters = [];
              provider.pageInfo.filter.filters.push(provider.settings.baseFilter);
            }
            // Call apex remote action
            Visualforce.remoting.Manager.invokeAction(
              provider.settings.remoteActions.getPageAction,
              provider.pageInfo,
              function (r, e) {
                if (e.status) {
                  // Success
                  console.log("Grid Data Provider")

                  if (window.isDebug) console.log(r);
                  // Set a prototype for all the returned results
                  var ptype = provider.getModelPrototype();
                  for (var i = 0; i < r.results.length; i++) {
                    r.results[i].__proto__ = ptype;
                    //var accountName = r.results[i].Account.Name;
                    //r.results[i].Account.Name = r.results[i].Account.Name.replace(/&amp;/g, '&')
                    //Koranda
                  }
                  // Pass successful data on to be parsed
                  pg.success(r);
                }
                else {
                  // Fail
                  pg.error(r, e);
                }
              }
            );
          },
        },
        schema: schema,
      });

      return dataSource;
    },

    /**
     * Get model prototype. Function that returns an object to be used as the prototype for the datasource models
     * @returns {{}}
     */
    getModelPrototype: function () {
      var ptype = {};
      // Define a prototype for any null values
      if (this.pageInfo.columns !== undefined) {
        for (var i = 0; i < this.pageInfo.columns.length; i++) {
          var relNames = this.pageInfo.columns[i].split('.');
          if (relNames.length == 2) {
            ptype[relNames[0]] = {};
          }
          else {
            // Null placeholder
            // ptype[this.pageInfo.columns[i]] = {
            //   toString: function () {
            //     return "";
            //   }
            // };
          }
        }
      }
      return ptype;
    },

    /**
     * Create schema
     * @param fieldMeta
     * @returns {{data: string, total: string, model: {id: string, fields: {}}}}
     */
    createSchema: function (fieldMeta) {

      var schema = {
        data: "results",
        total: "totalResults",
        // Model populated by parse method to define field metadata
        model: {
          id: "Id",
          fields: {}
        }
      };

      if (fieldMeta !== undefined) {
        var that = this;
        // Generate a grid column for each field metadata returned
        Object.each(this.pageInfo.columns, function (i) {
          var meta = Object.first(fieldMeta, function (x) {
            return x.name === i;
          });
          // If metadata not found may not have security to field
          if (meta !== undefined) {
            // Add to schema model fieldset so correct filter controls display
            var fieldSchema = {
              type: "string",
              editable: !meta.isReadonly,
              nullable: meta.isNillable,
              validation: {
                required: !meta.isNillable,
              }
            };
            switch (meta.type.toLowerCase()) {
              case "currency":
              case "integer":
              case "double":
              case "percent":
                fieldSchema.type = "number";
                break;
              case "boolean":
                fieldSchema.type = "boolean";
                break;
              case "date":
              case "datetime":
              case "time":
                fieldSchema.type = "date";
                // Parse to/from salesforce UTC ticks format
                fieldSchema.parse = function (v) {
                  var date = v;
                  if (typeof(v) === "number") {
                    // Convert ticks to UTC date object
                    date = new Date(v);
                    // Convert to user profile timezone
                    var info = sfdc.getUserInfo();
                    try {
                      var options = {
                        timeZone: info.userTimeZone !== undefined ? info.userTimeZone : "America/Denver",
                      };
                      var str = date.toLocaleString(undefined, options);
                      if (str.indexOf(" at") > -1) {
                        // Safari puts a "at" between date and time but doesn't parse string with it so remove it
                        str = str.replace(" at", "");
                      }
                      date = new Date(str);
                    }
                    catch (e) {
                      // Timezone adjustment maybe didnt work in a browser
                    }
                  }
                  return date;
                }
                break;
              case "string":
              default:
                break;
            }
            if (meta.name.indexOf(".") > 0 && meta.name.indexOf(".Name") < 0) {
              // Only primary data fields editable for now.
              fieldSchema.editable = false;
            }
            // Set datasource schema info
            schema.model.fields[meta.name] = fieldSchema;

            // Notify delegate field metadata read
            if (typeof(that.delegate.onReadFieldMetadata) === "function") {
              that.delegate.onReadFieldMetadata(meta);
            }
          }
        });

      }
      return schema;
    },
  };

  return GridDataProvider;
});
crmc.define('ForeignKeyControl',['GridDataProvider'], function(GridDataProvider) {
	var fkControl = {
      makeControl: function(input, relObjectName, thatSettings,setFunction){
        // Create datasource that can retrieve FK name/id values
          var settings = Object.create(thatSettings);
          settings.pageInfo= {
            objectName: relObjectName,
            columns: ["Name", "Id"]
          };
          
          var setSelect = function(selectedItem){
            if (selectedItem !== undefined) {
                  if ($.isFunction(setFunction)) 
                    setFunction(selectedItem["Id"]);
                }
            else
            {
              setFunction("");
            }

          };
          var ds = GridDataProvider.init(settings).createDataSource();
          ds.sort({ field: "Name", dir: "asc" });
          // initialize a Kendo UI combobox
          var ac = input.kendoComboBox({
            dataTextField: "Name",
            dataValueField: "Name",
            //suggest: true,
            dataSource: ds,
            change: function (e) {
              // When name is changed also update id value
              var selectedItem = this.dataItem(this.select());
              setSelect(selectedItem);
            }
          }).data("kendoComboBox");
          ac.input.keyup(function (e) {
            if (ac.input.val().length > 0 && ac.input.val().match(/^\s/) === null)//bit of regex to prevent whitespace
              ac.dataSource.filter({ field: "Name", operator: "startswith", value: ac.input.val() });
            else
              ac.dataSource.filter();
          });
          ac.input.blur(function (e) {
            var dataItems = ac.dataItems();
            if (dataItems.length === 1) {
              var selectedItem = dataItems[0];
              ac.select(0);
              input.value = selectedItem["Name"];
              setSelect(selectedItem);
            }
            else
            {
              input.value = ac.value();
              setSelect(ac.dataItem());
            }
          });
      },
      editor: function(relObjectName, thatSettings, idName){
        var that = this;
        return function(container, options) {
          // create an input element
          var input = $("<input/>");
          // set its name to the field to which the column is bound ('name' in this case)
          input.attr("name", options.field);
          // append it to the container
          input.appendTo(container);

          that.makeControl(input, relObjectName, thatSettings,function(selectedId){
            options.model[idName+"Id"] = selectedId;
            if (selectedId == "")
            {
              options.model[idName].Id = "";
              options.model[idName].Name = "";
            }
          });
        }
      }
    };
    return fkControl;
});
crmc.define('KendoEntry',['ForeignKeyControl'], function(fkControl) {
  return {
    /**
     * Entry
     * @param title
     * @param fields
     * @param options
     * @param settings     
     * @param onComplete
     */
    entry: function (title, fields, options, settings, onComplete) {
      //var title = "Popup Title!";
      //var content = "This is the message!";
      var unique = new Date().getTime();
      var content = '<table style="width:100%">';
      Object.each(fields, function (x) {
        content
            += "<tr><th><label for='" + x.name + "_" + unique + "' >" + x.label + ":</label></th><td style='text-align:left;'><input style='width:100%;' id='" + x.name + "_" + unique + "' /></td></tr>";
      });
      content += "</table>";
      var popup = kendo.template("<div id='KendoPopupBox" + unique + "' style='display:none; text-align:center;'><p>#= val #</p><span id='OKWindow" + unique + "' class='k-button'>OK</span>&nbsp; &nbsp;<span id='closeWindow" + unique + "' class='k-button'>Cancel</span></div>");
      var data = { val: content }; //A value in JavaScript/JSON
      var result = popup(data); //Pass the data to the compiled template
      $("body").append(result);

      Object.each(fields, function (x) {
        if (x.type == 'date') {
          $("#" + x.name + "_" + unique).kendoDatePicker({
            format: "yyyy-MM-dd"
          });
        }
        else if (x.type == 'comboBox') {
          $("#" + x.name + "_" + unique).kendoComboBox({
            dataTextField: 'label',
            dataValueField: 'value',
            dataSource: x.values,
            filter: "contains",
            suggest: true
          });
        }
        else if (x.type == 'picklist') {
          $("#" + x.name + "_" + unique).kendoDropDownList({
            dataTextField: 'label',
            dataValueField: 'value',
            dataSource: x.values,
          });
        }
        else if (x.type == 'boolean') {
          $("#" + x.name + "_" + unique)[0].type = 'checkbox';
        }
        else if (x.type == 'reference') {
          fkControl.makeControl($("#" + x.name + "_" + unique), x.referenceTo, settings, function(selectedId){
            $("#" + x.name + "_" + unique)[0].value = selectedId;
          });
        }
        else {
          $("#" + x.name + "_" + unique).kendoMaskedTextBox();//for consistent styling
        }
      });


      var closeWindow = $("#closeWindow" + unique);
      var okWindow = $("#OKWindow" + unique);
      var box = $("#KendoPopupBox" + unique);

      closeWindow.bind("click", function () {
        box.data("kendoWindow").close();
      });

      okWindow.bind("click", function () {
        box.data("kendoWindow").close();
        var selectedValues = [];
        Object.each(fields, function (x) {
          if (x.type == 'boolean')
            selectedValues.push({ name: x.name, value: $("#" + x.name + "_" + unique)[0].checked });
          else
            selectedValues.push({ name: x.name, value: $("#" + x.name + "_" + unique)[0].value });
        });
        onComplete(selectedValues);
      });

      if (!box.data("kendoWindow")) {
        box.kendoWindow({
          width: options != undefined ? options.width : null,
          draggable: true,
          modal: true,
          resizable: false,
          actions: ["Close"],
          title: title
        });
      }

      box.data("kendoWindow").center().open();
    }
  };
});				
