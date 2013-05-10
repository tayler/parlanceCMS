module DefaultView {

  function page_template(title, content, notice) {
    title = title + " :: ParlanceCMS"
      html =
      <div class="navbar navbar-top">
        <div class=navbar-inner>
          <div class=container>
            {Topbar.html()}
          </div>
        </div>
      </div>
      <span id=#notice class=container>{notice}</span>
      <div id=#main class="container row content">
        {content}
      </div>
    Resource.page(title, html)
  }

}

module Topbar {
  function html() {
    <a class="brand heading-text" href="/">parlanceCMS</a>
    <ul class="main-menu pull-right">
      {user_menu()}
    </>

  }

  function user_menu() {
    match (UserModel.get_logged_user()) {
      case {guest}:
        <li class=menu-item><a class=nav-link href="/signup">Sign Up</></>
        <li class=menu-item><a class=nav-link href="/login">Login</></>
      case ~{user}: user_box(user.username)
    }
  }

  private function user_box(username) {
    id = Dom.fresh_id()
    <ul id={id} class="nav pull-right">
      <li class=menu-item>Hello {username}!</>
      <li class=menu-item><a class=nav-link href="/post/create">New Post</></>
      <li class=menu-item><a class=nav-link href="/post/edit">Edit Post</></>
      <li class=menu-item><a class=nav-link href="/admin">Admin</></>
      <li class=menu-item><a class=nav-link href="/admin/options">Options</></>
      <li class=menu-item><a class=nav-link onclick={logout} href="#">Sign out</></>
    </>
  }

  private function logout(_) {
    UserModel.logout()
    Client.reload()
  }
}

