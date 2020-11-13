package gasm.assets;

import haxe.Http;
import haxe.crypto.Base64;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

using Lambda;
using StringTools;

class Loader {
	var _imageFolder = 'image';
	var _soundFolder = 'sound';
	var _atlasFolder = 'atlas';
	var _spineFolder = 'spine';
	var _modelFolder = 'model';
	var _gradientFolder = 'gradient';
	var _fontFolder = 'font';
	var _configFolder = 'config';
	var _localizedFolder = 'localized';
	var _defaultLocale = 'en';
	var _commonFolder = 'common';
	var _content:FileEntry;
	var _commonContent:FileEntry;
	var _platformContent:FileEntry;
	var _brandingContent:FileEntry;
	var _brandingCommon:FileEntry;
	var _brandingPlatform:FileEntry;
	var _platform:String;
	var _locale:String;
	var _extensionHandlers:IntMap<HandlerItem->Void>;
	var _loadingQueue:Array<QueueItem>;
	var _formats:Array<FormatType>;
	var _loadedBytes:StringMap<Int>;
	var _totalBytes:Int;
	var _totalItems = 0;
	var _loadedItems:Int;
	var _itemIndex = 0;

	/**
	 * Create asset loader.
	 *
	 * Can handle scenarios where you have a skin/branding, multiple platform packs (for example mobile/desktop), localized assets and multiple file types.
	 *
	 * @param	descriptorPath - Path to asset folder descriptor created with npm directory-tree
	 * @param 	config	- Loader configuration object
	 */
	public function new(descriptorPath:String, ?config:AssetConfig) {
		config = config != null ? config : {};
		_platform = config.platform;
		_locale = config.locale;
		_formats = config.formats;
		_imageFolder = config.imageFolder != null ? config.imageFolder : _imageFolder;
		_soundFolder = config.soundFolder != null ? config.soundFolder : _soundFolder;
		_fontFolder = config.fontFolder != null ? config.fontFolder : _fontFolder;
		_atlasFolder = config.atlasFolder != null ? config.atlasFolder : _atlasFolder;
		_spineFolder = config.spineFolder != null ? config.spineFolder : _spineFolder;
		_modelFolder = config.modelFolder != null ? config.modelFolder : _modelFolder;
		_gradientFolder = config.gradientFolder != null ? config.gradientFolder : _gradientFolder;
		_configFolder = config.configFolder != null ? config.configFolder : _configFolder;
		_defaultLocale = config.defaultLocale != null ? config.defaultLocale : _defaultLocale;
		_commonFolder = config.commonFolder != null ? config.commonFolder : _commonFolder;
		_localizedFolder = config.localizedFolder != null ? config.localizedFolder : _localizedFolder;
		_extensionHandlers = new IntMap<HandlerItem->Void>();
		_loadingQueue = [];
		_loadedBytes = new StringMap<Int>();
		var http = new Http(descriptorPath);
		http.onData = data -> {
			var parsedData = haxe.Json.parse(data);
			_content = cast parsedData.children.find(item -> item.name == 'default');
			if (config.pack != 'default') {
				_brandingContent = cast parsedData.children.find(item -> item.name == config.pack);
			}
			_commonContent = _content.children.find(item -> item.name == _commonFolder);
			_platformContent = _content.children.find(item -> item.name == config.platform);
			if (_brandingContent != null) {
				_brandingCommon = _brandingContent.children.find(item -> item.name == _commonFolder);
				_brandingPlatform = _brandingContent.children.find(item -> item.name == config.platform);
			}
			onReady();
		};
		http.onError = function(error) {
			trace('error: $error');
		};
		http.request();
	}

	public function load() {
		_loadedItems = 0;
		_totalBytes = _loadingQueue.fold((curr : QueueItem, last : Int) -> {
			var size = curr.size;
			if (curr.extras != null) {
				for (e in curr.extras) {
					size += e.size;
				}
			}
			return (size + last);
		}, 0);
		loadNext();
	}

	public function addHandler(type:AssetType, handler:HandlerItem->Void) {
		_extensionHandlers.set(type.getIndex(), handler);
	}

