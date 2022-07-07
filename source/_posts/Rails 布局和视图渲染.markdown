---
layout: post
title:  "[RubyOnRails]Rails 布局和视图渲染"
date:   2016-06-30-09 22:14:49 +0800
categories: RubyOnRails
---

什么都不渲染

或许 render 方法最简单的用法是什么也不渲染：

render nothing: true

渲染文本

调用 render 方法时指定 :plain 选项，可以把没有标记语言的纯文本发给浏览器：

render plain: "OK"

渲染普通的 JavaScript

Rails 能渲染普通的 JavaScript：

render js: "alert('Hello Rails');"

layout 选项

render 方法的大多数选项渲染得到的结果都会作为当前布局的一部分显示。后文会详细介绍布局。

:layout 选项告知 Rails，在当前动作中使用指定的文件作为布局：

render layout: "special_layout"

也可以告知 Rails 不使用布局：

render layout: false

 运行时选择布局

可以使用一个 Symbol，在处理请求时选择布局：

    class ProductsController < ApplicationController

        layout :products_layout

        def show
            @product = Product.find(params[:id])
        end

        private
        def products_layout
            @current_user.special? ? "special" : "products"
        end

    end

如果当前用户是特殊用户，会使用一个特殊布局渲染产品视图。

还可使用行间方法，例如 Proc，决定使用哪个布局。如果使用 Proc，其代码块可以访问 controller 实例，这样就能根据当前请求决定使用哪个布局：

    class ProductsController < ApplicationController
     layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
    end

2.2.14.3 条件布局

在控制器中指定布局时可以使用 :only 和 :except 选项。这两个选项的值可以是一个方法名或者一个方法名数组，这些方法都是控制器中的动作：

    class ProductsController < ApplicationController
     layout "product", except: [:index, :rss]
    end

这么声明后，除了 rss 和 index 动作之外，其他动作都使用 product 布局渲染视图。

2.2.14.4 布局继承

布局声明按层级顺序向下顺延，专用布局比通用布局优先级高。例如：

  ● application_controller.rb

    class ApplicationController < ActionController::Base
     layout "main"
    end

  ● posts_controller.rb

    class PostsController < ApplicationController
    end

  ● special_posts_controller.rb

    class SpecialPostsController < PostsController
     layout "special"
    end

  ● old_posts_controller.rb

    class OldPostsController < SpecialPostsController
        layout false

        def show
            @post = Post.find(params[:id])
        end

        def index
            @old_posts = Post.older
            render layout: "old"
        end
        # ...
    end

在这个程序中：

  ● 一般情况下，视图使用 main 布局渲染；

  ● PostsController#index 使用 main 布局；

  ● SpecialPostsController#index 使用 special 布局；

  ● OldPostsController#show 不用布局；

  ● OldPostsController#index 使用 old 布局；

2.2.15 避免双重渲染错误

大多数 Rails 开发者迟早都会看到一个错误消息：Can only render or redirect once per action（动作只能渲染或重定向一次）。这个提示很烦人，也很容易修正。出现这个错误的原因是，没有理解 render 的工作原理。

例如，下面的代码会导致这个错误：

    def show
     @book = Book.find(params[:id])
     if @book.special?
        render action: "special_show"
     end
     render action: "regular_show"
    end

如果 @book.special? 的结果是 true，Rails 开始渲染，把 @book 变量导入 special_show 视图中。但是，show 动作并不会就此停止运行，当 Rails 运行到动作的末尾时，会渲染regular_show 视图，导致错误出现。解决的办法很简单，确保在一次代码运行路线中只调用一次 render 或 redirect_to 方法。有一个语句可以提供帮助，那就是 and return。下面的代码对上述代码做了修改：

    def show
        @book = Book.find(params[:id])
        if @book.special?
            render action: "special_show" and return
        end
        render action: "regular_show"
    end

千万别用 && return 代替 and return，因为 Ruby 语言操作符优先级的关系，&& return 根本不起作用。

