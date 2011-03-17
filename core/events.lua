-- Copyright 2007-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.

local L = _G.locale.localize

---
-- Textadept's core event structure and handlers.
module('events', package.seeall)

-- Markdown:
-- ## Overview
--
-- Textadept is very event-driven. Most of its functionality comes through event
-- handlers. Events occur when you create a new buffer, press a key, click on a
-- menu, etc. You can even make an event occur with Lua code. Instead of having
-- a single event handler however, each event can have a set of handlers. These
-- handlers are simply Lua functions that are called in the order they were
-- added to an event. This enables dynamically loaded modules to add their own
-- handlers to events.
--
-- Events themselves are nothing special. They do not have to be declared in
-- order to be used. They are simply strings containing an arbitrary event name.
-- When an event of this name occurs, either generated by Textadept or you, all
-- event handlers assigned to it are run.
--
-- Events can be given any number of arguments. These arguments will be passed
-- to the event's handler functions. If a handler returns either true or false
-- explicitly, all subsequent handlers are not called. This is useful if you
-- want to stop the propagation of an event like a keypress.
--
-- ## Textadept Events
--
-- The following is a list of all Scintilla events generated by Textadept in
-- `event_name(arguments)` format:
--
-- * **char\_added** (ch)<br />
--   Called when an ordinary text character is added to the buffer.
--       - ch: the ASCII representation of the character.
-- * **save\_point\_reached** ()<br />
--   Called when a save point is entered.
-- * **save\_point\_left** ()<br />
--   Called when a save point is left.
-- * **double\_click** (position, line)<br />
--   Called when the mouse button is double-clicked.
--       - position: the text position the click occured at.
--       - line: the line number the click occured at.
-- * **update\_ui** ()<br />
--   Called when the text or styling of the buffer has changed or the selection
--   range has changed.
-- * **margin\_click** (margin, modifiers, position)<br />
--   Called when the mouse is clicked inside a margin.
--       - margin: the margin number that was clicked.
--       - modifiers: the appropriate combination of `SCI_SHIFT`, `SCI_CTRL`,
--         and `SCI_ALT` to indicate the keys that were held down at the time of
--         the margin click.
--       - position: The position of the start of the line in the buffer that
--         corresponds to the margin click.
-- * **user\_list\_selection** (wParam, text)<br />
--   Called when the user has selected an item in a user list.
--       - wParam: the list_type parameter from
--         [`buffer:user_list_show()`][buffer_user_list_show].
--       - text: the text of the selection.
-- * **uri\_dropped** (text)<br />
--   Called when the user has dragged a URI such as a file name or web address
--   into Textadept.
--       - text: URI text.
-- * **call\_tip\_click** (position)<br />
--   Called when the user clicks on a calltip.
--       - position: 1 if the click is in an up arrow, 2 if in a down arrow, and
--         0 if elsewhere.
-- * **auto\_c\_selection** (lParam, text)<br />
--   Called when the user has selected an item in an autocompletion list.
--       - lParam: the start position of the word being completed.
--       - text: the text of the selection.
--
-- [buffer_user_list_show]: ../modules/buffer.html#buffer:user_list_show
--
-- The following is a list of gui events generated in
-- `event_name(arguments)` format:
--
-- * **buffer\_new** ()<br />
--   Called when a new [buffer][buffer] is created.
-- * **buffer\_deleted** ()<br />
--   Called when a [buffer][buffer] has been deleted.
-- * **buffer\_before\_switch** ()<br />
--   Called right before another [buffer][buffer] is switched to.
-- * **buffer\_after\_switch** ()<br />
--   Called right after a [buffer][buffer] was switched to.
-- * **view\_new** ()<br />
--   Called when a new [view][view] is created.
-- * **view\_before\_switch** ()<br />
--   Called right before another [view][view] is switched to.
-- * **view\_after\_switch** ()<br />
--   Called right after [view][view] was switched to.
-- * **reset\_before** ()<br />
--   Called before resetting the Lua state during a call to [`reset()`][reset].
-- * **reset\_after** ()<br />
--   Called after resetting the Lua state during a call to [`reset()`][reset].
-- * **quit** ()<br />
--   Called when quitting Textadept.<br />
--   Note: Any quit handlers added must be inserted at index 1 because the
--   default quit handler in `core/events.lua` returns `true`, which ignores all
--   subsequent handlers.
-- * **error** (text)<br />
--   Called when an error occurs in the C code.
--       - text: The error text.
-- * **appleevent\_odoc** (uri)<br />
--   Called when Mac OSX instructs Textadept to open a document.
--       - uri: The URI to open.
--
-- [buffer]: ../modules/buffer.html
-- [view]: ../modules/view.html
-- [reset]: ../modules/_G.html#reset
--
-- ## Example
--
-- The following Lua code generates and handles a custom `my_event` event:
--
--     function my_event_handler(message)
--       gui.print(message)
--     end
--
--     events.connect('my_event', my_event_handler)
--     events.emit('my_event', 'my message')

