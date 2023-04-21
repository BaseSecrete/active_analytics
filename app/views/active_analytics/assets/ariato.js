Ariato = {}

Ariato.launchWhenDomIsReady = function(root) {
  if (document.readyState != "loading") {
    Ariato.launch()
    Ariato.launch(document, "aria-roledescription")
    Ariato.launch(document, "data-ariato")
  }
  else
    document.addEventListener("DOMContentLoaded", function() { Ariato.launchWhenDomIsReady(root) } )
}

Ariato.launch = function(root, attribute, parent) {
  attribute || (attribute = "role")
  var elements = (root || document).querySelectorAll("[" + attribute + "]")
  for (var i = 0; i < elements.length; i++)
    Ariato.start(elements[i], attribute, parent)
}

Ariato.mount = function() {
}

Ariato.start = function(element, attribute, parent) {
  var names = element.getAttribute(attribute).split(" ")
  for (var i = 0; i < names.length; i++) {
    var name = names[i].charAt(0).toUpperCase() + names[i].slice(1) // Capitalize
    var func = Ariato.stringToFunction("Ariato." + name) || Ariato.stringToFunction(name)
    if (func instanceof Function)
      Ariato.instanciate(func, element, parent)
  }
}

Ariato.instanciate = function(func, element, parent) {
  try {
    controller = Object.create(func.prototype)
    controller.parent = parent
    controller.node = element
    Ariato.initialize(controller, element)
    func.call(controller, element)
  } catch (ex) {
    console.error(ex)
  }
}

Ariato.stringToFunction = function(fullName) {
  var func = window, names = fullName.split(".")
  for (var i = 0; i < names.length; i++)
    if (!(func = func[names[i]]))
      return null
  return func
}

Ariato.initialize = function(controller, container) {
  Ariato.listenEvents(container, controller)
  Ariato.assignRoles(container, controller)
}

Ariato.listenEvents = function(root, controller) {
  var elements = root.querySelectorAll("[data-event]")
  for (var i = 0; i < elements.length; i++) {
    elements[i].getAttribute("data-event").split(" ").forEach(function(eventAndAction) {
      var array = eventAndAction.split("->")
      Ariato.listenEvent(controller, elements[i], array[0], array[1])
    })
  }
}

Ariato.listenEvent = function(controller, element, event, action) {
  if (controller[action] instanceof Function)
    element.addEventListener(event, controller[action].bind(controller))
}

Ariato.findRoles = function(container) {
  var roles = {}, elements = container.querySelectorAll("[data-role]")
  for (var i = 0; i < elements.length; i++) {
    var name = elements[i].getAttribute("data-role")
    roles[name] ? roles[name].push(elements[i]) : roles[name] = [elements[i]]
  }
  return roles
}

Ariato.assignRoles = function(container, controller) {
  controller.roles = Ariato.findRoles(container)
  for (var name in controller.roles)
    if (controller.roles[name].length == 1)
      controller[name] = controller.roles[name][0]
}

Ariato.Dialog = function(node) {
  node.setAttribute("hidden", true)
  node.addEventListener("open", this.open.bind(this))
  node.addEventListener("close", this.close.bind(this))
  node.addEventListener("keydown", this.keydown.bind(this))
}

Ariato.Dialog.open = function(elementOrId) {
  var dialog = elementOrId instanceof Element ? elementOrId : document.getElementById(elementOrId)
  dialog && dialog.dispatchEvent(new CustomEvent("open"))
}

Ariato.Dialog.close = function(button) {
  var dialog = Ariato.Dialog.current()
  if (dialog && dialog.node.contains(button))
    dialog.close()
}

Ariato.Dialog.closeCurrent = function() {
  var dialog = Ariato.Dialog.current()
  dialog && dialog.close()
}

Ariato.Dialog.replace = function(elementOrId) {
  Ariato.Dialog.closeCurrent()
  Ariato.Dialog.open(elementOrId)
}

Ariato.Dialog.close = function(button) {
  var dialog = Ariato.Dialog.current()
  if (dialog && dialog.node.contains(button))
    dialog.close()
}

Ariato.Dialog.list = []

Ariato.Dialog.current = function() {
  return this.list[this.list.length - 1]
}

Ariato.Dialog.prototype.open = function(event) {
  Ariato.Dialog.list.push(this)
  document.addEventListener("focus", this.bindedLimitFocusScope = this.limitFocusScope.bind(this), true)
  this.initiator = document.activeElement
  this.node.removeAttribute("hidden")

  this.lockScrolling()
  this.createBackdrop()
  this.createFocusStoppers()
  this.focusFirstDescendant(this.node)
}

Ariato.Dialog.prototype.close = function(event) {
  document.removeEventListener("focus", this.bindedLimitFocusScope, true)
  this.node.setAttribute("hidden", true)
  this.removeFocusStoppers()
  this.removeBackdrop()
  this.unlockScrolling()
  this.initiator.focus()
  Ariato.Dialog.list.pop()
}

Ariato.Dialog.prototype.keydown = function(event) {
  if (event.key == "Escape")
    this.close()
}

