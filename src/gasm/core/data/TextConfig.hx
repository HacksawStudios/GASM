package gasm.core.data;

typedef TextConfig = {
    ?text:String,
    font:Null<String>,
    size:Null<Int>,
    ?color:Null<Int>,
    ?selectable:Bool,
    ?filters:Array<Any>,
    ?backgroundColor:Int,
    ?width:Float,
    ?height:Float,
    ?autoSize:String,
    ?align:String,
    ?scaleToFit:Bool,
}
