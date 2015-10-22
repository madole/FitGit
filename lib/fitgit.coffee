FitgitView = require './fitgit-view'
dataStore = require './data-store'

{CompositeDisposable} = require 'atom'
$ = require 'jquery'


module.exports = Fitgit =
  fitgitView: null
  subscriptions: null

  activate: (state) ->
    @fitgitView = new FitgitView(state.fitgitViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'fitgit:toggle': => @toggle()
    @setUpEventListeners()


  deactivate: ->
    @subscriptions.dispose()
    @fitgitView.destroy()

  serialize: ->
    fitgitViewState: @fitgitView.serialize()

  toggle: ->
      unless @rightPanel
          @rightPanel = atom.workspace.addRightPanel(item: @fitgitView.getElement(), visible: true)

      if @rightPanel.visible
          @rightPanel.hide()
      else
          @rightPanel.show()
          @fitgitView.showLettersChart()
          @fitgitView.showClickScatterGraph()


  setUpEventListeners: ->
      # Set up the start time
      $(window).trigger({type: dataStore.SET_START_TIME})

      # Set up workspace listener
      workspaceView = atom.views.getView(atom.workspace)
      $(workspaceView).on 'keydown', (e) =>
          if(e.which is 8 or e.which is 46)
              $(window).trigger({type: dataStore.INCREMENT_DELETES})
              @fitgitView.updateDeletes()
          else if(e.which >= 48 and e.which <= 111)
              $(window).trigger({type: dataStore.INCREMENT_CHARACTERS_TYPED, key: e.which})
          ##count keypresses
          $(window).trigger({type: dataStore.INCREMENT_KEY_PRESSES, key: e.which})
          @fitgitView.updateLettersChart()


      ### SET UP SAVES LISTENER ###
      atom.workspace.observeTextEditors (editor) =>
          editor.onDidSave =>
              $(window).trigger({type: dataStore.INCREMENT_SAVES})
              @fitgitView.updateSaves()

      ### SET UP CLICKS LISTENER ###
      $(workspaceView).on 'mouseup', (e) =>
          $(window).trigger
              type: dataStore.INCREMENT_MOUSE_CLICKS
              clickPos:
                  x: e.pageX
                  y: e.pageY
          @fitgitView.updateClickScatterGraph()
