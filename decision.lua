Decision = {}

function Decision:new(data)
  newObj = {meeting = data.meeting, number = data.number, decision = data.decision}
  self.__index = self

  newObj.label = string.format("dec:%d-%d", data.meeting, data.number)

  return setmetatable(newObj, self)
end

function Decision:id()
    return string.format("%d.%d", self.meeting, self.number)
end

function Decision:decision()
    return self.decision
end

function Decision:running()
  return string.format("\\decrunning{%s}{%s}{%s}", self:id(), self.decision, self.label)
end

decisions = {}

function new_decision(meeting, number, decision)
    local dec = Decision:new({meeting = meeting, number = number, decision = decision})
    table.insert(decisions, dec)
    return dec
end

function decision_comp(a, b)
    if a.meeting < b.meeting then
       return true
    elseif (a.meeting == b.meeting) and (a.number < b.number) then
       return true
    else
      return false
    end
end

function decisions_list()
    table.sort(decisions, decision_comp)
    res = {"\\begin{itemize}"}
    for _, d in pairs(decisions) do
        table.insert(res, string.format("\\decitem{%d}{%d}{%s}[%s]", d.meeting, d.number, d.decision, d.label))
    end
    table.insert(res, "\\end{itemize}")
    if #res > 2 then
    	return res
    else
        return ""
    end
end

function dump_decision_list(filename)
  f = io.open(filename, "w")
  f:write("\\begin{itemize}\n")
  table.sort(decisions, decision_comp)
  for _, d in pairs(decisions) do
    f:write(string.format("\\decitem{%d}{%d}{%s}\n", d.meeting, d.number, d.decision))
    f:write(string.format("\\oudbesluit{%d}{%s}{%s}\n", d.meeting, d.number, d.decision))
  end
  f:write("\\end{itemize}")
  f:flush()
  f:close()
end