注意，ActionController 能检测到是否显式调用了 render 方法，所以下面这段代码不会出错：

    def show
     @book = Book.find(params[:id])
     if @book.special?
     render action: "special_show"
     end
    end

如果 @book.special? 的结果是 true，会渲染 special_show 视图，否则就渲染默认的 show 模板。

2.3 使用 redirect_to 方法

响应 HTTP 请求的另一种方法是使用 redirect_to。如前所述，render 告诉 Rails 构建响应时使用哪个视图（以及其他静态资源）。redirect_to 做的事情则完全不同：告诉浏览器向另一个地址发起新请求。例如，在程序中的任何地方使用下面的代码都可以重定向到 photos 控制器的 index 动作：

redirect_to photos_url

redirect_to 方法的参数与 link_to 和 url_for 一样。有个特殊的重定向，返回到前一个页面：

redirect_to :back

2.3.1 设置不同的重定向状态码

调用 redirect_to 方法时，Rails 会把 HTTP 状态码设为 302，即临时重定向。如果想使用其他的状态码，例如 301（永久重定向），可以设置 :status 选项：

redirect_to photos_path, status: 301

和 render 方法的 :status 选项一样，redirect_to 方法的 :status 选项同样可使用数字状态码或符号。

2.3.2 render 和 redirect_to 的区别

有些经验不足的开发者会认为 redirect_to 方法是一种 goto 命令，把代码从一处转到别处。这么理解是不对的。执行到 redirect_to 方法时，代码会停止运行，等待浏览器发起新请求。你需要告诉浏览器下一个请求是什么，并返回 302 状态码。

下面通过实例说明。

    def index
     @books = Book.all
    end

    def show
     @book = Book.find_by(id: params[:id])
     if @book.nil?
     render action: "index"
     end
    end

在这段代码中，如果 @book 变量的值为 nil 很可能会出问题。记住，render :action 不会执行目标动作中的任何代码，因此不会创建 index 视图所需的 @books 变量。修正方法之一是不渲染，使用重定向：

    def index
     @books = Book.all
    end

    def show
     @book = Book.find_by(id: params[:id])
     if @book.nil?
     redirect_to action: :index
     end
    end

这样修改之后，浏览器会向 index 动作发起新请求，执行 index 方法中的代码，一切都能正常运行。

这种方法有个缺点，增加了浏览器的工作量。浏览器通过 /books/1 向 show 动作发起请求，控制器做了查询，但没有找到对应的图书，所以返回 302 重定向响应，告诉浏览器访问/books/。浏览器收到指令后，向控制器的 index 动作发起新请求，控制器从数据库中取出所有图书，渲染 index 模板，将其返回浏览器，在屏幕上显示所有图书。

在小型程序中，额外增加的时间不是个问题。如果响应时间很重要，这个问题就值得关注了。下面举个虚拟的例子演示如何解决这个问题：

    def index
     @books = Book.all
    end

    def show
        @book = Book.find_by(id: params[:id])
        if @book.nil?
            @books = Book.all
            flash.now[:alert] = "Your book was not found"
            render "index"
        end
    end

在这段代码中，如果指定 ID 的图书不存在，会从模型中取出所有图书，赋值给 @books 实例变量，然后直接渲染 index.html.erb 模板，并显示一个 Flash 消息，告知用户出了什么问题。

2.4 使用 head 构建只返回报头的响应

head 方法可以只把报头发送给浏览器。还可使用意图更明确的 render :nothing 达到同样的目的。head 方法的参数是 HTTP 状态码的符号形式（参见前文表格），选项是一个 Hash，指定报头名和对应的值。例如，可以只返回报错的报头：

head :bad_request

生成的报头如下：

    HTTP/1.1 400 Bad Request
    Connection: close
    Date: Sun, 24 Jan 2010 12:15:53 GMT
    Transfer-Encoding: chunked
    Content-Type: text/html; charset=utf-8
    X-Runtime: 0.013483
    Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
    Cache-Control: no-cache

