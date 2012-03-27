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
    _posts.remove();
    
    
  }
  
  void run() {
    
    CrimsonHttpServer server = new CrimsonHttpServer();
    CrimsonModule module = new CrimsonModule(server);
    module.handlers 
               .addEndpoint(new Favicon())
               .addFilter(new CookieSession())
               .addEndpoint(new Route("/post/all", "GET", getPosts))  //return all posts
               .addEndpoint(new Route("/post", "GET", getRecentPost))  //return the first post
               .addEndpoint(new Route("/post", "POST", addPost)) //add a post
               .addEndpoint(new StaticFile("./blog"));
    
    server.modules["*"] = module;  //this is the default module.
    
    server.listen("127.0.0.1", 8083);


  }
  
  
  Future getPosts(req,res,CrimsonData data) {
    print("getting posts");
    Completer completer = new Completer();
    
    List postList = new List();
    //for each post (which is a map) add it to the list
    
    Cursor cursor = _posts.find({});
    
    print("cursor is null=${cursor == null}");
    cursor.each((post) {
      postList.add(post); 
    }).then((dummy) {
      //when we've got them all, return them
      String postAsString = JSON.stringify(postList);
      print("postAsString:$postAsString");
      res.outputStream.writeString(postAsString);  
      completer.complete(data); 
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



