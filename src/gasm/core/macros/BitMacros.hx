package gasm.core.macros;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:remove @:autoBuild(BitMacros.assignBits())
extern interface BitFlag {}
/**
 * ...
 * @author Leo Bergman
 */
class BitMacros
{
	#if macro
	public static function assignBits():Array<Field> {
		var fields = Context.getBuildFields();
		var args = [];
		var states = [];
		var index = 0;
		for (f in fields) {
		  switch (f.kind) {
			case FVar(t, _):
				var field:Field = {
				  name:  f.name,
				  access: [Access.APublic],
				  kind: FieldType.FProp("default", "null", (macro:Int)), 
				  pos: pos,
				  value: 1 << index
				};
				index++;
			default:
		  }
		}
		return fields;
    }
	#end
  }
}