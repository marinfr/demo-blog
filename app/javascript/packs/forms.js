$(document).ready(function () {
  $("form.js-form [type='submit']").prop("disabled", true);

  function handleFormInput(event) {
    if (event.key === "Enter") { return }

    $field = $(event.target).closest(".field")
    $field.removeClass("invalid")
    $field.find(".validation-errors").remove()

    $form           = $field.closest("form.js-form");
    $requiredFields = $form.find("textarea, input[type!='submit']:visible");
    $emptyFields    = $requiredFields.filter(function () { return !$(this).val().trim(); });
    $errorFields    = $form.find(".field.invalid");
    $submit         = $form.find("[type=submit]");

    if ($emptyFields.length || $errorFields.length) {
      $submit.prop("disabled", true);
    } else {
      $submit.prop("disabled", false);
    }
  }

  function handleSubmit(event) {
    event.preventDefault();
    $form = $(event.target);
    $form.find("[type='submit']").prop("disabled", true);

    $.ajax({
      type:    $form.attr("method"),
      url:     $form.attr("action"),
      data:    $form.serialize(),
      success: function (data) {
        redirectURL = data.redirect_url

        if (redirectURL) {
          return window.location = redirectURL
        } else {
          location.reload();
        }
      },
      error:   function (data) {
        $.each(data.responseJSON.errors, function (field, errors) {
          $field = $form.find("[name$='[" + field + "]']");
          validationErrors = errors.join("<br>");
          $field.after("<p class='validation-errors'>" + validationErrors + "</p>");
          $field.closest(".field").addClass("invalid");
        });
      }
    });
  }

  $("form.js-form textarea, input[type!='submit']").keyup(handleFormInput);
  $("form.js-form").submit(handleSubmit);
});
