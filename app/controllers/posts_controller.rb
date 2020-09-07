class PostsController < ApplicationController
  before_action :find_post_for_current_user, only: [:update, :destroy]

  def index
    @my_posts = params[:my_posts].present?
    posts     = @my_posts ? current_user.posts : Post.all
    @posts    = posts
      .includes(:author)
      .order(created_at: :desc)
      .paginate(page: params[:page], per_page: 5)
  end

  def show
    @post = Post
      .includes(:author, reactions: :user, comments: [:author, reactions: :user])
      .order("comments.created_at DESC")
      .find_by(id: params[:id])

    redirect_to :root, alert: "This post does not exist." unless @post

    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(permitted_params)

    unless @post.valid?
      return render json: { errors: @post.errors }, status: 400
    end

    @post.save!
    flash[:success] = "Your post has been published!"
    render json: { redirect_url: post_path(@post) }
  end

  def update
    @post.assign_attributes(permitted_params)

    unless @post.valid?
      return render json: { errors: @post.errors }, status: 400
    end

    @post.save!
    flash[:success] = "Your post has been updated!"
    render json: {}
  end

  def destroy
    @post.destroy!
    redirect_to root_path, notice: "Your post has been removed."
  end

  private

  def permitted_params
    params.require(:post).permit(:title, :content).tap do |whitelisted|
      whitelisted[:title]   = params[:post][:title].strip
      whitelisted[:content] = helpers.sanitize(helpers.normalize_content(params[:post][:content]))
    end
  end

  def find_post_for_current_user
    @post = current_user.posts.find_by(id: params[:id])

    unless @post
      flash[:alert] = "This post does not exist."
      respond_to do |format|
        format.json { render json: { redirect_url: root_path }, status: 400 }
        format.html { redirect_to root_path }
      end
    end
  end
end
