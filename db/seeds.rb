User.destroy_all
Post.destroy_all
Comment.destroy_all

first_user  = User.create!(email: "user1@mail.com", password: 123456)
second_user = User.create!(email: "user2@mail.com", password: 123456)
first_post  = first_user.posts.create(title: "The first post", content: "This is the first post!")
second_post = second_user.posts.create(title: "The second post", content: "This is the second post!")