或者使用其他 HTTP 报头提供其他信息：

head :created, location: photo_path(@photo)

生成的报头如下：

    HTTP/1.1 201 Created
    Connection: close
    Date: Sun, 24 Jan 2010 12:16:44 GMT
    Transfer-Encoding: chunked
    Location: /photos/1
    Content-Type: text/html; charset=utf-8
    X-Runtime: 0.083496
    Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
    Cache-Control: no-cache

3 布局结构

Rails 渲染响应的视图时，会把视图和当前模板结合起来。查找当前模板的方法前文已经介绍过。在布局中可以使用三种工具把各部分合在一起组成完整的响应：

  ● 静态资源标签

  ● yield 和 content_for

  ● 局部视图

3.1 静态资源标签帮助方法

静态资源帮助方法用来生成链接到 Feed、JavaScript、样式表、图片、视频和音频的 HTML 代码。Rails 提供了六个静态资源标签帮助方法：

  ● auto_discovery_link_tag

  ● javascript_include_tag

  ● stylesheet_link_tag

  ● image_tag

  ● video_tag

  ● audio_tag

这六个帮助方法可以在布局或视图中使用，不过 auto_discovery_link_tag、javascript_include_tag 和 stylesheet_link_tag 最常出现在布局的 <head> 中。

静态资源标签帮助方法不会检查指定位置是否存在静态资源，假定你知道自己在做什么，只负责生成对应的链接。

3.1.1 使用 auto_discovery_link_tag 链接到 Feed

auto_discovery_link_tag 帮助方法生成的 HTML，大多数浏览器和 Feed 阅读器都能用来自动识别 RSS 或 Atom Feed。auto_discovery_link_tag 接受的参数包括链接的类型（:rss 或 :atom），传递给 url_for 的 Hash 选项，以及该标签使用的 Hash 选项：

    <%= auto_discovery_link_tag(:rss, {action: "feed"},
     {title: "RSS Feed"}) %>

auto_discovery_link_tag 的标签选项有三个：

  ● :rel：指定链接 rel 属性的值，默认值为 "alternate"；

  ● :type：指定 MIME 类型，不过 Rails 会自动生成正确的 MIME 类型；

  ● :title：指定链接的标题，默认值是 :type 参数值的全大写形式，例如 "ATOM" 或 "RSS"；

3.1.2 使用 javascript_include_tag 链接 JavaScript 文件

javascript_include_tag 帮助方法为指定的每个资源生成 HTML script 标签。

如果启用了 Asset Pipeline，这个帮助方法生成的链接指向 /assets/javascripts/ 而不是 Rails 旧版中使用的 public/javascripts。链接的地址由 Asset Pipeline 伺服。

Rails 程序或引擎中的 JavaScript 文件可存放在三个位置：app/assets，lib/assets 或 vendor/assets。详细说明参见 Asset Pipeline 中的“静态资源的组织方式”一节。

文件的地址可使用相对文档根目录的完整路径，或者是 URL。例如，如果想链接到 app/assets、lib/assets 或 vendor/assets 文件夹中名为 javascripts 的子文件夹中的文件，可以这么做：

    <%= javascript_include_tag "main" %>

Rails 生成的 script 标签如下：
    <script src='/assets/main.js'></script>

对这个静态资源的请求由 Sprockets gem 伺服。

同时引入 app/assets/javascripts/main.js 和 app/assets/javascripts/columns.js 可以这么做：

    <%= javascript_include_tag "main", "columns" %>

引入 app/assets/javascripts/main.js 和 app/assets/javascripts/photos/columns.js：

    <%= javascript_include_tag "main", "/photos/columns" %>

引入 http://example.com/main.js：

    <%= javascript_include_tag "http://example.com/main.js" %>

3.1.3 使用 stylesheet_link_tag 链接 CSS 文件

stylesheet_link_tag 帮助方法为指定的每个资源生成 HTML <link> 标签。

