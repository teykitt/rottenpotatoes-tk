class MoviesController < ApplicationController

  helper_method :sort_saved
  helper_method :ratings_param_saved

  def sort_saved
    @sort_saved = session[:sort_saved]
  end

  def sort_saved=(sort_col)
    session[:sort_saved] = sort_col
  end

  def ratings_param_saved
    @ratings_param_saved
    end

  def ratings_param_saved=(ratings_param_to_save)
    session[:ratings_param_saved] = ratings_param_to_save
    end

  def Movie
    @all_ratings = Movie.select(:rating).collect(&:rating).compact.uniq.sort
    logger.debug(@all_ratings.inspect)
#    @selected_ratings_params = @all_ratings if !@selected_ratings
#    @selected_ratings_params = ratings_param_saved if sort_saved
  end

  def selected_movie_ratings
    self.Movie
    if params[:ratings]
       @selected_ratings_params = params[:ratings].keys
       logger.debug("@selected_ratings keys")
       logger.debug(@selected_ratings_params)
       @selected_ratings = @selected_ratings_params.collect {|v| v=v.to_s.gsub(/[ratings_]/,'')}
       logger.debug("@selected_ratings post gsub")
       logger.debug(@selected_ratings)
       logger.debug(self.ratings_param_saved)
       self.ratings_param_saved = params[:ratings]
       logger.debug(self.ratings_param_saved)
    else
      @selected_ratings = ratings_param_saved if ratings_param_saved
      @selected_ratings = @all_ratings if !ratings_param_saved
    end
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
#    self.Movie
#    @movies = Movie.all
#    @movies = Movie.where(:rating => @selected_ratings) if self.selected_movie_ratings
    self.sort
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def sort
    logger.debug("enter sort - sort_saved session")
    logger.debug(self.sort_saved.inspect)
    if params[:col]
       col_header = params[:col].to_s
    else
      col_header = sort_saved
    end
    self.sort_saved = col_header
    logger.debug("after - sort_saved session")
    logger.debug(self.sort_saved.inspect)
    col = col_header.gsub("_header", '')
    @col = col
    logger.debug("col.inspect")
    logger.debug(col.inspect)
    logger.debug("@col.inspect")
    logger.debug(@col.inspect)
    logger.debug(self.ratings_param_saved)
#    self.ratings_param_saved = params[:ratings] if params[:ratings]
#    @movies = Movie.find(:all, :order => col)
    @movies = Movie.where(:rating => @selected_ratings).order(col) if self.selected_movie_ratings
    logger.debug(@movie.inspect)
    render :template => 'movies/index'
    end
end
