# This class, and the helper file pdf_helper.rb can be used to convert a Stixyboard to a pdf file, for better printing support for example.
# The pdf can also be converted to png or any other graphic format and be used as thumbnails of Stixyboards. 


# Prince XML Ruby interface. 
# http://www.princexml.com
#
# Library by Subimage Interactive - http://www.subimage.com
#
#
# USAGE
# -----------------------------------------------------------------------------
#   prince = Prince.new()
#   html_string = render_to_string(:template => 'some_document')
#   send_data(
#     prince.pdf_from_string(html_string),
#     :filename => 'some_document.pdf'
#     :type => 'application/pdf'
#   )
#

class Prince
  attr_accessor :exe_path, :style_sheets, :log_file
  # Initialize method
  #
  def initialize()
    # Finds where the application lives, so we can call it.
    @exe_path = "/usr/local/bin/prince" #`which prince`.chomp
  	@style_sheets = ''
  	@log_file = "#{RAILS_ROOT}/log/prince.log"
  end
  
  # Sets stylesheets...
  # Can pass in multiple paths for css files.
  #
  def add_style_sheets(*sheets)
    for sheet in sheets do
      @style_sheets << " -s #{sheet} "
    end
  end
  
  # Returns fully formed executable path with any command line switches
  # we've set based on our variables.
  #
  def exe_path
    # Add any standard cmd line arguments we need to pass
    @exe_path << " --input=html --server --log=#{@log_file} "
    @exe_path << @style_sheets
    return @exe_path
  end
  
  # Makes a pdf from a passed in string.
  #
  # Returns PDF as a stream, so we can use send_data to shoot
  # it down the pipe using Rails.
  #
  def pdf_from_string(string)
    path = self.exe_path()
    # Don't spew errors to the standard out...and set up to take IO 
    # as input and output
    path << ' --silent - -o -'
    
    # Show the command used...
    ActiveRecord::Base.logger.info "\n\nPRINCE XML PDF COMMAND"
    ActiveRecord::Base.logger.info path
    ActiveRecord::Base.logger.info ''
    
    # Actually call the prince command, and pass the entire data stream back.
    pdf = IO.popen(path, "w+")
    pdf.puts(string)
    pdf.close_write
    pdf.gets(nil)
  end
end