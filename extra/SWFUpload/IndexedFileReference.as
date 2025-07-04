import flash.net.FileReference;
class IndexedFileReference extends FileReference { 
	public static var num_index:Number = 0; 
	public var test:Number = 111; 
	function IndexedFileReference(){
		super();
		num_index++;
	}
	public function get index():Number{
		return num_index;
	}
}