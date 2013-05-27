// abstract type means it can only be manipulated with functions in the package in which the declaration occurs
abstract type User.name = string
abstract type User.status = {active} or {string activationCode}

abstract type User.info = {
	Email.email email,
	string username,
	string passwd,
	User.status status
}
// so we don't have to pass all the User.info around each time
type User.t = { Email.email email, User.name username }
type User.logged = {guest} or {User.t user }
// guest is initial value for every user
private UserContext.t(User.logged) logged_user = UserContext.make({guest})

type Post = { int postId, string title, string body, int categoryId, string author, string dateAdded }

type Comment = { int postId, string comment }
// type Post_comment = {int postCommentId, int postId, int commentId}

type Category = { int categoryId, string category }

type Visit = { int visitId, string url, string title, int visitCount }

database opa_analytics {
	int /visit_key
	Visit  /visits[{url}]
}

database parlance {

	User.info /users[{username}]

	// posts
	int /keys/post_key
	Post /posts[{ postId }]

	// comments

	// many comments to one post
<<<<<<< HEAD
	Comment /comments[{ postId }]
=======
	// can add to list of comments with /movie/cast/stars <+ { name: "James Caan", birthyear: 1940 }
	Comment /comments[{ postId }]
>>>>>>> develop

	// categories
	// one category to many posts
	int /keys/category_key
	Category /categories[{ categoryId }]

}

module PostModel {

	exposed function outcome set_new_post(newPost) {
		string dateAdded = Date.to_string(Date.now())

		/parlance/keys/post_key++
		postKey = /parlance/keys/post_key
		/parlance/posts[{ postId:postKey }] <- { title:newPost.title, body:newPost.body, categoryId:newPost.categoryId, author:newPost.author, ~dateAdded }

<<<<<<< HEAD
		void
=======
		{success}

		// TODO: add userId to entry

>>>>>>> develop

	}

	function get_post(requestedPostId) {
		postDate = /parlance/posts[{ postId:requestedPostId }]/dateAdded
		postTitle = /parlance/posts[{ postId:requestedPostId }]/title
		postBody = /parlance/posts[{ postId:requestedPostId }]/body
		postAuthor = /parlance/posts[{ postId:requestedPostId}]/author

		categoryId = /parlance/posts[{ postId:requestedPostId }]/categoryId
		postCategory = /parlance/categories[{ categoryId:categoryId }]/category
<<<<<<< HEAD

		postDetails = {title: postTitle, body: postBody, ~categoryId, category: postCategory, dateAdded: postDate} // ~commentSet,
=======

		// dbset(Comment, _) commentSet = /parlance/comments

		// ~commentSet == commentSet: commentSet
		postDetails = {title: postTitle, body: postBody, author: postAuthor, ~categoryId, category: postCategory, dateAdded: postDate} // ~commentSet,
>>>>>>> develop

		postDetails
	}

	function get_posts_by_category(requestedCategoryId) {
		relatedPosts = /parlance/posts[ categoryId == requestedCategoryId ]

		relatedPostsList = DbSet.iterator(relatedPosts) |> Iter.to_list



		relatedPostsList
	}

	function all_posts() {
		dbset(Post, _) justPosts = /parlance/posts
		allPostsList = DbSet.iterator(justPosts) |> Iter.to_list

		allPostsList

	}

	/**
	  * Gets 5 most recent posts for Recent Posts section
	  *
	  *
	  *
	  *
	  *
	  *
	  */
	function recent_posts() {
		recentPosts = /parlance/posts[ limit 5 ]
		recentPostsList = DbSet.iterator(recentPosts) |> Iter.to_list

		recentPostsList
	}
}
module CategoryModel {
	function get_all_categories() {
		allCategoriesSet = /parlance/categories

		categoriesList = DbSet.iterator(allCategoriesSet) |> Iter.to_list

		categoriesList

	}

	function new_category(newCategory) {
		/parlance/keys/category_key++
		categoryKey= /parlance/keys/category_key

		/parlance/categories[{ categoryId:categoryKey }] <- { category:newCategory }

		categoryKey
	}

}

module UserModel {
	exposed function outcome register(user) {
		activationCode = Random.string(15)
		status =
		#<Ifstatic:NO_ACTIVATION_MAIL>
		{active}
		#<Else>
		{~activationCode}
		#<End>
		user = {
			email: user.email,
			username: user.username,
			passwd: user.passwd,
			~status
		}
		x = ?/parlance/users[{username: user.username}]
		match (x) {
			case {none}:
				/parlance/users[{username: user.username}] <- user
				send_registration_email({~activationCode, username:user.username, email: user.email})
				{success}
			case {some: _}:
				{failure: "A user with the given name already exists."}
		}
	}

	private function send_registration_email(args) {
		from = Email.of_string("no-reply@{Data.main_host}")
		subject = "New Parlance Registration"
		email =
			<p>Hello {args.username}!</p>
			<p>Thank you for registering with Parlance.</p>
			<p>Activate your account by clicking on
				<a href="http://{Data.main_host}/activation/{args.activationCode}">
              		this link
				</a>.
          	</p>
         content = {html: email}
         continuation = function(_) { void }
         SmtpClient.try_send_async(from, args.email, subject, content, Email.default_options, continuation)
	}

	exposed function outcome activate_account(activationCode) {
		user = /parlance/users[status == ~{activationCode}]
			|> DbSet.iterator
			|> Iter.to_list
			|> List.head_opt
		match (user) {
			case {none}: {failure}
			case {some: user}:
			/parlance/users[{username: user.username}] <- {user with status: {active}}
			{success}
		}
	}

	// get username and email out of User.info
	private function User.t mk_view(User.info info) {
		{username: info.username, email: info.email}
	}

	exposed function outcome(User.t, string) login(username, passwd) {
		x = ?/parlance/users[~{username}]
		match (x) {
			case {none}: {failure: "The username/password combination is invalid."}
			case {some: user}:
				match (user.status) {
					case {activationCode: _}:
					{failure: "You need to activate your account by clicking the link we sent you by email."}
					case {active}:
						if (user.passwd == passwd) {
							user_view = mk_view(user)
							UserContext.set(logged_user, {user: user_view})
							{success: user_view}
						} else {
							{failure: "The username/password combination is invalid."}
						}
					}
		}
	}

	function string get_name(User.t user) {
		user.username
	}

	function User.logged get_logged_user() {
		UserContext.get(logged_user)
	}

	function logout() {
		UserContext.set(logged_user, {guest})
	}
}

module AnalyticsModel {
	exposed function add_visit(url, title) {
		x = ?/opa_analytics/visits[~{url}]
		match(x) {
			case {none}:
				/opa_analytics/visit_key++
				visitId = /opa_analytics/visit_key
				visit = {~visitId, ~url, ~title, visitCount: 1}
				/opa_analytics/visits <- visit
			case {some: page}:
				/opa_analytics/visits[~{url}]/visitCount++
		}
	}
}

module Data {
	main_host = "parlancecms.com"
}



