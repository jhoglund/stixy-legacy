import flash.external.ExternalInterface;
class logger {
	public static function debug(msg, name:String){
		ExternalInterface.call("logger.debug", msg, name);
	}
}