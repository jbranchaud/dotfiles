# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to make opened Markdown files always be soft wrapped:
#
path = require 'path'

# import other inits
jekyll = require './inits/jekyll.coffee'

atom.workspaceView.eachEditorView (editorView) ->
  editor = editorView.getEditor()
  if path.extname(editor.getPath()) is '.md'
    editor.setSoftWrap(false)

# demo command from http://jasonrudolph.com/blog/2014/03/02/defining-atom-commands-in-your-init-script/
atom.workspaceView.command 'dot-atom:demo', ->
  console.log "Hello from dot-atom:demo"

# log something more interesting
atom.workspaceView.command 'dot-atom:project-path', ->
  console.log atom.project.getPath()

# trying to open the console, sorta works
atom.workspaceView.command 'dot-atom:console', ->
  @trigger('console:open')