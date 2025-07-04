require File.dirname(__FILE__) + '/../test_helper'

class WidgetInstanceTextTest < Test::Unit::TestCase
  fixtures :widget_instance_texts
  def setup
    @widget = WidgetInstanceText.new
    @text = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
  end
  
  # Replace this with your real tests.
  def test_translate
    text = WidgetInstanceText.new
    assert_kind_of WidgetInstanceText, text
    # text.value = '<FONT COLOR=red FACE=Verdana SIZE="5">Test</FONT>'
    # text.save!
    # text.reload
    # assert_equal "<font style=\"font-family: 'Verdana'; color: red\" SIZE=\"5\">Test</FONT>", text.value
  end
    
  def test_santanize_xml    
    @widget.value = '<?xml version="1.0" encoding="UTF-8"?>Lorem ipsum dolor sit amet'
    assert_widget_value
  end
  
  def test_santanize_link_javascript   
    @widget.value = '<a href="javascript:ttt()" title="sss">Lorem</a> ipsum <a href="xxx" title="sss">dolor</a> sit amet'
    assert_widget_value '<a title="sss">Lorem</a> ipsum <a href="xxx" title="sss">dolor</a> sit amet'
  end
  
  def test_santanize_inline_javascript   
    @widget.value = 'sss <script>
    ert = null
    </script> sss'
    assert_widget_value 'sss  sss'
  end
  
  def test_santanize_inline_javascript_with_attributes   
    @widget.value = 'sss <script language="application/javascript">
    ert = null
    </script> sss'
    assert_widget_value 'sss  sss'
  end
  
  def test_santanize_form_element   
    @widget.value = 'sss <form method="something">
    <input>
    </form> sss'
    assert_widget_value 'sss 
    <input>
     sss'
  end
  
  def test_santanize_comments   
    @widget.value = '<!-- Some comment
    /// With strange content
     text -->Lorem ipsum dolor sit amet'
    assert_widget_value
  end
  
  def test_santanize_editor_block_node_with_content    
    @widget.value = '<sx:moz-editor-block-spacer>Lorem<div>ipsum<div></div><b></b></div></sx:moz-editor-block-spacer>ipsum dolor sit amet' 
    assert_widget_value 'Loremipsum<div><b></b></div>ipsum dolor sit amet'
  end
  
  def test_santanize_editor_block_node_with_linebreak_content    
    @widget.value =%q{<sx:moz-editor-block-spacer>
      <div>Lorem</div>
      ipsum
      </sx:moz-editor-block-spacer> dolor}
    assert_widget_value %q{
      Lorem
      ipsum
       dolor}
  end
  
  def test_santanize_remaining_moz_element    
    @widget.value = %q{</sx:moz-editor-block-spacer><sx:moz-editor-block-spacer style="something">
      <div>Lorem</div>
      }
    assert_widget_value %q{
      <div>Lorem</div>
      }
  end
  
  def test_santanize_rename_moz_element    
    @widget.value = %q{<sx:moz-editor-block-spacer>
      <div>Lorem</div>
      ipsum
      </sx:moz-editor-block-spacer> dolor lorem <sx:moz-editor-cursor-spacer style="again"> ipsume</sx:moz-editor-cursor-spacer>}
    assert_widget_value   %q{
      Lorem
      ipsum
       dolor lorem <span style="again"> ipsume</span>}
  end
  
  def test_santanize_editor_block_no_div    
    @widget.value =%q{<sx:moz-editor-block-spacer></sx:moz-editor-block-spacer>Lorem ipsum dolor}
    assert_widget_value %q{Lorem ipsum dolor}
  end
  
  def test_santanize_editor_block_no_div_with_content  
    @widget.value =%q{<sx:moz-editor-block-spacer>
      Lorem </sx:moz-editor-block-spacer>ipsum dolor}
    assert_widget_value %q{
      Lorem ipsum dolor}
  end
  
  
  def test_santanize_editor_block_without_content    
    @widget.value = '<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer>Lorem ipsum dolor sit amet' 
    assert_widget_value
  end
  
  def test_santanize_editor_cursor_with_content    
    @widget.value = '<sx:moz-editor-cursor-spacer>Lorem<div>ipsum<div></div><b></b></div></sx:moz-editor-cursor-spacer>ipsum dolor sit amet' 
    assert_widget_value 'Lorem<div>ipsum<div></div><b></b></div>ipsum dolor sit amet'
  end
  
  def test_santanize_editor_cursor_without_content    
    @widget.value = '<sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>Lorem ipsum dolor sit amet' 
    assert_widget_value
  end
  
  
  def test_santanize_bogus_node_and_read    
    @widget.value = '<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>Lorem ipsum dolor sit amet' 
    assert_widget_value
    assert_equal '<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    Lorem ipsum dolor sit amet', @widget.value
  end
  
  
  def test_nil_value
    assert_kind_of String, WidgetInstanceText.new(:value => nil).value
  end
  
  private
  
  def assert_widget_value value = 'Lorem ipsum dolor sit amet'
    assert_equal value, @widget.read_attribute(:value)
  end
end