local handlers = {}

---
-- Adds a handler function to an event.
-- @param event The string event name. It is arbitrary and need not be defined
--   anywhere.
-- @param f The Lua function to add.
-- @param index Optional index to insert the handler into.
-- @return Index of handler.
-- @see disconnect
function connect(event, f, index)
  if not handlers[event] then handlers[event] = {} end
  local h = handlers[event]
  if index then table.insert(h, index, f) else h[#h + 1] = f end
  return index or #h
end

---
-- Disconnects a handler function from an event.
-- @param event The string event name.
-- @param index Index of the handler (returned by events.connect).
-- @see connect
function disconnect(event, index)
  if not handlers[event] then return end
  table.remove(handlers[event], index)
end

local error_emitted = false

---
-- Calls all handlers for the given event in sequence (effectively "generating"
-- the event).
-- If true or false is explicitly returned by any handler, the event is not
-- propagated any further; iteration ceases.
-- @param event The string event name.
-- @param ... Arguments passed to the handler.
-- @return true or false if any handler explicitly returned such; nil otherwise.
function emit(event, ...)
  local h = handlers[event]
  if not h then return end
  local pcall, unpack, type = _G.pcall, _G.unpack, _G.type
  for i = 1, #h do
    local ok, result = pcall(h[i], unpack{...})
    if not ok then
      if not error_emitted then
        error_emitted = true
        emit('error', result)
        error_emitted = false
      else
        io.stderr:write(result)
      end
    end
    if type(result) == 'boolean' then return result end
  end
end

--- Map of Scintilla notifications to their handlers.
local c = _SCINTILLA.constants
local scnnotifications = {
  [c.SCN_CHARADDED] = { 'char_added', 'ch' },
  [c.SCN_SAVEPOINTREACHED] = { 'save_point_reached' },
  [c.SCN_SAVEPOINTLEFT] = { 'save_point_left' },
  [c.SCN_DOUBLECLICK] = { 'double_click', 'position', 'line' },
  [c.SCN_UPDATEUI] = { 'update_ui' },
  [c.SCN_MARGINCLICK] = { 'margin_click', 'margin', 'modifiers', 'position' },
  [c.SCN_USERLISTSELECTION] = { 'user_list_selection', 'wParam', 'text' },
  [c.SCN_URIDROPPED] = { 'uri_dropped', 'text' },
  [c.SCN_CALLTIPCLICK] = { 'call_tip_click', 'position' },
  [c.SCN_AUTOCSELECTION] = { 'auto_c_selection', 'lParam', 'text' }
}

---
-- Handles Scintilla notifications.
-- @param n The Scintilla notification structure as a Lua table.
-- @return true or false if any handler explicitly returned such; nil otherwise.
function notification(n)
  local f = scnnotifications[n.code]
  if not f then return end
  local args = {}
  for i = 2, #f do args[i - 1] = n[f[i]] end
  return emit(f[1], unpack(args))
end
