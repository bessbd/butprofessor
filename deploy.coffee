{exec} = require 'child_process'
async = require 'async'
temp = require("temp").track()


async.auto {
  getTmp:        (cb) -> temp.mkdir 'static', cb
  build:         ['getTmp', (cb, results) -> exec "coffee build.coffee #{results.getTmp}", (builderr, buildso, buildse) -> cb(null, {builderr, buildso, buildse})]
  getRemoteURL:  (cb) -> exec 'git config --get remote.origin.url', (err, so, se) -> cb null, so.trim().replace 'github.com', process.env.GIT_NAME + ':' + process.env.GH_TOKEN + '@github.com'
  checkoutPages: ['build', (cb) -> exec 'git checkout -B gh-pages', -> cb null]
  gitrm:         ['checkoutPages', (cb) -> exec 'git rm -rf .', -> cb null]
  gitclean:      ['checkoutPages', (cb) -> exec 'git clean -fxd', -> cb null]
  setGitUser:    (cb) -> exec 'git config user.name ' + process.env.GIT_NAME, -> cb(null)
  setGitEmail:   (cb) -> exec 'git config user.email "' + process.env.GIT_EMAIL + '"', -> cb(null)
  moveFiles:     ['gitrm', 'gitclean', 'build', (cb, results) -> exec "mv #{results['getTmp']}/* .", cb(null)]
  gitAddAll:     ['moveFiles', (cb) -> exec 'git add -A .', -> cb(null)]
  gitCommit:     ['gitAddAll', (cb) -> exec 'git commit --allow-empty -m "commit msg"', -> cb(null)]
  gitPush:       ['gitCommit', (cb, results) -> exec 'git push --force "' + results.getRemoteURL + '" gh-pages', (pusherr, pushso, pushse) -> cb(null, {pusherr, pushso, pushse})]
  }, (err, res) ->
    console.log JSON.stringify(res).replace(new RegExp(process.env.GH_TOKEN, 'g'), '****')
    console.log 'done'