如果启用了 Asset Pipeline，这个帮助方法生成的链接指向 /assets/stylesheets/，由 Sprockets gem 伺服。样式表文件可以存放在三个位置：app/assets，lib/assets 或vendor/assets。

文件的地址可使用相对文档根目录的完整路径，或者是 URL。例如，如果想链接到 app/assets、lib/assets 或 vendor/assets 文件夹中名为 stylesheets 的子文件夹中的文件，可以这么做：

    <%= stylesheet_link_tag "main" %>

引入 app/assets/stylesheets/main.css 和 app/assets/stylesheets/columns.css：

    <%= stylesheet_link_tag "main", "columns" %>

引入 app/assets/stylesheets/main.css 和 app/assets/stylesheets/photos/columns.css：

    <%= stylesheet_link_tag "main", "photos/columns" %>

引入 http://example.com/main.css：

    <%= stylesheet_link_tag "http://example.com/main.css" %>

默认情况下，stylesheet_link_tag 创建的链接属性为 media="screen" rel="stylesheet"。指定相应的选项（:media，:rel）可以重写默认值：

    <%= stylesheet_link_tag "main_print", media: "print" %>

3.1.4 使用 image_tag 链接图片

image_tag 帮助方法为指定的文件生成 HTML <img /> 标签。默认情况下，文件存放在 public/images 文件夹中。

注意，必须指定图片的扩展名。

    <%= image_tag "header.png" %>

可以指定图片的路径：

    <%= image_tag "icons/delete.gif" %>

可以使用 Hash 指定额外的 HTML 属性：

    <%= image_tag "icons/delete.gif", {height: 45} %>

可以指定一个替代文本，在关闭图片的浏览器中显示。如果没指定替代文本，Rails 会使用图片的文件名，去掉扩展名，并把首字母变成大写。例如，下面两个标签会生成相同的代码：

    <%= image_tag "home.gif" %>

    <%= image_tag "home.gif", alt: "Home" %>

还可指定图片的大小，格式为“{width}x{height}”：

    <%= image_tag "home.gif", size: "50x20" %>

除了上述特殊的选项外，还可在最后一个参数中指定标准的 HTML 属性，例如 :class、:id 或 :name：

    <%= image_tag "home.gif", alt: "Go Home",
     id: "HomeImage",
     class: "nav_bar" %>

3.1.5 使用 video_tag 链接视频

video_tag 帮助方法为指定的文件生成 HTML5 <video> 标签。默认情况下，视频文件存放在 public/videos 文件夹中。

    <%= video_tag "movie.ogg" %>

生成的代码如下：

    <video src="/videos/movie.ogg" />

和 image_tag 类似，视频的地址可以使用绝对路径，或者相对 public/videos 文件夹的路径。而且也可以指定 size: "#{width}x#{height}" 选项。video_tag 还可指定其他 HTML 属性，例如 id、class 等。

video_tag 方法还可使用 HTML Hash 选项指定所有 <video> 标签的属性，包括：

  ● poster: "image_name.png"：指定视频播放前在视频的位置显示的图片；

  ● autoplay: true：页面加载后开始播放视频；

  ● loop: true：视频播完后再次播放；

  ● controls: true：为用户提供浏览器对视频的控制支持，用于和视频交互；

  ● autobuffer: true：页面加载时预先加载视频文件；

把数组传递给 video_tag 方法可以指定多个视频：

<%= video_tag ["trailer.ogg", "movie.ogg"] %>

生成的代码如下：

    <video><source src="trailer.ogg" /><source src="movie.ogg" /></video>

3.1.6 使用 audio_tag 链接音频

audio_tag 帮助方法为指定的文件生成 HTML5 <audio> 标签。默认情况下，音频文件存放在 public/audio 文件夹中。

    <%= audio_tag "music.mp3" %>

还可指定音频文件的路径：

    <%= audio_tag "music/first_song.mp3" %>

还可使用 Hash 指定其他属性，例如 :id、:class 等。

