{% extends 'includes/layout.swig' %}   {#  模板继承 #}
{% block body %}
{% if (theme.swiftype_key) %}
  <div class="form-group has-success has-feedback" id="site_search">
    <form class="site-search-form">
        <input type="text" id="st-search-input" name="q" results="0" placeholder="{{ __('search') }}" class="st-search-input st-default-search-input form-control" />
    </form>
  </div>
{% else %}
  <div id="site_search">
   <div class="form-group">
    <input type="text" id="local-search-input" name="q" results="0" placeholder="{{ __('search') }}" class="st-search-input st-default-search-input form-control"/>
   </div>
   <div id="local-search-result"></div>
  </div>
{% endif %}
  <div id="archive-outer">
    <div id="archive-inter">
      {% set y = 0; %}
      {% for postItem in page.posts.toArray() %} 
        <div classets="archive-item">
            {% if postItem.date === undefined %} {# 防止日期为空 #}
            {% set postItem.date = date(Date.now(), 'YYYY/MM/DD') %}
            {% endif %}
            {% set year = postItem.date.year(); %} 
            {% if (y != year) %}  {#  判断年分隔算法 #}
              {% set y = year %}
              <div id="archive-year"> {{ y }}年 </div>
            {% endif %}
            {% if !postItem.link %}
            {# 文章链接 #}
            <a href="{{ url_for(postItem.path) }}">
              <time id="archive-item-time" datetime="{{ date_xml(postItem.date) }}">
                {{ date(postItem.date, "MM-DD") }}
              </time>
              {{ postItem.title || '没有标题' }} 
            </a>
          {% endif %}
        </div>
      {% endfor %}
    </div>
  </div>
    {%- if page.prev or page.next %}
    <nav class="pagination" id="page-nav">
      {{
        paginator({
          prev_text: '<i class="fa fa-angle-left" aria-label="' + __('accessibility.prev_page') + '"></i>',
          next_text: '<i class="fa fa-angle-right" aria-label="' + __('accessibility.next_page') + '"></i>',
          mid_size: 1,
          escape: false
        })
      }}
    </nav>
  {%- endif %}
 {% if (config.search) %}
  <script type="text/javascript">
    var searchFunc = function(path, search_id, content_id) {
      'use strict';
      $.ajax({
        url: path,
        dataType: "xml",
        success: function( xmlResponse ) {
          // get the contents from search data
          var datas = $( "entry", xmlResponse ).map(function() {
            return {
              title: $( "title", this ).text(),
              content: $("content",this).text(),
              url: $( "url" , this).text()
            };
          }).get();

          var $input = document.getElementById(search_id);
          if (!$input) return;
          var $resultContent = document.getElementById(content_id);
          if ($("#local-search-input").length > 0) {
            $input.addEventListener('input', function () {
              var str = '<ul class=\"search-result-list\">';
              var keywords = this.value.trim().toLowerCase().split(/[\s\-]+/);
              $resultContent.innerHTML = "";
              if (this.value.trim().length <= 0) {
                return;
              }
              // perform local searching
              datas.forEach(function (data) {
                var isMatch = true;
                var content_index = [];
                if (!data.title || data.title.trim() === '') {
                  data.title = "Untitled";
                }
                var data_title = data.title.trim().toLowerCase();
                var data_content = data.content.trim().replace(/<[^>]+>/g, "").toLowerCase();
                var data_url = data.url;
                var index_title = -1;
                var index_content = -1;
                var first_occur = -1;
                // only match artiles with not empty contents
                if (data_content !== '') {
                  keywords.forEach(function (keyword, i) {
                    index_title = data_title.indexOf(keyword);
                    index_content = data_content.indexOf(keyword);

                    if (index_title < 0 && index_content < 0) {
                      isMatch = false;
                    } else {
                      if (index_content < 0) {
                        index_content = 0;
                      }
                      if (i == 0) {
                        first_occur = index_content;
                      }
                      // content_index.push({index_content:index_content, keyword_len:keyword_len});
                    }
                  });
                } else {
                  isMatch = false;
                }
                // show search results
                if (isMatch) {
                  str += "<li><a href='" + data_url + "' class='search-result-title'>" + data_title + "</a>";
                  var content = data.content.trim().replace(/<[^>]+>/g, "");
                  if (first_occur >= 0) {
                    // cut out 100 characters
                    var start = first_occur - 20;
                    var end = first_occur + 80;

                    if (start < 0) {
                      start = 0;
                    }

                    if (start == 0) {
                      end = 100;
                    }

                    if (end > content.length) {
                      end = content.length;
                    }

                    var match_content = content.substring(start, end);

                    // highlight all keywords
                    keywords.forEach(function (keyword) {
                      var regS = new RegExp(keyword, "gi");
                      match_content = match_content.replace(regS, "<em class=\"search-keyword\">" + keyword + "</em>");
                    });

                    str += "<p class=\"search-result\">" + match_content + "...</p>"
                  }
                  str += "</li>";
                }
              });
              str += "</ul>";
              $resultContent.innerHTML = str;
            });
          }
        }
      });
    }
    let url = "{{ config.url }}/search.xml";
    searchFunc(url, 'local-search-input', 'local-search-result');
  </script>
 {% endif %}
{% endblock %}