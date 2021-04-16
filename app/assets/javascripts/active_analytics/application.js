//= require active_analytics/ariato

ActiveAnalytics = {}

ActiveAnalytics.Header = function() {
}

ActiveAnalytics.Header.prototype.toggleDateRangeForm = function() {
  var form = this.node.querySelector("#dateRangeForm")
  if (form.hasAttribute("hidden"))
    form.removeAttribute("hidden")
  else
    form.setAttribute("hidden", "hidden")
}

Ariato.launchWhenDomIsReady()