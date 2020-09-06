class CommentsController < ApplicationController
  before_action :find_post,                     only: [:create, :update, :destroy]
  before_action :find_comment_for_current_user, only: [:update, :destroy]

  def create
    @comment = @post.comments.new(permitted_params.merge(user_id: current_user.id))

    unless @comment.valid?
      return render json: { errors: @comment.errors }, status: 400
    end

    @comment.save!
    render json: {}
  end

  def update
    @comment.assign_attributes(permitted_params)

    unless @comment.valid?
      return render json: { errors: @comment.errors }, status: 400
    end

    @comment.save!
    render json: {}
  end

  def destroy
    @comment.destroy!
    redirect_to post_path(@post), notice: "Your comment has been destroyed."
  end

  private

  def permitted_params
    params.require(:comment).permit(:content).tap do |whitelisted|
      whitelisted[:content] = helpers.sanitize(helpers.normalize_content(params[:comment][:content]))
    end
  end

  def find_post
    @post = Post.find(params[:post_id])

    unless @post
      flash[:alert] = "This post does not exist."
      redirect_to root_path
    end
  end

  def find_comment_for_current_user
    @comment = @post.comments.find_by(id: params[:id], user_id: current_user.id)

    unless @comment
      flash[:alert] = "This comment does not exist."
      redirect_to post_path(@post)
    end
  end
end
