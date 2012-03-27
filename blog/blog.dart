#import('dart:html');
#import("dart:json");

void main() {
  var input = new Element.tag("textarea");
  document.body.nodes.add(input);
  var button = new Element.tag("button");
  document.body.nodes.add(button);
  var postDiv = new Element.tag("div");
  document.body.nodes.add(postDiv);
  button.on.click.add((event) {
    XMLHttpRequest req = new XMLHttpRequest();
    req.open("POST", "http://localhost:8083/post");
    Map blogPost = new LinkedHashMap<String,String>();
    blogPost["text"] = input.value;
    blogPost["posted"] = new Date.now().toString();
    String jsonData = JSON.stringify(blogPost);
    addPostToUi(postDiv,blogPost);
    req.send(jsonData);
   
  });
  
  //load the posts
  XMLHttpRequest req = new XMLHttpRequest.getTEMPNAME("http://localhost:8083/post/all", (result) {
    print(result.responseText);
    List posts = JSON.parse(result.responseText);
    for (Map blogPost in posts) {
      addPostToUi(postDiv,blogPost);
    }
  });
  
  
}

void addPostToUi(postDiv, blogPost) {
  var postedDate = new Element.tag("div");
  postedDate.innerHTML = blogPost["posted"];
  var postText = new Element.tag("div");
  postText.nodes.add(postedDate);
  postText.nodes.add(new Element.html("<span>${blogPost['text']}</span>"));
  postDiv.nodes.add(postText);
}
