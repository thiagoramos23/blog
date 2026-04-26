// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import Trix from "trix"
import "../vendor/dark"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())
window.addEventListener("phx:page-loading-stop", () => {
  requestAnimationFrame(() => applyStoredImageAttachmentWidths())
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.Trix = Trix

const editorUploadPath = "/admin/uploads/images"
const minImageAttachmentWidth = 160

document.addEventListener("change", (event) => {
  const input = event.target

  if (!(input instanceof HTMLInputElement) || !input.matches("[data-trix-insert-file]")) {
    return
  }

  const [file] = input.files || []

  if (!file) {
    return
  }

  const editorInputId = input.dataset.trixInsertFile
  const editorElement = document.querySelector(`trix-editor[input="${editorInputId}"]`)

  if (editorElement?.editor) {
    editorElement.editor.insertFile(file)
  }

  input.value = ""
})

document.addEventListener("trix-file-accept", (event) => {
  if (!event.file.type.startsWith("image/")) {
    event.preventDefault()
  }
})

document.addEventListener("trix-attachment-add", (event) => {
  const file = attachmentFile(event.attachment)

  if (!file) {
    return
  }

  uploadTrixAttachment(event.attachment, file)
})

document.addEventListener("trix-attachment-before-toolbar", (event) => {
  const attachment = event.attachment || event.detail?.attachment
  const figure = event.target

  if (!(figure instanceof HTMLElement) || !isImageAttachment(attachment)) {
    return
  }

  installImageResizeControls(figure, attachment)
})

document.addEventListener("trix-attachment-edit", (event) => {
  requestAnimationFrame(() => applyStoredImageAttachmentWidths(event.target))
})

document.addEventListener("trix-initialize", (event) => {
  applyStoredImageAttachmentWidths(event.target)
  observeImageAttachmentWidths(event.target)
})

document.addEventListener("DOMContentLoaded", () => {
  applyStoredImageAttachmentWidths()
  observeImageAttachmentWidths()
})

function attachmentFile(attachment) {
  if (typeof attachment.getFile === "function") {
    return attachment.getFile()
  }

  return attachment.file
}

function isImageAttachment(attachment) {
  if (!attachment) {
    return false
  }

  const contentType =
    (typeof attachment.getContentType === "function" && attachment.getContentType()) ||
    (typeof attachment.getAttribute === "function" && attachment.getAttribute("contentType")) ||
    ""

  return contentType.startsWith("image/")
}

function installImageResizeControls(figure, attachment) {
  if (figure.querySelector("[data-trix-image-resize-controls]")) {
    return
  }

  const storedWidth = storedImageAttachmentWidth(figure)

  if (storedWidth) {
    syncRenderedImageSize(figure, storedWidth)
  }

  const controls = document.createElement("div")
  controls.className = "trix-image-resize-controls"
  controls.dataset.trixImageResizeControls = "true"
  controls.setAttribute("aria-hidden", "true")

  const readout = document.createElement("span")
  readout.className = "trix-image-resize-readout"
  readout.dataset.trixImageResizeReadout = "true"
  readout.textContent = `${Math.round(figure.getBoundingClientRect().width)}px`
  controls.appendChild(readout)

  ;["left", "right", "top-left", "top-right", "bottom-left", "bottom-right"].forEach((direction) => {
    const handle = document.createElement("span")
    handle.className = `trix-image-resize-handle trix-image-resize-handle--${direction}`
    handle.dataset.trixImageResizeHandle = direction
    handle.addEventListener("pointerdown", (event) => {
      startImageResize(event, figure, attachment)
    })
    controls.appendChild(handle)
  })

  figure.appendChild(controls)
}

function startImageResize(event, figure, attachment) {
  event.preventDefault()
  event.stopPropagation()

  const handle = event.currentTarget
  const direction = handle.dataset.trixImageResizeHandle || "right"
  const startsFromLeft = direction.includes("left")
  const startX = event.clientX
  const startWidth = figure.getBoundingClientRect().width
  const maxWidth = maxImageAttachmentWidth(figure)
  const readout = figure.querySelector("[data-trix-image-resize-readout]")
  let nextWidth = Math.round(startWidth)

  if (typeof handle.setPointerCapture === "function") {
    handle.setPointerCapture(event.pointerId)
  }

  figure.classList.add("trix-image-resizing")

  const resize = (moveEvent) => {
    const dragDistance = startsFromLeft ? startX - moveEvent.clientX : moveEvent.clientX - startX
    nextWidth = clamp(Math.round(startWidth + dragDistance), minImageAttachmentWidth, maxWidth)

    syncRenderedImageSize(figure, nextWidth)

    if (readout) {
      readout.textContent = `${nextWidth}px`
    }
  }

  const stopResize = () => {
    persistImageAttachmentSize(figure, attachment, nextWidth)

    figure.classList.remove("trix-image-resizing")
    handle.removeEventListener("pointermove", resize)
    handle.removeEventListener("pointerup", stopResize)
    handle.removeEventListener("pointercancel", stopResize)
  }

  handle.addEventListener("pointermove", resize)
  handle.addEventListener("pointerup", stopResize)
  handle.addEventListener("pointercancel", stopResize)
}

function persistImageAttachmentSize(figure, attachment, width) {
  const editorElement = figure.closest("trix-editor")
  const editor = editorElement?.editor
  const trixAttachment = attachment.attachment || attachment
  const height = proportionalImageAttachmentHeight(figure, attachment, width)

  if (editor && typeof editor.updateAttributesForAttachment === "function") {
    editor.updateAttributesForAttachment({width, height}, trixAttachment)

    requestAnimationFrame(() => applyStoredImageAttachmentWidths(editorElement))
    return
  }

  attachment.setAttributes({
    width,
    height
  })
}

function syncRenderedImageSize(figure, width) {
  const image = figure?.querySelector("img")
  const height = storedImageAttachmentHeight(figure) || proportionalImageAttachmentHeight(figure, null, width)

  if (image) {
    image.setAttribute("width", String(width))

    if (height) {
      image.setAttribute("height", String(height))
    }
  }

  if (figure) {
    figure.style.maxWidth = `${width}px`
  }

  syncRenderedAttachmentData(figure, width, height)
}

function syncRenderedAttachmentData(figure, width, height) {
  if (!figure) {
    return
  }

  const serializedAttachment = figure.getAttribute("data-trix-attachment")

  if (!serializedAttachment) {
    return
  }

  try {
    const attachmentData = JSON.parse(serializedAttachment)

    attachmentData.width = width

    if (height) {
      attachmentData.height = height
    }

    const nextSerializedAttachment = JSON.stringify(attachmentData)

    if (nextSerializedAttachment !== serializedAttachment) {
      figure.setAttribute("data-trix-attachment", nextSerializedAttachment)
    }
  } catch (_error) {
    return
  }
}

function applyStoredImageAttachmentWidths(root = document) {
  imageAttachmentFigures(root).forEach((figure) => {
    const width = storedImageAttachmentWidth(figure)

    if (!width) {
      return
    }

    syncRenderedImageSize(figure, width)
  })
}

function imageAttachmentFigures(root) {
  const figures = []

  if (root instanceof HTMLElement && root.matches(".trix-content .attachment[data-trix-attachment]")) {
    figures.push(root)
  }

  root.querySelectorAll?.(".trix-content .attachment[data-trix-attachment]").forEach((figure) => {
    figures.push(figure)
  })

  return figures
}

function observeImageAttachmentWidths(root = document) {
  const containers = root instanceof HTMLElement && root.matches(".trix-content")
    ? [root]
    : Array.from(root.querySelectorAll?.(".trix-content") || [])

  containers.forEach((container) => {
    if (container.dataset.trixImageWidthObserver) {
      return
    }

    container.dataset.trixImageWidthObserver = "true"

    const observer = new MutationObserver(() => {
      requestAnimationFrame(() => applyStoredImageAttachmentWidths(container))
    })

    observer.observe(container, {
      attributes: true,
      attributeFilter: ["data-trix-attachment"],
      childList: true,
      subtree: true
    })
  })
}

function proportionalImageAttachmentHeight(figure, attachment, width) {
  const image = figure?.querySelector("img")
  const naturalWidth = image?.naturalWidth || Number(image?.getAttribute("width")) || Number(attachment?.getAttribute?.("width"))
  const naturalHeight = image?.naturalHeight || Number(image?.getAttribute("height")) || Number(attachment?.getAttribute?.("height"))

  if (!naturalWidth || !naturalHeight) {
    return null
  }

  return Math.max(1, Math.round(width * naturalHeight / naturalWidth))
}

function storedImageAttachmentHeight(figure) {
  try {
    const attachmentData = JSON.parse(figure.getAttribute("data-trix-attachment") || "{}")
    const height = Number(attachmentData.height)

    return Number.isFinite(height) && height > 0 ? height : null
  } catch (_error) {
    return null
  }
}

function storedImageAttachmentWidth(figure) {
  try {
    const attachmentData = JSON.parse(figure.getAttribute("data-trix-attachment") || "{}")
    const width = Number(attachmentData.width)

    return Number.isFinite(width) && width > 0 ? width : null
  } catch (_error) {
    return null
  }
}

function maxImageAttachmentWidth(figure) {
  const editor = figure.closest("trix-editor")
  const container = editor || figure.parentElement
  const styles = container ? window.getComputedStyle(container) : null
  const horizontalPadding = styles ? parseFloat(styles.paddingLeft) + parseFloat(styles.paddingRight) : 0
  const availableWidth = container ? container.clientWidth - horizontalPadding : window.innerWidth

  return Math.max(minImageAttachmentWidth, Math.round(availableWidth))
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}

function uploadTrixAttachment(attachment, file) {
  const csrf = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
  const formData = new FormData()
  const xhr = new XMLHttpRequest()

  formData.append("file", file)

  xhr.open("POST", editorUploadPath, true)
  xhr.responseType = "json"

  if (csrf) {
    xhr.setRequestHeader("x-csrf-token", csrf)
  }

  xhr.setRequestHeader("accept", "application/json")

  xhr.upload.addEventListener("progress", (progressEvent) => {
    if (progressEvent.lengthComputable) {
      const progress = progressEvent.loaded / progressEvent.total * 100
      attachment.setUploadProgress(progress)
    }
  })

  xhr.addEventListener("load", () => {
    if (xhr.status >= 200 && xhr.status < 300) {
      const payload = xhr.response || {}

      if (payload.url) {
        attachment.setAttributes({
          url: payload.url,
          href: payload.url
        })

        return
      }
    }

    attachment.remove()
    window.alert("Image upload failed. Check your admin credentials and R2 configuration.")
  })

  xhr.addEventListener("error", () => {
    attachment.remove()
    window.alert("Image upload failed. Check your network connection and try again.")
  })

  xhr.send(formData)
}
