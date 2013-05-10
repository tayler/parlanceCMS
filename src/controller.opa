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
      case "/signup" : SignupController.signup()
      case "/activation/" activationCode = Rule.alphanum_string: SignupController.activation(activationCode)
      case "/login" : LoginController.login()
      case "/admin" : AdminController.dashboard()
      case "/admin/options" : AdminController.options()
      // default : View.default_page()
    }
  }
}

module PostController {
  function all_posts() {
    posts = PostModel.all_posts()
    PostView.post_list(posts)
  }

  function create_post() {
    match (UserModel.get_logged_user()) {
      case {guest}:
        LoginView.loginForm("/post/create")
      case ~{user}:
        allCategories = CategoryModel.get_all_categories()
        PostView.create_post(allCategories)
    }
  }

  function single_post(postId) {
    postDetails = PostModel.get_post(postId)
    PostView.single_post(postDetails)
  }

  function edit_post(postId) {
    match (UserModel.get_logged_user()) {
      case {guest}:
        LoginView.loginForm("/post/edit")
      case ~{user}:
        PostView.edit_post(postId)
    }

  }

  // function delete_post() {

  // }

  function posts_by_category(categoryId) {
    relatedPosts = PostModel.get_posts_by_category(categoryId)

    PostView.post_list(relatedPosts)
  }

}

module CategoryController {
}
module SignupController {
  function signup() {
    SignupView.signupForm()
  }
  function activation(activationCode) {
    SignupView.activate_user(activationCode)
  }
}
module LoginController {
  function login() {
    LoginView.loginForm("/")
  }
}

module AdminController {
  function dashboard() {
    match (UserModel.get_logged_user()) {
      case {guest}:
        // should redirect to dash when they've logged in
        LoginView.loginForm("/admin")
      case ~{user}:
        AdminView.dashboard()
    }
  }

  function options() {
    match (UserModel.get_logged_user()) {
      case {guest}:
        // should redirect to dash when they've logged in
        LoginView.loginForm("/admin/options")
      case ~{user}:
        AdminView.options()
    }
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












