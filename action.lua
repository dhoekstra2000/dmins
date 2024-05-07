-- require "lualoader"
-- local lyaml = require "lyaml"

_ICONS = {open = "\\actionicon", progress = "\\progressicon", done = "\\doneicon", stricken = "\\strickenicon"}

Action = {}

function Action:new(data)
  newObj = {meeting = data.meeting, section = data.section, number = data.number, person = data.person, action = data.action, due_date = data.due_date}
  self.__index = self

  if data.state then
    newObj.state = data.state
  else
    newObj.state = "open"
  end

  newObj.icon = _ICONS[newObj.state]

  newObj.label = string.format("act:%d-%d", data.meeting, data.number)

  if data.old then
    newObj.old = data.old
  else
    newObj.old = false
  end

  return setmetatable(newObj, self)
end

function Action:set_state(state)
  self.state = state
  self.icon = _ICONS[state]
end

function Action:running_text()
  return string.format("\\aprunning{%s}{%d}{%d}{%s}{%s}", self.icon, self.meeting, self.number, self.person, self.label)
end

function Action:latex_label()
  return string.format("\\label{%s}", self.label)
end

function Action:id()
  return string.format("%d.%d", self.meeting, self.number)
end

function Action:old()
  return self.old
end

function action_comp(a, b)
    if a.meeting < b.meeting then
       return true
    elseif (a.meeting == b.meeting) and (a.number < b.number) then
       return true
    else
      return false
    end
end

local actionspoints = {}
local actions_per_person = {}
local actions_per_meeting = {}

-- API
function add_new_ap(meeting, section, number, person, action, due_date)
  if actions_per_meeting[meeting] then
    for _,a in pairs(actions_per_meeting[meeting]) do
      if a.number == number then return nil end
    end
  end
  if due_date then
    year, month, day = string.match(due_date, "(%d+)/(%d+)/(%d+)")
    due_date = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day)})
  end
  person = person:gsub("%s+", "")
  local ap = Action:new{meeting = meeting, section = section, number = number, person = person, action = action, due_date = due_date }
  table.insert(actionspoints, ap)
  if actions_per_person[person] then
    table.insert(actions_per_person[person], ap)
  else
    actions_per_person[person] = { ap }
  end
  if actions_per_meeting[meeting] then
    table.insert(actions_per_meeting[meeting], ap)
  else
    actions_per_meeting[meeting] = { ap }
  end
  return ap
end

function change_ap_state(id, state)
  meeting, number = string.match(id, "(%d+)%.(%d+)")
  meeting = tonumber(meeting)
  number = tonumber(number)
  if actions_per_meeting[meeting] then
    for _, a in pairs(actions_per_meeting[meeting]) do
      if a.number == number then
        a:set_state(state)
      end
    end
  end
end

function print_ap(id)
  meeting, number = string.match(id, "(%d+)%.(%d+)")
  meeting = tonumber(meeting)
  number = tonumber(number)
  if actions_per_meeting[meeting] then
    for _, a in pairs(actions_per_meeting[meeting]) do
      if a.number == number then
        tex.print(a:running_text())
      end
    end
  end
end

function section_list(meeting, section)
  if actions_per_meeting[meeting] then
    res = {"\\begin{itemize}"}
    for _, a in pairs(actions_per_meeting[meeting]) do
      if a.section == section then
--         table.insert(res, string.format("\\item[%s] %d.%d \\textbf{%s}: %s", a.icon, a.meeting, a.number, a.person, a.action))
        table.insert(res, string.format("\\secactitem{%s}{%d}{%d}{%s}{%s}", a.icon, a.meeting, a.number, a.person, a.action))
      end
    end
    if #res > 1 then
      table.insert(res, "\\end{itemize}")
      tex.print(res)
    end
  end
end

function meeting_list(meeting)
  if actions_per_meeting[meeting] then
    res = {"\\begin{itemize}"}
    for _, a in pairs(actions_per_meeting[meeting]) do
--       table.insert(res, string.format("\\item[%s] %d.%d \\textbf{%s}: %s", a.icon, a.meeting, a.number, a.person, a.action))
      table.insert(res, string.format("\\meetactitem{%s}{%d}{%d}{%s}{%s}", a.icon, a.meeting, a.number, a.person, a.action))
    end
    if #res > 1 then
      table.insert(res, "\\end{itemize}")
      tex.print(res)
    end
  end
end

function actions_list()
  res = {"\\begin{itemize}"}
  for _, m in pairs(actions_per_meeting) do
    for _, a in pairs(m) do
--     table.insert(res, string.format("\\item[%s] %d.%d \\textbf{%s}: %s", a.icon, a.meeting, a.number, a.person, a.action))
      table.insert(res, string.format("\\meetactitem{%s}{%d}{%d}{%s}{%s}", a.icon, a.meeting, a.number, a.person, a.action))
    end
  end
  if #res > 1 then
    table.insert(res, "\\end{itemize}")
    tex.print(res)
  end
end

function person_list(person, res, exclude_done)
  if actions_per_person[person] then
    local empty = true
    local acts = actions_per_person[person]
    table.sort(acts, action_comp)
    for _, a in pairs(acts) do
      if not (exclude_done and (a.state == "done" or a.state == "stricken")) then
        if empty then
          table.insert(res, string.format("\\actpersonitem{%s}", person))
          table.insert(res, "\\begin{itemize}")
          empty = false
        end

        if a.old then
  --         table.insert(res, string.format("\\item[%s] %d.%d %s", a.icon, a.meeting, a.number, a.action))
          table.insert(res, string.format("\\oldactitem{%s}{%d}{%d}{%s}", a.icon, a.meeting, a.number, a.action))
        else
  --         table.insert(res, string.format("\\item[\\protect\\hyperref[%s]{%s}] %d.%d %s (p.\\ \\pageref{%s})", a.label, a.icon, a.meeting, a.number, a.action, a.label))
          table.insert(res, string.format("\\persactitem{%s}{%s}{%d}{%d}{%s}", a.label, a.icon, a.meeting, a.number, a.action))
        end
      end
    end
    
    if not empty then
      table.insert(res, "\\end{itemize}")
    end
  end
end

function persons_list(exclude_done)
  res = {"\\begin{itemize}"}
  for key, acts in orderedPairs(actions_per_person) do
      person_list(key, res, exclude_done)
  end
  table.insert(res, "\\end{itemize}")
  return res
end

function dump_actions_list(filename)
  f = io.open(filename, "w")
  f:write("\\begin{itemize}\n")
  table.sort(actionspoints, action_comp)
  for _, a in pairs(actionspoints) do
    if a.state == "open" or a.state == "progress" then
      f:write(string.format("\\coveractitem{%s}{%d}{%d}{%s}{%s}\\\\\n", a.icon, a.meeting, a.number, a.person, a.action))
      f:write(string.format("\\apstate{%d.%d}{%s}\n", a.meeting, a.number, a.state))
      f:write(string.format("\\oap{%s}{%d}{%d}{%s}{%s}\n\n", a.state, a.meeting, a.number, a.person, a.action))
    end
  end
  f:write("\\end{itemize}")
  f:flush()
  f:close()
end

-- Ordered pairs
function __genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex)
    return orderedIndex
end

function orderedNext(t, state)
    local key = nil
    if state == nil then
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        for i = 1, table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    return orderedNext, t, nil
end
