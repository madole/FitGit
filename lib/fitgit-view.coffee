require './thirdparty/d3'
heatmap = require './thirdparty/heatmap'
c3 = require './thirdparty/c3'
dataStore = require './data-store'
$ = require 'jquery'


createDiv = -> document.createElement('div')

class FitgitView
    POMODORO_MAX_DURATION: 1
    POMODORO_INTERVAL: 1000
    HEATMAP_VALUE: 3

    constructor: (serializedState) ->
        # Create Heatmap Element and put it on body

        @heatmapContainerWrapper = createDiv()
        @heatmapContainerWrapper.classList.add('heatmap__wrapper')
        body = document.body.insertBefore(@heatmapContainerWrapper, document.body.firstChild)

        @heatmapContainer = createDiv()
        @heatmapContainer.id = 'heatmap__container'
        @heatmapContainer.classList.add('heatmap__container')
        @heatmapContainerWrapper.appendChild(@heatmapContainer)


        # Create root element
        @element = document.createElement('div')
        @element.classList.add('fitgit')

        @img = createDiv()
        @img.classList.add('img__container', 'container')
        @img.innerHTML = '<img src="http://i.imgur.com/FTmXGNR.png?2"/>'
        @element.appendChild(@img)

        # Create Duration - You've been working for 25 minutes
        @durationContainer = createDiv()
        @durationContainer.classList.add('duration__container', 'container')
        @element.appendChild(@durationContainer)

        @duration = createDiv()
        @duration.classList.add('duration', 'fitgit-text')
        @duration.textContent = 'You\'ve just started working'
        @durationContainer.appendChild(@duration)

        @updateTimeInterval = setInterval =>
            duration = dataStore.getDuration()
            @duration.textContent = "You\'ve been working for #{duration}"
        , 10000

        # Create letters/keypresses chart
        @lettersChartContainer = createDiv()
        @lettersChartContainer.classList.add('letters-chart__container', 'container')
        @element.appendChild(@lettersChartContainer)

        @lettersLabel = createDiv()
        @lettersLabel.classList.add('letters-chart__label', 'fitgit-text')
        @lettersLabel.textContent = 'No characters Typed Today'
        @lettersChartContainer.appendChild(@lettersLabel)

        @lettersChart = createDiv()
        @lettersChart.id = 'letters-chart'
        @lettersChart.textContent = 'AHHHHHH'
        @lettersChart.classList.add('letters-chart')
        @lettersChartContainer.appendChild(@lettersChart)

        @lettersCountData = ['Characters Typed', 0]
        @keypressesCountData = ['Key Presses', 0]

        # Create deletes count chart
        @deletesCountContainer = createDiv()
        @deletesCountContainer.classList.add('deletes-count__container', 'container')
        @element.appendChild(@deletesCountContainer)

        @deletesCount = createDiv()
        @deletesCount.classList.add('deletes-count', 'fitgit-text')
        @deletesCount.textContent = 'No deletes today'
        @deletesCountContainer.appendChild(@deletesCount)

        # Create saves count chart
        @savesCountContainer = createDiv()
        @savesCountContainer.classList.add('saves-count__container', 'container')
        @element.appendChild(@savesCountContainer)

        @savesCount = createDiv()
        @savesCount.classList.add('saves-count', 'fitgit-text')
        @savesCount.textContent = 'No saves so far today'
        @savesCountContainer.appendChild(@savesCount)

        # Create Sactter graph
        @clickScatterGraphContainer = createDiv()
        @clickScatterGraphContainer.classList.add('click-scatter-graph__container', 'container')
        @element.appendChild(@clickScatterGraphContainer)

        @clickScatterGraphLabel = createDiv()
        @clickScatterGraphLabel.classList.add('click-scatter-graph__label', 'fitgit-text')
        @clickScatterGraphLabel.textContent = 'No clicks so far'
        @clickScatterGraphContainer.appendChild(@clickScatterGraphLabel)


        @clickScatterGraph = createDiv()
        @clickScatterGraph.id = 'click-scatter-graph'
        @clickScatterGraph.classList.add('click-scatter-graph')
        @clickScatterGraphContainer.appendChild(@clickScatterGraph)

        @scatterGraphData1 = ['clicks_x']
        @scatterGraphData2 = ['clicks']

        # Set up pomodoro gague
        @pomodoroContainer = createDiv()
        @pomodoroContainer.classList.add('pomodoro__container', 'container')
        @element.appendChild(@pomodoroContainer)

        @pomodoroGague = createDiv()
        @pomodoroGague.id = 'pomodoro-gague'
        @pomodoroGague.classList.add('pomodoro-gague')
        @pomodoroContainer.appendChild(@pomodoroGague)

        @pomodoroButton = document.createElement('button')
        @pomodoroButton.classList.add('pomodoro__button', 'fitgit-text', 'fitgit-button')
        @pomodoroButton.textContent = 'Start pomodoro'
        @pomodoroButton.onclick = @showPomodoroGague
        @pomodoroContainer.appendChild(@pomodoroButton)

        @heatmapToggleContainer = createDiv()
        @heatmapToggleContainer.classList.add('heatmap-toggle__container', 'container')
        @element.appendChild(@heatmapToggleContainer)

        @heatmapToggleButton = document.createElement('button')
        @heatmapToggleButton.classList.add('heatmap-toggle__button', 'fitgit-text', 'fitgit-button')
        @heatmapToggleButton.textContent = 'Show Clicks Heatmap'
        @heatmapToggleButton.onclick = @setUpHeatMap
        @heatmapToggleContainer.appendChild(@heatmapToggleButton)



    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @element.remove()
        clearInterval(@updateTimeInterval)

    getElement: ->
        @element


    setUpHeatMap: =>
        unless @heatmapInstance
            @heatmapInstance = heatmap.create(
                  container: @heatmapContainer
                  maxOpacity: .6
                  radius: 50
                  blur: .90
                  backgroundColor: 'rgba(0, 0, 58, 0.96)'
             )
        mouseClicks = dataStore.getMouseClicks()

        #map mouseclicks to heatmapData format
        heatmapData = mouseClicks.map (data) =>
                x: data.x
                y: data.y
                value: @HEATMAP_VALUE

        @heatmapInstance.setData {data: heatmapData}
        @heatmapContainerWrapper.classList.remove('hide')


        @heatmapToggleButton.textContent = 'Hide Clicks Heatmap'
        @heatmapToggleButton.onclick = @hideHeatmap

        $(window).on dataStore.INCREMENT_MOUSE_CLICKS, @addToHeatmap

    addToHeatmap: ({clickPos}) =>
        @heatmapInstance.addData
            x: clickPos.x
            y: clickPos.y
            value: @HEATMAP_VALUE

    hideHeatmap: =>
        @heatmapToggleButton.textContent = 'Show Clicks Heatmap'
        @heatmapToggleButton.onclick = @setUpHeatMap
        @heatmapContainerWrapper.classList.add('hide')
        $(window).off dataStore.INCREMENT_MOUSE_CLICKS, @addToHeatmap


    showPomodoroGague: =>
        minutes = ['minutes', 0]
        unless @pomodoroTimer
            @pomodoroTimer = c3.generate
                bindto: '#pomodoro-gague'
                data:
                    type: 'gauge'
                    columns: [
                        minutes
                    ]
                color:
                    pattern: ['#FF0000', '#F97600', '#F6C600', '#60B044']
                    threshold:
                        values: [0.35, 0.70, 1]
                gauge:
                    max: @POMODORO_MAX_DURATION
        else
            @pomodoroTimer.load
                data:
                    columns: minutes

        @kickOffPomodoroTimer()

    showClickScatterGraph: ->
        @scatterGraph = c3.generate
            bindto: '#click-scatter-graph'
            size:
                width: 500
            padding:
                top: 30
                right: 30
            data:
                x: 'clicks_x'
                type: 'scatter'
                columns: [
                    @scatterGraphData1
                    @scatterGraphData2
                ]
            axis:
                x:
                    label: 'X'
                    fit: false
                y:
                    label: 'Y'

    showLettersChart: ->
        @lettersChart = c3.generate
            bindto: '#letters-chart'
            point:
                show: false
            size:
                width: 500
            padding:
                top: 30
                right: 30
            xs:
                x: 'click_x'
            color:
                pattern: ['#d79b00', '#0d17f4' ]
            data:
                type: 'spline'
                columns: [
                    @lettersCountData
                    @keypressesCountData
                ]
        i = 0


    updateLettersChart: ->
        newCharactersTypedCount = dataStore.getCharactersTypedCount()
        if newCharactersTypedCount is 1
            @lettersLabel.textContent = "#{newCharactersTypedCount} character typed today"
        else
            @lettersLabel.textContent = "#{newCharactersTypedCount} characters typed today"

        newKeyPressesCount = dataStore.getKeyPressesCount()

        @lettersCountData.push newCharactersTypedCount
        @keypressesCountData.push newKeyPressesCount

        if(@lettersChart?.load)
            @lettersChart.load
                columns: [
                    @lettersCountData
                    @keypressesCountData
                ]

    updateClickScatterGraph: ->
        xClicks = ['clicks_x']
        yClicks = ['clicks']

        newClicks = dataStore.getMouseClicks()
        newClicks.forEach (click) ->
            xClicks.push click.x
            yClicks.push -click.y

        if(@scatterGraph?.load)
            @scatterGraph.load
                columns: [
                    xClicks
                    yClicks
                ]
            # @scatterGraph.load
            #     data: newClicks
            #     keys:
            #         values: ['x', 'y']

        newClicksCount = newClicks.length
        if newClicksCount is 1
            @clickScatterGraphLabel.textContent = "#{newClicksCount} click so far"
        else
            @clickScatterGraphLabel.textContent = "#{newClicksCount} clicks so far today"

    updateDeletes: ->
        delCount = dataStore.getDeletesCount()
        if(delCount is 1)
            @deletesCount.textContent = "#{delCount} delete today"
        else
            @deletesCount.textContent = "#{delCount} deletes today"

    updateSaves: ->
        saveCount = dataStore.getSavesCount()
        if(saveCount is 1)
            @savesCount.textContent = "#{saveCount} save so far today"
        else
            @savesCount.textContent = "#{saveCount} saves so far today"

    kickOffPomodoroTimer: ->
        $(window).trigger({type: dataStore.SET_POMODORO_START_TIME})
        @pomodoroButton.textContent = 'Stop pomodoro'
        @pomodoroButton.onclick = @stopPomodoro
        @pomodoroInterval = setInterval(@updatePomodoroTimer, @POMODORO_INTERVAL)

    updatePomodoroTimer: =>
        duration = dataStore.getPomodoroDuration()

        if(@pomodoroTimer?.load)
            minutes = ['minutes', duration]
            @pomodoroTimer.load
                columns: [minutes]

        if duration >= @POMODORO_MAX_DURATION
            alert('GO TAKE A BREAK')
            clearInterval(@pomodoroInterval)
            @pomodoroButton.textContent = 'Start pomodoro'
            @pomodoroButton.onclick = @showPomodoroGague
            $(window).trigger({type: dataStore.CLEAR_POMODORO_START_TIME})

    stopPomodoro: =>
        clearInterval(@pomodoroInterval)
        $(window).trigger({type: dataStore.CLEAR_POMODORO_START_TIME})
        @pomodoroButton.textContent = 'Start pomodoro'
        @pomodoroButton.onclick = @showPomodoroGague


module.exports = FitgitView
