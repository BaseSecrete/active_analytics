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

Ariato.Accordion = function(node) {
  this.node = node
  node.ariaAccordion = this
  this.regions = []
}

Ariato.Accordion.addRegion = function(region) {
  var button = region.labelledBy()

  if (!button)
    return

  var accordion = region.node.parentElement.ariaAccordion || new Ariato.Accordion(region.node.parentElement)
  accordion.addRegion(region)
  return accordion
}

Ariato.Accordion.prototype.addRegion = function(region) {
  this.regions.push(region)
}

Ariato.Accordion.prototype.hideRegions = function() {
  for (var i = 0; i < this.regions.length; i++)
    this.regions[i].hide()
}

Ariato.Accordion.prototype.showRegion = function(region) {
  if (this.mutilpleAllowed())
    region.expanded() ? region.hide() : region.show()
  else {
    this.hideRegions()
    region.show()
  }
}

Ariato.Accordion.prototype.mutilpleAllowed = function() {
  return this.node.hasAttribute("data-allow-multiple")
}

Ariato.Carousel = function() {
  this.currentSlide() || this.showSlide(this.slides()[0])
  this.node.addEventListener("keydown", this.keydown.bind(this))

  var nextButton = this.node.querySelector("[data-carousel=next]")
  nextButton && nextButton.addEventListener("click", this.clicked.bind(this))

  var previousButton = this.node.querySelector("[data-carousel=previous]")
  previousButton.addEventListener("click", this.clicked.bind(this))
}

Ariato.Carousel.prototype.slides = function() {
  return this.node.querySelectorAll("[aria-roledescription=slide]")
}

Ariato.Carousel.prototype.currentSlide = function() {
  return this.node.querySelector("[aria-current=slide]")
}

Ariato.Carousel.prototype.showSlide = function(slide) {
  var slides = this.slides()

  for (var i = 0; i < slides.length; i++)
    if (slides[i] == slide)
      slides[i].setAttribute("aria-current", "slide")
    else
      slides[i].removeAttribute("aria-current")
}

Ariato.Carousel.prototype.nextSlide = function(slide) {
  var slides = this.slides()
  this.currentSlide()
  for (var i = 0; i < slides.length; i++) {
    if (slides[i] == slide)
      slides[i].setAttribute("aria-current", "slide")
    else
      slides[i].removeAttribute("aria-current")
  }
}

Ariato.Carousel.prototype.nextSlide = function(slide) {
  var current = this.currentSlide()
  return current && current.nextElementSibling
}

Ariato.Carousel.prototype.previousSlide = function(slide) {
  var current = this.currentSlide()
  return current && current.previousElementSibling
}

Ariato.Carousel.prototype.keydown = function(event) {
  switch(event.key) {
    case "ArrowLeft":
      this.showSlide(this.previousOrLastSlide())
      break
    case "ArrowRight":
      this.showSlide(this.nextOrFirstSlide())
      break
  }
}

Ariato.Carousel.prototype.clicked = function(event) {
  switch(event.currentTarget.getAttribute("data-carousel")) {
    case "next":
      this.showSlide(this.previousOrLastSlide())
      break
    case "previous":
      this.showSlide(this.nextOrFirstSlide())
      break
  }
}

Ariato.Carousel.prototype.previousOrLastSlide = function(event) {
  var slide = this.previousSlide()
  if (slide)
    return slide
  else {
    var slides = this.slides()
    return slides[slides.length-1]
  }
}

