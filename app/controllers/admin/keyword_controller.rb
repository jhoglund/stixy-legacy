class Admin::KeywordController < Admin::AdminApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @paginator, @page,  @keywords = paginate :keywords, :per_page => 50, :order_by => 'tag asc' 
  end

  def show
    @keyword = Keyword.find(params[:id])
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(params[:keyword])
    if @keyword.save
      flash[:notice] = 'Keyword was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @keyword = Keyword.find(params[:id])
  end

  def update
    @keyword = Keyword.find(params[:id])
    if @keyword.update_attributes(params[:keyword])
      flash[:notice] = 'Keyword was successfully updated.'
      redirect_to :action => 'show', :id => @keyword
    else
      render :action => 'edit'
    end
  end

  def destroy
   # cascade delete on keyword is on, it will clean up the join table
    Keyword.find(params[:id]).destroy
    flash[:notice] = 'Keyword was successfully deleted.'
    redirect_to :action => 'list'
  end
end
