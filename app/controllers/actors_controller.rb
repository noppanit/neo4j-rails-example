class ActorsController < ApplicationController
#  before_filter :find_actor, :only => [:show, :edit, :update, :destroy, :link, :unlink]
  around_filter :neo_tx


  def index
    @actors = Actor.all.nodes
  end

  def create
    @actor = Actor.new
    @actor.update(params[:actor])
    flash[:notice] = 'Actor was successfully created.'
    redirect_to(@actor)
  end

  def update
    @actor.update(params[:actor])
    flash[:notice] = 'Actor was successfully updated.'
    redirect_to(@actor)
  end

  def destroy
    @actor.del
    redirect_to(actors_url)
  end

  def edit
  end

  def show
    @movies = Movie.all.nodes
  end

  def link
    @movie = Neo4j.load_node(params[:movie_id])
    rel1 = @actor.acted_in.new(@movie)
    rel1.character = params[:character]
    redirect_to(@actor)
  end
  
  def unlink
    relationship = Neo4j.load_rel(params[:rel_id])
    relationship.del
    redirect_to(@actor)
  end

  def new
    @actor = Actor.value_object.new
  end

  private

  def find_actor
    @actor = Neo4j.load_node(params[:id])
  end

  private

  def neo_tx
    Neo4j::Transaction.new
    @actor = Neo4j.load_node(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end