	public function queueItem(id:String, type:AssetType) {
		var entry = getEntry(id, type);
		if (entry != null) {
			// var extraType = switch (type) {
			// 	case AssetType.BitmapFont: AssetType.BitmapFontImage;
			// 	case AssetType.Atlas: AssetType.AtlasImage;
			// 	case AssetType.SpineAtlas: AssetType.SpineImage;
			// 	default: null;
			// }
			// var extraType2 = switch (type) {
			// 	case AssetType.SpineAtlas: AssetType.SpineConfig;
			// 	default: null;
			// }
			final extraTypes:Array<AssetType> = switch (type) {
				case AssetType.BitmapFont: [BitmapFontImage];
				case AssetType.Atlas: [AtlasImage];
				case AssetType.SpineAtlas: [SpineImage, SpineConfig];
				default: [];
			}
			_totalItems++;

			final queueItem:QueueItem = {
				type: type,
				name: entry.name,
				path: entry.path,
				size: entry.size,
				extension: entry.extension,
				extras: null,
			};

			if (entry.extras != null) {
				queueItem.extras = [];
				for (e in entry.extras) {
					final extraItem:QueueItem = {
						type: extraTypes[queueItem.extras.length],
						name: e.name,
						path: e.path,
						size: e.size,
						extension: e.extension,
					};
					queueItem.extras.push(extraItem);

					_totalItems++;
				}
			}

			_loadingQueue.push(queueItem);
		}
	}

	dynamic public function onReady() {}

	dynamic public function onComplete() {}

	dynamic public function onProgress(percentDone:Int) {}

	dynamic public function onError(error:String) {}

	function loadNext() {
		if (_itemIndex < _loadingQueue.length) {
			var item = _loadingQueue[_itemIndex];
			loadItem(item, _extensionHandlers.get(item.type.getIndex()));
			if (item.extras != null) {
				for (e in item.extras) {
					loadItem(e, _extensionHandlers.get(e.type.getIndex()));
				}
			}

			haxe.Timer.delay(() -> {
				_itemIndex++;
				loadNext();
			}, 0);
		}
	}

	function loadItem(item:QueueItem, ?handler:HandlerItem->Void) {
		#if js
		var request = new js.html.XMLHttpRequest();
		request.open('GET', item.path, true);
		request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
		request.onload = event -> {
			if (request.status != 200) {
				onError(request.statusText);
				return;
			}
			_loadedItems++;
			var bytes = haxe.io.Bytes.ofData(request.response);
			switch (item.type) {
				case AssetType.Font:
					var fontResourceName = 'R_font_' + item.name; untyped {
						var s = js.Browser.document.createStyleElement();
						s.type = "text/css";
						s.innerHTML = "@font-face{ font-family: " + fontResourceName + "; src: url('data:font/ttf;base64," + Base64.encode(bytes)
							+ "') format('truetype'); }";
						js.Browser.document.getElementsByTagName('head')[0].appendChild(s);
						// create a div in the page to force font loading
						var div = js.Browser.document.createDivElement();
						div.style.fontFamily = fontResourceName;
						div.style.opacity = 0;
						div.style.width = "1px";
						div.style.height = "1px";
						div.style.position = "fixed";
						div.style.bottom = "0px";
						div.style.right = "0px";
						div.innerHTML = ".";
						div.className = "hx__loadFont";
						js.Browser.document.body.appendChild(div);
					};
				default:
					null;
			}
			if (handler != null) {
				handler({id: item.name, data: bytes, path: item.path});
			}
			if (_loadedItems == _totalItems) {
				onComplete();
			}
		};
		request.onprogress = function(event:js.html.ProgressEvent) {
			var loaded = event.loaded;
			var total = event.total;
			handleProgress(Std.int(loaded), item.path, Std.int(total));
		}
		request.send(null);
		#else
		throw 'NOT IMPLEMENTED';
		#end
	}

