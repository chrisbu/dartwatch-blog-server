#library("dartwatch:blogserver");
#import("../crimson/core/crimson.dart");
#import("../crimson/handlers/handlers.dart");
#import("../mongo-dart/lib/mongo.dart");
#import("dart:json");
#import("dart:io");

class BlogServer {
  
  MCollection _posts;
  
  BlogServer() { 
    Db db = new Db("dart-blog-server");
    db.open();
    _posts = db.collection("posts");
    
    // uncomment the following line to remove all the posts at app startup
    _posts.remove();
    
    
  }
  
  void run() {
    
    CrimsonHttpServer server = new CrimsonHttpServer();
    CrimsonModule module = new CrimsonModule(server);
    module.handlers 
               .addEndpoint(new Favicon())
               .addFilter(new CookieSession())
               .addEndpoint(new Route("/post/all", "GET", getPosts))  //return all posts
               //.addEndpoint(new Route("/post", "GET", getRecentPost))  //return the first post
               .addEndpoint(new Route("/post", "POST", addPost)) //add a post
               .addEndpoint(new StaticFile("./client"));
    
    server.modules["*"] = module;  //this is the default module.
    
    server.listen("127.0.0.1", 8083);


  }
  
  
  Future getPosts(req,res,CrimsonData data) {
    Completer completer = new Completer();
    
    List postList = new List();
    
    Cursor cursor = _posts.find({});
    
    cursor.each((Map post) {
      //for each post (which is a map) add it to the list
      
      print("is the post a map?${post is Map}");
      
      //the mongo-dart ObjectId isn't supported by the JSON.stringify() 
      //so we'll just extract it, convert it to a string, and put it back again.
      var id = post["_id"];
      post.remove("_id");
      post["_id"] = id.toString();
      
      //finally, add the post to the list of posts.
      postList.add(post); 
      
    }).then((dummy) {
      //when we've got them all from the db, return them
      print(postList);
      try {
        String postAsString = JSON.stringify(postList);
        res.outputStream.writeString(postAsString);  
        completer.complete(data);
      }
      catch (var ex, var stack) {
        print(ex);
        print(stack);
        completer.completeException(ex);
      }
    });
    
    return completer.future;
  } 

  Future addPost(HttpRequest req,res,data) {
    print("adding post: ${req}");
    Completer completer = new Completer();
    
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(req.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String postdata = body.toString();
      print("postdata: ${postdata}");
      if (postdata != null) {
        
        Map blogPost = JSON.parse(postdata);
        print(blogPost);
        Map savedBlogPost = new Map<String,Object>();
        savedBlogPost["text"] = blogPost["text"];
        savedBlogPost["posted"] = blogPost["posted"];
        _posts.insert(savedBlogPost);  
        completer.complete(data);
      }
    };
    
    
    return completer.future;
  }

  Future getRecentPost(req,res,data) {
    
  }


}

void main() {
    new BlogServer().run();
}



