package main

import (
  "encoding/json"
  "time"
  "io"
  "io/ioutil"
  "os"
  "fmt"
  "errors"
  "net/http"
  "path/filepath"
)

// OpenplanetStore primary instance of Openplanet Store
type OpenplanetStore struct {
  LoadedAt time.Time
  Dir string
  CacheDir string
  TexturesDir string
  WD string //Op next user dir
}

func (o *OpenplanetStore) Valid() bool {
  return !o.LoadedAt.IsZero()
}


// DownloadFileFromUrl downloads file from url to destination path
// param dest is full file path where to write downloaded file bytes
func (o *OpenplanetStore) DownloadFileFromUrl(url, dest, referer string) error {
  client := http.Client{
    Timeout: time.Second * 60,
  }
  req, err := http.NewRequest(http.MethodGet, url, nil)
  if err != nil {
    return err
  }
  req.Header.Set("User-Agent", "Openplanet Store")
  if len(referer) > 0 {
    req.Header.Set("Referer", referer)
  }

  res, err := client.Do(req)
  defer res.Body.Close()
  if err != nil {
    return err
  }

  // cache dir
  if err := os.MkdirAll(filepath.Dir(dest), 0750); err != nil {
    return err
  }

	// Create a empty file
	file, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer file.Close()

	//Write the bytes to the fiel
	_, err = io.Copy(file, res.Body)
	if err != nil {
		return err
	}

	return nil
}

func (o *OpenplanetStore) GetAvailablePlugins() ([]PluginInfo, error) {
  urlbase := "https://openplanet.nl/api/files/"

  var currpage int = 0;
  var page PluginInfoPage
  var plugins []PluginInfo

  // Get first page
  url := fmt.Sprintf("%s/%d", urlbase, currpage)
  pageBytes, err := o.FetchJSON(url)
  if err != nil {
    return nil, err
  }
  if err := json.Unmarshal(pageBytes, &page); err != nil {
    return nil, err
  }
  for _, item :=  range page.Items {
    plugins = append(plugins, item)
  }

  // Get other pages
  for currpage = 1; currpage < page.Pages; currpage++ {
    url = fmt.Sprintf("%s/%d", urlbase, currpage)
    pageBytes, err = o.FetchJSON(url)
    if err != nil {
      return nil, err
    }
    if err := json.Unmarshal(pageBytes, &page); err != nil {
      return nil, err
    }
    for _, item :=  range page.Items {
      postTime := time.Unix(item.PostTime, 0)
      updateTime := time.Unix(item.UpdateTime, 0)
      item.CreatedAt = postTime.Format("2006-01-02")
      item.UpdatedAt = updateTime.Format("2006-01-02")
      plugins = append(plugins, item)
    }
  }

  return plugins, nil
}

// FetchJSON fetches json from given url and returns byte slice
func (o *OpenplanetStore) FetchJSON(url string) ([]byte, error) {
  client := http.Client{
    Timeout: time.Second * 10,
  }
  req, err := http.NewRequest(http.MethodGet, url, nil)
  if err != nil {
    return nil, err
  }
  req.Header.Set("User-Agent", "Openplanet Store")
  req.Header.Set("Content-Type", "application/json")
  req.Header.Set("Accept", "application/json")
  res, err := client.Do(req)
  defer res.Body.Close()
  if err != nil {
    return nil, err
  }
  body, err := ioutil.ReadAll(res.Body)
  if err != nil {
    return nil, err
  }
  return body, nil
}

// DeletePlugin deletes plugin files
func (o *OpenplanetStore) DeletePlugin(pluginType int, pluginPath string) error {
  stats, err := os.Stat(pluginPath)
  if os.IsNotExist(err) {
    return errors.New("plugin files not found")
  }
  switch (pluginType) {
    case 1: // Legaxy
      if filepath.Base(filepath.Dir(pluginPath)) != "Scripts" {
        // Remove legacy plugin directory
        return os.RemoveAll(filepath.Dir(pluginPath))
      } else {
        // Remove legacy plugin file
        if err := os.Remove(pluginPath); err != nil {
          return err
        }
        // Remove legacy signature file
        sigfile := pluginPath + ".sig"
        if _, err := os.Stat(sigfile); !os.IsNotExist(err) {
          return os.Remove(sigfile)
        }
      }
    break
    case 2: // Directory
      if stats.IsDir() {
        return os.RemoveAll(pluginPath)
      }
    break
    case 3: // Zip
      return os.Remove(pluginPath)
    break
    default:
      return errors.New("unknown plugin type")
    break;
  }
  return nil
}
