$ = require 'jquery'
moment = require 'moment'

INCREMENT_CHARACTERS_TYPED = 'INCREMENT_CHARACTERS_TYPED'
INCREMENT_DELETES = 'INCREMENT_DELETES'
INCREMENT_SAVES = 'INCREMENT_SAVES'
INCREMENT_KEY_PRESSES = 'INCREMENT_KEY_PRESSES'
INCREMENT_MOUSE_CLICKS = 'INCREMENT_MOUSE_CLICKS'
SET_START_TIME = 'SET_START_TIME'
SET_POMODORO_START_TIME = 'SET_POMODORO_START_TIME'
CLEAR_POMODORO_START_TIME = 'CLEAR_POMODORO_START_TIME'

charactersTypedCount = []
deletesCount = 0
savesCount = 0
keyPressesCount = 0
mouseClicks = []
startTime = null
pomodoroStartTime = null

$(window).on INCREMENT_CHARACTERS_TYPED, (data) ->
    charactersTypedCount.push data

getCharactersTypedCount = -> charactersTypedCount.length

$(window).on INCREMENT_DELETES, ->
    deletesCount++

getDeletesCount = -> deletesCount

$(window).on INCREMENT_SAVES, ->
    savesCount++

getSavesCount = -> savesCount

$(window).on INCREMENT_KEY_PRESSES, ->
    keyPressesCount++

getKeyPressesCount = -> keyPressesCount

$(window).on SET_START_TIME, ->
    startTime = moment()

getDuration = ->
    now = moment()
    return moment.duration(now.diff(startTime)).humanize()

$(window).on INCREMENT_MOUSE_CLICKS, (data) ->
    mouseClicks.push data.clickPos

getMouseClicks = -> mouseClicks


$(window).on SET_POMODORO_START_TIME, ->
    pomodoroStartTime = moment()

getPomodoroDuration = ->
    now = moment()
    return moment.duration(now.diff(pomodoroStartTime)).as('minutes')

$(window).on CLEAR_POMODORO_START_TIME, ->
    pomodoroStartTime = null

module.exports = {
    INCREMENT_CHARACTERS_TYPED
    INCREMENT_DELETES
    INCREMENT_SAVES
    INCREMENT_KEY_PRESSES
    SET_START_TIME
    INCREMENT_MOUSE_CLICKS
    SET_POMODORO_START_TIME
    CLEAR_POMODORO_START_TIME
    getCharactersTypedCount
    getDeletesCount
    getSavesCount
    getKeyPressesCount
    getDuration
    getMouseClicks
    getPomodoroDuration
}