和 video_tag 类似，audio_tag 也有特殊的选项：

  ● autoplay: true：页面加载后开始播放音频；

  ● controls: true：为用户提供浏览器对音频的控制支持，用于和音频交互；

  ● autobuffer: true：页面加载时预先加载音频文件；

3.2 理解 yield

在布局中，yield 标明一个区域，渲染的视图会插入这里。最简单的情况是只有一个 yield，此时渲染的整个视图都会插入这个区域：

    <html>

     <head>

     </head>

     <body>

     <%= yield %>

     </body>

    </html>

    布局中可以标明多个区域：

    <html>

     <head>

     <%= yield :head %>

     </head>

     <body>

     <%= yield %>

     </body>

    </html>

视图的主体会插入未命名的 yield 区域。要想在具名 yield 区域插入内容，得使用 content_for 方法。

3.3 使用 content_for 方法

content_for 方法在布局的具名 yield 区域插入内容。例如，下面的视图会在前一节的布局中插入内容：

    <% content_for :head do %>

     <title>A simple page</title>

    <% end %>



    <p>Hello, Rails!</p>

套入布局后生成的 HTML 如下：

    <html>

     <head>

     <title>A simple page</title>

     </head>

     <body>

     <p>Hello, Rails!</p>

     </body>

    </html>

如果布局不同的区域需要不同的内容，例如侧边栏和底部，就可以使用 content_for 方法。content_for 方法还可用来在通用布局中引入特定页面使用的 JavaScript 文件或 CSS 文件。

3.4 使用局部视图

局部视图可以把渲染过程分为多个管理方便的片段，把响应的某个特殊部分移入单独的文件。

3.4.1 具名局部视图

在视图中渲染局部视图可以使用 render 方法：

    <%= render "menu" %>

渲染这个视图时，会渲染名为 _menu.html.erb 的文件。注意文件名开头的下划线：局部视图的文件名开头有个下划线，用于和普通视图区分开，不过引用时无需加入下划线。即便从其他文件夹中引入局部视图，规则也是一样：

    <%= render "shared/menu" %>

这行代码会引入 app/views/shared/_menu.html.erb 这个局部视图。



3.4.2 使用局部视图简化视图

局部视图的一种用法是作为“子程序”（subroutine），把细节提取出来，以便更好地理解整个视图的作用。例如，有如下的视图：

    <%= render "shared/ad_banner" %>



    <h1>Products</h1>



    <p>Here are a few of our fine products:</p>

    ...

    <%= render "shared/footer" %>

这里，局部视图 _ad_banner.html.erb 和 _footer.html.erb 可以包含程序多个页面共用的内容。在编写某个页面的视图时，无需关心这些局部视图中的详细内容。

程序所有页面共用的内容，可以直接在布局中使用局部视图渲染。

3.4.3 局部布局

和视图可以使用布局一样，局部视图也可使用自己的布局文件。例如，可以这样调用局部视图：

    <%= render partial: "link_area", layout: "graybar" %>

这行代码会使用 _graybar.html.erb 布局渲染局部视图 _link_area.html.erb。注意，局部布局的名字也以下划线开头，和局部视图保存在同个文件夹中（不在 layouts 文件夹中）。


还要注意，指定其他选项时，例如 :layout，必须明确地使用 :partial 选项。

3.4.4 传递本地变量

本地变量可以传入局部视图，这么做可以把局部视图变得更强大、更灵活。例如，可以使用这种方法去除新建和编辑页面的重复代码，但仍然保有不同的内容：

    <h1>New zone</h1>

    <%= render partial: "form", locals: {zone: @zone} %>

    <h1>Editing zone</h1>

    <%= render partial: "form", locals: {zone: @zone} %>

    <%= form_for(zone) do |f| %>

     <p>

     <b>Zone name</b><br>
     <%= f.text_field :name %>
     </p>
     <p>
     <%= f.submit %>
     </p>
    <% end %>

虽然两个视图使用同一个局部视图，但 Action View 的 submit 帮助方法为 new 动作生成的提交按钮名为“Create Zone”，为 edit 动作生成的提交按钮名为“Update Zone”。

