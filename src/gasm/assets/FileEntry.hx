package gasm.assets;

typedef FileEntry = {
	name:String,
	size:Int,
	type:FileEntryType,
	path:String,
	?children:Array<FileEntry>,
	?extension:String,
	?extras:Array<FileEntry>,
}

@:enum abstract FileEntryType(String) from String to String {
	var Directory = 'directory';
	var File = 'file';
}
