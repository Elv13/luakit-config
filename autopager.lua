local ready_views = setmetatable({}, { mode = "_k" })

local go_next = [=[
(function() {
var el = document.querySelector("[rel='next']");
if (el) { // Wow a developer that knows what he's doing!
location = el.href;
}
else { // Search from the bottom of the page up for a next link.
var els = document.getElementsByTagName("a");
var i = els.length;
while ((el = els[--i])) {
if (el.text.search(/(\bnext\b|^>$|^(>>|»)$|^(>|»)|(>|»)$|\bmore\b)/i) > -1) {
location = el.href;
break;
}
}
}
})();
]=]

webview.init_funcs.autopager = function (view, w)
    view:add_signal("load-status", function (v, status)
        print("Status", status)
        ready_views[v] = (status == "finished")
    end)
    view:add_signal("expose", function (v)
        local cur, max = view:get_scroll_vert()
        if ready_views[v] and cur == max then
            ready_views[v] = false
            v:eval_js(go_next, "(autopager.lua)")
        end
    end)
end