	function getEntry(name:String, type:AssetType):FileEntry {
		var typeFolder = switch (type) {
			case AssetType.Image: _imageFolder;
			case AssetType.Sound: _soundFolder;
			case AssetType.Font | AssetType.BitmapFont: _fontFolder;
			case AssetType.Atlas: _atlasFolder;
			case AssetType.SpineAtlas: _spineFolder;
			case AssetType.Model: _modelFolder;
			case AssetType.Gradient: _gradientFolder;
			case AssetType.Config: _configFolder;
			default: null;
		}
		var platformFolder:FileEntry = null;
		if (_platformContent != null) {
			platformFolder = _platformContent.children.find(item -> item.name == typeFolder);
		}
		var brandingPlatformFolder:FileEntry = null;
		if (_brandingPlatform != null) {
			brandingPlatformFolder = _brandingPlatform.children.find(item -> item.name == typeFolder);
		}
		var brandingCommonFolder:FileEntry = null;

		if (_brandingCommon != null) {
			brandingCommonFolder = _brandingCommon.children.find(item -> item.name == typeFolder);
		}
		var commonFolder:FileEntry = _commonContent.children.find(item -> item.name == typeFolder);
		function getFilesFromFolder(folder:FileEntry, locale:String):Array<FileEntry> {
			if (folder == null) {
				return null;
			}
			var matches:Array<FileEntry>;
			var localized = folder.children.find(item -> item.name == _localizedFolder);
			if (localized != null) {
				var localeDir = localized.children.find(item -> item.name == locale && item.type == 'directory');
				if (localeDir == null) {
					localeDir = localized.children.find(item -> item.name == _defaultLocale && item.type == 'directory');
				}
				if (localeDir != null) {
					matches = findFilesByName(localeDir, name);
				}
			}
			if (matches == null || matches.length < 1) {
				matches = findFilesByName(folder, name);
			}
			return matches;
		}
		// Resolve files in following priority: Branding platform -> Branding common -> Default platform -> Default common
		var files = getFilesFromFolder(brandingPlatformFolder, _locale);
		if (files == null || files.length == 0) {
			files = getFilesFromFolder(brandingCommonFolder, _locale);
			if (files == null || files.length == 0) {
				files = getFilesFromFolder(platformFolder, _locale);
				if (files == null || files.length == 0) {
					files = getFilesFromFolder(commonFolder, _locale);
				}
			}
		}

		var entry:FileEntry = null;
		if (files != null) {
			if (files.length > 1) {
				switch (type) {
					case AssetType.BitmapFont:
						entry = files.find(val -> val.extension == '.xml' || val.extension == '.fnt');
						final extra = files.find(val -> val.extension == '.png');
						gasm.core.utils.Assert.that(extra != null, 'Unable to find bitmap font image.');
						entry.extras = [];
						extra.type = 'file';
						extra.path = extra.path.replace('\\', '/');
						extra.name = getCleanFilename(extra.name);
						extra.size = extra.size != null ? Std.int(extra.size) : 0;
						entry.extras.push(extra);
					case AssetType.Atlas:
						entry = files.find(val -> val.extension == '.atlas');
						var preferredExtension = getPreferredExtension(AssetType.AtlasImage);
						var extra = files.find(val -> val.extension == preferredExtension);
						if (extra == null) {
							extra = files.find(val -> val.extension == '.basis' || val.extension == '.png' || val.extension == '.jpg');
						}
						gasm.core.utils.Assert.that(extra != null, 'Unable to find atlas image.');
						entry.extras = [];
						extra.type = 'file';
						extra.path = extra.path.replace('\\', '/');
						extra.name = getCleanFilename(extra.name);
						extra.size = extra.size != null ? Std.int(extra.size) : 0;
						entry.extras.push(extra);
					case AssetType.SpineAtlas:
						entry = files.find(val -> val.extension == '.atlas');

						// SpineImage
						var preferredExtension = getPreferredExtension(AssetType.SpineImage);
						var extra = files.find(val -> val.extension == preferredExtension);
						if (extra == null) {
							extra = files.find(val -> val.extension == '.png' || val.extension == '.jpg');
						}
						gasm.core.utils.Assert.that(extra != null, 'Unable to find spine image.');
						entry.extras = [];
						extra.type = 'file';
						extra.path = extra.path.replace('\\', '/');
						extra.name = getCleanFilename(extra.name);
						extra.size = extra.size != null ? Std.int(extra.size) : 0;
						entry.extras.push(extra);

						// SpineConfig
						var extraConfig = files.find(val -> val.extension == '.json');
						gasm.core.utils.Assert.that(extraConfig != null, 'Unable to find spine config.');
						extraConfig.type = 'file';
						extraConfig.path = extraConfig.path.replace('\\', '/');
						extraConfig.name = getCleanFilename(extraConfig.name);
						extraConfig.size = extraConfig.size != null ? Std.int(extraConfig.size) : 0;
						entry.extras.push(extraConfig);
					default:
						var preferredExtension = getPreferredExtension(type);
						if (preferredExtension == null) {
							trace('Multiple files with same name found, but no preferred extension configured.');
							trace('When constructing Loader add format param defining if you prefer to use '
								+ [for (match in files) match.extension].join(' or ')
								+ ' for type '
								+ type.getName());
						}
						entry = files.find(val -> val.extension == preferredExtension);
				}
			} else {
				entry = files[0];
			}
		}
		if (entry == null) {
			return null;
		}
		entry.path = entry.path.replace('\\', '/');
		entry.name = getCleanFilename(entry.name);
		entry.size = entry.size != null ? Std.int(entry.size) : 0;
		return entry;
	}

