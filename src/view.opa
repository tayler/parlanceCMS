module DefaultView {

  function page_template(title, content) {
    title = title + " :: ParlanceCMS"
      html = 
      <div class="navbar navbar-top">
        <div class=navbar-inner>
          <div class=container>
            <a class="brand heading-text" href="/">parlanceCMS</>
            <ul class="main-menu pull-right">
              <li class=menu-item><a class=nav-link href="/post/create">New Post</></>
              <li class=menu-item><a class=nav-link href="/post/edit">Edit Post</></>
              <li class=menu-item><a class=nav-link href="/login">Login</></>
              <li class=menu-item><a class=nav-link href="/admin">Admin</></>
              <li class=menu-item><a class=nav-link href="/admin/options">Options</></>
            </>
          </div>
        </div>
      </div>
      <div id=#main class="container row content">
        {content}
      </div>
    Resource.page(title, html)
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
    tags = Dom.get_value(#postTags)



    categoryId = match(String.is_empty(newCategory)) {

      case {true} :
        println(Debug.dump("you used an existing category"))
        categoryId = String.to_int(categoryIdString)
        categoryId
      case {false} :
        println(Debug.dump("you created a new category"))

        // save new category and get id
        categoryId = CategoryModel.new_category(newCategory)
        categoryId
    }
    //   
    // }
    
    newPost = ~{title, body, categoryId, tags}

    // work on parser from dropbox as a database tutorial at blog.opalang.org


    PostModel.set_new_post(newPost)
  }
}

module SiteView {

}

module DomConstruction {
  // function build_tag_elements(tags) {
  //   List.map(
  //     function(tag) {<li id=#{tag.tagId} class=tag-list-member>{tag.tag}</li>},
  //     tags
  //   )

  // }  
}

module PostView {
  function post_list(posts) {
    content = <div id=#allPosts onready={function(_) {
                List.map(function(post) {
                  postCategory = /parlance/categories[{ categoryId:post.categoryId  }]/category
                  postTags = TagModel.get_post_tags(post.postId)
                  // println(Debug.dump(postTags))
                  #allPosts =+  <div class=post-wrapper>
                                  <h2 class="post-title heading-text"><a href="/post/{post.postId}">{post.title}</></>
                                  <p>{post.dateAdded}</>
                                  <div class="body-copy post-body">{Markdown.xhtml_of_string(Markdown.default_options, post.body)}</>
                                  <div>category: <a href="/category/{post.categoryId}">{postCategory}</></>
                                  <div id=#postTags>tags: </>
                                </>
                  List.map(function(tag) {
                    println(Debug.dump(tag))
                    // it's appending all the tags to the first instance of #postTags. I don't think I can use an id to identify this DOM element because it has to 
                    // append to each section.
                    #allPosts =+ <div>tag</>
                  }, postTags)
                }, posts)
                void
    }}></>;
    // println(Debug.dump(posts))
    DefaultView.page_template("Post", content)
  }

  // markdown samples and explanation source: http://en.wikipedia.org/wiki/Markdown
  function create_post(allCategories) {
    // println(Debug.dump(allCategories))

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
                
                <span class=help-block>Tags (separated by a comma)</span>
                <input id=#postTags type=text placeholder="tag1, tag2, tag3, etc." />

                <div>
                  <a id=#submitNewPost class=btn onclick={ Events.submit_post(_) }>Post</a>
                </div>
              </form>
         
    DefaultView.page_template("New Post", content)

  }

  function add_categories_options(allCategories) {
    List.map(function(category) {
       #postCategory =+ <option value="{category.categoryId}">{category.category}</>
    }, allCategories)

    void
  }
  // function show_tags(tag) {
  //   <a href="/tag/by_tag/{tag.tagId}>{tag.tag}</a>

  //   void
  // }

  function single_post(postDetails) {
// println(Debug.dump(postDetails.tagList))
// println(Debug.dump(postDetails))

    
    content = <div class="span12 post-wrapper">
                <h2 class="post-title heading-text">{postDetails.title}</>
                <div class="row post-row">
                  <div class="span6 post-image-and-meta">
                    <img src="/resources/img/posts/big-bay-bridge.jpg">
                    <div class=post-author>Author: </>
                    <div class=post-date>{postDetails.dateAdded}</>
                    <div class=post-category>Post Category: <a href="/category/{postDetails.categoryId}">{postDetails.category}</></>
                    
                  </>
                  <div class="span5 body-copy post-body">{Markdown.xhtml_of_string(Markdown.default_options, postDetails.body)}</>
                </>
              </>
      // see what this looks like


    // List.iter(show_tags, postDetails.tagList)
    // List.iter(function(tag) {
    //   content =+ <a href="/tag/by_tag/{tag.tagId}>{tag.tag}</a>
    // }, postDetails.tagList)

    DefaultView.page_template({postDetails.title}, content)
                    // <div>tags:<ul>{DomConstruction.build_tag_elements(postDetails.tagList)}</></>
  }

  /** 
  * edit_post 
  */
  function edit_post(post) {
    content = <div>This is the edit_post view. {post}</div>
    DefaultView.page_template("Edit Post", content)   
  }
  
}

module CategoryView {
  function posts_by_category(relatedPosts) {
    content = <div>Hello</>
    // postData = DbSet.iterator(relatedPosts) |> Iter.to_list

    // List.map(function(postDetails) {


    // }, postData)
    DefaultView.page_template("Posts related to category", content)


    // println(Debug.dump(categoryId))
  }
}

module LoginView {
    function login() {
      content = <div>This is the login view</div>
      DefaultView.page_template("Login", content)     
    }

}

module AdminView {
  function dashboard() {
      content = <div>This is the dashboard view</div>
      DefaultView.page_template("Admin", content)
  }

  function options() {
      content = <div>This is the options view</div>
      DefaultView.page_template("Options", content)
  }

}