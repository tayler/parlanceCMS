module RouteController {

  resources = @static_resource_directory("resources")

  dispatcher = {
    parser {
      case "/" : PostController.all_posts()
      case "/post/" postId = Rule.integer: PostController.single_post(postId)
      case "/post/create" : PostController.create_post()
      case "/post/edit/" postId = Rule.integer: PostController.edit_post(postId)
      // case "/delete" : PostController.delete_post()
      case "/category/" categoryId = Rule.integer: PostController.posts_by_category(categoryId)
      // case "/tag/" tagId = Rule.integer: PostController.posts_by_tag(tagId)
      case "/login" : LoginController.login()
      case "/admin" : AdminController.dashboard()
      case "/admin/options" : AdminController.options()
      // default : View.default_page()
    }
  }
}

module Site {
}

module PostController {
  function all_posts() {
    posts = PostModel.all_posts()
    PostView.post_list(posts)
  }

  function create_post() {
    allCategories = CategoryModel.get_all_categories()
    PostView.create_post(allCategories)
  }

  function single_post(postId) {
    postDetails = PostModel.get_post(postId)
    PostView.single_post(postDetails)
  }

  function edit_post(postId) {
    PostView.edit_post(postId)
  }

  // function delete_post() {

  // }

  function posts_by_category(categoryId) {
    relatedPosts = PostModel.get_posts_by_category(categoryId)

    PostView.post_list(relatedPosts)
  }
  // function posts_by_tag(tagId) {
  //   // relatedPosts = PostModel.get_posts_by_tag(tagId)

  //   PostView.post_list(relatedPosts)
  // }


}

module CategoryController {
}

module LoginController {
  function login() {
    LoginView.login()
  }
}

module AdminController {
  function dashboard() {
    AdminView.dashboard()
  }

  function options() {
      AdminView.options()
  }
}


// removed from { css: ... } for testing: , "http://fonts.googleapis.com/css?family=Abel", "http://fonts.googleapis.com/css?family=Lora"
Server.start(Server.http, [
  { register:
    [ { doctype: { html5 } },
      { js: [ ] },
      { css: [ "/resources/css/style.css"] } 
    ]
  },
  { resources: RouteController.resources },
  { custom: RouteController.dispatcher }
])












