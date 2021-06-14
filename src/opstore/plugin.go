package main

// import (
//   "time"
// )

type PluginInfo struct{
  ID string `json:"id"`
  Name string `json:"name"`
  Author string `json:"author"`
  Version string `json:"version"`
  ShortDescription string `json:"shortdescription"`
  Filename string `json:"filename"`
  Filesize int `json:"filesize"`
  PostTime int64 `json:"posttime"`
  UpdateTime int64 `json:"updatetime"`
  Downloads int `json:"downloads"`
  Tags []PluginTag `json:"tags"`

  CreatedAt string `json:"createdAt"`
  UpdatedAt string `json:"updatedAt"`
}

type PluginTag struct {
  Type string `json:"type"`
  Name string `json:"name"`
  Class string `json:"class"`
  Tooltip string `json:"tooltip"`
}

type PluginInfoPage struct{
  Total   int           `json:"total"`
  Page    int           `json:"page"`
  Pages   int           `json:"pages"`
  Items   []PluginInfo  `json:"items"`
}
