User.destroy_all
Post.destroy_all
Comment.destroy_all

first_user     = User.create!(email: "user1@mail.com", password: 123456)
second_user    = User.create!(email: "user2@mail.com", password: 123456)
first_post     = first_user.posts.create(title: "The first post", content: "This is the first post!")
second_post    = second_user.posts.create(title: "The second post", content: "This is the second post!")
first_comment  = first_post.comments.create(content: "This is the first comment", user_id: second_user.id)
second_comment = second_post.comments.create(content: "This is the second comment", user_id: first_user.id)

demo_post = second_user.posts.create(
  title:   "This is a sample post to show what you can do here!",
  content: %Q{
    <section>
    The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
    </section>

    <br>
    <a href="#">This is a link</a>

    <br>
    <b>Bold</b>

    <br>
    line
    break

    <br>
    <code>
    A code snippet
    </code>

    <br>
    <em>Emphasized </em>

    <br>
    <h2>h2</h2>
    <h3>h3</h3>
    <h4>h4</h4>
    <h5>h5</h5>
    <h6>h6</h6>

    <br>
    <i>italic</i>

    <br>
    Ordered list:
    <ol>
    <li>item 1</li>
    <li>item 2</li>
    </ol>

    Unordered list
    <ul>
    <li>item 1</li>
    <li>item 2</li>
    </ul>

    <p>Paragraph</p>

    <s>Strikethrough</s>

    <br>
    <strong>Strong</strong>

    <br>
    <mark>Mark</mark>
  }
)