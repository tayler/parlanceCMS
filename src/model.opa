type User = {int userId, string username, string password}

type Post = { int postId, string title, string body, int categoryId, int userId, string dateAdded }

type Comment = {int postId, string comment}

type Category = {int categoryId, string category}

database parlance {

	User /user

	// posts
	int /keys/post_key
	Post /posts[{ postId }]
	
	// comments

	// many comments to one post
	Comment /comments[{ postId }] 

	// categories
	// one category to many posts
	int /keys/category_key
	Category /categories[{ categoryId }]
	
}

module PostModel {

	function set_new_post(newPost) {
		string dateAdded = Date.to_string(Date.now())

		/parlance/keys/post_key++
		postKey = /parlance/keys/post_key
		/parlance/posts[{ postId:postKey }] <- { title:newPost.title, body:newPost.body, categoryId:newPost.categoryId, userId:1, ~dateAdded }

		void

	}

	function get_post(requestedPostId) {
		postDate = /parlance/posts[{ postId:requestedPostId }]/dateAdded
		postTitle = /parlance/posts[{ postId:requestedPostId }]/title
		postBody = /parlance/posts[{ postId:requestedPostId }]/body

		categoryId = /parlance/posts[{ postId:requestedPostId }]/categoryId
		postCategory = /parlance/categories[{ categoryId:categoryId }]/category
		
		postDetails = {title: postTitle, body: postBody, ~categoryId, category: postCategory, dateAdded: postDate} // ~commentSet, 

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

