#!/usr/bin/env lua

local libdir = os.getenv("LUA_LIBDIR")
if libdir then
	package.path = libdir .. ";" .. package.path
	package.cpath = libdir .. ";" .. package.cpath
end

SimpleSection = "SimpleSection"
NamedSection = "NamedSection"
TypedSection = "TypedSection"

DynamicList = "DynamicList"
DummyValue = "DummyValue"
MultiValue = "MultiValue"
ListValue = "ListValue"
TextValue = "TextValue"
Value = "Value"
Flag = "Flag"


getmetatable("").__mod = function(a, b)
	local ok, res

	if not b then
		return a
	elseif type(b) == "table" then
		local k, _
		for k, _ in pairs(b) do if type(b[k]) == "userdata" then b[k] = tostring(b[k]) end end

		ok, res = pcall(a.format, a, unpack(b))
		if not ok then
			error(res, 2)
		end
		return res
	else
		if type(b) == "userdata" then b = tostring(b) end

		ok, res = pcall(a.format, a, b)
		if not ok then
			error(res, 2)
		end
		return res
	end
end

function translate(s)
	return { ":translate", s }
end

function translatef(...)
	local l = { ":translatef" }
	for _, s in ipairs({...}) do
		l[_ + 1] = s
	end
	return l
end