Ariato.Carousel.prototype.nextOrFirstSlide = function(event) {
  var slide = this.nextSlide()
  if (slide)
    return slide
  else {
    var slides = this.slides()
    return slides[0]
  }
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

Ariato.MenuBar = function() {
  this.node.addEventListener("keydown", this.keyDown.bind(this))
}

// Ariato defines role="menubar" but MenuBar in camel case is nicer
Ariato.Menubar = Ariato.MenuBar

Ariato.Menubar.prototype.keyDown = function(event) {
  switch (event.key) {
    case "ArrowDown":
      event.preventDefault()
      if (event.target.hasAttribute("aria-haspopup"))
        this.openItem(event.target)
      else
        this.focusNextItem(event.target)
      break
    case "ArrowUp":
      event.preventDefault()
      if (event.target.hasAttribute("aria-haspopup"))
        this.openItem(event.target)
      else
        this.focusPreviousItem(event.target)
      break
    case "ArrowRight":
      // Open parent next menu
      // Open child menu
      // Focus next item
      this.openNextMenu(event.target)
      break
      if (event.target.hasAttribute("aria-haspopup"))
        this.openItem(event.target)
      else
        this.openNextMenu(this.findParentMenu(event.target))
    case "ArrowLeft":
      this.openPreviousMenu(event.target)
      break
    case "Escape":
      this.closeAllExcept()
      break
  }
}

Ariato.Menubar.prototype.closeAllExcept = function(item) {
  var menus = this.node.querySelectorAll("[role=menu]")
  for (var i = 0; i < menus.length; i++)
    menus[i].style.display = menus[i].contains(item) ? "block" : null
}

Ariato.Menubar.prototype.openItem = function(item) {
  var menu = item.parentElement.querySelector("[role=menu]")
  item.setAttribute("aria-expanded", true)
  var subItem = menu.querySelector("[role=menuitem]")
  if (subItem) {
    this.closeAllExcept(subItem)
    subItem.focus()
  } else {
    this.closeAllExcept(item)
    item.focus()
  }
}

Ariato.Menubar.prototype.openNextMenu = function(item) {
  var menu = this.findNextMenu(item)
  menu && this.openItem(menu.parentElement.querySelector("[role=menuitem]"))
}

Ariato.Menubar.prototype.openPreviousMenu = function(item) {
  var menu = this.findPreviousMenu(item)
  menu && this.openItem(menu.parentElement.querySelector("[role=menuitem]"))
}

Ariato.Menubar.prototype.focusNextItem = function(item) {
  var nextItem = this.findNextItem(item)
  nextItem && nextItem.focus()
}

Ariato.Menubar.prototype.focusPreviousItem = function(item) {
  var previousItem = this.findPreviousItem(item)
  previousItem && previousItem.focus()
}

Ariato.Menubar.prototype.findParentMenu = function(item) {
  var parent = item.parentElement
  var menuRoles = ["menu", "menubar"]
  while (parent && !menuRoles.includes(parent.getAttribute("role")))
    parent = parent.parentElement
  return parent
}

Ariato.Menubar.prototype.findNextItem = function(item) {
  var menu = this.findParentMenu(item)
  var items = menu.querySelectorAll("[role=menuitem]")
  for (var i = 0; i < items.length; i++)
    if (items[i] == item)
      return items[i+1]
}

Ariato.Menubar.prototype.findPreviousItem = function(item) {
  var menu = this.findParentMenu(item)
  var items = menu.querySelectorAll("[role=menuitem]")
  for (var i = 0; i < items.length; i++)
    if (items[i] == item)
      return items[i-1]
}

Ariato.Menubar.prototype.findNextMenu = function(item) {
  var menus = this.rootMenus()
  for (var i = 0; i < menus.length; i++)
    if (menus[i].contains(item))
      return menus[i+1]

  var parent = item.parentElement
  for (var i = 0; i < menus.length; i++)
    if (parent.contains(menus[i]))
      return menus[i+1]
}

Ariato.Menubar.prototype.findPreviousMenu = function(item) {
  var menus = this.rootMenus()
  for (var i = 0; i < menus.length; i++)
    if (menus[i].contains(item))
      return menus[i-1]

  var parent = item.parentElement
  for (var i = 0; i < menus.length; i++)
    if (parent.contains(menus[i]))
      return menus[i-1]
}

Ariato.Menubar.prototype.rootMenus = function() {
  return this.node.querySelectorAll("li > [role=menu]")
}

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

/*
 * A region is a role="region" element which represents a panel of an accordion.
 * It is controlled by a button.
 */
Ariato.Region = function(node) {
  this.node = node
  var labelledBy = this.labelledBy()
  
  if (!labelledBy)
    return

  this.accordion = Ariato.Accordion.addRegion(this)
  labelledBy.addEventListener("click", this.buttonClicked.bind(this))
}

Ariato.Region.prototype.labelledBy = function() {
  return document.getElementById(this.node.getAttribute("aria-labelledby"))
}

Ariato.Region.prototype.buttonClicked = function(event) {
  this.accordion.showRegion(this)
}

Ariato.Region.prototype.show = function(event) {
  this.labelledBy().setAttribute("aria-expanded", true)
  this.node.removeAttribute("hidden")
}

Ariato.Region.prototype.hide = function(event) {
  this.labelledBy().setAttribute("aria-expanded", false)
  this.node.setAttribute("hidden", "")
}

Ariato.Region.prototype.expanded = function() {
  return !this.node.hasAttribute("hidden")
}

Ariato.Tablist = function(node) {
  this.node = node
  var tabs = this.tabs()
  for (var i = 0; i < tabs.length; i++) {
    tabs[i].addEventListener("click", this.click.bind(this))
    tabs[i].addEventListener("keydown", this.keydown.bind(this))
    tabs[i].addEventListener("keyup", this.keyup.bind(this))
  }
  tabs[0] && this.showTab(tabs[0])
}

Ariato.Tablist.prototype.click = function(event) {
  this.showTab(event.currentTarget)
}

Ariato.Tablist.prototype.tabs = function() {
  return this.node.querySelectorAll("[role=tab]")
}

Ariato.Tablist.prototype.activeTab = function() {
  return this.node.querySelector("[aria-selected=true]")
}

Ariato.Tablist.prototype.panels = function() {
  var tabs = this.tabs(), result = []
  for (var i = 0; i < tabs.length; i++)
    result.push(document.getElementById(tabs[i].getAttribute("aria-controls")))
  return result
}

Ariato.Tablist.prototype.showTab = function(tab) {
  this.hidePanels()
  tab.removeAttribute("tabindex")
  tab.setAttribute("aria-selected", "true")
  document.getElementById(tab.getAttribute("aria-controls")).style.display = null
  tab.focus()
}

Ariato.Tablist.prototype.hidePanels = function() {
  var tabs = this.tabs()
  for (var i = 0; i < tabs.length; i++) {
    tabs[i].setAttribute("tabindex", "-1");
    tabs[i].setAttribute("aria-selected", "false");
  }

  var panels = this.panels()
  for (var i = 0; i < panels.length; i++)
    panels[i].style.display = "none"
}

Ariato.Tablist.prototype.keydown = function(event) {
  switch (event.key) {
    case "End":
      var tabs = this.tabs()
      event.preventDefault()
      this.showTab(this.tabs()[tabs.length - 1])
      break
    case "Home":
      event.preventDefault()
      this.showTab(this.tabs()[0])
      break
    case "ArrowUp":
      event.preventDefault()
      this.showPrevious()
      break
    case "ArrowDown":
      event.preventDefault()
      this.showNext()
      break
  }
}

Ariato.Tablist.prototype.keyup = function(event) {
  if (event.key == "ArrowLeft")
    this.showPrevious()
  else if (event.key == "ArrowRight")
    this.showNext(event)
  // TODO delete
}

Ariato.Tablist.prototype.showNext = function() {
  var tabs = this.tabs()
  var index = Array.prototype.indexOf.call(tabs, this.activeTab())
  tabs[index + 1] && this.showTab(tabs[index + 1])
}

Ariato.Tablist.prototype.showPrevious = function() {
  var tabs = this.tabs()
  var index = Array.prototype.indexOf.call(tabs, this.activeTab())
  tabs[index - 1] && this.showTab(tabs[index - 1])
}

Ariato.ThemeSwitcher = function() {
  Ariato.ThemeSwitcher.initialize()
  this.node.addEventListener("click", this.change.bind(this))
}

Ariato.ThemeSwitcher.initialize = function() {
  if (!this.initialized) {
    console.log("initialize")
    this.initialized = true
    this.update()
  }
}

Ariato.ThemeSwitcher.update = function() {
  var name = localStorage.getItem("ariato-theme")
  document.documentElement.classList.forEach(function(theme) {
    theme.startsWith("theme-") && document.documentElement.classList.remove(theme)
  })
  document.documentElement.classList.add("theme-" + name)

  var buttons = document.querySelectorAll("[data-ariato='ThemeSwitcher']")
  for (var i = 0; i < buttons.length; i++)
    buttons[i].setAttribute("aria-pressed", buttons[i].getAttribute("data-theme") == name)
}

Ariato.ThemeSwitcher.prototype.change = function(event) {
  var name = event.currentTarget.getAttribute("data-theme")
  localStorage.setItem("ariato-theme", name)
  name && Ariato.ThemeSwitcher.update(name)
}