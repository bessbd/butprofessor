fs = require "fs"
path = require 'path'
glob = require 'glob'
async = require 'async'
rimraf = require 'rimraf'
marked = require 'marked'
fse = require 'fs-extra'
ck = require 'coffeekup'

cheerio = require 'cheerio'

{exec} = require 'child_process'

OUTDIR = 'dist'

indextpl = ->
  doctype 5
  html lang: "en", ->
    head ->
      meta charset: "utf-8"
      title "But Professor‽"
      link href: "bower_components/bootstrap/dist/css/bootstrap.min.css", rel: "stylesheet"
      link href: "static/blog.css", rel: "stylesheet"
      script """
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
        ga('create', 'UA-71639036-1', 'auto');
        ga('send', 'pageview');
      """
    body ->
      div ".container", ->
        div ".blog-header", ->
          h1 ".blog-title", ->
            a href: 'index.html', "But Professor‽"
          p ".lead.blog-description", "Some random deep thoughts from when “it’s compiling”"
        div ".row", ->
          div ".col-sm-8.blog-main", ->
            for post in @posts
              div ".blog-post", ->
                div post.compiled
                div ".addthis_sharing_toolbox", ''
                a href: post.fnew, '[permalink]'
                hr()
          div ".col-sm-3.col-sm-offset-1.blog-sidebar", ->
            div ".sidebar-module.sidebar-module-inset", ->
              h4 "About"
              p "A blog on programming as art, critical thinking and things like that"
      script type: "text/javascript", src: "//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-56828401947111a4", async: "async"
      script src: "bower_components/jquery/dist/jquery.min.js"
      script src: "bower_components/bootstrap/dist/js/bootstrap.min.js"

posttpl = ->
  doctype 5
  html lang: "en", ->
    head ->
      meta charset: "utf-8"
      title "But Professor‽"
      link href: "bower_components/bootstrap/dist/css/bootstrap.min.css", rel: "stylesheet"
      link href: "static/blog.css", rel: "stylesheet"
      script """
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
        ga('create', 'UA-71639036-1', 'auto');
        ga('send', 'pageview');
        """
    body ->
      div ".container", ->
        div ".blog-header", ->
          h1 ".blog-title", ->
            a href: 'index.html', "But Professor‽"
          p ".lead.blog-description", "Some random deep thoughts from when “it’s compiling”"
        div ".row", ->
          div ".col-sm-8.blog-main", ->
            div ".blog-post", ->
              div @post.compiled
              a href: @post.fnew, '[permalink]'
              div ".addthis_sharing_toolbox", ''
              hr()
              div "#disqus_thread", ''
              script """
                /**
                * RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
                * LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables
                */
                /*
                var disqus_config = function () {
                this.page.url = PAGE_URL; // Replace PAGE_URL with your page's canonical URL variable
                this.page.identifier = """ + @post.fnew + """; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
                };
                */
                (function() { // DON'T EDIT BELOW THIS LINE
                var d = document, s = d.createElement('script');
                s.src = 'https://butprofessor.disqus.com/embed.js';
                s.setAttribute('data-timestamp', +new Date());
                (d.head || d.body).appendChild(s);
                })();
                """
              noscript ->
                text "Please enable JavaScript to view the "
                a href: "https://disqus.com/?ref_noscript", rel: "nofollow", "comments powered by Disqus."
              script type: "text/javascript", ->
                """google_ad_client = "ca-pub-5489197102815138";
                google_ad_slot = "1331359202";
                google_ad_width = 728;
                google_ad_height = 90;"""
            script type: "text/javascript", src:"//pagead2.googlesyndication.com/pagead/show_ads.js"
            # nav ->
            #   ul ".pager", ->
            #     li ->
            #       a href: "#", "Previous"
            #     li ->
            #       a href: "#", "Next"
          div ".col-sm-3.col-sm-offset-1.blog-sidebar", ->
            div ".sidebar-module.sidebar-module-inset", ->
              h4 "About"
              p "A blog on programming as art, critical thinking and things like that"
      script type: "text/javascript", src: "//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-56828401947111a4", async: "async"
      script src: "bower_components/jquery/dist/jquery.min.js"
      script src: "bower_components/bootstrap/dist/js/bootstrap.min.js"


doBuild = (odir = OUTDIR, cb) ->
  async.auto {
    rmdir: (cb) ->
      rimraf odir, {disableGlob: false}, (err) -> cb null
    mkdir: ['rmdir', (cb) ->
      exec "mkdir #{odir}", (err, so, se) ->
        console.log {so, se}
        cb err
    ]
    bower: ['mkdir', (cb) ->
      exec 'bower install', (err, so, se) ->
        console.log {so, se}
        cb err
    ]
    bowermover: ['bower', (cb) ->
      fse.copy 'bower_components', path.join(odir, 'bower_components'), {clobber: true}, (err) -> cb err
    ]
    staticmover: ['mkdir', (cb) ->
      fse.copy 'static', path.join(odir, 'static'), {clobber: true}, (err) -> cb err
    ]
    glob: (cb) ->
      glob 'pages/*', cb
    convert: ['mkdir', 'glob', (cb, res) ->
      async.map res.glob.sort().reverse(), ((fn, cb) ->
        fs.readFile fn, (err, content) ->
          ch = cheerio.load marked(content.toString())
          fnew = path.parse(fn).name + '.html'
          ch('h2').first().replaceWith('<h2><a href="' + fnew + '">' + ch('h2').first().text() + '</a></h2>')

          ret = {compiled: ch.html(), fnew}
          fs.writeFile path.join(odir, fnew), ck.render(posttpl, {post: ret, format: true}), (err) ->
            cb err, ret
      ), (err, posts) ->
        rendered = ck.render indextpl, {posts, format: true}
        fs.writeFile path.join(odir, "index.html"), rendered, (error) ->
          cb error
    ]
  }, (err, results) ->
     console.log {err, results}

module.exports = {doBuild}

if require.main is module
  od = process.argv[2] || OUTDIR
  doBuild od, ->
    console.log "done"
