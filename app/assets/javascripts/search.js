var SearchResultsView = Backbone.View.extend({
    el: "#search_results",

    events: {
        "change select": "submit",
        "click a[data-toggle='more_facets']": "handleMoreFacetClick"
    },

    initialize: function () {
        var inputs = $(".facet-range input[type=slider]");
        for (var i = 0; i < inputs.length; i++) {
            var $input = $(inputs[i]);
            var range = $input.val().split(";");
            $input.slider({
                from: parseInt(range[0]),
                to: parseInt(range[1]),
                step: 1,
                skin: "round_plastic",
                callback: _.bind(this.submit, this)
            });
        }

        $.cookie.json = true;
        var openFacets = $.cookie("openFacets") || [];
        for (var i = 0; i < openFacets.length; i++) {
            var $link = $("a[data-facet='" + openFacets[i] + "']");
            this.toggleMoreFacet($link);
        }
    },

    submit: function () {
        this.$el.submit();
    },

    handleMoreFacetClick: function (event) {
        event.stopPropagation();
        event.preventDefault();

        var $link = $(event.currentTarget);
        this.toggleMoreFacet($link);
    },

    toggleMoreFacet: function ($link) {
        var $target = $("#" + $link.data("target"));

        var facet = $link.data("facet");
        var openFacets = $.cookie("openFacets") || [];

        $target.toggle();
        if ($link.text().indexOf("more") == -1) {
            $link.html("more &#9662;");

            openFacets = _.without(openFacets, facet);
        } else {
            $link.html("less &#9652;");

            openFacets.push(facet);
        }

        $.cookie("openFacets", _.uniq(openFacets), { path: "/" });
    }
});

new SearchResultsView();
