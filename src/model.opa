
// abstract type means it can only be manipulated with functions in the package in which the declaration occurs
abstract type User.name = string
abstract type User.status = {active} or {string activationCode}

abstract type User.info = {
	Email.email email,
	string username,
	string passwd,
	User.status status
}

// type User = {int userId, string username, string password}

// add userId or a post_userId collection
type Post = { int postId, string title, string body, int categoryId, int userId, string dateAdded }

type Comment = {int postId, string comment}
// type Post_comment = {int postCommentId, int postId, int commentId}

type Category = {int categoryId, string category}

database parlance {

	User.info /users[{username}]

	// posts
	int /keys/post_key
	Post /posts[{ postId }]

	// comments
	// int /keys/comment_key

	// many comments to one post
	// can add to list of comments with /movie/cast/stars <+ { name: "James Caan", birthyear: 1940 }
	Comment /comments[{ postId }]

	// categories
	// one category to many posts
	int /keys/category_key
	// changed primary key to category from categoryId; ?/parlance/categories[]
	Category /categories[{ categoryId }]

}

module PostModel {

	function set_new_post(newPost) {
		string dateAdded = Date.to_string(Date.now())

		/parlance/keys/post_key++
		postKey = /parlance/keys/post_key
		/parlance/posts[{ postId:postKey }] <- { title:newPost.title, body:newPost.body, categoryId:newPost.categoryId, userId:1, ~dateAdded }


		// TODO: add userId to entry

		void

	}

	// db set query
	// type declaration
		// type stored = {int x, int y, string v, list(string) lst}
	// db declaration
		// stored /set[{x}]
	// query
		// dbset(stored, _) x = /dbname/set[y == 10] // Returns a database set because y is not a primary key
	function get_post(requestedPostId) {
		// I don't really need to do this all separately. I could do postDetails = /parlance/posts[{ postId:requestedPostId }]
		// to do that, I'll need to change what the things in the view are called
		postDate = /parlance/posts[{ postId:requestedPostId }]/dateAdded
		postTitle = /parlance/posts[{ postId:requestedPostId }]/title
		postBody = /parlance/posts[{ postId:requestedPostId }]/body

		categoryId = /parlance/posts[{ postId:requestedPostId }]/categoryId
		postCategory = /parlance/categories[{ categoryId:categoryId }]/category

		// dbset(Comment, _) commentSet = /parlance/comments

		// ~commentSet == commentSet: commentSet
		postDetails = {title: postTitle, body: postBody, ~categoryId, category: postCategory, dateAdded: postDate} // ~commentSet,

		postDetails
	}

	/**
	  * Gets all posts associated with a category, tag, or author/user
	  *
	  * @param {string} byWhat - "category", "tag", "user"
	  * @param {int} whatId - the byWhat's id
	  *
	  * @return {dbSet} - a set of all the posts related to the byWhat
	  *
	  */
	  // this didn't work; error - This querying is invalid because 'byWhat' is not found inside the row
			// {body : string;
			//   categoryId : int;
			//   dateAdded : string;
			//   postId : int;
			//   title : string;
			//   userId : int}
	// function get_posts_by(byWhat, whatId) {
	// 	relatedPosts = /parlance/posts[ byWhat == whatId ]

	// 	relatedPosts
	// }

	function get_posts_by_category(requestedCategoryId) {
		relatedPosts = /parlance/posts[ categoryId == requestedCategoryId ]

		relatedPostsList = DbSet.iterator(relatedPosts) |> Iter.to_list



		relatedPostsList
	}
	// function get_associated(allPosts) {
	// 	println(Debug.dump(allPosts))
	// }

	function all_posts() {
		dbset(Post, _) justPosts = /parlance/posts
		allPostsList = DbSet.iterator(justPosts) |> Iter.to_list

		allPostsList
		// get associated user/author

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

		// allCategoriesSet
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
		user = {
			email: user.email,
			username: user.username,
			passwd: user.passwd,
			status: {~activationCode}
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
				<a href="http://{Data.main_host}{Data.main_port}/activation/{args.activationCode}">
              		this link
				</a>.
          	</p>
         content = {html: email}
         continuation = function(_) { void }
         SmtpClient.try_send_async(from, args.email, subject, content, Email.default_options, continuation)
	}
}

module Data {
	main_host = "localhost"
	main_port = ":8080"
}

