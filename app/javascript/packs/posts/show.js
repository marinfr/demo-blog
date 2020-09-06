$(document).ready(function () {
  function handlePostEdit() {
    $(".comments-container").hide()
    $(".post-actions .main-actions").hide()
    $(".post-actions .extra-actions").show()
    $(".post-body .edit-post").show()
    $(".post-body .content").hide()
  }

  function cancelPostEdit() {
    $(".post-actions .extra-actions").hide()
    $(".post-actions .main-actions").show()
    $(".post-body .content").show()
    $(".post-body .edit-post").hide()
    $(".comments-container").show()
  }

  function handleCommentEdit(event) {
    $comment = $(event.target).closest(".comment-container")

    $comment.find(".edit-form").show();
    $comment.find(".content").hide();
    $comment.find(".main-actions").hide();
    $comment.find(".extra-actions").show();
  }

  function cancelCommentEdit() {
    $comment = $(event.target).closest(".comment-container")

    $comment.find(".extra-actions").hide();
    $comment.find(".main-actions").show();
    $comment.find(".content").show();
    $comment.find(".edit-form").hide();
  }

  function handlePostReaction(event) {
    $target    = $(event.currentTarget)
    $container = $target.closest(".reactions")

    $.ajax({
      type: "POST",
      url:  $container.data("url"),
      data: {
        resource_id:   $container.data("resourceId"),
        resource_type: $container.data("resourceType"),
        type:          $target.data("type")
      },
      success: function (data) {
        location.reload();
      },
      error: function (data) {
        location.reload();
      }
    });
  }

  $(".js-post-edit").click(handlePostEdit);
  $(".js-cancel-post-edit").click(cancelPostEdit);
  $(".js-comment-edit").click(handleCommentEdit);
  $(".js-cancel-comment-edit").click(cancelCommentEdit);
  $(".reactions span").click(handlePostReaction);
});