#import('dart:html');
#import("dart:json");

void main() {
  buildUi();
  loadExistingPosts();
  
}

void loadExistingPosts() {
//load the posts
  XMLHttpRequest req = new XMLHttpRequest.getTEMPNAME("http://localhost:8083/post/all", (result) {
    List posts = JSON.parse(result.responseText);
    for (Map blogPost in posts) {
      //add each post back to the UI
      addPostToUi(blogPost);
    }
  });
  
}

void buildUi() {
  Element input = new Element.tag("textarea");
  input.id = "textbox";
  document.body.nodes.add(input);
  
  var button = new Element.tag("button");
  button.text="Add Post";
  button.id="add-post-button";
  button.on.click.add(_onAddPostClick);
  document.body.nodes.add(button);
  
  var postDiv = new Element.tag("div");
  postDiv.id = "list-of-posts";
  document.body.nodes.add(postDiv);
   
}

void _onAddPostClick(event) {
  var textbox = document.body.query("#textbox");
  Map blogPost = new Map<String,String>();
  blogPost["text"] = textbox.value;
  blogPost["posted"] = new Date.now().toString();
    
  addPostToServer(blogPost);
  addPostToUi(blogPost);
}

void addPostToUi(blogPost) {
  var postDiv = document.body.query("#list-of-posts");
  
  var postedDateElement = new Element.tag("div");
  postedDateElement.innerHTML = "Posted on ${blogPost['posted']}";
  var postText = new Element.tag("div");
  postText.nodes.add(postedDateElement);
  postText.nodes.add(new Element.html("<span>${blogPost['text']}</span>"));
  postText.nodes.add(new Element.html("<hr />"));
  postDiv.nodes.add(postText);
}

void addPostToServer(blogPost) {
  String jsonData = JSON.stringify(blogPost);
  XMLHttpRequest req = new XMLHttpRequest();
  req.open("POST", "http://localhost:8083/post");
  req.send(jsonData);
}