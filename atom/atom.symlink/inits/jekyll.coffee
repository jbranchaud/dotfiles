# Atom utilties for my Jekyll workflow

# inject Jekyll frontmatter at the front of a given editor
injectJekyllFrontmatter = (editor) ->
  # assumes we are looking at an editor
  editor.moveCursorToTop()
  editor.insertText '---\nlayout: post\ntitle: \nsummary: \ntags:\n---\n\n'

# command to add jekyll frontmatter to a file
atom.workspaceView.command 'dot-atom:jekyll-fm', ->
  # assumes we are looking at an editor
  editor = atom.workspace.activePaneItem
  injectJekyllFrontmatter(editor)

# command to create new jekyll post with frontmatter
atom.workspaceView.command 'dot-atom:jekyll-new', ->
  atom.workspace.open().then (editor) ->
    # the open promise responds with a newly opened editor object
    injectJekyllFrontmatter(editor)