每个局部视图中都有个和局部视图同名的本地变量（去掉前面的下划线）。通过 object 选项可以把对象传给这个变量：

    <%= render partial: "customer", object: @new_customer %>

在 customer 局部视图中，变量 customer 的值为父级视图中的 @new_customer。

如果要在局部视图中渲染模型实例，可以使用简写句法：

    <%= render @customer %>

假设实例变量 @customer 的值为 Customer 模型的实例，上述代码会渲染 _customer.html.erb，其中本地变量 customer 的值为父级视图中 @customer 实例变量的值。

3.4.5 渲染集合
渲染集合时使用局部视图特别方便。通过 :collection 选项把集合传给局部视图时，会把集合中每个元素套入局部视图渲染：

    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    <p>Product Name: <%= product.name %></p>

传入复数形式的集合时，在局部视图中可以使用和局部视图同名的变量引用集合中的成员。在上面的代码中，局部视图是 _product，在其中可以使用 product 引用渲染的实例。
渲染集合还有个简写形式。假设 @products 是 product 实例集合，在 index.html.erb 中可以直接写成下面的形式，得到的结果是一样的：

    <h1>Products</h1>
    <%= render @products %>

Rails 根据集合中各元素的模型名决定使用哪个局部视图。其实，集合中的元素可以来自不同的模型，Rails 会选择正确的局部视图进行渲染。
    <h1>Contacts</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    <p>Customer: <%= customer.name %></p>
    <p>Employee: <%= employee.name %></p>

在上面几段代码中，Rails 会根据集合中各成员所属的模型选择正确的局部视图。

如果集合为空，render 方法会返回 nil，所以最好提供替代文本。
    <h1>Products</h1>
    <%= render(@products) || "There are no products available." %>

3.4.6 本地变量

要在局部视图中自定义本地变量的名字，调用局部视图时可通过 :as 选项指定：

    <%= render partial: "product", collection: @products, as: :item %>

这样修改之后，在局部视图中可以使用本地变量 item 访问 @products 集合中的实例。

使用 locals: {} 选项可以把任意本地变量传入局部视图：

    <%= render partial: "product", collection: @products,
     as: :item, locals: {title: "Products Page"} %>

在局部视图中可以使用本地变量 title，其值为 "Products Page"。

在局部视图中还可使用计数器变量，变量名是在集合后加上 _counter。例如，渲染 @products 时，在局部视图中可以使用 product_counter 表示局部视图渲染了多少次。不过不能和as: :value 一起使用。

在使用主局部视图渲染两个实例中间还可使用 :spacer_template 选项指定第二个局部视图。

3.4.7 间隔模板

    <%= render partial: @products, spacer_template: "product_ruler" %>

Rails 会在两次渲染 _product 局部视图之间渲染 _product_ruler 局部视图（不传入任何数据）。

3.4.8 集合局部视图的布局

渲染集合时也可使用 :layout 选项。

    <%= render partial: "product", collection: @products, layout: "special_layout" %>

使用局部视图渲染集合中的各元素时会套用指定的模板。和局部视图一样，当前渲染的对象以及 object_counter 变量也可在布局中使用。

3.5 使用嵌套布局
在程序中有时需要使用不同于常规布局的布局渲染特定的控制器。此时无需复制主视图进行编辑，可以使用嵌套布局（有时也叫子模板）。下面举个例子。
假设 ApplicationController 布局如下：

    <html>
    <head>
     <title><%= @page_title or "Page Title" %></title>
     <%= stylesheet_link_tag "layout" %>
     <style><%= yield :stylesheets %></style>
    </head>
    <body>
     <div id="top_menu">Top menu items here</div>
     <div id="menu">Menu items here</div>
     <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>

在 NewsController 的页面中，想隐藏顶部目录，在右侧添加一个目录：

    <% content_for :stylesheets do %>
    #top_menu {display: none}
    #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
    <div id="right_menu">Right menu items here</div>
    <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
