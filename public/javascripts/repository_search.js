/*
  Live searching on repositories
*/
if (!Gitorious)
    var Gitorious = {};

$(document).ready(function () {
    var searchContainer = jQuery("#repo_search");
    var searchUri = searchContainer.attr("gts:searchUri");

    var backend = {get: function (uri, phrase, callback){
        jQuery.getJSON(uri + phrase, function(data) {
            callback(data);
        });
    }}
    /*
      Renderer for rendering repositories as search results
     */
    var renderer = {
        // Should return something that can be appended to a jQuery object
        render: function(repo) {
            row = jQuery('<li class="clone"></li>');

            repo_title = repo.description || repo.name

            title = jQuery('<div class="name"><a href="' + repo.uri + 
                           '" title="' + repo_title + '">' + repo.name + "</a></div>");
            title.appendTo(row);
            
            ownerType = repo.owner_type;
            description = jQuery('<div class="' + ownerType + '"></div>');

            ownerUri = repo.owner_uri;
            ownerTag = jQuery('<a href="' + ownerUri + '">' + repo.owner + '</a>');
            ownerTag.appendTo(description);

            
            if (image = repo.img) {
                imageTag = jQuery('<img src="' + image + '" width="16" height="16" />');
                imageTag.prependTo(description);
            }

            description.appendTo(row);
            return row;
        }
    }

    jQuery("#repo_search").liveSearch(backend, {
        resourceUri: searchUri, 
        itemClass: "clone",
        resultContainer: ".repository_list",
        waitingClass: "searching",
        renderer: renderer,
        onDisplay: function() {
            jQuery(".team_clones").hide();
            jQuery(".personal_clones").hide();
        },
        onReset: function (){
            jQuery(".team_clones").show();
            jQuery(".personal_clones").show();
        }});
}
)
