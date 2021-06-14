package main

import (
  "C"
  "os"
  "log"
  "fmt"
  "time"
  "encoding/json"
  "path/filepath"
)

var ops *OpenplanetStore

// Init is called when .dll is loaded.
func init() {
  ops = &OpenplanetStore{}
  ops.LoadedAt = time.Now()
}

// PUBLIC API
// Since Go is a garbage collected language, and the garbage collector needs
// to know the location of every pointer to Go memory. Then Because of this
// Openlpanet Store API Should avoid exporting pointers.
// Initialize Openplanet Store
//export Initialize
func Initialize(path *C.char) *C.char {
  if (ops == nil || !ops.Valid())  {
    return C.CString("&OpenplanetStore not located")
  }

  nextDir, err := filepath.Abs(C.GoString(path))
  if err != nil {
    return C.CString(err.Error())
  }
  ops.WD = nextDir
  ops.Dir = filepath.Join(nextDir, ".opstore")
  if _, err := os.Stat(ops.Dir); os.IsNotExist(err) {
    if err := os.MkdirAll(ops.Dir, 0750); err != nil {
      return C.CString(err.Error())
    }
  }

  // cache dir
  ops.CacheDir = filepath.Join(ops.Dir, "cache")
  if err := os.MkdirAll(ops.CacheDir, 0750); err != nil {
    return C.CString(err.Error())
  }

  // textures dir
  ops.TexturesDir = filepath.Join(nextDir, "Textures", "OpenplanetStore")
  if err := os.MkdirAll(ops.TexturesDir, 0750); err != nil {
    return C.CString(err.Error())
  }
  return C.CString("")
}

// GetPluginImagePath return path to plugin image.
// If local image does not exist then it tries to download
// requested image to local cache. When both fail
// then empty string is returned.
//export GetPluginImagePath
func GetPluginImagePath(siteID int) *C.char {
  relImgPath := filepath.Join("OpenplanetStore", "plugins", fmt.Sprint(siteID), "plugin-img.jpg")
  fullImgPath := filepath.Join(ops.WD, "Textures", relImgPath)
  if _, err := os.Stat(fullImgPath); !os.IsNotExist(err) {
    return C.CString(relImgPath)
  }
  var imgUrl = fmt.Sprintf("https://openplanet.nl/imgu/%d.jpg", siteID)
  if err := ops.DownloadFileFromUrl(imgUrl, fullImgPath, ""); err != nil {
    return C.CString("")
  }
  return C.CString(relImgPath)
}

// GetAvailablePlugins returns json string of
//export GetAvailablePlugins
func GetAvailablePlugins() *C.char {
  ap, err := ops.GetAvailablePlugins()
  if err != nil {
    return C.CString("")
  }
  res, err := json.Marshal(ap)
  if err != nil {
    return C.CString("")
  }
  return C.CString(string(res))
}

// Dispose performs graceful shutdown of Openplanet store
//export Dispose
func Dispose() bool {
  ops = nil
  return true
}

// DeletePlugin
//export DeletePlugin
func DeletePlugin(pluginType int, pluginPath *C.char) *C.char {
  var res string
  if err := ops.DeletePlugin(pluginType, C.GoString(pluginPath)); err != nil {
    res = err.Error()
  }
  return C.CString(res)
}

//export DownloadPlugin
func DownloadPlugin(siteID int, pluginFile *C.char) *C.char {
  filename := C.GoString(pluginFile)
  var furl = fmt.Sprintf("https://openplanet.nl/files/get/%d", siteID)
  var loadPath string

  if filepath.Ext(filename) == ".op" {
    cdir := filepath.Join(ops.WD, "Plugins")
    if err := os.MkdirAll(cdir, 0750); err != nil {
      return C.CString(err.Error())
    }
    ppath := filepath.Join(cdir, filename)
    if err := ops.DownloadFileFromUrl(furl, ppath, fmt.Sprintf("https://openplanet.nl/files/%d", siteID)); err != nil {
      return C.CString(err.Error())
    }
    loadPath = ppath
  } else {
    cdir := filepath.Join(ops.CacheDir, fmt.Sprintf("plugin-%d", siteID))
    if err := os.MkdirAll(cdir, 0750); err != nil {
      return C.CString(err.Error())
    }
    ppath := filepath.Join(cdir, filename)
    if err := ops.DownloadFileFromUrl(furl, ppath, fmt.Sprintf("https://openplanet.nl/files/%d", siteID)); err != nil {
      return C.CString(err.Error())
    }
    return C.CString(ppath)
  }

  return C.CString(loadPath)
}

// Need a main function to make CGO compile package as C shared library!
func main() {
  homeDir, err := os.UserHomeDir()
  if err != nil {
    log.Fatal(err)
  }
  nextDir := filepath.Join(homeDir, "OpenplanetNext")
  fmt.Println("Initialize: ", C.GoString(Initialize(C.CString(nextDir))))
  ap, err := ops.GetAvailablePlugins()
  fmt.Println("Available plugins: ", ap, err)
}