Ariato.Dialog.prototype.focusFirstDescendant = function(parent) {
  var focusable = ["A", "BUTTON", "INPUT", "SELECT", "TEXTAREA"]

  for (var i = 0; i < parent.children.length; i++) {
    var child = parent.children[i]
    if (focusable.indexOf(child.nodeName) != -1 && !child.disabled && child.type != "hidden") {
      child.focus()
      return child
    }
    else {
      var focus = this.focusFirstDescendant(child)
      if (focus) return focus
    }
  }
}

Ariato.Dialog.prototype.limitFocusScope = function(event) {
  if (this == Ariato.Dialog.current())
    if (!this.node.contains(event.target))
      this.focusFirstDescendant(this.node)
}

Ariato.Dialog.prototype.lockScrolling = function() {
  document.body.style.position = "fixed";
  document.body.style.top = "-" + window.scrollY + "px";
}

Ariato.Dialog.prototype.unlockScrolling = function() {
  var scrollY = document.body.style.top
  document.body.style.position = ""
  document.body.style.top = ""
  window.scrollTo(0, parseInt(scrollY || "0") * -1)
}

Ariato.Dialog.prototype.createFocusStoppers = function() {
  this.node.parentNode.insertBefore(this.focusStopper1 = document.createElement("div"), this.node)
  this.focusStopper1.tabIndex = 0

  this.node.parentNode.insertBefore(this.focusStopper2 = document.createElement("div"), this.node.nextSibling)
  this.focusStopper2.tabIndex = 0
}

Ariato.Dialog.prototype.removeFocusStoppers = function() {
  this.focusStopper1 && this.focusStopper1.parentNode.removeChild(this.focusStopper1)
  this.focusStopper2 && this.focusStopper2.parentNode.removeChild(this.focusStopper2)
}

Ariato.Dialog.prototype.createBackdrop = function() {
  this.backdrop = document.createElement("div")
  this.backdrop.classList.add("dialog-backdrop")
  this.node.parentNode.insertBefore(this.backdrop, this.node)
  this.backdrop.appendChild(this.node)
}

Ariato.Dialog.prototype.removeBackdrop = function() {
  this.backdrop.parentNode.insertBefore(this.node, this.backdrop)
  this.backdrop.parentNode.removeChild(this.backdrop)
  this.backdrop = null
}

Ariato.Alertdialog = Ariato.Dialog

Ariato.MenuButton = function(node) {
  this.node = this.button = node
  this.menu = document.getElementById(this.button.getAttribute("aria-controls"))

  this.menu.addEventListener("keydown", this.keydown.bind(this))
  this.button.addEventListener("keydown", this.keydown.bind(this))
  
  this.button.addEventListener("click", this.clicked.bind(this))
  window.addEventListener("click", this.windowClicked.bind(this), true)
}

Ariato.MenuButton.prototype.clicked = function(event) {
  this.node.getAttribute("aria-expanded") == "true" ? this.close() :  this.open()
}

Ariato.MenuButton.prototype.windowClicked = function() {
  if (!this.node.contains(event.target) && this.node.getAttribute("aria-expanded") == "true")
    this.close()
}

Ariato.MenuButton.prototype.open = function() {
  this.button.setAttribute("aria-expanded", "true")
  this.menu.style.display = "block"
}

Ariato.MenuButton.prototype.close = function() {
  this.button.setAttribute("aria-expanded", "false")
  this.menu.style.display = null
}

Ariato.MenuButton.prototype.keydown = function(event) {
  switch(event.key) {
    case "Escape":
      this.close()
      break
    case "ArrowDown":
      event.preventDefault()
      this.focusNextItem()
      break
    case "ArrowUp":
      event.preventDefault()
      this.focusPreviousItem()
      break
    case "Tab":
      this.close()
    case "Home":
    case "PageUp":
      event.preventDefault()
      this.items()[0].focus()
      break
    case "End":
    case "PageDown":
      event.preventDefault()
      var items = this.items()
      items[items.length-1].focus()
      break
  }
}

Ariato.MenuButton.prototype.items = function() {
  return this.menu.querySelectorAll("[role=menuitem]")
}

Ariato.MenuButton.prototype.currentItem = function() {
  return this.menu.querySelector("[role=menuitem]:focus")
}

Ariato.MenuButton.prototype.nextItem = function() {
  var items = this.items()
  var current = this.currentItem()
  if (!current) return items[0]
  for (var i = 0; i < items.length; i++) {
    if (items[i] == current)
      return items[i+1]
  }
}

Ariato.MenuButton.prototype.previousItem = function() {
  var items = this.items()
  var current = this.currentItem()
  if (!current) return items[0]
  for (var i = 0; i < items.length; i++) {
    if (items[i] == current)
      return items[i-1]
  }
}

Ariato.MenuButton.prototype.focusNextItem = function() {
  var item = this.nextItem()
  item && item.focus()
}

Ariato.MenuButton.prototype.focusPreviousItem = function() {
  var item = this.previousItem()
  item && item.focus()
}

Ariato.Menu = function(node) {
  var button = this.labelledBy()
  button && new Ariato.MenuButton(button)
}

Ariato.Menu.prototype.labelledBy = function() {
  return document.getElementById(this.node.getAttribute("aria-labelledby"))
}