	inline function getCleanFilename(name:String):String {
		final len = name.lastIndexOf('.') != -1 ? name.lastIndexOf('.') : null;
		return name.substr(0, len);
	}

	inline function findFilesByName(dir:FileEntry, name:String):Array<FileEntry> {
		return dir.children.filter(item -> getCleanFilename(item.name) == name && item.type == 'file');
	}

	function handleProgress(position:Int, id:String, total:Int) {
		_loadedBytes.set(id, position);
		var loadedTotal = _loadedBytes.fold((curr : Int, last : Int) -> curr + last, 0);
		onProgress(Std.int((loadedTotal / _totalBytes) * 100));
	}

	function getPreferredExtension(type:AssetType) {
		var fmt = _formats.find(val -> val.type == type);
		if (fmt != null) {
			return fmt.extension;
		}
		return null;
	}
}

typedef QueueItem = {
	name:String,
	type:AssetType,
	path:String,
	size:Int,
	extension:String,
	?extras:Array<QueueItem>,
}

typedef FormatType = {
	type:AssetType,
	extension:String,
}

enum AssetType {
	Image;
	Sound;
	Font;
	BitmapFont;
	BitmapFontImage;
	Config;
	Atlas;
	AtlasImage;
	Gradient;
	Model;
	SpineAtlas;
	SpineImage;
	SpineConfig;
}

typedef HandlerItem = {
	id:String,
	data:haxe.io.Bytes,
	?path:String,
}

typedef AssetConfig = {
	/**
	 * If specified, resources will resolved from this sub directory
	 */
	?pack:String,
	/**
	 * platform - If specified, resources will load from this platform folder
	 */
	?platform:String,
	/**
	 * If specfied, will look for a locale sub folder and prioritize assets in that folder
	 */
	?locale:String,
	/**
	 * Array with FormatTypes to define what extension to use if multiple files with same name is found. For example [{type:AssetType.Sound, extension:'.mp3'}] will ensure you only load mp3 audio
	 */
	?formats:Array<FormatType>,
	/**
	 * Name of folder containing images, defaults to 'image'
	 */
	?imageFolder:String,
	/**
	 * Name of folder containing sounds, defaults to 'sound'
	 */
	?soundFolder:String,
	/**
	 * Name of folder containing fonts, defaults to 'font'
	 */
	?fontFolder:String,
	/**
	 * Name of folder containing atlases, defaults to 'atlas'
	 */
	?atlasFolder:String,
	/**
	 * Name of folder containing spines, defaults to 'spine'
	 */
	?spineFolder:String,
	/**
	 * Name of folder containing models, defaults to 'model'
	 */
	?modelFolder:String,
	/**
	 * Folder for gradient .grd assets
	**/
	?gradientFolder:String,
	/**
	 * Name of folder containing json config files, defaults to 'config'
	 */
	?configFolder:String,
	/**
	 * If locale has been set, this is the name of locale sub folder in which to look for localized assets. Defaults to 'localized'
	 */
	?localizedFolder:String,
	/**
	 * If locale for a resource is not found, this is the locale to fall back to. Dfeaults to 'en'
	 */
	?defaultLocale:String,
	/**
	 * Folder for non-platform specific assets
	**/
	?commonFolder:String,
}