module Events {
  /**
  * fires on submit of new post; collects all data from new post inputs; sends to model
  */
  function submit_post(_) {
    title = Dom.get_value(#postTitle)
    body = Dom.get_value(#postBody)
    categoryIdString = Dom.get_value(#postCategory)
    newCategory = Dom.get_value(#postCategoryNew)
    author = match (UserModel.get_logged_user()) {
      case {guest}:
        "guest"
      case ~{user}:
        UserModel.get_name(user)
    }
    println(Debug.dump(author))

    categoryId = match(String.is_empty(newCategory)) {

      case {true} :
        categoryId = String.to_int(categoryIdString)
        categoryId
      case {false} :
        // save new category and get id
        categoryId = CategoryModel.new_category(newCategory)
        categoryId
    }

    newPost = ~{title, body, categoryId, author}

    // work on parser from dropbox as a database tutorial at blog.opalang.org

    #notice = match (PostModel.set_new_post(newPost)) {
      case {success: _}:
        SiteView.alert("Congratulations! Your new post was saved.", "success")
      case {failure: msg}:
        SiteView.alert("The post did not save correctly.", "error")
    }
  }
}

module SiteView {
  function alert(message, alertClass) {
    <div class="alert alert-{alertClass}">
      <button type="button" class="close" data-dismiss="alert">×</button>
        {message}
    </div>
  }
}

module PostView {
  function post_list(posts) {
    content = <div id=#allPosts onready={function(_) {
                List.map(function(post) {
                  postCategory = /parlance/categories[{ categoryId:post.categoryId  }]/category
                  // println(Debug.dump(postTags))
                  #allPosts =+  <div class="span12 post-wrapper">
                                  <h2 class="post-title heading-text"><a href="/post/{post.postId}">{post.title}</></>
                                  <div class="row post-row">
                                    <div class="span3 post-meta">
                                      <div>By {post.author}</>
                                      <div>{post.dateAdded}</>
                                      <div>Category: <a href="/category/{post.categoryId}">{postCategory}</></>
                                    </>
                                    <div class="span8 body-copy post-body">{Markdown.xhtml_of_string(Markdown.default_options, post.body)}</>
                                  </>
                                </>
                }, posts)
                void
    }}></>;
// <div class="span12 post-wrapper">
//                 <h2 class="post-title heading-text">{postDetails.title}</>
//                 <div class="row post-row">
//                   <div class="span3 post-meta">
//                     <div class=post-author>By: {postDetails.author}</>
//                     <div class=post-date>{postDetails.dateAdded}</>
//                     <div class=post-category>Post Category: <a href="/category/{postDetails.categoryId}">{postDetails.category}</></>
//                   </>
//                   <div class="span8 body-copy post-body">{Markdown.xhtml_of_string(Markdown.default_options, postDetails.body)}</>
//                 </>
//               </>
    // println(Debug.dump(posts))
    DefaultView.page_template("Post", content, <></>)
  }

  // markdown samples and explanation source: http://en.wikipedia.org/wiki/Markdown
  function create_post(allCategories) {

    content = <h2 class="post-title heading-text">Create New Post</h2>
              <form class=form-horizontal>
                <span class=help-block>Give the post a title</span>
                <input class=span6 id=#postTitle type=text placeholder="Post Title" />

                <span class=help-block>Post body goes here</span>
                <textarea id=#postBody rows="10" class=span6></textarea>
                <ul class=markdown-instructions>
                  <li>Headings: # First-level heading; #### Fourth-level heading</>
                  <li>Paragraphs: A paragraph is one or more consecutive lines of text separated by one or more blank lines.</>
                  <li>Lists:
                    <ul>
                      <li>* An item in a bulleted (unordered) list
                        <ul>
                          <li>* A subitem, indented with 4 spaces</>
                        </>
                      </>
                      <li>* Another item in a bulleted list</>
                      <li>1. An item in an enumerated (ordered) list</>
                      <li>    1.1. A subitem, indented with 4 spaces</>
                      <li>2. Another item in an enumerated list</>
                    </>
                  </>
                  <li>Emphasized text: *emphasis* or _emphasis_  (e.g., italics); **strong emphasis** or __strong emphasis__ (e.g., boldface); but prefer css classes</>
                  <li>Code: Some text with `some code` inside, or indent several lines of code by at least four spaces.</>
                  <li>Line breaks: End the line with two or more spaces, then type return: def show_results space space</>
                  <li>Blockquotes: > "This entire paragraph of text will be enclosed in an HTML blockquote element."</>
                  <li>External links: [link text here](link.address.here) (e.g., [Markdown](http://en.wikipedia.com/wiki/Markdown))</>
                  <li>Images: ![Alt text](/path/to/img.jpg)</>
                </>

                <span class=help-block>Use Existing Category</span>
                <select id=#postCategory onready={ function(_) { add_categories_options(allCategories) }}></>

                <span class=help-block>Add Category</span>
                <input id=#postCategoryNew type=text placeholder="Post Category" />

                <div>
                  <a id=#submitNewPost class=btn onclick={ Events.submit_post(_) }>Post</a>
                </div>
              </form>

    DefaultView.page_template("New Post", content, <></>)

  }

  function add_categories_options(allCategories) {
    List.map(function(category) {
       #postCategory =+ <option value="{category.categoryId}">{category.category}</>
    }, allCategories)

    void
  }

  function single_post(postDetails) {
    content = <div class="span12 post-wrapper">
                <h2 class="post-title heading-text">{postDetails.title}</>
                <div class="row post-row">
                  <div class="span3 post-meta">
                    <div class=post-author>By {postDetails.author}</>
                    <div class=post-date>{postDetails.dateAdded}</>
                    <div class=post-category>Post Category: <a href="/category/{postDetails.categoryId}">{postDetails.category}</></>
                  </>
                  <div class="span8 body-copy post-body">{Markdown.xhtml_of_string(Markdown.default_options, postDetails.body)}</>
                </>
              </>

    DefaultView.page_template({postDetails.title}, content, <></>)
  }

  /**
  * edit_post
  */
  function edit_post(post) {
    content = <div>This is the edit_post view. {post}</div>
    DefaultView.page_template("Edit Post", content, <></>)
  }

}

module CategoryView {
  function posts_by_category(relatedPosts) {
    content = <div>Hello</>
    // postData = DbSet.iterator(relatedPosts) |> Iter.to_list

    // List.map(function(postDetails) {


    // }, postData)
    DefaultView.page_template("Posts related to category", content, <></>)


    // println(Debug.dump(categoryId))
  }
}

module SignupView {
  private fld_username =
    Field.text_field({Field.new with
      label: "Username",
      required: {with_msg: <>Please enter a username.</>},
      hint: <>Your username will be displayed as the author of your posts</>
    })

  private fld_email =
    Field.email_field({Field.new with
      label: "Email",
      required: {with_msg: <>Please enter a valid email address.</>},
      hint: <>Your activation link will be sent to this address.</>
    })

  private fld_passwd =
    Field.passwd_field({Field.new with
      label: "Password",
      required: {with_msg: <>Please enter your password.</>},
      hint: <>Password should be at least 6 characters long and contain at least one digit.</>,
      validator: {passwd: Field.default_passwd_validator}
    })

  private fld_passwd2 =
    Field.passwd_field({Field.new with
      label: "Repeat password",
      required: {with_msg: <>Please repeat your password.</>},
      validator: {equals: fld_passwd, err_msg: <>Your passwords do not match.</>}
    })

  function signupForm() {
    form = Form.make(signup, {})
    fld = Field.render(form, _)
    form_body =
      <>
        {fld(fld_username)}
        {fld(fld_email)}
        {fld(fld_passwd)}
        {fld(fld_passwd2)}
        <a href="#" class="btn btn-primary btn-large" onclick={Form.submit_action(form)}>Sign up</>
        <div id=#notice></>
      </>
    content =
      Form.render(form, form_body)

    DefaultView.page_template("Sign up", content, <></>)
  }

  private client function signup(_) {
    email = Field.get_value(fld_email) ? error("Cannot read form email")
    username = Field.get_value(fld_username) ? error("Cannot read form name")
    passwd = Field.get_value(fld_passwd) ? error("Cannot read form passwd")
    newUser = ~{email, username, passwd}

    #notice = match (UserModel.register(newUser)) {
      case {success: _}:
        SiteView.alert("Congratulations! You are successfully registered. You will receive an email with account activation instructions shortly.", "success")
      case {failure: msg}:
        SiteView.alert("Your registration failed: {msg}", "error")
    }
  }

  function activate_user(activationCode) {
    notice =
      match (UserModel.activate_account(activationCode)) {
        case {success: _}:
          SiteView.alert("Your account is activated now.", "success") <+>
          <a href="/login">Go Login</>
        case {failure: _}:
          SiteView.alert("Activation code is invalid.", "error")

      }
    DefaultView.page_template("Account activation", <></>, notice)

  }
}

module LoginView {
  private fld_username = Field.text_field({Field.new with
    label: "Username",
    required: {with_msg: <>Please enter your username.</>} })
  private fld_passwd = Field.passwd_field({Field.new with
    label: "Password",
    required: {with_msg: <>Please enter your password.</>} })

  function loginForm(redirect) {
    form = Form.make(login(some(redirect), _), {})
    fld = Field.render(form, _)
    form_body =
      <>
        {fld(fld_username)}
        {fld(fld_passwd)}
        <div id=#signin_result />
        <a href="#" class="btn btn-primary btn-large" onclick={Form.submit_action(form)}>Sign in</>
      </>
      content = Form.render(form, form_body)
    DefaultView.page_template("Login", content, <></>)
  }

  private function login(redirect, _) {
    // #signin_result = <></> // to get rid of the msg box, so they see that this error is new
    username = Field.get_value(fld_username) ? error("Cannot get login")
    passwd = Field.get_value(fld_passwd) ? error("Cannot get passwd")
    match (UserModel.login(username, passwd)) {
      case {failure: msg}:
        #signin_result =
          <div class="alert alert-error">
            {msg}
          </div>
        // Dom.transition(#signin_result, Dom.Effect.sequence([
        //   Dom.Effect.with_duration({immediate}, Dom.Effect.hide()),
        //   Dom.Effect.with_duration({slow}, Dom.Effect.fade_in())
        // ])) |> ignore
      case {success: _}:
        match (redirect) {
          case {none}: Client.reload()
          case {some: url}: Client.goto(url)
        }
    }
  }
}

module AdminView {
  function dashboard() {
      content = <div>This is the dashboard view</div>
      DefaultView.page_template("Admin", content, <></>)
  }

  function options() {
      content = <div>This is the options view</div>
      DefaultView.page_template("Options", content, <></>)
  }

}