function Map(config, title, description)
	return {
		_config = config,
		_title = title,
		_description = description,
		_sections = {},

		section = function(self, widget, ...)
			local stype, sname, title, description
			if widget == NamedSection then
				stype, sname, title, description = unpack({...})
			else
				stype, title, description = unpack({...})
			end

			local sec = {
				_widget = widget,
				_title = title,
				_description = description,
				_stype = stype,
				_sname = sname,
				_options = {},
				_tabs = {},

				tab = function(self, tabname, title, description)
					self._tabs[#self._tabs + 1] = {
						_name = tabname,
						_title = title,
						_description = description,
						_options = {}
					}
				end,

				option = function(self, widget, name, title, description)
					local opt = {
						_widget = widget,
						_name = name,
						_title = title,
						_description = description,
						_depends = {},
						_values = {},

						depends = function(self, name, value)
							if type(name) == "table" then
								self._depends[#self._depends+1] = name
							else
								self._depends[#self._depends+1] = { name, tostring(value) }
							end
						end,

						value = function(self, value, label)
							self._values[#self._values+1] = { tostring(value), label }
						end
					}

					self._options[#self._options+1] = opt

					return opt
				end,

				taboption = function(self, tabname, widget, name, title, description)
					local opt = self:option(widget, name, title, description)
					for _, tab in ipairs(self._tabs) do
						if tab._name == tabname then
							tab._options[#tab._options+1] = opt
						end
					end
					return opt
				end
			}

			self._sections[#self._sections+1] = sec

			return sec
		end
	}
end


function dump(x, i)
	if type(x) == "table" then
		for k, v in pairs(x) do
			if type(v) == "table" then
				print((i or "") .. k .. ":")
				dump(v, (i or "") .. "  ")
			else
				print((i or "") .. k .. ":", v)
			end
		end
	else
		print((i or ""), x)
	end
end


local ok, fn = pcall(loadfile, arg[1])
if not ok then
	error(fn)
end

local ok, res = pcall(fn)
if not ok then
	error(res)
end

function printf(...)
	io.write(string.format(...))
end

function str(v)
	if v ~= nil then
		return "'"..(tostring(v):gsub("\\", "\\\\"):gsub("'", "\\'")).."'"
	else
		return "null"
	end
end

function val(v, fn)
	if type(v) == "string" then
		return str(v)
	elseif type(v) == "number" then
		return tostring(v)
	elseif type(v) == "boolean" then
		return v and "true" or "false"
	elseif type(v) == "table" then
		if v[1] == ":translate" then
			return string.format("_(%s)", str(v[2]))
		elseif v[1] == ":translatef" then
			local args
			for i = 3, #v do
				args = (args and args .. ", " or "") .. val(v[i])
			end
			return string.format("_(%s).format(%s)", str(v[2]), args or "??")
		elseif v[1] == ":function" then
			return v[2]
		end

		if #v > 0 then
			local l = {}
			for _, i in ipairs(v) do
				l[_] = val(fn and fn(i) or i)
			end
			return string.format("[ %s ]", table.concat(l, ", "))
		else
			local l = {}
			for k, i in pairs(v) do
				l[#l+1] = str(k) .. ': ' .. val(fn and fn(i) or i)
			end
			return string.format("{ %s }", table.concat(l, ", "))
		end
	elseif v ~= nil then
		return string.format("null /* %s:%s */", type(v), tostring(v))
	else
		return "null"
	end
end

function fun(fn)
	local info = debug.getinfo(fn)
	if info.source and info.source:byte(1) == 64 then
		local f = io.open(info.source:sub(2), "r")
		local n = 0
		local src = {}
		while true do
			local l = f:read("*l")
			if not l then
				break
			end

			n = n + 1

			if n > info.lastlinedefined then
				break
			elseif n >= info.linedefined then
				src[#src+1] = "\t"..l
			end
		end
		f:close()
		return { ":function", string.format("function() { /*\n%s\n*/ }", table.concat(src, "\n")) }
	else
		return { ":function", string.format("function() { /* ... */ }") }
	end
end


printf("var m, s, o;\n\n")

if res._title and res._description then
	printf("m = new form.Map(%s, %s,\n\t%s);\n\n",
		val(res._config),
		val(res._title),
		val(res._description))
elseif res._title then
	printf("m = new form.Map(%s, %s);\n\n",
		val(res._config),
		val(res._title))
else
	printf("m = new form.Map(%s);\n\n",
		val(res._config))
end

for _, sec in ipairs(res._sections) do
	if sec._sname and sec._title and sec._description then
		printf("s = m.section(form.%s, %s, %s, %s,\n\t%s);\n",
			sec._widget,
			val(sec._stype),
			val(sec._sname),
			val(sec._title),
			val(sec._description))
	elseif sec._sname and sec._title then
		printf("s = m.section(form.%s, %s, %s, %s);\n",
			sec._widget,
			val(sec._stype),
			val(sec._sname),
			val(sec._title))
	elseif sec._sname then
		printf("s = m.section(form.%s, %s, %s);\n",
			sec._widget,
			val(sec._stype),
			val(sec._sname))
	elseif sec._title and sec._description then
		printf("s = m.section(form.%s, %s, %s,\n\t%s);\n",
			sec._widget,
			val(sec._stype),
			val(sec._title),
			val(sec._description))
	elseif sec._title then
		printf("s = m.section(form.%s, %s, %s);\n",
			sec._widget,
			val(sec._stype),
			val(sec._title))
	else
		printf("s = m.section(form.%s, %s);\n",
			sec._widget,
			val(sec._stype))
	end

	for _, prop in ipairs({'anonymous', 'addremove', 'template'}) do
		local p, t = prop:match("^([^:]+):(.+)$")
		if sec[p or prop] ~= nil then
			printf("s.%s = %s;\n",
				p or prop,
				val(t and _G[t](sec[p or prop]) or sec[p or prop]))
		end
	end

	printf("\n")

	local tabs = (#sec._tabs > 0) and sec._tabs or {{ _options = sec._options }}
	local has_tab = false

	for _, tab in ipairs(tabs) do
		if tab._name then
			if tab._title and tab._description then
				printf("s.tab(%s, %s, %s);\n",
					val(tab._name),
					val(tab._title),
					val(tab._description))
			elseif tab._title then
				printf("s.tab(%s, %s);\n",
					val(tab._name),
					val(tab._title))
			else
				printf("s.tab(%s);\n",
					val(tab._name))
			end
			has_tab = true
		end
	end

	if has_tab then
		printf("\n")
	end

	for _, tab in ipairs(tabs) do
		if _ > 1 then
			printf("\n")
		end
		for _, opt in ipairs(tab._options) do
			local optfn = tab._name and string.format("taboption(%s, ", val(tab._name)) or "option("
			if opt._title and opt._description then
				printf("o = s.%sform.%s, %s, %s,\n\t%s);\n",
					optfn, opt._widget or "??",
					val(opt._name),
					val(opt._title),
					val(opt._description))
			elseif opt._title then
				printf("o = s.%sform.%s, %s, %s);\n",
					optfn, opt._widget or "??",
					val(opt._name),
					val(opt._title))
			else
				printf("o = s.%sform.%s, %s);\n",
					optfn, opt._widget or "??",
					val(opt._name))
			end

			for _, prop in ipairs({'default', 'optional', 'rmempty', 'size', 'cfgvalue:fun', 'write:fun', 'remove:fun'}) do
				local p, t = prop:match("^([^:]+):(.+)$")
				if opt[p or prop] ~= nil then
					printf("o.%s = %s;\n",
						p or prop,
						val(t and _G[t](opt[p or prop]) or opt[p or prop]))
				end
			end

			for _, dep in ipairs(opt._depends) do
				if #dep == 2 then
					printf("o.depends(%s, %s);\n",
						val(dep[1]),
						val(dep[2]))
				else
					printf("o.depends(%s);\n",
						val(dep, tostring))
				end
			end

			for _, value in ipairs(opt._values) do
				if value[2] then
					printf("o.value(%s, %s);\n",
							val(value[1]),
							val(value[2]))
				else
					printf("o.value(%s);\n",
							val(value[1]))
				end
			end

			printf("\n")
		end
	end
end

printf("return m.render();\n")

--dump(res)
