type User = {int userId, string username, string password}

// add userId or a post_userId collection
type Post = { int postId, string title, string body, int categoryId, int userId, string dateAdded }

type Comment = {int postId, string comment}
// type Post_comment = {int postCommentId, int postId, int commentId}

type Tag = {int tagId, string tag}
type Post_tag = {int postTagId, int postId, int tagId}

type Category = {int categoryId, string category}

database parlance {

	User /user

	// posts
	int /keys/post_key
	Post /posts[{ postId }]
	
	// comments
	// int /keys/comment_key

	// many comments to one post
	// can add to list of comments with /movie/cast/stars <+ { name: "James Caan", birthyear: 1940 }
	Comment /comments[{ postId }] 

	// int keys/post_comment_key
	// Post_comment /post_comment
	
	// tags
	int /keys/tag_key
	Tag /tags[{ tagId }]

	// post_tag is a many-to-many relationship, so I need an associative table
	int /keys/post_tag_key
	Post_tag /post_tag[{ postTagId }]

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

	    separatedTags = String.explode(",", newPost.tags)

		TagModel.save_tags(separatedTags, postKey)

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

		// gives just the tagId as an int (shouldn't it give me a set of tagIds - assuming there is more than one with that postId - It wouldn't let me make this a dbset type)
		// tagId = /parlance/post_tag[postId == requestedPostId]/tagId
		// tagIds = /parlance/post_tag[postId == requestedPostId]/tagId

		// tagList = get_tags(tagIds)

		// println(Debug.dump(tagIds))

		// gives the whole record at that postId like this: { size`: 3, tagId: 3, postTagId: 3, postId: 3, }
		// dbset(Post_tag, _) = tagId = /parlance/post_tag[postId == requestedPostId]
		
		// ~commentSet == commentSet: commentSet
		postDetails = {title: postTitle, body: postBody, ~categoryId, category: postCategory, dateAdded: postDate} // ~tagList, ~commentSet, 

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

	function get_posts_by_tag(requestedTagId) {
		postIds = /parlance/post_tag[ tagId == requestedTagId ]/postId
		postIdsList = DbSet.iterator(postIds) |> Iter.to_list
		relatedPosts = List.empty

		relatedPosts = List.map(function(requestedPostId) {
			post = /parlance/posts[ postId == requestedPostId]
			postList = [post | relatedPosts]
			postList
		}, postIdsList)

		println(Debug.dump(relatedPosts))

		relatedPosts
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

module TagModel {
	function save_tags(tags, postKey) {
		List.map(function(tag) {
			trimmedTag = String.trim(tag)
			// does the tag exist ya?
			// println(Debug.dump(trimmedTag))
			
			exists = /parlance/tags[ tag == tag ]
			existsList = DbSet.iterator(exists) |> Iter.to_list
			// println(Debug.dump(existsList))
			// println(Debug.dump(List.is_empty(existsList)))
			
			// if no save tag 
			tagKey = match (List.is_empty(existsList)) {
				case {true} :
					println(Debug.dump("you made a new tag"))
					/parlance/keys/tag_key++
					tagKey = /parlance/keys/tag_key
					/parlance/tags[{ tagId:tagKey }] <- { tagId:tagKey, tag:tag }

					tagKey

				case {false} :
					println(Debug.dump("you used an existing tag"))
					tagMax = List.max(existsList)
					// println(Debug.dump(tagMax))
					tagKey = tagMax.tagId
					// println(Debug.dump(tagKey))

					tagKey
			}
			
			// associate with postId
			/parlance/keys/post_tag_key++
			postTagKey = /parlance/keys/post_tag_key
			/parlance/post_tag[{ postTagId:postTagKey }] <- { postId:postKey, tagId:tagKey }
			
		}, tags)
	}

// 	function get_tags(tagIds) {
// 		tagIdList = DbSet.iterator(tagIds) |> Iter.to_list
// 		tagBuild = List.empty

// 		// maybe change this to tagIdList.iter or whatever; handle it the dbset way instead of converting to List
// 		allTagList = List.map(function(tagId) {
// 			// get the tags that have that tagId
// 			tagSet = /parlance/tags[{ tagId:tagId }]
// // println(Debug.dump(tagSet))
// 			finalTagList = [ tagSet | tagBuild ]
// 			finalTagList
// 		}, tagIdList)
// 		allTagList
// 	}

	// this is giving me a list that is too deep. I think I'd have to iterate through two levels to get at these tags
	// function get_post_tags(requestedPostId) {
	// 	println(Debug.dump(requestedPostId))
	// 	tagIds = /parlance/post_tag[ postId == requestedPostId ]/tagId
	// 	tagIdsList = DbSet.iterator(tagIds) |> Iter.to_list
	// 	tags = []

	// 	tags = List.map(function(requestedTagId) {
	// 		tag = /parlance/tags[ tagId == requestedTagId]
	// 		println(Debug.dump(tag))
	// 		tagList = [tag | tags]
	// 		println(Debug.dump(tagList))
	// 		tagList
	// 	}, tagIdsList)

	// 	tags
	// }
}

// I think type intmap records can only be accessed by the int or a range of ints. So can't search for categoryId by a postId that is in the same map
