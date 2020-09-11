# Demo Blog

**You can check the app on-air here: `link coming soon`**

A blog app built with:

  - Ruby on Rails 6
  - Bootstrap
  - MySQL
  - Graphql

# How to run it locally?

  1. Make sure you have Ruby installed: `ruby -v` (I have `2.5.7`)
  2. Make sure you have MySQL installed: `mysql -VERSION` (I have `8.0.21`)
  3. Download the ZIP file of this project and unpack it
  4. Create a duplicate of the `/config/database.example.yml` file, name it `database.yml` and replace `YOUR_USERNAME_HERE` and `YOUR_PASSWORD_HERE` with your DB username and password
  5. Open a terminal window in the project folder and run `bundle install`
  6. Run `bundle exec rails db:setup`
  7. Run `bundle exec rails s`
  8. Go to http://localhost:3000 in your browser

# How to test the GraphQL API?

1. Go to http://localhost:3000/graphiql in your browser (you have to sign in as a user - authentication good enough for development)
2. You can use examples from the file below

```
query Posts {
  posts {
    id
    title
    content
    createdAt
    updatedAt
    author {
      email
    }
  }
}

query Post {
  post(id: 1) {
    id
    title
    content
    createdAt
    updatedAt
    author {
      email
    }
  }
}

query PostReactions {
  post(id: 1) {
    reactions {
      type
      user {
        email
      }
    }
  }
}

query Comments {
  post(id: 1) {
    comments {
      id
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
  }
}

query Comment {
  comment(id: 1) {
    id
    content
    createdAt
    updatedAt
    author {
      email
    }
  }
}

query CommentReactions {
  comment(id: 1) {
    reactions {
      type
      user {
        email
      }
    }
  }
}

mutation CreatePost {
  createPost(input: {title: "title", content: "content"}) {
    post {
      id
      title
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
    errors
  }
}

mutation UpdatePost {
  updatePost(input: {id: 1, title: "titlenew", content: "contentnew"}) {
    post {
      id
      title
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
    errors
  }
}

mutation DeletePost {
  deletePost(input: {id: 1}) {
    post {
      id
      title
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
  }
}

mutation CreateComment {
  createComment(input: {postId: 1, content: "content"}) {
    comment {
      id
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
    errors
  }
}

mutation UpdateComment {
  updateComment(input: {id: 1, content: "contentnew"}) {
    comment {
      id
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
    errors
  }
}

mutation DeleteComment {
  deleteComment(input: {id: 1}) {
    comment {
      id
      content
      createdAt
      updatedAt
      author {
        email
      }
    }
  }
}

mutation ReactToPost {
  reactToPost(input: {postId: 1, type: "like"}) {
    reaction {
      type
      user {
        email
      }
    }
    errors
  }
}

mutation DeleteReactionToPost {
  deleteReactionToPost(input: {postId: 1}) {
    reaction {
      type
      user {
        email
      }
    }
  }
}

mutation ReactToComment {
  reactToComment(input: {commentId: 1, type: "like"}) {
    reaction {
      type
      user {
        email
      }
    }
    errors
  }
}

mutation DeleteReactionToComment {
  deleteReactionToComment(input: {commentId: 1}) {
    reaction {
      type
      user {
        email
      }
    }
  }
}
```