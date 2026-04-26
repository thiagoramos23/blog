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

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.Trix = Trix

const editorUploadPath = "/admin/uploads/images"

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

function attachmentFile(attachment) {
  if (typeof attachment.getFile === "function") {
    return attachment.getFile()
  }

  return attachment.file
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
